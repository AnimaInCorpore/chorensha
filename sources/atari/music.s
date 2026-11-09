
; The game's music: MCDRV (sources/mcdrv.s) on the 68030, played by the
; YM2151 kernel on the DSP (dsprite.asm, opm16_*.asm).
;
; The game calls MCDRV through trap #4. MCDRV's OPM register writes go into a
; ring of DSP stream words: $00rrdd sets register rr to dd, $80nnnn waits n
; blocks (48 frames at 24585 Hz, about 2 ms). The timer registers stay here:
; timer A is MCDRV's clock. MCDRV's timer interrupt runs at timer A's rate in
; DSP time, writing waits between the ticks: mostly in the game's VSYNC wait
; (music_idle), up to MUSIC_IDLE_LEAD blocks ahead of what the DSP has been
; sent, else when the DSP asks for music (HF3, while it holds less than its
; lead) and the ring is short of MUSIC_LEAD blocks (music_generate, from
; send_music_packet). send_music_packet then sends the ring.

	xdef music_init
	xdef music_generate
	xdef music_idle
	xdef music_opm_write
	xdef send_music_packet
	xdef trap_4_handler

	ifnd MCDRV_TEST
	xref mcdrv_init
	xref mcdrv_dispatch
	xref mcdrv_tick
	endif

MUSIC_RING_SIZE=4096 ; Stream words.
MUSIC_RING_RESERVE=1024 ; Room left for a timer tick (a song start writes a few hundred).
MUSIC_LEAD=16 ; Blocks generated ahead of what the DSP has been sent, at least.
MUSIC_IDLE_LEAD=32 ; And in the game's idle time.
MUSIC_PACKET=64 ; At most this many words a packet (dsprite.asm MUSIC_PACKET).
MUSIC_PACKETS=4 ; At most this many packets a call.
TIMER_A_STEP=35197201 ; A timer A step (64 / 4 MHz) in blocks, 0.32 fixed point.

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

music_init:
	move.l	#music_ring,music_write
	move.l	#music_ring,music_read

	jmp		mcdrv_init

; ------------------------------------------------------------------------------

; MCDRV's signature and version, which the game looks for in front of the
; trap #4 handler before it plays music.

	dc.b	'-MCDRV0-'
	dc.l	$00680001

trap_4_handler:
	addq.b	#1,music_busy

	move	#$0090,-(sp) ; A format 0 frame for MCDRV's RTE.
	pea		.back(pc)
	move	sr,-(sp)
	jmp		mcdrv_dispatch

.back:
	subq.b	#1,music_busy

	rte

; ------------------------------------------------------------------------------

; Run MCDRV's timer interrupt until the ring is MUSIC_LEAD blocks ahead of
; what the DSP has been sent. Not while the game is in MCDRV (on the X68000,
; MCDRV masks the OPM interrupt for that), nor while music_idle runs it.

music_generate:
	tst.b	music_busy
	bne		.exit

	movem.l	d0-d5/a0,-(sp)
	moveq	#MUSIC_LEAD,d4
	moveq	#-1,d5 ; As many ticks as it takes.
	bsr		generate_ticks
	movem.l	(sp)+,d0-d5/a0

.exit:
	rts

; From the game's VSYNC wait (sz2.s XSP_VSYNC): MCDRV's timer interrupt in the
; time the game would spin anyway, up to MUSIC_IDLE_LEAD blocks ahead, so that
; the VBL seldom runs it in the renderer's time. One tick a call (about
; 0.4 ms), so that the game leaves its wait soon after the VBL. Keeps all
; registers.

music_idle:
	tst.b	music_busy
	bne		.exit

	btst	#0,timer_control ; Anything to do? Asked without taking music_busy,
	beq		.exit ; which keeps the VBL from generating.

	move.l	d0,-(sp)
	move.l	music_block,d0
	sub.l	music_sent_blocks,d0
	cmp.l	#MUSIC_IDLE_LEAD,d0
	movem.l	(sp)+,d0 ; Keeps the flags.
	bge		.exit

	addq.b	#1,music_busy ; The VBL generates nothing meanwhile.
	movem.l	d0-d5/a0,-(sp)
	moveq	#MUSIC_IDLE_LEAD,d4
	moveq	#1,d5
	bsr		generate_ticks
	movem.l	(sp)+,d0-d5/a0
	subq.b	#1,music_busy

.exit:
	rts

; d4 = how many blocks ahead to stop, d5 = at most this many ticks (-1: no
; limit).

generate_ticks:
.tick:
	btst	#0,timer_control ; Timer A loaded?
	beq		.done

	subq.l	#1,d5
	bcs		.done

	move.l	music_block,d0
	sub.l	music_sent_blocks,d0
	cmp.l	d4,d0
	bge		.done

	move.l	music_read,d0 ; Room in the ring.
	sub.l	music_write,d0
	subq.l	#4,d0
	bpl.s	.room

	add.l	#MUSIC_RING_SIZE*4,d0

.room:
	cmp.l	#MUSIC_RING_RESERVE*4,d0
	blo		.done

	; Timer A runs out: its period was taken when it last did, as the
	; counter reloads then.

	move.l	music_time_frac,d0
	move.l	music_time,d1
	add.l	music_period_frac,d0
	move.l	music_period,d2
	addx.l	d2,d1
	move.l	d0,music_time_frac
	move.l	d1,music_time

	bsr		timer_a_period

	sub.l	music_block,d1 ; Whole blocks since the last wait (the time starts at 0.5, so writes round to the nearest block).
	beq.s	.irq

	add.l	d1,music_block
	move.l	d1,d0
	or.l	#$800000,d0
	bsr		ring_put

.irq:
	btst	#2,timer_control ; Its interrupt enabled?
	beq		.tick

	move	#$010c,-(sp) ; As if the OPM interrupted (vector $43). MCDRV keeps all registers.
	pea		.tick(pc)
	move	sr,-(sp)
	jmp		mcdrv_tick

.done:
	rts

; ------------------------------------------------------------------------------

; MCDRV writes an OPM register: d1.b = register, d2.b = value. Keeps all
; registers.

music_opm_write:
	movem.l	d0-d1/a0,-(sp)

	moveq	#0,d0
	move.b	d1,d0
	cmp		#$10,d0
	blo.s	.stream

	cmp		#$14,d0
	bhi.s	.stream
	beq.s	.control

	cmp		#$11,d0
	bhi.s	.done ; Timer B: MCDRV does not use it.
	beq.s	.timer_a_low

	moveq	#3,d0 ; $10: the upper 8 bits of timer A.
	and		timer_a,d0
	moveq	#0,d1
	move.b	d2,d1
	lsl		#2,d1
	or		d1,d0
	move	d0,timer_a

	bra.s	.done

.timer_a_low:
	move	#$3fc,d0 ; $11: the lower 2 bits.
	and		timer_a,d0
	moveq	#3,d1
	and.b	d2,d1
	or		d1,d0
	move	d0,timer_a

	bra.s	.done

.control:
	move.b	timer_control,d0 ; Timer A started: it counts from now.
	move.b	d2,timer_control
	btst	#0,d0
	bne.s	.done

	btst	#0,d2
	beq.s	.done

	bsr		timer_a_period

	bra.s	.done

.stream:
	lsl		#8,d0
	move.b	d2,d0
	bsr		ring_put

.done:
	movem.l	(sp)+,d0-d1/a0

	rts

; ------------------------------------------------------------------------------

; Timer A's period, (1024 - value) steps, in blocks (32.32).

timer_a_period:
	movem.l	d0-d1,-(sp)

	move.l	#1024,d0
	sub		timer_a,d0
	mulu.l	#TIMER_A_STEP,d1:d0
	move.l	d1,music_period
	move.l	d0,music_period_frac

	movem.l	(sp)+,d0-d1

	rts

; ------------------------------------------------------------------------------

; d0 = a stream word. Dropped when the ring is full.

ring_put:
	move.l	music_write,a0
	move.l	d0,(a0)+
	cmp.l	#music_ring_end,a0
	bne.s	.no_wrap

	lea		music_ring,a0

.no_wrap:
	cmp.l	music_read,a0
	beq.s	.full

	move.l	a0,music_write

	rts

.full:
	addq.l	#1,music_dropped

	rts

; ------------------------------------------------------------------------------

; In the VBL, before each sprite packet and before the restore runs: while
; the DSP asks for music (HF3: it waits for the 68030 and holds less than its
; lead), send it up to MUSIC_PACKET words of the ring a packet, each followed
; by the number of blocks its waits add up to.

	ifnd MCDRV_TEST

send_music_packet:
	btst	#4,$ffffa202.w ; HF3.
	beq		.exit

	btst	#4,$ffffa200.w ; HF1: the 68030 takes the restore runs; a packet now
	bne		.exit ; would block both sides.

	movem.l	d0-d3/a0-a1,-(sp)

	moveq	#MUSIC_PACKETS-1,d3

.packet:
	bsr		music_generate

	move.l	music_read,a0
	move.l	music_write,d0
	sub.l	a0,d0
	beq		.done
	bhi.s	.count

	move.l	#music_ring_end,d0 ; Up to the end of the ring this time.
	sub.l	a0,d0

.count:
	lsr.l	#2,d0
	cmp.l	#MUSIC_PACKET,d0
	bls.s	.header

	moveq	#MUSIC_PACKET,d0

.header:
	lea		$ffffa204.w,a1
	move.l	d0,d1
	or.l	#$800000,d1
	move.l	d1,(a1)
	moveq	#0,d2
	subq	#1,d0

	; The DSP needs a moment after the header before it reads the words,
	; so each word waits for the transmit register to be free.

.loop:
	btst	#1,$ffffa202.w
	beq.s	.loop
	move.l	(a0)+,d1
	move.l	d1,(a1)
	bclr	#23,d1
	beq.s	.next

	add.l	d1,d2

.next:
	dbf		d0,.loop

.blocks:
	btst	#1,$ffffa202.w
	beq.s	.blocks
	move.l	d2,(a1)

	add.l	d2,music_sent_blocks
	cmp.l	#music_ring_end,a0
	bne.s	.store

	lea		music_ring,a0

.store:
	move.l	a0,music_read

	; HF3 dropped when the packet began. Once the DSP has taken the last
	; word and had a moment to measure its FIFO again, it may ask for more.

.taken:
	btst	#2,$ffffa202.w ; TRDY.
	beq.s	.taken

	moveq	#7,d0
	dbf		d0,*

	btst	#4,$ffffa202.w
	dbeq	d3,.packet

.done:
	movem.l	(sp)+,d0-d3/a0-a1

.exit:
	rts

	endif

; ------------------------------------------------------------------------------
	data
; ------------------------------------------------------------------------------

music_time:
	dc.l	0 ; Timer A's last overflow in blocks (32.32).

music_time_frac:
	dc.l	$80000000

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

music_ring:
	ds.l	MUSIC_RING_SIZE
music_ring_end:

music_write:
	ds.l	1

music_read:
	ds.l	1

music_period:
	ds.l	1 ; Timer A's next period in blocks (32.32).

music_period_frac:
	ds.l	1

music_block:
	ds.l	1 ; The block the last wait ended at.

music_sent_blocks:
	ds.l	1 ; The blocks the DSP has been sent.

music_dropped:
	ds.l	1 ; Words the ring had no room for.

timer_a:
	ds.w	1 ; Its 10-bit value.

timer_control:
	ds.b	1 ; OPM register $14 as written.

music_busy:
	ds.b	1 ; The game is in MCDRV.

	even

; ------------------------------------------------------------------------------
