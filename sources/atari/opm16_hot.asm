; opm16 kernel: the per-frame operator loops (internal P).
; Shared by the game's DSP program (sources/atari/dsprite.asm) and the
; standalone test program (tools/opm16/opmtest.asm), which define the memory
; map (see opmtest.asm) before including it.

; Unmodulated, written to the X ring at r5.
st_ind_w:
	move	x:(r4)+,x1
	move	x:(r4)+,y0
	move	l:(r7),b10
	and	y1,b
	move	b1,r0
	move	(r5)-			; the pipelined first store hits the scratch word
	do	#BLOCK,_end
	mac	x1,y1,b	y:(r0),x0
	and	y1,b	a,x:(r5)+
	move	b1,r0
	mpyr	x0,y0,a
_end
	move	a,x:(r5)+
	move	b10,l:(r7)+
	rts

; Unmodulated, added to the X ring at r3 in place.
st_ind_accx:
	move	x:(r4)+,x1
	move	x:(r4)+,y0
	move	l:(r7),b10
	move	r3,r5
	and	y1,b
	move	b1,r0
	do	#BLOCK,_end
	mac	x1,y1,b	y:(r0),x0
	and	y1,b	x:(r3)+,a
	macr	x0,y0,a	b1,r0
	move	a,x:(r5)+
_end
	move	b10,l:(r7)+
	rts

; Unmodulated, added to the Y mix.
st_ind_mix:
	move	x:(r4)+,x1
	move	x:(r4)+,y0
	move	l:(r7),b10
	move	n1,r1
	move	n1,r5
	and	y1,b
	move	b1,r0
	do	#BLOCK,_end
	mac	x1,y1,b	y:(r0),x0
	and	y1,b	y:(r1)+,a
	macr	x0,y0,a	b1,r0
	move	a,y:(r5)+
_end
	move	b10,l:(r7)+
	rts

; Modulated by the X ring at r3, written to the X ring at r5 (may be r3).
st_ser_w:
	move	x:(r4)+,x1
	move	x:(r4)+,y0
	move	l:(r7),b10
	move	x:(r3)+,a
	do	#BLOCK,_end
	add	b,a
	and	y1,a
	move	a1,r0
	mac	x1,y1,b
	move	y:(r0),x0
	mpyr	x0,y0,a	x:(r3)+,x0
	move	a,x:(r5)+	x0,a
_end
	move	b10,l:(r7)+
	rts

; Modulated by the X ring at r3, added to the Y mix.
st_ser_mix:
	move	x:(r4)+,x1
	move	x:(r4)+,x0
	move	l:(r7),b10
	move	n1,r1
	move	n1,r5
	move	x:(r3)+,a
	do	#BLOCK,_end
	add	b,a
	and	y1,a
	mac	x1,y1,b	a1,r0
	move	y:(r1)+,a
	move	y:(r0),y0
	macr	x0,y0,a
	move	x:(r3)+,a	a,y:(r5)+
_end
	move	b10,l:(r7)+
	rts

; Operator 1 with feedback, written to RING_A. The channel's history is
; copied to HX0 (newest) and y:FBB (older) for the block and back after.
st_fb_w:
	move	x:(r4)+,x1		; increment
	move	x:(r4)+,x0		; onward gain
	move	x0,y:FBB+1
	move	x:(r4)+,y0		; history gain, y0 for the first product
	move	y0,y:FBB+2
	move	x:(r4)+,x0
	move	x0,x:HX0
	move	x:(r4),x0
	move	x0,y:FBB
	move	l:(r7),b10
	move	#HX0,r2
	move	#FBB,r5
	move	#2,m5
	move	#RING_A,r3
	do	#BLOCK,_end
	move	x:(r2),x0	y:(r5),a
	add	x0,a	x0,y:(r5)+
	add	b,a
	and	y1,a
	move	a1,r0
	mac	x1,y1,b
	move	y:(r0),x0
	mpyr	x0,y0,a	y:(r5)+,y0
	mpyr	x0,y0,a	a,x:(r2)	y:(r5)+,y0
	move	a,x:(r3)+
_end
	move	#>-1,m5
	move	b10,l:(r7)+
	move	y:FBB,x0		; r4 -> older history
	move	x0,x:(r4)-
	move	x:HX0,x0
	move	x0,x:(r4)+
	move	(r4)+
	rts

; Modulated by the X ring at r3, added to the X ring at r1 in place.
st_ser_accx:
	move	x:(r4)+,x1
	move	x:(r4)+,x0
	move	l:(r7),b10
	move	r1,r5
	move	x:(r3)+,a
	do	#BLOCK,_end
	add	b,a
	and	y1,a
	mac	x1,y1,b	a1,r0
	move	x:(r1)+,a
	move	y:(r0),y0
	macr	x0,y0,a
	move	a,x:(r5)+
	move	x:(r3)+,a
_end
	move	b10,l:(r7)+
	rts
