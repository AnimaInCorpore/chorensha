
	xdef initialize_audio
	xdef release_audio
	xdef convert_pcm_sample
	xdef send_music_tables

;	xdef allocated_samples_buffer
	xdef next_free_sample_address

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

SAMPLES_BUFFER_SIZE=3*1024*1024 ; The effects (370 kB of 8-bit mono) as 16-bit stereo at 24585 Hz.

initialize_audio:
	; Allocate the samples buffer (ST-RAM only, for the DMA).

	move	#0,-(sp)
	move.l	#SAMPLES_BUFFER_SIZE,-(sp)
	move	#68,-(sp)
	trap	#1
	addq.l	#8,sp

	move.l	d0,allocated_samples_buffer_address
	move.l	d0,next_free_sample_address
	add.l	#SAMPLES_BUFFER_SIZE,d0
	move.l	d0,samples_buffer_end_address

	jsr		music_init ; MCDRV, for the game's music (music.s).

	rts

; ------------------------------------------------------------------------------

; The music kernel's tables, after the sprite masks (dsprite.asm music_init).

send_music_tables:
	movem.l	d0/a0-a1,-(sp)

	lea		music_tables,a0
	lea		$ffffa204.w,a1
	move.l	(a0),d0 ; The count, then the words.

.loop:
	btst	#1,$ffffa202.w
	beq		.loop
	move.l	(a0)+,(a1)
	subq.l	#1,d0
	bpl		.loop

	movem.l	(sp)+,d0/a0-a1

	rts

; ------------------------------------------------------------------------------
;
; a0 = the game's PCM entry: 2(a0).l length, 6(a0).l address of 8-bit signed
; mono samples at 12517 Hz (PCM_DAT). Converts them into the samples buffer
; as 16-bit stereo at 24585 Hz, the rate the DSP mixes at, and points the
; entry there. Each output frame lies between two input samples a and b and
; takes a + (b - a) * q / 4, q being its position rounded down to quarters.
; Four silent frames end each sample, so that the DSP's last received word
; is zero.
;

PCM_STEP=33367 ; 12517 / 24585 in 16.16.

convert_pcm_sample:
	movem.l	d0-d7/a1-a3,-(sp)

	move.l	6(a0),a1
	move.l	2(a0),d7
	move.l	next_free_sample_address,a2
	move.l	a2,d6
	lea		pcm_quarters,a3

	move.l	d7,d0 ; At most two frames (8 bytes) an input sample.
	lsl.l	#3,d0
	add.l	#4*4,d0
	add.l	a2,d0
	cmp.l	samples_buffer_end_address,d0
	bhi		.no_room

	subq.l	#2,d7 ; Intervals - 1.
	bmi		.end

	moveq	#0,d0 ; Position within the interval (16-bit fraction).

.interval:
	move.b	(a1)+,d2
	ext		d2
	move.b	(a1),d3
	ext		d3
	sub		d2,d3
	asl		#8,d2
	asl		#6,d3
	move	d2,(a3) ; Left and right of the four quarters.
	move	d2,2(a3)
	add		d3,d2
	move	d2,4(a3)
	move	d2,6(a3)
	add		d3,d2
	move	d2,8(a3)
	move	d2,10(a3)
	add		d3,d2
	move	d2,12(a3)
	move	d2,14(a3)

.frame:
	move	d0,d4
	rol		#2,d4
	and		#3,d4
	move.l	(a3,d4.w*4),(a2)+
	add		#PCM_STEP,d0
	bcc.s	.frame

	dbf		d7,.interval

.end:
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+

	move.l	a2,next_free_sample_address
	move.l	d6,6(a0)
	sub.l	d6,a2
	move.l	a2,2(a0)

	movem.l	(sp)+,d0-d7/a1-a3

	rts

.no_room:
	clr.l	2(a0) ; Silent.

	movem.l	(sp)+,d0-d7/a1-a3

	rts

; ------------------------------------------------------------------------------

release_audio:
	; Free allocated samples buffer.

	move.l	allocated_samples_buffer_address,-(sp)
	move	#73,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

; ------------------------------------------------------------------------------
	data
; ------------------------------------------------------------------------------

music_tables:
	incbin	"opm16_tab.bin"

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

allocated_samples_buffer_address:
	ds.l	1

next_free_sample_address:
	ds.l	1

samples_buffer_end_address:
	ds.l	1

pcm_quarters:
	ds.l	4

; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------


