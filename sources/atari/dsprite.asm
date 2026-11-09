; DSP program of the Falcon port of Cho Ren Sha 68k: the sprite masks (which
; background pixels the 68030 restores) and the sound (the YM2151 music of the
; opm16 kernel, opm16_*.asm, plus the sound effects from DMA playback).
;
; Some figures: 1885 sprite patterns with 1372 different masks; up to about
; 4000 RLE values; the music takes about half the DSP at 24585 Hz.
;
; Host protocol. A packet is a header word, then its words:
;   $80nnnn  n music stream words ($00rrdd register write, $80nnnn wait),
;            then the number of blocks the packet's waits add up to; sent
;            while HF3 is set (the DSP waits or draws the old masks, its
;            FIFO has room for MUSIC_PACKET words and holds less than
;            MUSIC_LEAD blocks); the 68030 polls TXDE for each word
;   n        n sprites, 3 words each (flip + mask index, X, Y), sent while
;            HF2 is set; after the header (the 68030 waits for TRDY) the
;            words come without polling
; The 68030 draws the new sprites before it gets the restore runs, so the runs
; must not touch a pixel a new sprite covers: the masks are per pixel (pairs
; of pixels would restore half-covered pairs over finished sprites).
; After a sprite packet the DSP works out the restore runs, then sends their
; count (the 68030 polls RXDF) and waits for HF1 from the 68030, taking music
; packets meanwhile, before it sends the runs, which the 68030 reads without
; polling. The DSP renders music while it waits for a packet or for HF1, and
; between the sprites it draws and the lines it scans, never inside a
; transfer: the SSI ring holds 16 ms of sound. While the 68030 waits for the
; runs, music is rendered only when the ring runs low (POLL_URGENT); the
; waits catch up, and the ring is topped up before the runs go out.

	opt mu,nohdr

	include	'ioequ.inc'
	include	'opm16_tab.asm' ; BLOCK = 48 and the rate constants (24585 Hz).

NUMBER_OF_PACKED_SPRITES1 equ 923 ; Masks in X memory; the others go to Y.
NUMBER_OF_PACKED_SPRITES2 equ 462
RLE_RESTORE_WIDTH equ 16+256+16
RLE_LONG_EVEN_BIAS equ RLE_RESTORE_WIDTH+4 ; Odd-run block plus its preceding BRA.W.
RLE_LINE_BYTES equ 512*2 ; One screen line, including the part right of the restore area.
RLE_MAX_OFFSET equ $7fff ; The 68030 adds offsets with ADDA.W.
RLE_GAP_SPLIT equ RLE_MAX_OFFSET+1-RLE_LINE_BYTES ; A gap this long is sent before it can overflow.
RLE_CHUNK_SHIFT equ $000020 ; MPY by this: a1 = the top 6 bits, a0 = the rest shifted up.
MAX_SPRITES equ 512

; Sound: the SSI sends the ring to the DAC and receives the sound effects
; (DMA playback, 16-bit stereo) at 25.175 MHz / 256 / 4 = 24585 Hz. The
; transmit interrupt sends a word of the ring and stores the received word in
; its place, so the ring holds effect samples behind the SSI. Each block of
; music is rendered once the SSI has left its segment of the ring and added
; to the effects there; the sum plays one ring later. r6 and m6 belong to it.
SEG equ 2*BLOCK ; Ring words per block.
NSEG equ 8
SSI_RING_SIZE equ NSEG*SEG
MUSIC_PACKET equ 64
MUSIC_LEAD equ 40 ; Blocks of music the DSP asks to hold (78 ms): the 68030 sends in
; the VBL, before each sprite packet and before the restore runs, which can be a
; few frames apart when the game slows down. Not more, as a new song waits behind them.
CARRIER_SCALE equ $0ff400 ; Half of 8168/32768: room for the effects.
FIFO_SIZE equ 256

; Memory. X:a and X:a+$4000 are the same word, as are Y:a and Y:a+$4000;
; P:$0000-$3FFF is Y and P:$4000-$7FFF is X. Internal RAM: X:$00-$FF (below),
; Y:$00-$FF (the music's copy of the sine ROM). External code is at P:$0200
; up to P:$0BFF (Y:$4200-$4BFF).

; X internal
RING_A equ $41 ; X:$40 takes the pipelined first store.
RING_B equ RING_A+BLOCK+1 ; X:RING_B-1 likewise.
HX0 equ $a2 ; Feedback history of the channel in work.
rle_states equ $a4 ; Modulo 2 with r3.
SAVE equ $a8 ; music_poll keeps the sprite code's registers here.

; Y internal: the sine. Y external, Y:$4000-$41FF:
MIX_C equ $4000
MIX_L equ MIX_C+BLOCK
MIX_R equ MIX_C+2*BLOCK
FBB equ $4090 ; Older history, onward gain, history gain (modulo 3).
sprite_mask equ $40a0 ; 16 words.
sprite_convert_shifts equ $40b0 ; 2 words.
rle_length equ $40b2
scrolling_offset equ $40b3
ssi_status equ $40b4
stack equ $4100 ; The stack grows down from here (y:-(r7)).
rle_chunk_boundaries equ $4100 ; X and Y at the same addresses.
rle_chunk_tables equ rle_chunk_boundaries+32
PHASES equ $4140 ; L, the music's 32 operator phases.

; X external
bit_reverse_table equ $4000
REGS equ $4160
VARS equ $4260
CH_AUD equ $42a0
CH_PLAY equ $42a8
CH_OPG equ $42b0
FBKCH equ $42b8
AMSCH equ $42c0
AMOFF equ $42c8
CH_DIRTY equ $42d0
ZERO equ $42d8
SINK equ $42d9
TAB_SHIFT equ $42e0
CH_PMS equ $42e8
CH_NOTE equ $42f0
CH_BLOCK equ $42f8
FIFO equ $4300 ; FIFO_SIZE words, modulo.
CH_KCX equ $4400
OP_KEY equ $4420
SLOTTAB equ $4440
TAB_PSTEP equ $44c0 ; The tables, uploaded by the 68030 in this order.
TAB_GAIN equ TAB_PSTEP+768
TAB_ENV_ADD equ TAB_GAIN+1024
TAB_ENV_MUL equ TAB_ENV_ADD+64
TAB_DT1 equ TAB_ENV_MUL+64
TAB_NOISE equ TAB_DT1+128
TAB_FBK equ TAB_NOISE+32
OPR equ TAB_FBK+8
PITCH equ OPR+104
ENV equ PITCH+256
sprite_infos1 equ ENV+512 ; 2 words a sprite: flip + mask index, Y << 12 | X.
sprite_infos2 equ sprite_infos1+2*MAX_SPRITES
packed_sprite_masks1 equ sprite_infos2+2*MAX_SPRITES ; Up to X:$7FFF.

; Y external, above the code
ssi_ring equ $4c00 ; Modulo SSI_RING_SIZE with r6.
rle_buffer equ ssi_ring+SSI_RING_SIZE ; Needs to be in front of the screen buffer!
screen_buffer equ rle_buffer+4000
packed_sprite_masks2 equ screen_buffer+(16+256+16)*(16+256+16)/8/3 ; Up to Y:$7FFF.

	include	'opm16_vars.asm'

; X internal, the sound's state between calls (short addresses).
poll_save equ $36 ; music_poll's a2, a1, a0, x0.
ring_seg equ $3e ; The ring segment of the next block.
render_state equ $3f ; 0 idle, 1-8 the channel to render next, 9 the mix.
music_welcome equ $3d ; Bit 0: in a wait that takes music packets.
poll_need equ $3c ; music_poll renders once the SSI is this far past the next segment.

POLL_URGENT equ 5*SEG ; While the 68030 waits for the runs: 3 segments left (6 ms).
POLL_TRANSFER equ 4*SEG ; Before the transfer, which renders nothing: more than 4 left.

push	macro	register
        move    register,y:-(r7)
        endm

pop		macro	register
        move    y:(r7)+,register
        endm

peek	macro	register
        move    y:(r7),register
        endm

; -----------------------------------------------------------------------------
	org	p:$0
; -----------------------------------------------------------------------------

	jmp		main

	org	p:$10 ; SSI transmit: fast interrupt.
	movep	y:(r6),x:m_tx
	movep	x:m_rx,y:(r6)+

	org	p:$12 ; SSI transmit with exception (underrun).
	jsr		ssi_tx_exception

; -----------------------------------------------------------------------------
	org	p:$40
; -----------------------------------------------------------------------------

; Wait for a packet: music for the FIFO, or the sprites of the next picture.

receive_sprite_infos:
	bset	#m_hf2,x:m_hcr ; Ready for a packet.
	bset	#0,x:<music_welcome
	jsr		music_flags

_wait:
	jsr		music_step
	jclr	#m_hrdf,x:m_hsr,_wait

	movep	x:m_hrx,a
	jclr	#23,a1,_sprites
	jsr		>receive_music_packet
	jmp		_wait

_sprites:
	bclr	#m_hf2,x:m_hcr
	bclr	#0,x:<music_welcome
	bclr	#m_hf3,x:m_hcr

	move	x:<work_sprite_infos,r0
	move	#>$ffff,x1
	move	#>$fff,y1
	move	a1,x0

	tst		a
	jeq		_none

	do		x0,_loop

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,a
	and		x1,a
	move	a1,x:(r0)+ ; Flip info + mask index.

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,b ; X position.

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,a ; Y position.

	and		y1,a
	rep		#12
	lsl		a
	and		y1,b
	add		b,a
	move	a1,x:(r0)+ ; Y << 12 | X.
_loop:

_none:
	move	x0,x:<number_of_work_sprite_infos

	rts

; -----------------------------------------------------------------------------

draw_inverted_masks:
	move	x:<work_sprite_infos,r0
	move	x:<number_of_work_sprite_infos,a

	tst		a a,x0
	jne		_start

	rts

_start:
	move	x:(r0)+,a

	do		x0,_loop

	jsr		music_poll
	jsr		prepare_mask
	jsr		sprite_position

	move	y:scrolling_offset,y1
	add		y1,b #>16+256,y1
	jmi		<_skip_drawing

	cmp		y1,b b1,y0
	jcc		<_skip_drawing

	move	x1,b0
	move	#>(16+256+16)/8/3/2,y1
	mac		y0,y1,b a1,n1
	move	#sprite_mask,r4
	move	#screen_buffer,r5
	move	b0,n5
	move	#<shift_values,r1
	move	n1,n2
	move	#<shift_masks,r2
	move	(r5)+n5
	move	(r1)+n1
	move	(r2)+n2
	move	#(16+256+16)/8/3-1,n5

	; Draw inverted mask.

	move	x:(r1),x0 y:(r4)+,y0

	do		#16,_loop2

	mpy		-x0,y0,a x:(r2),x0 y:(r5)+,y1
	and		x0,a a0,b
	not		a
	and		y1,a y:(r5)-,y1
	not		b a1,y:(r5)+
	and		y1,b x:(r1),x0 y:(r4)+,y0
	move	b1,y:(r5)+n5
_loop2:

_skip_drawing:
	move	x:(r0)+,a
_loop:

	rts

; -----------------------------------------------------------------------------

; Scan the mask of the pixels to restore, from the left, and write each run as
; the byte offset from the end of the previous run, then its length in bytes.
; The scan clears the mask.
;
; x0 holds the run state, all zeros outside a run and all ones inside, so a
; word without a run boundary XORs to zero: the common case, four cycles.
; In other words each set bit of t = w ^ (w >> 1) (w XORed with the state)
; is a boundary. t is taken apart in four 6-bit chunks, and two tables give
; the first boundary of a chunk (X) and the chunk without it (Y).

create_rle_data:
	move	#screen_buffer+(16+256+16)/8/3*16,r4
	move	#rle_buffer,r5
	move	#rle_chunk_tables,r0
	move	#<rle_states,r3
	move	#1,m3 ; r3 toggles between the two run states.

	clr		b ; Bytes since the last boundary.
	move	b1,x0 ; Outside a run.
	move	#>24*2,y0
	move	#>RLE_CHUNK_SHIFT,y1

	do		#240/16,_blocks

	jsr		music_poll

	do		#16,_loop

	move	y:(r4),a

	do		#(16+256+16)/8/3,_loop2

	eor		x0,a a0,y:(r4)+
	jne		<_boundaries
_next_word:
	add		y0,b y:(r4),a
_loop2:

	jclr	#0,x0,_next_line

	clr		b b1,y:(r5)+ ; The run ends with the line.
	move	(r3)+
	move	b1,x0

_next_line:
	move	#>(512-(16+256+16))*2,x1
	add		x1,b #>RLE_GAP_SPLIT,a

	; No run is open at the end of a line. Send a long gap now as an
	; offset with an empty run, so that every offset fits in 16 bits:
	; one more line, including its runs, adds at most RLE_LINE_BYTES.

	cmp		a,b
	jlt		<_next_line2

	clr		b b1,y:(r5)+ ; Offset.
	move	b1,y:(r5)+ ; Empty run.

_next_line2:
	nop
_loop:
	nop
_blocks:

	clr		b
	move	b1,y:(r5)+ ; Offset.
	move	#>12,b
	move	b1,y:(r5)+ ; Jump displacement past the 68030 RLE loop.

	move	#rle_buffer,x0
	move	r5,a
	sub		x0,a
	move	a1,y:rle_length

	move	#>-1,m3

	rts

; a1 = the word XORed with the state, not zero. b counts from the chunk start
; here: a boundary at pixel p writes b+2p and sets b to -2p. Each boundary
; flips the state in r3.

_boundaries:
	lsr		a a1,x1
	eor		x1,a
	move	a1,x1
	mpy		x1,y1,a ; a1 = first chunk (signed), a0 = the rest.
	move	#>6*2,x0

	do		#4,_loop3

	move	a1,n0
	move	a0,x1
	jset	#23,x:(r0+n0),_next_chunk ; No boundary in this chunk.

_next_boundary:
	move	x:(r0+n0),a
	add		a,b y:(r0+n0),n0
	tfr		a,b b1,y:(r5)+
	neg		b (r3)+
	jclr	#23,x:(r0+n0),_next_boundary

_next_chunk:
	mpy		x1,y1,a
	add		x0,b
_loop3:

	sub		y0,b x:(r3),x0 ; _next_word adds the word again.
	jmp		<_next_word

; -----------------------------------------------------------------------------

draw_masks:
	move	x:<work_sprite_infos,r0
	move	x:<number_of_work_sprite_infos,a

	tst		a a,x0
	jne		_start

	rts

_start:
	move	x:(r0)+,a

	do		x0,_loop

	jsr		music_poll
	jsr		prepare_mask
	jsr		sprite_position

	move	b1,y0
	move	x1,b0
	move	#>(16+256+16)/8/3/2,y1
	mac		y0,y1,b a1,n1
	move	#sprite_mask,r4
	move	#screen_buffer,r5
	move	b0,n5
	move	#<shift_values,r1
	move	n1,n2
	move	#<shift_masks,r2
	move	(r5)+n5
	move	(r1)+n1
	move	(r2)+n2
	move	#(16+256+16)/8/3-1,n5

	; Draw mask.

	move	x:(r1),x0 y:(r4)+,y0

	do		#16,_loop2

	mpy		-x0,y0,a x:(r2),x0 y:(r5)+,y1
	and		x0,a a0,b
	or		y1,a y:(r5)-,y1
	move	a1,y:(r5)+
	or		y1,b x:(r1),x0 y:(r4)+,y0
	move	b1,y:(r5)+n5
_loop2:

	move	x:(r0)+,a
_loop:

	rts

; -----------------------------------------------------------------------------
; Sound, per frame.
; -----------------------------------------------------------------------------

	include	'opm16_hot.asm'

; Add the rendered block to the effects in its ring segment, clear the mixes
; and move on to the next segment.

mix_out:
	move	x:<ring_seg,r0
	move	#MIX_C,r4
	move	#MIX_L,r5
	move	#MIX_R,r7

	do		#BLOCK,_end

	move	y:(r4)+,a ; Both channels.
	move	y:(r0),x0 ; Effect (the left word; the effects are mono).
	add		x0,a y:(r5)+,x0 ; Left.
	tfr		a,b y:(r7)+,y0 ; Right.
	add		x0,a
	add		y0,b a,y:(r0)+
	move	b,y:(r0)+
_end:

	clr		a
	move	#MIX_C,r4
	rep		#3*BLOCK
	move	a,y:(r4)+

	move	x:<ring_seg,a
	move	#>SEG,x0
	add		x0,a
	move	#>ssi_ring+SSI_RING_SIZE,x0
	cmp		x0,a
	jlt		_wrap
	move	#>ssi_ring,a
_wrap:
	move	a1,x:<ring_seg

	rts

; From the sprite code: take a music packet if one came (only while the DSP
; asks for them, in draw_masks), and render a block if one is due. Keeps every
; register but r6/m6; changes the condition codes.

music_poll:
	move	a2,x:<poll_save
	move	a1,x:<poll_save+1
	move	a0,x:<poll_save+2
	move	x0,x:<poll_save+3

	jset	#m_hrdf,x:m_hsr,music_poll_packet

music_poll_check:
	move	x:<render_state,a
	tst		a
	jne		music_poll_work

	move	r6,a ; How far is the SSI past the next segment's start?
	move	x:<ring_seg,x0
	sub		x0,a
	jge		<_ahead
	move	#>SSI_RING_SIZE,x0
	add		x0,a
_ahead:
	move	x:<poll_need,x0
	cmp		x0,a
	jlt		music_poll_done
	jmp		music_poll_work

music_poll_done:
	move	x:<poll_save+3,x0
	move	x:<poll_save,a2
	move	x:<poll_save+1,a1
	move	x:<poll_save+2,a0

	rts

int_end: ; The build checks that no P address is used twice.

; -----------------------------------------------------------------------------
	org	p:$200 ; External code, up to P:$0BFF.
; -----------------------------------------------------------------------------

music_poll_packet:
	move	r1,x:SAVE+11
	movep	x:m_hrx,a
	jsr		receive_music_packet
	move	x:SAVE+11,r1
	jmp		music_poll_check

music_poll_work:
	move	b2,x:SAVE
	move	b1,x:SAVE+1
	move	b0,x:SAVE+2
	move	x1,x:SAVE+7
	move	y0,x:SAVE+8
	move	y1,x:SAVE+9
	move	r0,x:SAVE+10
	move	r1,x:SAVE+11
	move	r2,x:SAVE+12
	move	r3,x:SAVE+13
	move	r4,x:SAVE+14
	move	r5,x:SAVE+15
	move	r7,x:SAVE+16
	move	n0,x:SAVE+17
	move	n1,x:SAVE+18
	move	n2,x:SAVE+19
	move	n3,x:SAVE+20
	move	n4,x:SAVE+21
	move	n5,x:SAVE+22
	move	n7,x:SAVE+23
	move	m3,x:SAVE+24
	move	#>-1,m3

_render:
	jsr		music_step
	move	x:<render_state,a
	tst		a
	jne		_render

	move	x:SAVE+24,m3
	move	x:SAVE+23,n7
	move	x:SAVE+22,n5
	move	x:SAVE+21,n4
	move	x:SAVE+20,n3
	move	x:SAVE+19,n2
	move	x:SAVE+18,n1
	move	x:SAVE+17,n0
	move	x:SAVE+16,r7
	move	x:SAVE+15,r5
	move	x:SAVE+14,r4
	move	x:SAVE+13,r3
	move	x:SAVE+12,r2
	move	x:SAVE+11,r1
	move	x:SAVE+10,r0
	move	x:SAVE+9,y1
	move	x:SAVE+8,y0
	move	x:SAVE+7,x1
	move	x:SAVE+2,b0
	move	x:SAVE+1,b1
	move	x:SAVE,b2

	jmp		music_poll_done

; One piece of the music: start the next block if the SSI has left its
; segment, render one channel, or mix the block into the ring. Uses every
; register but r6/m6; m3 must be linear.

music_step:
	move	x:<render_state,a
	tst		a
	jne		_go

	move	r6,a ; Is the SSI still in the next segment?
	move	x:<ring_seg,x0
	sub		x0,a
	jlt		_start
	move	#>SEG,x0
	cmp		x0,a
	jlt		_flags

_start:
	jsr		render_prep
	move	#>1,a
	move	a1,x:<render_state

	rts

_go:
	move	#>9,x0
	cmp		x0,a
	jeq		_mix

	jsr		render_channel
	move	x:<render_state,a
	move	#>1,x0
	add		x0,a
	move	a1,x:<render_state

	rts

_mix:
	jsr		mix_out
	clr		a
	move	a1,x:<render_state
	move	x:blocks,a ; Blocks played, for tests.
	move	#>1,x0
	add		x0,a
	move	a1,x:blocks

_flags:
music_flags:
	jclr	#0,x:<music_welcome,_full ; HF3: send music now (room, and the
	move	x:fifo_wr,a ; DSP is in one of its waits).
	move	x:fifo_rd,x0
	sub		x0,a
	move	#>FIFO_SIZE-1,x0
	and		x0,a
	move	a1,a
	move	#>FIFO_SIZE-1-MUSIC_PACKET,x0
	cmp		x0,a
	jgt		_full
	move	x:fifo_blocks,a ; The music it holds: the FIFO and the wait in progress.
	move	x:wait_count,x0
	add		x0,a
	move	#>MUSIC_LEAD,x0
	cmp		x0,a
	jge		_full
	bset	#m_hf3,x:m_hcr

	rts

_full:
	bclr	#m_hf3,x:m_hcr

	rts

; -----------------------------------------------------------------------------

main:
	movep	#0,x:m_bcr ; Reset leaves 15 wait states on every external access.
	movep	#1,x:m_pbc
	bclr	#m_hf2,x:m_hcr
	bclr	#m_hf3,x:m_hcr
	ori		#$04,omr ; Data ROMs: the sine at Y:$100.
	move	#stack,r7
	move	#>-1,m0
	move	#>-1,m1
	move	#>-1,m2
	move	#>-1,m3
	move	#>-1,m4
	move	#>-1,m5
	move	#>-1,m7

	move	#$100,r0 ; The sine into Y RAM, for the music.
	move	#0,r1
	do		#256,_sine
	move	y:(r0)+,x0
	move	x0,y:(r1)+
_sine:

	move	#>SEG,x0
	move	x0,x:<poll_need

	move	#0,x0
	jsr		fill_screen_buffer
	jsr		start_ssi

	jclr	#1,x:m_hsr,*
	movep	x0,x:m_htx ; DSP <-> CPU synchronization.

	jsr		receive_sprite_masks
	jsr		music_init

_loop:
	jsr		<receive_sprite_infos
	move	#>POLL_URGENT,x0 ; The 68030 waits for the runs.
	move	x0,x:<poll_need
	jsr		<draw_inverted_masks
	jsr		<create_rle_data
	jsr		convert_rle_data
	jsr		send_rle_data
	jsr		swap_sprite_infos
	move	#>SEG,x0 ; Render as soon as the SSI has left a segment,
	move	x0,x:<poll_need ; and take music meanwhile (until the next
	bset	#0,x:<music_welcome ; sprite packet).
	jsr		music_flags
	jsr		<draw_masks

	jmp		_loop

; -----------------------------------------------------------------------------

receive_sprite_masks:
	move	#packed_sprite_masks1,r0

	move	#packed_sprite_masks2,r4

	move	#>NUMBER_OF_PACKED_SPRITES1,x0

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x1

	tfr		x1,a
	sub		x0,a
	jcc		_extended_receive

	do		x1,_loop

	do		#11,_loop2

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x:(r0)+
_loop2:

	nop
_loop:

	rts

_extended_receive:
	do		#NUMBER_OF_PACKED_SPRITES1,_loop3

	do		#11,_loop4

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x:(r0)+
_loop4:

	nop
_loop3:

	do		a1,_loop5

	do		#11,_loop6

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,y:(r4)+
_loop6:

	nop
_loop5:

	rts

; -----------------------------------------------------------------------------

; The music's memory, its tables (count, then the words, from the 68030 right
; after the masks), its records, and the first ring segment to render.

music_init:
	clr		a
	move	#REGS,r0
	move	#>FIFO-REGS,x0
	rep		x0
	move	a,x:(r0)+
	move	#CH_KCX,r0
	move	#>TAB_PSTEP-CH_KCX,x0
	rep		x0
	move	a,x:(r0)+
	move	#OPR,r0
	move	#>sprite_infos1-OPR,x0
	rep		x0
	move	a,x:(r0)+
	move	#PHASES,r0
	rep		#32
	move	a,l:(r0)+
	move	#MIX_C,r0
	rep		#3*BLOCK+4
	move	a,y:(r0)+

	move	#TAB_SHIFT,r0
	move	#>$008000,a
	do		#8,_shift
	move	a1,x:(r0)+
	lsl		a
_shift:

	move	#>1,x0
	move	x0,x:lfsr
	move	#>FIFO,x0
	move	x0,x:fifo_rd
	move	x0,x:fifo_wr

	move	#TAB_PSTEP,r0
	jclr	#m_hrdf,x:m_hsr,*
	movep	x:m_hrx,x0
	do		x0,_tables
	jclr	#m_hrdf,x:m_hsr,*
	movep	x:m_hrx,x:(r0)+
_tables:

	move	#TAB_PSTEP,r0 ; Doubled for the shift by multiplication.
	do		#768,_double
	move	x:(r0),a
	asl		a
	move	a1,x:(r0)+
_double:

	jsr		init_records

	move	r6,a ; Render from the SSI's segment on, once it has left it.
	move	#>ssi_ring,x0
	sub		x0,a
	move	#>SEG,x0
	clr		b
_seg:
	cmp		x0,a
	jlt		_found
	sub		x0,a
	add		x0,b
	jmp		_seg
_found:
	move	#>ssi_ring,x0
	add		x0,b
	move	b1,x:<ring_seg
	clr		a
	move	a1,x:<render_state

	rts

; -----------------------------------------------------------------------------

; Clear the ring and start the SSI: 16-bit words, two per frame, network
; mode, clocks and frame syncs from the crossbar.

start_ssi:
	move	#ssi_ring,r6
	move	#SSI_RING_SIZE-1,m6
	clr		a
	rep		#SSI_RING_SIZE
	move	a,y:(r6)+

	movep	#$1f8,x:m_pcc
	movep	#$3000,x:m_ipr ; SSI at interrupt level 2.
	movep	#0,x:m_crb
	movep	#$4100,x:m_cra
	movep	y:(r6)+,x:m_tx
	movep	#$7a00,x:m_crb ; Transmit and receive, transmit interrupt.
	andi	#$fc,mr
	rts

ssi_tx_exception:
	movep	x:m_sr,y:ssi_status ; Clears the underrun flag.
	movep	y:(r6),x:m_tx
	movep	x:m_rx,y:(r6)+
	rti

; -----------------------------------------------------------------------------

; Send the count of the runs, wait for the 68030's HF1, then send the runs.

send_rle_data:
	move	y:rle_length,a
	asr		a ; Number of runs.

	jclr	#1,x:m_hsr,*
	movep	a1,x:m_htx
	bset	#0,x:<music_welcome
	jsr		music_flags

_wait:
	jsr		music_step
	jclr	#m_hrdf,x:m_hsr,_go
	movep	x:m_hrx,a ; Only music comes now.
	jsr		>receive_music_packet
_go:
	jclr	#m_hf1,x:m_hsr,_wait

	bclr	#0,x:<music_welcome
	bclr	#m_hf3,x:m_hcr

	move	#>POLL_TRANSFER,x0 ; Top the ring up for the transfer.
	move	x0,x:<poll_need
	do		#3,_top_up
	jsr		music_poll
	nop ; No JSR at a loop's end.
_top_up:
	move	#rle_buffer,r4
	move	y:rle_length,b ; Number of words.

	do		b1,_loop

	jclr	#1,x:m_hsr,*
	movep	y:(r4)+,x:m_htx
_loop:

	rts

; -----------------------------------------------------------------------------
;
; r0 = packed sprite mask address (Y memory).
;
convert_packed_sprite_mask2:
	move	#<sprite_convert_masks,r1

	move	#sprite_mask,r4
	move	#sprite_convert_shifts,r5

	move	y:(r0)+,x1

	do		#10/2,_loop

	tfr		x1,a x:(r1)+,x0 y:(r5)+,y0
	and		x0,a y:(r0)+,y1
	mpy		x1,y0,a a1,y:(r4)+
	mpy		y1,y0,b x:(r1)-,x0 y:(r5)-,y0
	and		x0,b a0,x1
	or		x1,b y:(r0)+,x1
	mpy		y1,y0,a b1,y:(r4)+
	move	a0,y:(r4)+
_loop:

	tfr		x1,a x:(r1)+,x0
	and		x0,a
	move	a,y:(r4)+

	rts

; -----------------------------------------------------------------------------

; Mask of the sprite whose info word is in a: r0 = its packed mask, then
; converted into sprite_mask and flipped. Keeps r0 (the info pointer).

prepare_mask:
	move	#>NUMBER_OF_PACKED_SPRITES1,x0
	move	#>11,x1
	move	#>$3fff,y0

	push	r0
	push	a1

	and		y0,a
	sub		x0,a a1,x0

	jcc		<_masks2

	mpy		x0,x1,a
	asr		a #packed_sprite_masks1,r0
	move	a0,n0
	nop
	move	(r0)+n0

	jsr		convert_packed_sprite_mask1

	jmp		<_skip

_masks2:
	move	a1,x0
	mpy		x0,x1,a
	asr		a #packed_sprite_masks2,r0
	move	a0,n0
	nop
	move	(r0)+n0

	jsr		convert_packed_sprite_mask2

_skip:
	jsset	#15,y:(r7),vertical_flip_sprite_mask
	jsset	#14,y:(r7)+,horizontal_flip_sprite_mask

	pop		r0

	rts

; Screen offset and shift of the sprite at r0 (its position word):
; x1 = word column, a = shift (X mod 24), b = Y. Advances r0.

sprite_position:
	move	x:(r0)+,b ; Y << 12 | X.
	move	b1,y1
	move	#>$fff,x0
	and		x0,b
	move	b1,x0 ; X.
	move	#$055556,x1 ; 1.0/24.0
	mpy		x0,x1,a #>24/2,y0
	move	a1,x1
	mpy		x1,y0,b x0,a
	move	b0,b
	sub		b,a #>$000800,y0
	mpy		y1,y0,b ; b1 = Y.

	rts

; -----------------------------------------------------------------------------

; Convert each run's byte length to a jump displacement into the 68030
; longword restoration blocks. Odd runs end with one word move. This runs
; before the transfer: the 68030 reads the host port without polling, so
; send_rle_data must not spend time between a run's offset and its length.
; The terminal run already holds its displacement.

convert_rle_data:
	move	y:rle_length,a
	asr		a #>1,x1 ; Number of runs.
	sub		x1,a #rle_buffer+1,r4 ; Runs before the terminal one.
	jeq		<_skip

	move	#>RLE_LONG_EVEN_BIAS,x0
	move	#2,n4

	do		a1,_loop

	btst	#1,y:(r4) ; Odd number of pixels?
	tfr		x0,b y:(r4),a
	tcs		x1,b
	asr		a ; Number of pixels.
	add		b,a
	neg		a
	move	a1,y:(r4)+n4
_loop:

_skip:
	rts

; -----------------------------------------------------------------------------
;
; r0 = packed sprite mask address (X memory).
;
convert_packed_sprite_mask1:
	move	#<sprite_convert_masks,r1

	move	#sprite_mask,r4
	move	#sprite_convert_shifts,r5

	move	x:(r0)+,x1

	do		#10/2,_loop

	tfr		x1,a x:(r1)+,x0 y:(r5)+,y0
	and		x0,a x:(r0)+,y1
	mpy		x1,y0,a a1,y:(r4)+
	mpy		y1,y0,b x:(r1)-,x0 y:(r5)-,y0
	and		x0,b a0,x1
	or		x1,b x:(r0)+,x1
	mpy		y1,y0,a b1,y:(r4)+
	move	a0,y:(r4)+
_loop:

	tfr		x1,a x:(r1)+,x0
	and		x0,a
	move	a,y:(r4)+

	rts

; -----------------------------------------------------------------------------

; a = a music packet's header ($80nnnn): its n words go into the FIFO, then
; the blocks their waits add up to. HF3 drops first, so that the 68030 waits
; for the FIFO to be measured again.

receive_music_packet:
	bclr	#m_hf3,x:m_hcr
	move	#>$ffff,x0
	and		x0,a
	jeq		_blocks

	move	#FIFO_SIZE-1,m1
	move	x:fifo_wr,r1
	nop

	do		a1,_loop

	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x:(r1)+
_loop:

	move	r1,x:fifo_wr
	move	#>-1,m1

_blocks:
	jclr	#0,x:m_hsr,*
	movep	x:m_hrx,x0
	move	x:fifo_blocks,a
	add		x0,a
	move	a1,x:fifo_blocks

	jmp		music_flags

; -----------------------------------------------------------------------------

vertical_flip_sprite_mask:
	move	#sprite_mask,r4
	move	#sprite_mask+16,r5

	do		#16/2,_loop

	move	y:(r4),x0
	move	y:-(r5),x1
	move	x1,y:(r4)+
	move	x0,y:(r5)
_loop:

	rts

; -----------------------------------------------------------------------------

horizontal_flip_sprite_mask:
	move	#bit_reverse_table,r0

	move	#sprite_mask,r4
	move	#sprite_convert_shifts,r5

	move	#>$ff,y1

	move	y:(r5)+,y0

	do		#16,_loop

	move	y:(r4),x0
	mpy		x0,y0,a x0,x1
	and		y1,a y:(r5)-,y0
	mpy		x1,y0,b a1,n0
	and		y1,b y:(r5)+,y0
	move	x:(r0+n0),x0
	mpy		x0,y0,a b1,n0
	move	y:(r5)-,y0
	move	x:(r0+n0),x0
	mac		x0,y0,a y:(r5)+,y0
	move	a0,y:(r4)+
_loop:

	rts

; -----------------------------------------------------------------------------

fill_screen_buffer:
	move	#screen_buffer+(16+256+16)/8/3*16,r4

	rep		#(16+256+16)/8/3*256
	move	x0,y:(r4)+

	rts

; -----------------------------------------------------------------------------

swap_sprite_infos:
	move	x:<work_sprite_infos,x0
	move	x:<display_sprite_infos,x1
	move	x0,x:<display_sprite_infos
	move	x1,x:<work_sprite_infos

	move	x:<number_of_work_sprite_infos,x0
	move	x:<number_of_display_sprite_infos,x1
	move	x0,x:<number_of_display_sprite_infos
	move	x1,x:<number_of_work_sprite_infos

	rts

; -----------------------------------------------------------------------------
; Sound, per block.
; -----------------------------------------------------------------------------

	include	'opm16_warm.asm'
	include	'opm16_block.asm'

ext_end: ; Up to P:$0BFF.

; -----------------------------------------------------------------------------
	org	x:$0 ; Internal X RAM.
; -----------------------------------------------------------------------------

shift_values:
	dc		-1.0/@POW(2.0,0.0)
	dc		-1.0/@POW(2.0,1.0)
	dc		-1.0/@POW(2.0,2.0)
	dc		-1.0/@POW(2.0,3.0)
	dc		-1.0/@POW(2.0,4.0)
	dc		-1.0/@POW(2.0,5.0)
	dc		-1.0/@POW(2.0,6.0)
	dc		-1.0/@POW(2.0,7.0)
	dc		-1.0/@POW(2.0,8.0)
	dc		-1.0/@POW(2.0,9.0)
	dc		-1.0/@POW(2.0,10.0)
	dc		-1.0/@POW(2.0,11.0)
	dc		-1.0/@POW(2.0,12.0)
	dc		-1.0/@POW(2.0,13.0)
	dc		-1.0/@POW(2.0,14.0)
	dc		-1.0/@POW(2.0,15.0)
	dc		-1.0/@POW(2.0,16.0)
	dc		-1.0/@POW(2.0,17.0)
	dc		-1.0/@POW(2.0,18.0)
	dc		-1.0/@POW(2.0,19.0)
	dc		-1.0/@POW(2.0,20.0)
	dc		-1.0/@POW(2.0,21.0)
	dc		-1.0/@POW(2.0,22.0)
	dc		-1.0/@POW(2.0,23.0)

shift_masks:
	dc		$ffffff
	dc		$7fffff
	dc		$3fffff
	dc		$1fffff
	dc		$0fffff
	dc		$07ffff
	dc		$03ffff
	dc		$01ffff
	dc		$00ffff
	dc		$007fff
	dc		$003fff
	dc		$001fff
	dc		$000fff
	dc		$0007ff
	dc		$0003ff
	dc		$0001ff
	dc		$0000ff
	dc		$00007f
	dc		$00003f
	dc		$00001f
	dc		$00000f
	dc		$000007
	dc		$000003
	dc		$000001

sprite_convert_masks:
	dc		$ffff00
	dc		$00ff00

work_sprite_infos:
	dc		sprite_infos1

display_sprite_infos:
	dc		sprite_infos2

number_of_work_sprite_infos:
	dc		0

number_of_display_sprite_infos:
	dc		0

	org	x:rle_states ; Modulo 2 with r3.

	dc		$000000,$ffffff

; -----------------------------------------------------------------------------
	org	x:bit_reverse_table ; External X RAM.
; -----------------------------------------------------------------------------

	dc		$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
	dc		$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
	dc		$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
	dc		$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	dc		$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
	dc		$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	dc		$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
	dc		$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	dc		$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
	dc		$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
	dc		$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
	dc		$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	dc		$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
	dc		$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	dc		$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
	dc		$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF

; Run scan tables for a 6-bit chunk c of boundaries (bit 5 first), indexed
; by c as a signed number from rle_chunk_tables. X and Y use the same
; addresses. X: twice the pixel of the first boundary; bit 23 set means c
; has none. Y: c without its first boundary.

	org	x:rle_chunk_boundaries

	dc		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; c = 32..63
	dc		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc		$800000,10,8,8,6,6,6,6,4,4,4,4,4,4,4,4 ; c = 0..31
	dc		2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

	org	y:rle_chunk_boundaries

	dc		0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ; c = 32..63
	dc		16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	dc		0,0,0,1,0,1,2,3,0,1,2,3,4,5,6,7 ; c = 0..31
	dc		0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

; -----------------------------------------------------------------------------
	org	y:sprite_convert_shifts ; External Y RAM.
; -----------------------------------------------------------------------------

	dc		$008000
	dc		$000080
	dc		0 ; rle_length
	dc		0 ; scrolling_offset

; -----------------------------------------------------------------------------
	end
; -----------------------------------------------------------------------------
