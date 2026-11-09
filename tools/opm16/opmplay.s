; opmplay: plays an opm16 word stream on the Falcon DSP.
; Loads OPM16.LOD, uploads OPM16TAB.BIN to the DSP, routes DSP transmit to
; the DAC at 25.175 MHz / 256 / (PRESCALE + 1), then feeds STREAM.BIN to the
; host port. Assemble with -DPRESCALE=3 for 24585 Hz (default 5: 16390 Hz).

	ifnd	PRESCALE
PRESCALE	equ	5
	endif

	text

	xdef	start
start:
	move.l	4(sp),basepage_ptr
	lea	stack_top,sp
	move.l	basepage_ptr,a0
	move.l	#$100,d0
	add.l	12(a0),d0
	add.l	20(a0),d0
	add.l	28(a0),d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#74,-(sp)		; Mshrink
	trap	#1
	lea	12(sp),sp

main:
	pea	msg_hello
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	lea	name_tab,a0		; load the tables
	lea	tab_buffer,a1
	move.l	#16384,d1
	bsr	load_file
	tst.l	d0
	bmi	fail

	move.l	#2*1024*1024,-(sp)	; stream buffer
	move.w	#72,-(sp)		; Malloc
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq	fail
	move.l	d0,stream_ptr
	lea	name_stream,a0
	move.l	stream_ptr,a1
	move.l	#2*1024*1024,d1
	bsr	load_file
	tst.l	d0
	bmi	fail
	move.l	d0,stream_len

	clr.l	-(sp)			; supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_ssp

	move.w	#128,-(sp)		; Locksnd
	trap	#14
	addq.l	#2,sp
	clr.w	-(sp)			; Buffoper(0): stop DMA
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	#1,-(sp)		; Sndstatus(1): reset
	move.w	#140,-(sp)
	trap	#14
	addq.l	#4,sp
	clr.w	-(sp)			; Soundcmd(LTATTEN, 0)
	clr.w	-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	clr.w	-(sp)			; Soundcmd(RTATTEN, 0)
	move.w	#1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#2,-(sp)		; Soundcmd(ADDERIN, MATIN)
	move.w	#4,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#1,-(sp)		; Setmode(stereo 16)
	move.w	#132,-(sp)
	trap	#14
	addq.l	#4,sp
	clr.w	-(sp)			; Settracks(0, 0)
	clr.w	-(sp)
	move.w	#133,-(sp)
	trap	#14
	addq.l	#6,sp
	clr.w	-(sp)			; Setmontracks(0)
	move.w	#134,-(sp)
	trap	#14
	addq.l	#4,sp
	clr.w	-(sp)			; Dsptristate(transmit on, receive off)
	move.w	#1,-(sp)
	move.w	#137,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#1,-(sp)		; Devconnect(DSP xmit, DAC, 25 MHz, PRESCALE, no handshake)
	move.w	#PRESCALE,-(sp)
	clr.w	-(sp)
	move.w	#8,-(sp)
	move.w	#1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	lea	12(sp),sp

	move.l	#16000,-(sp)		; Dsp_Reserve
	move.l	#16000,-(sp)
	move.w	#107,-(sp)
	trap	#14
	lea	10(sp),sp
	pea	lod_buffer		; Dsp_LoadProg
	move.w	#3,-(sp)
	pea	name_lod
	move.w	#108,-(sp)
	trap	#14
	lea	12(sp),sp
	tst.w	d0
	bne	fail_super

	lea	tab_buffer,a0		; upload the tables: count, then words
	move.l	(a0)+,d7
	bsr	send_long_d7
	subq.l	#1,d7
.tab	move.l	(a0)+,d6
	bsr	send_d6
	dbra	d7,.tab

	move.l	stream_ptr,a0		; play
	move.l	stream_len,d7
	lsr.l	#2,d7
	subq.l	#1,d7
.play	move.l	(a0)+,d6
	bsr	send_d6
	subq.l	#1,d7
	bpl	.play

.idle	bra	.idle			; let the last blocks play; Hatari ends the run

send_long_d7:
	move.l	d7,d6
send_d6:
	btst	#1,$ffffa202.w
	beq.s	send_d6
	move.l	d6,$ffffa204.w
	rts

; a0 = name, a1 = buffer, d1 = max bytes -> d0 = bytes read or negative
load_file:
	movem.l	d1-d3/a0-a2,-(sp)
	move.l	a1,a2
	move.l	d1,d3
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#61,-(sp)		; Fopen
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi.s	.out
	move.w	d0,d2
	move.l	a2,-(sp)
	move.l	d3,-(sp)
	move.w	d2,-(sp)
	move.w	#63,-(sp)		; Fread
	trap	#1
	lea	12(sp),sp
	move.l	d0,-(sp)
	move.w	d2,-(sp)
	move.w	#62,-(sp)		; Fclose
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d0
.out	movem.l	(sp)+,d1-d3/a0-a2
	rts

fail_super:
fail:
	pea	msg_fail
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)		; wait for a key
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1

	data
msg_hello:	dc.b	"opm16 prototype",13,10,0
msg_fail:	dc.b	"opm16: load failed",13,10,0
name_lod:	dc.b	"OPM16.LOD",0
name_tab:	dc.b	"OPM16TAB.BIN",0
name_stream:	dc.b	"STREAM.BIN",0
	even

	bss
basepage_ptr:	ds.l	1
old_ssp:	ds.l	1
stream_ptr:	ds.l	1
stream_len:	ds.l	1
tab_buffer:	ds.b	16384
lod_buffer:	ds.b	32768
		ds.b	4096
stack_top:
