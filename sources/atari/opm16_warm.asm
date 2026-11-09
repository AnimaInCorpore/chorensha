; opm16 kernel: noise, channel routines and envelopes.
; Shared by the game's DSP program (sources/atari/dsprite.asm) and the
; standalone test program (tools/opm16/opmtest.asm), which define the memory
; map (see opmtest.asm) before including it.

; Operator 1 without feedback, written to RING_A.
op1_ind:
	move	#RING_A,r5
	jsr	<st_ind_w
	move	(r4)+			; past the history words
	move	(r4)+
	move	(r4)+
	rts

; Y mix += X ring at r3.
ring_mix:
	move	n1,r1
	move	n1,r5
	move	x:(r3)+,x0
	do	#BLOCK,_end
	move	y:(r1)+,a
	add	x0,a	x:(r3)+,x0
	move	a,y:(r5)+
_end
	rts

; Channel 7 operator 4 replaced by noise, added to the Y mix. The noise
; value (+-amplitude) changes when the latch counter overflows.
st_noise_mix:
	move	(r4)+
	move	(r4)+
	move	(r7)+
	move	n1,r1
	move	n1,r5
	move	x:noise_acc,b
	move	x:noise_step,x1
	move	x:noise_val,y0
	do	#BLOCK,_end
	add	x1,b
	jclr	#23,b1,_keep
	move	#>$7fffff,x0
	and	x0,b
	move	x:lfsr,a
	lsr	a
	move	x:noise_amp,y0
	jcc	<_pos
	move	#>LFSR_TAPS,x0
	eor	x0,a
	move	a1,x:lfsr
	move	x:noise_amp,a
	neg	a
	move	a,y0
	move	#>1,x0
	move	x0,x:noise_bit
	jmp	<_keep
_pos
	move	a1,x:lfsr
	move	#>0,x0
	move	x0,x:noise_bit
_keep
	move	y:(r1)+,a
	add	y0,a
	move	a,y:(r5)+
_end
	move	b1,x:noise_acc
	move	y0,x:noise_val
	rts

; Operator 4 modulated by the X ring at r3, or unmodulated; the noise
; takes its place on channel 7 when enabled.
o4_ser:
	move	x:noise_rec,x0
	move	r4,a
	cmp	x0,a
	jeq	<st_noise_mix
	jmp	<st_ser_mix
o4_free:
	move	x:noise_rec,x0
	move	r4,a
	cmp	x0,a
	jeq	<st_noise_mix
	jmp	<st_ind_mix

; Channel routines: operator 1 into RING_A, with (f) or without (n)
; feedback, then the rest of the algorithm. r4 -> O1, r7 -> O1 phase.
alg0f:	jsr	<st_fb_w
	jmp	<body0
alg0n:	jsr	<op1_ind
body0:	move	#RING_A,r3		; O2 <- O1, O3 <- O2, O4 <- O3
	move	#RING_B,r5
	jsr	<st_ser_w
	move	#RING_B,r3
	move	#RING_A,r5
	jsr	<st_ser_w
	move	#RING_A,r3
	jmp	<o4_ser

alg1f:	jsr	<st_fb_w
	jmp	<body1
alg1n:	jsr	<op1_ind
body1:	move	#RING_A,r3		; O2 added to O1, O3 <- O1 + O2, O4 <- O3
	jsr	<st_ind_accx
	move	#RING_A,r3
	move	#RING_B,r5
	jsr	<st_ser_w
	move	#RING_B,r3
	jmp	<o4_ser

alg2f:	jsr	<st_fb_w
	jmp	<body2
alg2n:	jsr	<op1_ind
body2:	move	#RING_B,r5		; O2 alone, O3 <- O2 added to O1, O4 <- O1 + O3
	jsr	<st_ind_w
	move	#RING_B,r3
	move	#RING_A,r1
	jsr	<st_ser_accx
	move	#RING_A,r3
	jmp	<o4_ser

alg3f:	jsr	<st_fb_w
	jmp	<body3
alg3n:	jsr	<op1_ind
body3:	move	#RING_A,r3		; O2 <- O1, O3 added to O2, O4 <- O2 + O3
	move	#RING_B,r5
	jsr	<st_ser_w
	move	#RING_B,r3
	jsr	<st_ind_accx
	move	#RING_B,r3
	jmp	<o4_ser

alg4f:	jsr	<st_fb_w
	jmp	<body4
alg4n:	jsr	<op1_ind
body4:	move	#RING_A,r3		; O2 <- O1 out, O3 alone, O4 <- O3 out
	jsr	<st_ser_mix
	move	#RING_B,r5
	jsr	<st_ind_w
	move	#RING_B,r3
	jmp	<o4_ser

alg5f:	jsr	<st_fb_w
	jmp	<body5
alg5n:	jsr	<op1_ind
body5:	move	#RING_A,r3		; O2, O3, O4 <- O1, all out
	jsr	<st_ser_mix
	move	#RING_A,r3
	jsr	<st_ser_mix
	move	#RING_A,r3
	jmp	<o4_ser

alg6f:	jsr	<st_fb_w
	jmp	<body6
alg6n:	jsr	<op1_ind
body6:	move	#RING_A,r3		; O2 <- O1 out, O3 out, O4 out
	jsr	<st_ser_mix
	jsr	<st_ind_mix
	jmp	<o4_free

alg7f:	jsr	<st_fb_w
	jmp	<body7
alg7n:	jsr	<op1_ind
body7:	move	#RING_A,r3		; all four out; O1 is scaled as a carrier
	jsr	<ring_mix
	jsr	<st_ind_mix
	jsr	<st_ind_mix
	jmp	<o4_free

; Channel not played this block: step over its operators.
ch_skip:
	move	#11,n4
	move	#4,n7
	move	(r4)+n4
	move	(r7)+n7
	rts

; Render the eight channels into the Y mixes.
render_channels:
	move	#OPR,r4
	move	#PHASES,r7
	move	#>$ff,y1
	do	#8,_ch
	move	x:(r4)+,r1		; channel routine
	move	x:(r4)+,n1		; mix base
	jsr	(r1)
	nop
	nop
_ch
	rts


; Envelopes and gains of the 32 operators. r4 = ENV, x1 = ATT_MAX,
; y1 = 2^-13 (att >> 13 by mpy), n3 = 1, n4 = 6. Each record starts with
; the handler of its state; a handler leaves the new att in a and
; r4 -> E_TL for env_t.
env_ops:
	do	#32,env_end
	move	r4,r3			; record
	move	x:(r4)+,r1		; handler
	move	x:(r4)+,a		; att
	jmp	(r1)
h_att:	tst	a	x:(r4)+,y0	; y0 = attack multiplier, 0 = held
	jle	<env_att_end
	move	(r4)+
	move	y0,b
	tst	b	a1,x0
	jeq	<env_t
	mpy	x0,y0,a
	move	#>ATT_ONE,x0
	cmp	x0,a
	jge	<env_t
	clr	a
	jmp	<env_t
env_att_end:				; attack done: decay, or sustain right away
	clr	a	x:(r4)+,x0
	cmp	x0,a
	jge	<env_a_sus
	move	#h_dec,r1
	move	#E_DADD,n3
	jmp	<env_switch
env_a_sus:
	move	#h_sus,r1
	move	#E_SADD,n3
env_switch:				; new state r1, its step at offset n3
	move	r1,x:(r3)
	move	x:(r3+n3),x0
	move	#E_CUR,n3
	nop
	move	x0,x:(r3+n3)
	move	#E_ATT,n3
	add	x0,a
	cmp	x1,a
	tgt	x1,a
	jmp	<env_t
h_dec:	move	x:(r4)+,x0		; decay add
	move	x:(r4)+,y0		; sustain level
	cmp	y0,a
	jge	<env_d_sus
	add	x0,a
	cmp	x1,a
	tgt	x1,a
	jmp	<env_t
env_d_sus:
	move	#h_sus,r1
	move	#E_SADD,n3
	jmp	<env_switch
h_sus:	move	x:(r4)+,x0		; sustain add
	add	x0,a	(r4)+
	cmp	x1,a
	tgt	x1,a
	jmp	<env_t
h_rel:	cmp	x1,a	x:(r4)+,x0	; release add; at the bottom: off
	jeq	<env_r_off
	add	x0,a	(r4)+
	cmp	x1,a
	tgt	x1,a
	jmp	<env_t
env_r_off:
	move	#h_off,r1
	move	(r4)-
	move	r1,x:(r3)
h_off:	move	(r4)+n4			; released and silent: nothing changes
	move	(r4)+n4
	move	(r4)+
	move	(r4)+
	jmp	<env_next
env_t:	move	a1,x:(r3+n3)		; att
	move	a1,x0			; t = att >> 13 + TL * 8 + AM, <= 1023
	mpy	x0,y1,b	x:(r4)+,x0
	add	x0,b	x:(r4)+,r1	; r1 -> AM offset
	move	x:(r4)+,y0		; gain scale
	move	x:(r1),x0
	add	x0,b	x:(r4)+,r1	; r1 -> gain word
	move	#>TAB_GAIN+1023,x0
	cmp	x0,b	x:(r4)+,r2	; r2 -> audible flag
	tgt	x0,b
	move	b1,r5
	move	x:(r4)+,r3		; r3 -> 2^(-t/64) word
	move	x:(r5),x0		; 2^(-t/64)
	mpyr	x0,y0,a	x0,x:(r3)
	move	#>TAB_GAIN+960,x0
	cmp	x0,b	a1,x:(r1)
	jge	<env_quiet
	move	b1,x:(r2)
env_quiet:
	move	(r4)+n4
env_next:
	nop
env_end:
	rts
