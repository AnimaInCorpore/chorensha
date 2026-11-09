; opm16 kernel: register writes, LFO, envelope and pitch setup (per block).
; Shared by the game's DSP program (sources/atari/dsprite.asm) and the
; standalone test program (tools/opm16/opmtest.asm), which define the memory
; map (see opmtest.asm) before including it.

; A block in pieces, for a program that renders between other work:
; render_prep, then render_channel eight times, then the program's own mix
; into its output. Equivalent to render_block in opmtest.asm.
render_prep:
	jsr	<events
	jsr	<lfo_block
	jsr	<controls
	jsr	<noise_setup
	move	#>OPR,x0
	move	x0,x:rc_r4
	move	#>PHASES,x0
	move	x0,x:rc_r7
	rts

render_channel:
	move	x:rc_r4,r4
	move	x:rc_r7,r7
	move	#>$ff,y1
	move	x:(r4)+,r1		; channel routine
	move	x:(r4)+,n1		; mix base
	jsr	(r1)
	move	r4,x:rc_r4
	move	r7,x:rc_r7
	rts

; Apply the stream words that belong to this block.
events:
	move	x:wait_count,a
	tst	a
	jle	<_loop
	move	#>1,x0
	sub	x0,a
	move	a1,x:wait_count
	rts
_loop
	move	x:fifo_rd,a
	move	x:fifo_wr,x0
	cmp	x0,a
	jeq	<_dry			; FIFO empty
	move	#FIFO_SIZE-1,m1
	move	a1,r1
	nop
	move	x:(r1)+,a
	move	r1,x:fifo_rd
	move	#>-1,m1
	jclr	#23,a1,_write
	move	#>$7fffff,x0
	and	x0,a
	move	x:fifo_blocks,b		; this wait leaves the FIFO
	move	a1,y0
	sub	y0,b
	move	b1,x:fifo_blocks
	move	#>1,x0
	sub	x0,a
	move	a1,x:wait_count
	jmp	<_out
_write
	move	a1,x:ev_word
	move	#>$ff,x0
	and	x0,a
	move	a1,x:ev_data
	move	x:ev_word,x0
	move	#>$008000,y0		; >> 8
	mpy	x0,y0,a
	move	#>$ff,x0
	and	x0,a
	move	a1,x:ev_reg
	jsr	<write_reg
	jmp	<_loop
_dry
	move	x:starved,a		; the stream ran dry: count it
	move	#>1,x0
	add	x0,a
	move	a1,x:starved
_out
	rts

; -----------------------------------------------------------------------------
; LFO for this block.
lfo_block:
	move	x:native_frac,a		; native samples in this block (DDA)
	move	#>NATIVE_BLOCK_FRAC,x0
	add	x0,a
	move	#>NATIVE_BLOCK_INT,b
	jclr	#23,a1,_nocarry
	move	#>$7fffff,x0
	and	x0,a
	move	#>1,x0
	add	x0,b
_nocarry
	move	a1,x:native_frac
	move	b1,x:native
	move	x:REGS+$18,a		; step = (16 | (rate & 15)) << (rate >> 4)
	move	#>15,x0
	and	x0,a
	move	#>16,x0
	or	x0,a
	move	x:REGS+$18,b
	rep	#4
	lsr	b
	tst	b
	jeq	<_noshift
	move	b1,x0
	rep	x0
	lsl	a
_noshift
	move	a1,x0
	move	x:native,y0
	mpy	x0,y0,a
	asr	a			; step * native in a10
	move	a1,x1
	move	a0,x0
	move	x:lfo_hi,b
	move	x:lfo_lo,b0
	add	x,b
	move	x:REGS+$01,a		; test bit 1 holds the LFO in reset
	jclr	#1,a1,_run
	clr	b
_run
	move	b1,x:lfo_hi
	move	b0,x:lfo_lo
	asl	b
	asl	b
	move	#>$ff,x0
	move	b1,a
	and	x0,a			; lfo = bits 22-29
	move	x:REGS+$1b,b
	move	#>3,x0
	and	x0,b
	jeq	<_saw
	move	#>1,x0
	cmp	x0,b
	jeq	<_square
	move	#>2,x0
	cmp	x0,b
	jeq	<_triangle
	move	x:lfo_last,x0		; noise: a new byte when the index moves
	cmp	x0,a
	jeq	<_hold
	move	x:lfsr,b
	lsr	b
	jcc	<_n1
	move	#>LFSR_TAPS,x0
	eor	x0,b
_n1
	move	b1,x:lfsr
	move	#>$ff,x0
	and	x0,b
	move	b1,x:lfo_noise
_hold
	move	x:lfo_noise,x1		; am
	move	x:lfo_noise,y1		; pm byte
	jmp	<_depth
_saw
	move	a1,b
	move	#>$ff,x0
	eor	x0,b
	move	b1,x1
	move	a1,y1
	jmp	<_depth
_square
	move	#>$ff,x1
	jclr	#7,a1,_sq
	move	#>0,x1
_sq
	move	x1,b
	move	#>$80,x0
	eor	x0,b
	move	b1,y1
	jmp	<_depth
_triangle
	move	a1,b
	jset	#7,a1,_tr1
	move	#>$ff,x0
	eor	x0,b
_tr1
	lsl	b
	move	#>$ff,x0
	and	x0,b
	move	b1,x1
	jset	#6,a1,_tr2
	eor	x0,b
_tr2
	move	b1,y1
_depth
	move	a1,x:lfo_last
	move	x:REGS+$19,a		; am * AMD >> 7
	move	#>$7f,x0
	and	x0,a
	move	a1,y0
	mpy	x1,y0,a
	asr	a
	move	a0,a
	rep	#7
	asr	a
	move	a1,x:lfo_am
	move	y1,a			; signed pm byte * PMD >> 7
	move	#>$ff,x0
	and	x0,a
	jclr	#7,a1,_pmpos
	move	#>$ffff00,x0
	or	x0,a
_pmpos
	move	a1,x1
	move	x:REGS+$1a,a
	move	#>$7f,x0
	and	x0,a
	move	a1,y0
	mpy	x1,y0,a
	asr	a
	move	a0,x0
	move	x0,a
	rep	#7
	asr	a
	move	a1,x:lfo_pm
	rts

; -----------------------------------------------------------------------------
; Register write ev_reg = ev_data.
write_reg:
	move	x:ev_reg,a
	move	x:ev_data,b
	move	#>$19,x0
	cmp	x0,a
	jne	<_store
	jclr	#7,b1,_store
	move	#>$1a,a
_store
	move	#REGS,r2
	move	a1,n2
	nop
	move	b1,x:(r2+n2)
	move	x:ev_reg,a		; by groups of eight registers
	rep	#3
	lsr	a
	move	#wtab,r2
	move	a1,n2
	nop
	move	p:(r2+n2),r2
	nop
	jmp	(r2)

wtab:	dc	w_none,w_key,w_none,w_none,w_ctl,w_kc,w_dirty,w_pms
	dc	w_dt1,w_dt1,w_dt1,w_dt1,w_tl,w_tl,w_tl,w_tl
	dc	w_op,w_op,w_op,w_op,w_op,w_op,w_op,w_op
	dc	w_dt2,w_dt2,w_dt2,w_dt2,w_op,w_op,w_op,w_op

w_none:
	rts

w_key:
	move	x:ev_reg,a
	move	#>$08,x0
	cmp	x0,a
	jeq	<key_write
	rts

; $30-$37 KF: pitch.
w_dirty:
	move	x:ev_reg,a
	move	#>7,x0
	and	x0,a
	move	a1,x:cur_ch
	jmp	<mark_dirty

; $38-$3f PMS/AMS.
w_pms:
	move	x:ev_reg,a
	move	#>7,x0
	and	x0,a
	move	a1,x:cur_ch
	move	x:ev_data,b
	move	#>3,x0
	and	x0,b
	move	#AMSCH,r2
	move	a1,n2
	nop
	move	b1,x:(r2+n2)
	move	x:ev_data,b		; PMS
	rep	#4
	lsr	b
	move	#>7,x0
	and	x0,b
	move	#CH_PMS,r2
	nop
	move	b1,x:(r2+n2)
	jmp	<mark_dirty

; $40-$5f DT1/MUL: pitch.
w_dt1:
	jsr	<reg_slot
	jsr	<pitch_opstatic
	jmp	<mark_dirty

; $c0-$df DT2/D2R: sustain rate and pitch.
w_dt2:
	jsr	<reg_slot
	jsr	<op_update
	jsr	<pitch_opstatic
	jmp	<mark_dirty

; $60-$7f TL.
w_tl:
	jsr	<reg_slot
	jsr	<slot_info
	move	x:ev_data,a
	move	#>$7f,x0
	and	x0,a
	rep	#3
	lsl	a
	move	#>TAB_GAIN,x0
	add	x0,a
	move	#E_TL,n4
	nop
	move	a1,x:(r4+n4)
	rts

; $80-$bf, $e0-$ff: rates, levels, AM enable.
w_op:
	jsr	<reg_slot
	jmp	<op_update

; slot = ev_reg & 31
reg_slot:
	move	x:ev_reg,a
	move	#>31,x0
	and	x0,a
	move	a1,x:slot
	rts

mark_dirty:
	move	#CH_DIRTY,r2
	move	x:cur_ch,n2
	move	#>1,x0
	move	x0,x:(r2+n2)
	rts

; $28-$2f KC: pitch, and the rates of operators whose key scaling changes.
w_kc:
	move	x:ev_reg,a
	move	#>7,x0
	and	x0,a
	move	a1,x:cur_ch
	jsr	<mark_dirty
	jsr	<kc_cache
	clr	a
	move	a1,x:cur_n
_op
	move	x:cur_n,n3
	move	#opmap,r3
	nop
	move	p:(r3+n3),a
	move	x:cur_ch,x0
	add	x0,a
	move	a1,x:slot
	jsr	<slot_info
	jsr	<slot_ksr
	move	x:ksr,x0
	move	#E_KSR,n4
	nop
	move	x:(r4+n4),a
	cmp	x0,a
	jeq	<_same
	move	x0,x:(r4+n4)
	jsr	<op_rates
_same
	move	x:cur_n,a
	move	#>1,x0
	add	x0,a
	move	a1,x:cur_n
	move	#>4,x0
	cmp	x0,a
	jlt	<_op
	rts

; Block, note and DT1 row of cur_ch's KC.
kc_cache:
	move	#REGS+$28,r2
	move	x:cur_ch,n2
	nop
	move	x:(r2+n2),a
	move	a1,b
	rep	#4			; block
	lsr	a
	move	#>7,x0
	and	x0,a
	move	#CH_BLOCK,r2
	nop
	move	a1,x:(r2+n2)
	move	b1,a			; DT1 row
	move	#>$7c,x0
	and	x0,a
	move	#>TAB_DT1,x0
	add	x0,a
	move	#CH_KCX,r2
	nop
	move	a1,x:(r2+n2)
	move	#>15,x0			; (kc4 - kc4 >> 2) << 6
	and	x0,b
	move	b1,a
	lsr	b
	lsr	b
	move	b1,x0
	sub	x0,a
	rep	#6
	lsl	a
	move	#CH_NOTE,r2
	nop
	move	a1,x:(r2+n2)
	rts

; $20-$27: pan, feedback, algorithm.
w_ctl:
	move	x:ev_reg,a
	move	#>7,x0
	and	x0,a
	move	a1,x:cur_ch
	move	x:ev_data,b		; feedback factor
	rep	#3
	lsr	b
	and	x0,b
	move	#TAB_FBK,r2
	move	b1,n2
	nop
	move	x:(r2+n2),y0
	move	#FBKCH,r2
	move	a1,n2
	nop
	move	y0,x:(r2+n2)
	move	x:ev_data,a		; routine: algorithm + 8 with feedback
	move	a1,b
	and	x0,a
	move	#>$38,x0
	and	x0,b
	jeq	<_nofb
	move	#>8,x0
	add	x0,a
_nofb
	move	#playtab,r2
	move	a1,n2
	nop
	move	p:(r2+n2),y0
	move	x:ev_data,a		; pan: 3 both, 1 left, 2 right, 0 none
	rep	#6
	lsr	a
	move	#>3,x0
	and	x0,a
	move	#>MIX_C,y1
	cmp	x0,a
	jeq	<_pan
	move	#>MIX_R,y1
	move	#>2,x0
	cmp	x0,a
	jeq	<_pan
	move	#>MIX_L,y1
	move	#>1,x0
	cmp	x0,a
	jeq	<_pan
	move	#>ch_skip,y0
_pan
	move	#CH_PLAY,r2
	move	x:cur_ch,n2
	nop
	move	y0,x:(r2+n2)
	move	x:cur_ch,x0		; mix base: OPR + 13 * channel + 1
	move	#>CHR,y0
	mpy	x0,y0,a
	asr	a
	move	a0,a
	move	#>OPR+1,x0
	add	x0,a
	move	a1,r2
	nop
	move	y1,x:(r2)
	move	x:cur_ch,a		; gain scales and audible flags of O1..O4
	rep	#6
	lsl	a
	move	#>ENV+E_SCALE,x0
	add	x0,a
	move	a1,r4
	move	#>E_AUD-E_SCALE,x0
	add	x0,a
	move	a1,r3
	move	x:ev_data,a
	move	#>7,x0
	and	x0,a
	move	#carriers,r2
	move	a1,n2
	nop
	move	p:(r2+n2),b		; carrier bits
	move	x:cur_ch,a
	move	#>CH_AUD,x0
	add	x0,a
	move	#16,n4
	move	#16,n3
	do	#4,_ops
	move	#>1021,x0		; modulator: 8168/8 index units
	move	#>SINK,y0
	jclr	#0,b1,_mod
	move	#>CARRIER_SCALE,x0	; carrier: 8168/32768 (or less)
	move	a1,y0
_mod
	move	x0,x:(r4)+n4
	move	y0,x:(r3)+n3
	lsr	b
_ops
	rts

opmap:	dc	0,16,8,24
rolemap: dc	0,2,1,3			; slot >> 3 -> n
incoff:	dc	2,7,9,11		; increment word in the channel record
carriers: dc	$8,$8,$8,$8,$a,$e,$e,$f
dt2tab:	dc	0,384,500,608
playtab: dc	alg0n,alg1n,alg2n,alg3n,alg4n,alg5n,alg6n,alg7n
	dc	alg0f,alg1f,alg2f,alg3f,alg4f,alg5f,alg6f,alg7f

; Key on/off: channel = data & 7; data bits 3-6 = O1..O4.
key_write:
	move	x:ev_data,a
	move	#>7,x0
	and	x0,a
	move	a1,x:cur_ch
	move	x:ev_data,a
	lsr	a
	lsr	a
	lsr	a
	move	a1,x:kmask
	clr	a
	move	a1,x:cur_n
_op
	move	x:cur_n,n3
	move	#opmap,r3
	nop
	move	p:(r3+n3),a
	move	x:cur_ch,x0
	add	x0,a
	move	a1,x:slot
	jsr	<slot_info		; r4 = envelope record
	move	x:kmask,a
	move	x:cur_n,b
	tst	b
	jeq	<_bit
	move	b1,x0
	rep	x0
	lsr	a
_bit
	move	#>1,x0
	and	x0,a			; key on?
	move	x:slot,n2
	move	#OP_KEY,r2
	nop
	move	x:(r2+n2),b
	tst	a
	jeq	<_off
	tst	b
	jne	<_next
	move	#>1,x0
	move	x0,x:(r2+n2)
	move	#PHASES,r2		; phase 0
	move	x:cur_q,n2
	clr	b
	nop
	move	b10,l:(r2+n2)
	move	#>h_att,x0		; attack
	move	x0,x:(r4)
	move	#E_MUL,n4
	nop
	move	x:(r4+n4),x0
	move	#E_CUR,n4
	nop
	move	x0,x:(r4+n4)
	move	#E_AR,n4
	nop
	move	x:(r4+n4),a		; rate 62 and up: att = 0 at once
	move	#>62,x0
	cmp	x0,a
	jlt	<_next
	clr	a
	move	#E_ATT,n4
	nop
	move	a1,x:(r4+n4)
	jmp	<_next
_off
	tst	b
	jeq	<_next
	clr	a
	move	a1,x:(r2+n2)
	move	#>h_rel,x0		; release
	move	x0,x:(r4)
	move	#E_RADD,n4
	nop
	move	x:(r4+n4),x0
	move	#E_CUR,n4
	nop
	move	x0,x:(r4+n4)
_next
	move	x:cur_n,a
	move	#>1,x0
	add	x0,a
	move	a1,x:cur_n
	move	#>4,x0
	cmp	x0,a
	jlt	<_op
	rts

; slot -> cur_ch, cur_o (n), cur_q and r4 = its envelope record.
slot_info:
	move	x:slot,a
	lsl	a
	lsl	a
	move	#>SLOTTAB,x0
	add	x0,a
	move	a1,r3
	nop
	move	x:(r3)+,x0
	move	x0,x:cur_ch
	move	x:(r3)+,x0
	move	x0,x:cur_o
	move	x:(r3)+,x0
	move	x0,x:cur_q
	move	x:(r3)+,r4
	rts

; The same, computed (for filling SLOTTAB).
slot_calc:
	move	x:slot,a
	move	#>7,x0
	and	x0,a
	move	a1,x:cur_ch
	move	x:slot,a
	rep	#3
	lsr	a
	move	#rolemap,r3
	move	a1,n3
	nop
	move	p:(r3+n3),a
	move	a1,x:cur_o
	move	x:cur_ch,b
	lsl	b
	lsl	b
	move	a1,x0
	add	x0,b
	move	b1,x:cur_q
	rep	#4
	lsl	b
	move	#>ENV,x0
	add	x0,b
	move	b1,r4
	rts

; ksr of slot: keycode >> (KS ^ 3) -> x:ksr
slot_ksr:
	move	#REGS+$28,r3
	move	x:cur_ch,n3
	nop
	move	x:(r3+n3),a
	lsr	a
	lsr	a
	move	#>31,x0
	and	x0,a
	move	a1,y1			; keycode
	move	#REGS+$80,r3
	move	x:slot,n3
	nop
	move	x:(r3+n3),a
	rep	#6
	lsr	a
	move	#>3,x0
	eor	x0,a
	move	y1,b
	tst	a
	jeq	<_done
	move	a1,x0
	rep	x0
	lsr	b
_done
	move	b1,x:ksr
	rts

; Everything of slot's envelope record that comes from its registers.
op_update:
	jsr	<slot_info
	jsr	<slot_ksr
	move	x:ksr,x0
	move	#E_KSR,n4
	nop
	move	x0,x:(r4+n4)
	jsr	<op_rates
	jmp	<op_levels

; Rates of slot from x:ksr into the record at r4, and the step of its state.
op_rates:
	move	x:slot,n3
	move	#REGS+$80,r3		; attack: AR * 2
	nop
	move	x:(r3+n3),a
	move	#>31,x0
	and	x0,a
	lsl	a
	jsr	<eff_rate
	move	#E_AR,n4
	nop
	move	a1,x:(r4+n4)
	move	#TAB_ENV_MUL,r2
	move	#E_MUL,n4
	jsr	<rate_store
	move	#REGS+$a0,r3		; decay: D1R * 2
	nop
	move	x:(r3+n3),a
	move	#>31,x0
	and	x0,a
	lsl	a
	jsr	<eff_rate
	move	#TAB_ENV_ADD,r2
	move	#E_DADD,n4
	jsr	<rate_store
	move	#REGS+$c0,r3		; sustain: D2R * 2
	nop
	move	x:(r3+n3),a
	move	#>31,x0
	and	x0,a
	lsl	a
	jsr	<eff_rate
	move	#TAB_ENV_ADD,r2
	move	#E_SADD,n4
	jsr	<rate_store
	move	#REGS+$e0,r3		; release: RR * 4 + 2
	nop
	move	x:(r3+n3),a
	move	#>15,x0
	and	x0,a
	lsl	a
	lsl	a
	move	#>2,x0
	add	x0,a
	jsr	<eff_rate
	move	#TAB_ENV_ADD,r2
	move	#E_RADD,n4
	jsr	<rate_store
	move	x:(r4),x0		; the step of the current state
	move	#>h_att,a
	cmp	x0,a
	move	#E_MUL,n4
	jeq	<_cur
	move	#>h_dec,a
	cmp	x0,a
	move	#E_DADD,n4
	jeq	<_cur
	move	#>h_sus,a
	cmp	x0,a
	move	#E_SADD,n4
	jeq	<_cur
	move	#E_RADD,n4		; release (or off, where it is unused)
_cur
	nop
	move	x:(r4+n4),x0
	move	#E_CUR,n4
	nop
	move	x0,x:(r4+n4)
	rts

; x:(r4+n4) = x:(r2 + a)
rate_store:
	move	a1,n2
	nop
	move	x:(r2+n2),x0
	move	x0,x:(r4+n4)
	rts

; a = raw rate -> a = 0 or min(raw + ksr, 63)
eff_rate:
	tst	a
	jeq	<_done
	move	x:ksr,x0
	add	x0,a
	move	#>63,x0
	cmp	x0,a
	jle	<_done
	move	x0,a
_done
	rts

; Sustain level, TL and AM source of slot into the record at r4.
op_levels:
	move	x:slot,n3
	move	#REGS+$e0,r3		; sustain level: d1l |= (d1l + 1) & 16, << 18
	nop
	move	x:(r3+n3),a
	rep	#4
	lsr	a
	move	a1,x0
	move	#>1,y0
	add	y0,a
	move	#>16,y0
	and	y0,a
	move	a1,y0
	move	x0,a
	or	y0,a
	rep	#18
	lsl	a
	move	#E_SL,n4
	nop
	move	a1,x:(r4+n4)
	move	#REGS+$60,r3		; TL * 8 + TAB_GAIN
	nop
	move	x:(r3+n3),a
	move	#>$7f,x0
	and	x0,a
	rep	#3
	lsl	a
	move	#>TAB_GAIN,x0
	add	x0,a
	move	#E_TL,n4
	nop
	move	a1,x:(r4+n4)
	move	#REGS+$a0,r3		; AM source: the channel's offset or zero
	nop
	move	x:(r3+n3),a
	move	#>ZERO,x0
	jclr	#7,a1,_noam
	move	x:cur_ch,a
	move	#>AMOFF,x0
	add	x0,a
	move	a1,x0
_noam
	move	#E_AM,n4
	nop
	move	x0,x:(r4+n4)
	rts

; DT2 value, DT1 code and MUL of slot into its pitch record.
pitch_opstatic:
	jsr	<slot_info
	move	x:cur_q,a		; r5 = PITCH + 8 q
	rep	#3
	lsl	a
	move	#>PITCH,x0
	add	x0,a
	move	a1,r5
	move	x:slot,n3
	move	#REGS+$c0,r3
	nop
	move	x:(r3+n3),a
	rep	#6
	lsr	a
	move	#dt2tab,r2
	move	a1,n2
	nop
	move	p:(r2+n2),x0
	move	x0,x:(r5)+		; DT2 value
	move	#REGS+$40,r3
	nop
	move	x:(r3+n3),a
	move	a1,b
	rep	#4
	lsr	a
	move	#>7,x0
	and	x0,a
	move	a1,x:(r5)		; DT1 code
	move	#>15,x0			; MUL * 2, or 1 for MUL 0
	and	x0,b
	lsl	b
	jne	<_m
	move	#>1,b
_m
	move	#4,n5
	nop
	move	b1,x:(r5+n5)
	rts

; a1 = increment word of cur_ch, cur_o
inc_word:
	move	x:cur_ch,x0
	move	#>CHR,y0
	mpy	x0,y0,a
	asr	a
	move	a0,a
	move	x:cur_o,n3
	move	#incoff,r3
	nop
	move	p:(r3+n3),x0
	add	x0,a
	move	#>OPR,x0
	add	x0,a
	rts

; Records from the reset registers, once the tables are in.
init_records:
	clr	b
	move	b1,x:slot
	move	#SLOTTAB,r5
	do	#32,_slots
	jsr	<slot_calc
	move	x:cur_ch,x0
	move	x0,x:(r5)+
	move	x:cur_o,x0
	move	x0,x:(r5)+
	move	x:cur_q,x0
	move	x0,x:(r5)+
	move	r4,x:(r5)+
	move	x:slot,b
	move	#>1,x0
	add	x0,b
	move	b1,x:slot
_slots
	clr	b
	move	b1,x:slot
	do	#32,_ops
	jsr	<slot_info
	move	#>h_off,x0		; released and silent
	move	x0,x:(r4)
	move	#>ATT_MAX,x0
	move	#E_ATT,n4
	nop
	move	x0,x:(r4+n4)
	jsr	<inc_word		; gain word = increment word + 1
	move	#>1,x0
	add	x0,a
	move	#E_GAINW,n4
	nop
	move	a1,x:(r4+n4)
	move	#>SINK,x0		; 2^(-t/64) word: operator 1 only
	move	x:cur_o,a
	tst	a
	jne	<_mod
	move	x:cur_ch,a
	move	#>CH_OPG,x0
	add	x0,a
	move	a1,x0
_mod
	move	#E_OPGW,n4
	nop
	move	x0,x:(r4+n4)
	jsr	<inc_word		; pitch record: increment word
	move	x:cur_q,b
	rep	#3
	lsl	b
	move	#>PITCH+6,x0
	add	x0,b
	move	b1,r3
	nop
	move	a1,x:(r3)
	jsr	<op_update
	jsr	<pitch_opstatic
	move	x:slot,b
	move	#>1,x0
	add	x0,b
	move	b1,x:slot
_ops
	clr	a
	move	a1,x:ev_data
	move	#>$20,x0
	move	x0,x:ev_reg
	do	#8,_chs
	jsr	<w_ctl
	move	x:ev_reg,a
	move	#>1,x0
	add	x0,a
	move	a1,x:ev_reg
_chs
	clr	a
	move	a1,x:cur_ch
	do	#8,_kcs
	jsr	<kc_cache
	move	x:cur_ch,a
	move	#>1,x0
	add	x0,a
	move	a1,x:cur_ch
_kcs
	move	#>1,x0
	move	#CH_DIRTY,r0
	rep	#8
	move	x0,x:(r0)+
	rts

; -----------------------------------------------------------------------------
; Envelopes, gains, channel routines and pitch for this block.
controls:
	move	x:lfo_am,a		; AM offsets: lfo_am << (AMS - 1)
	tst	a
	jne	<_amcalc
	move	#AMOFF,r0
	rep	#8
	move	a,x:(r0)+
	jmp	<_amdone
_amcalc
	move	#AMSCH,r1
	move	#AMOFF,r0
	do	#8,_am
	move	x:(r1)+,a
	clr	b
	tst	a
	jeq	<_amst
	move	x:lfo_am,b
	move	#>1,x0
	sub	x0,a
	jeq	<_amst
	move	a1,x0
	rep	x0
	lsl	b
_amst
	move	b1,x:(r0)+
_am
_amdone
	clr	a
	move	#CH_AUD,r0
	rep	#8
	move	a,x:(r0)+
	move	#ENV,r4
	move	#1,n3
	move	#6,n4
	move	#>ATT_MAX,x1
	move	#>$000400,y1
	jsr	<env_ops
	move	#CH_OPG,r0		; history gains: 2^(-t/64) of O1 * FBK
	move	#FBKCH,r1
	move	#OPR+4,r5
	move	#CHR,n5
	nop
	do	#8,_hist
	move	x:(r0)+,x0
	move	x:(r1)+,y0
	mpyr	x0,y0,a
	move	a1,x:(r5)+n5
_hist
	move	#CH_AUD,r0		; channel routine, or ch_skip when silent
	move	#CH_PLAY,r1
	move	#OPR,r5
	move	#>ch_skip,y0
	do	#8,_play
	move	x:(r0)+,a
	tst	a	x:(r1)+,b
	teq	y0,b
	move	b1,x:(r5)+n5
_play
	jmp	<pitch_block

; Increments of the channels whose pitch changed, or with PM.
pitch_block:
	move	x:REGS+$1a,a
	move	#>$7f,x0
	and	x0,a
	move	a1,x:pmd
	clr	a
	move	a1,x:cur_ch
	move	#CH_DIRTY,r0
	move	#CH_PMS,r4
	do	#8,_chs
	move	x:(r0),b		; dirty
	move	x:(r4)+,a		; pms
	tst	b	a1,x:cur_pms
	jeq	<_clean
	clr	b
	move	b1,x:(r0)
	jsr	<pitch_ch
	jmp	<_inc
_clean
	tst	a
	jeq	<_next
	move	x:pmd,a
	tst	a
	jeq	<_next
_inc
	jsr	<pitch_pm
	jsr	<pitch_fast
_next
	move	(r0)+
	move	x:cur_ch,a
	move	#>1,x0
	add	x0,a
	move	a1,x:cur_ch
_chs
	rts

; PM term of cur_ch: lfo_pm >> (6 - pms), or << (pms - 5) for 6, 7.
pitch_pm:
	clr	b
	move	x:cur_pms,a
	tst	a
	jeq	<_done
	move	x:lfo_pm,b
	move	#>6,x0
	cmp	x0,a
	jge	<_up
	move	a1,x0
	move	#>6,a
	sub	x0,a
	move	a1,x0
	rep	x0
	asr	b
	jmp	<_done
_up
	move	#>5,x0
	sub	x0,a
	move	a1,x0
	rep	x0
	asl	b
_done
	move	b1,x:cur_pm
	rts

; Frequency code, block and DT1 step of cur_ch's operators.
pitch_ch:
	move	x:cur_ch,n2
	move	#REGS+$30,r2
	nop
	move	x:(r2+n2),a		; code = note + KF >> 2
	lsr	a
	lsr	a
	move	#CH_NOTE,r2
	nop
	move	x:(r2+n2),x0
	add	x0,a
	move	a1,y1
	move	#CH_BLOCK,r2
	nop
	move	x:(r2+n2),x1
	move	#CH_KCX,r2
	nop
	move	x:(r2+n2),y0
	move	x:cur_ch,a		; r5 = PITCH + 32 * channel
	rep	#5
	lsl	a
	move	#>PITCH,x0
	add	x0,a
	move	a1,r5
	move	#3,n5
	do	#4,_ops
	move	x:(r5)+,x0		; DT2 value
	tfr	y1,a	x:(r5)+,b	; DT1 code
	add	x0,a
	move	a1,x:(r5)+		; code + DT2
	move	x1,x:(r5)+		; block
	move	#>3,x0
	tfr	b,a
	and	x0,a
	add	y0,a
	move	a1,r1
	nop
	move	x:(r1),a
	jclr	#2,b1,_pos
	neg	a
_pos
	move	a1,x:(r5)+		; signed DT1 step
	move	(r5)+n5
_ops
	rts

; Increments of cur_ch's operators with the PM term x:cur_pm.
pitch_fast:
	move	x:cur_ch,a
	rep	#5
	lsl	a
	move	#>PITCH+2,x0
	add	x0,a
	move	a1,r2
	move	x:cur_pm,y1
	move	#3,n2
	do	#4,_ops
	move	x:(r2)+,a		; frequency code + DT2
	add	y1,a	x:(r2)+,b	; + PM; b = block
	jge	<_nn
	move	#>768,x0		; below the octave
	add	x0,a
	tst	b
	jne	<_dec
	clr	a			; block 0: the lowest step
	jmp	<_look
_dec
	move	#>1,x0
	sub	x0,b
	jmp	<_look
_nn
	move	#>768,x0
	cmp	x0,a
	jlt	<_look
	sub	x0,a			; above the octave
	cmp	x0,a
	jlt	<_ov1
	sub	x0,a
	move	#>1,y0
	add	y0,b
_ov1
	move	#>7,y0
	cmp	y0,b
	jlt	<_up
	move	#>767,a			; block 7: the highest step
	move	y0,b
	jmp	<_look
_up
	move	#>1,y0
	add	y0,b
_look
	move	#>TAB_PSTEP,x0		; step = PSTEP[eff] >> (7 - block)
	add	x0,a	b1,n3
	move	a1,r1
	move	#TAB_SHIFT,r3
	move	x:(r1),x0
	move	x:(r3+n3),y0
	mpy	x0,y0,a	x:(r2)+,x0	; x0 = DT1 step
	add	x0,a	x:(r2)+,y0	; y0 = MUL * 2
	move	a1,x0
	mpy	x0,y0,a
	asr	a
	asr	a
	move	a0,x0			; T = step * MUL * 2 >> 1
	move	#>NPF_FRAC,y0		; T * native samples per frame, mod 1
	mpy	x0,y0,a
	rep	#NPF_INT
	add	x0,a
	rep	#4
	asl	a
	move	a1,x0
	move	#>INC_K,y0
	mpyr	x0,y0,a	x:(r2)+,r1	; r1 -> increment word
	move	(r2)+n2
	move	a1,x:(r1)
_ops
	rts

; Noise step and amplitude for this block (channel 7, operator 4).
noise_setup:
	clr	a
	move	a1,x:noise_rec
	move	x:REGS+$0f,a
	jclr	#7,a1,_done
	move	#>31,x0
	and	x0,a
	eor	x0,a			; (NFRQ ^ 31) = latch period - 1
	move	#TAB_NOISE,r4
	move	a1,n4
	nop
	move	x:(r4+n4),x0
	move	x0,x:noise_step
	move	x:ENV+16*31+E_ATT,x0	; ((t ^ $3ff) << 1) / 32768 = t ^ $3ff << 9
	move	#>$000400,y0
	mpy	x0,y0,a
	move	x:REGS+$7f,b
	move	#>$7f,x0
	and	x0,b
	rep	#3
	lsl	b
	move	a1,x0
	add	x0,b
	move	#>1023,x0
	cmp	x0,b
	jle	<_t
	move	x0,b
_t
	eor	x0,b
	rep	#9
	lsl	b
	move	b1,x:noise_amp
	move	x:noise_bit,a
	tst	a
	jeq	<_plus
	neg	b
_plus
	move	b1,x:noise_val
	move	#>OPR+CHR*7+11,x0
	move	x0,x:noise_rec
_done
	rts
