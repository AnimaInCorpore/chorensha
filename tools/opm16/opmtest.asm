; opmtest: standalone test program for the opm16 kernel (opm16_*.asm), the
; YM2151 emulation of Cho Ren Sha 68k's music on the Falcon DSP.
;
; Plays a stream of register writes from the 68030 ($00rrdd = write,
; $80nnnn = wait n blocks) through the SSI at 25.175 MHz / 256 / divider.
; Work is done in blocks of BLOCK frames: events, LFO, envelopes, gains and
; pitch once per block, the operators per frame. The operators look up a
; copy of the Y ROM sine in Y RAM $00-$ff with a 48-bit phase (the low 8
; integer bits are the index; y1 = $ff is both the mask and the phase
; multiplier, so x1 holds increment / 510).
;
; The C++ model (model2.cpp) computes the same numbers. The first 128
; blocks are captured at X:CAPTURE, and a checksum of the first
; CHECK_BLOCKS blocks is kept at x:csum for comparing the two.

	opt	mu,nohdr

	include	'ioequ.inc'
	include	'opm16_tab.asm'		; BLOCK and the rate constants
	include	'opm16_cfg.asm'		; CHECK_BLOCKS

SEG		equ	2*BLOCK		; SSI words per block
CARRIER_SCALE	equ	$1fe800		; 8168/32768, as ymfm

; X internal
RING_A		equ	$01		; X:$00 takes the pipelined first store
RING_B		equ	BLOCK+2		; X:BLOCK+1 likewise
HX0		equ	$c0		; newest feedback history of the channel in work

; Y internal: the sine. Y external, above the program:
MIX_C		equ	$3000
MIX_L		equ	MIX_C+BLOCK
MIX_R		equ	MIX_C+2*BLOCK
FBB		equ	$30c0		; older history, onward gain, history gain (modulo 3)

; X external
REGS		equ	$0200
VARS		equ	$0300
CH_AUD		equ	$0340		; channel audible this block
CH_PLAY		equ	$0348		; channel routine when audible
CH_OPG		equ	$0350		; 2^(-t/64) of operator 1
FBKCH		equ	$0358		; feedback factor
AMSCH		equ	$0360		; AMS
AMOFF		equ	$0368		; AM offset this block
CH_DIRTY	equ	$0370		; pitch to recompute
ZERO		equ	$0378
SINK		equ	$0379
OP_KEY		equ	$0380		; by slot
TAB_SHIFT	equ	$03a0		; 2^(15 + block)
CH_PMS		equ	$03a8		; PMS
CH_NOTE		equ	$03b0		; (KC note - note >> 2) << 6
CH_BLOCK	equ	$03b8		; KC block
CH_KCX		equ	$03c0		; TAB_DT1 + (KC & $7c): DT1 row of the keycode
SSI_RING	equ	$0400		; 4 segments of SEG words
FIFO		equ	$0800		; FIFO_SIZE words
FIFO_SIZE	equ	512
TAB_PSTEP	equ	$0a00		; doubled after the upload
TAB_GAIN	equ	$0d00
TAB_ENV_ADD	equ	$1100
TAB_ENV_MUL	equ	$1140
TAB_DT1		equ	$1180
TAB_NOISE	equ	$1200
TAB_FBK		equ	$1220
OPR		equ	$1240		; channel records
PITCH		equ	$12c0		; pitch records
ENV		equ	$1400		; envelope records
PHASES		equ	$1600		; L memory, by operator
SLOTTAB		equ	$1700		; by slot: channel, n, q, envelope record
CAPTURE		equ	$2000		; first 128 blocks

	include	'opm16_vars.asm'

; -----------------------------------------------------------------------------
	org	p:$0
	jmp	start

	org	p:$10			; SSI transmit: fast interrupt
	movep	x:(r6)+,x:m_tx
	nop

	org	p:$12			; SSI transmit with exception (underrun)
	jsr	ssi_tx_exception

; -----------------------------------------------------------------------------
; Internal P: the per-frame code and the envelopes.
;
; Operator stages: r4 -> increment and gain of the operator (advanced by
; 2), r7 -> its phase (advanced by 1), y1 = $ff, n1 = mix base. r0 is the
; sine index.
; -----------------------------------------------------------------------------
	org	p:$40

	include	'opm16_hot.asm'
	include	'opm16_warm.asm'

; Mix the block into the SSI segment, clearing the mixes for the next.
emit:
	move	x:seg,r0
	move	#MIX_C,r4
	move	#MIX_L,r5
	move	#MIX_R,r7
	move	#0,y1
	do	#BLOCK,_end
	move	y:(r4),a
	tfr	a,b	y:(r5),x0
	add	x0,a	y:(r7),x0
	add	x0,b	a,x:(r0)+	y1,y:(r4)+
	move	b,x:(r0)+	y1,y:(r5)+
	move	y1,y:(r7)+
_end
	rts

int_end:

; -----------------------------------------------------------------------------
	org	p:$200
; -----------------------------------------------------------------------------

start:
	movep	#0,x:m_bcr
	movep	#1,x:m_pbc
	movep	#$1f8,x:m_pcc
	ori	#$04,omr		; data ROMs: sine at Y:$100
	movep	#$3000,x:m_ipr		; SSI at interrupt level 2
	andi	#$fc,mr
	move	#>-1,m0
	move	#>-1,m1
	move	#>-1,m2
	move	#>-1,m3
	move	#>-1,m4
	move	#>-1,m5
	move	#>-1,m7

	move	#$100,r0		; the sine into Y RAM
	move	#0,r1
	do	#256,_sine
	move	y:(r0)+,x0
	move	x0,y:(r1)+
_sine
	clr	a
	move	#REGS,r0
	rep	#$800
	move	a,x:(r0)+		; X $0200-$09ff, including the SSI ring
	move	#OPR,r0
	move	#>PHASES-OPR,x0
	rep	x0
	move	a,x:(r0)+
	move	#PHASES,r0
	rep	#32
	move	a,l:(r0)+
	move	#CAPTURE,r0
	move	#>$2000,x0
	rep	x0
	move	a,x:(r0)+
	move	#MIX_C,r0
	rep	#$100
	move	a,y:(r0)+
	move	#TAB_SHIFT,r0
	move	#>$008000,a
	do	#8,_shift
	move	a1,x:(r0)+
	lsl	a
_shift
	move	#>1,x0
	move	x0,x:lfsr
	move	#>FIFO,x0
	move	x0,x:fifo_rd
	move	x0,x:fifo_wr
	move	#>SSI_RING,x0
	move	x0,x:seg
	move	#>CAPTURE,x0
	move	x0,x:capture_ptr

	; the 68030 sends the tables (count, then X:TAB_PSTEP onwards)
	move	#TAB_PSTEP,r0
	jclr	#m_hrdf,x:m_hsr,*
	movep	x:m_hrx,x0
	do	x0,_tables
	jclr	#m_hrdf,x:m_hsr,*
	movep	x:m_hrx,x:(r0)+
_tables
	move	#TAB_PSTEP,r0		; doubled for the shift by multiplication
	do	#768,_double
	move	x:(r0),a
	asl	a
	move	a1,x:(r0)+
_double
	jsr	init_records

	; prefill the FIFO before playing, so the stream never runs dry
_prefill
	jsr	host_service
	move	x:fifo_wr,a
	move	x:fifo_rd,x0
	sub	x0,a
	move	#>FIFO_SIZE-1,x0
	and	x0,a
	move	a1,a
	move	#>400,x0
	cmp	x0,a
	jlt	_prefill

	; SSI: 16-bit words, two per frame, network mode
	movep	#0,x:m_crb
	movep	#$4100,x:m_cra
	move	#SSI_RING,r6
	move	#>4*SEG-1,m6
	nop
	move	x:(r6)+,a
	movep	a1,x:m_tx
	movep	#$5a00,x:m_crb

main_loop:
	jsr	host_service
	move	r6,a			; the SSI's position in the block's segment
	move	x:seg,x0
	sub	x0,a
	jlt	_free
	move	#>SEG,x0
	cmp	x0,a
	jlt	main_loop		; still playing it
_free
	jsr	render_block
	move	x:seg,a
	move	#>SEG,x0
	add	x0,a
	move	#>SSI_RING+4*SEG,x0
	cmp	x0,a
	jlt	_wrap
	move	#>SSI_RING,a
_wrap
	move	a1,x:seg
	jmp	main_loop

ssi_tx_exception:
	movep	x:m_sr,x:ssi_errors
	movep	x:(r6)+,x:m_tx
	rti

; Copy waiting host words into the FIFO, keeping it below 500 words.
host_service:
	move	#FIFO_SIZE-1,m1
	move	x:fifo_wr,r1
	nop
_loop
	jclr	#m_hrdf,x:m_hsr,_done
	move	r1,a
	move	x:fifo_rd,x0
	sub	x0,a
	move	#>FIFO_SIZE-1,x0
	and	x0,a
	move	a1,a			; drop the sign the subtraction left in a2
	move	#>500,x0
	cmp	x0,a
	jge	_done
	movep	x:m_hrx,x:(r1)+
	jmp	_loop
_done
	move	r1,x:fifo_wr
	move	#>-1,m1
	rts

; -----------------------------------------------------------------------------
render_block:
	jsr	events
	jsr	lfo_block
	jsr	controls
	jsr	noise_setup
	jsr	render_channels
	jsr	emit
	jsr	check
	move	x:blocks,a
	move	#>1,x0
	add	x0,a
	move	a1,x:blocks
	rts

; Checksum of the first CHECK_BLOCKS blocks and capture of the first 128.
check:
	move	x:blocks,a
	move	#>CHECK_BLOCKS,x0
	cmp	x0,a
	jge	_cap
	move	x:seg,r4
	move	x:csum,a2
	move	x:csum+1,a1
	move	x:csum+2,a0
	move	x:csum+3,b2
	move	x:csum+4,b1
	move	x:csum+5,b0
	move	x:csum_prev,y0
	do	#SEG,_sum
	move	x:(r4)+,x0
	add	x0,a
	mac	x0,y0,b
	move	x0,y0
_sum
	move	a2,x:csum
	move	a1,x:csum+1
	move	a0,x:csum+2
	move	b2,x:csum+3
	move	b1,x:csum+4
	move	b0,x:csum+5
	move	y0,x:csum_prev
_cap
	move	x:capture_ptr,a
	move	#>CAPTURE+$2000,x0
	cmp	x0,a
	jge	_out
	move	a1,r5
	move	x:seg,r4
	nop
	do	#SEG,_copy
	move	x:(r4)+,x0
	move	x0,x:(r5)+
_copy
	move	r5,x:capture_ptr
_out
	rts

	include	'opm16_block.asm'

	end
