; opm16 kernel: the envelope loop but for its state handlers (h_att to h_rel,
; opm16_warm.asm): its head, and the new attenuation into the operator's
; gain. Apart from opm16_warm.asm so that the game's DSP program can keep it
; in internal P, as it works on external data throughout.

env_ops:
	do	#32,env_end
	move	r4,r3			; record
	move	x:(r4)+,r1		; handler
	move	x:(r4)+,a		; att
	jmp	(r1)
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
