
	xdef initialize_graphics
	xdef release_graphics
	xdef compile_sprite
	xdef compile_characters
	xdef prepare_sprite_infos
	xdef graphics_engine
	xdef restart_raster_throttle
	xdef raster_stages_left
	xdef raster_interrupts
	xdef render_idle
	xdef renderer_lock
	xdef flip_pending
	xdef show_held_picture

	xdef display_screen_address
	xdef work_screen_address
	xdef display_window_address
	xdef text_bitmaps
	xdef text_matrix

SCREEN_BUFFER_SIZE=(16+512+256+16)*256*2*2
SCREEN_DISPLAY_OFFSET=16*2+16*256*2*2
TOTAL_NUMBER_OF_SPRITES=1885
TOTAL_NUMBER_OF_CHARACTERS=128 ; 4096 / (4 * 8) = 128
SPRITE_THROTTLE_DISPLAY_LINES=170 ; 240*3/4 = 180
REDRAW_VBLS=4 ; A picture of an unchanged sprite list at most this often.
LIST_SLOTS=4 ; Sprite lists kept, so that a picture can draw the one that belongs to its VBL.
PICTURE_LATENCY=2 ; From the VBL a sprite list is finished in to the VBL that shows its picture.
PICTURE_VBLS_MAX=4 ; The slowest picture cadence finish_picture settles on, in VBLs.
PICTURE_EARLY=4 ; Pictures in a row that are ready a VBL early before a cadence of 2 VBLs gets faster (a quarter of them at 3, an eighth at 4, at least one).
SPRITE_GROUP=4 ; Sprites draw_sprites draws between its throttle checks (a power of 2).
MASK_HASH_SIZE=4096 ; Hash table for finding equal sprite masks.

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

initialize_graphics:
	bsr		build_cell_span

	; Physbase.

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp

	move.l	d0,physbase

	; Allocate screen buffers (16 bytes boundary, ST-RAM only): three, so
	; that the next picture can be drawn while a finished one waits for its
	; VBL (see finish_picture).

	move	#0,-(sp)
	move.l	#SCREEN_BUFFER_SIZE*3+16,-(sp)
	move	#68,-(sp)
	trap	#1
	addq.l	#8,sp

	move.l	d0,allocated_screen_address

	add.l	#15,d0
	and.l	#$fffffff0,d0

	cmp.l	#-1,machine_supervidel
	beq		.no_supervidel

	add.l	#$a0000000,d0

.no_supervidel:
	move.l	d0,display_screen_address
	add.l	#SCREEN_BUFFER_SIZE,d0
	move.l	d0,work_screen_address
	add.l	#SCREEN_BUFFER_SIZE,d0
	move.l	d0,spare_screen_address
	sub.l	#SCREEN_BUFFER_SIZE,d0

	add.l	#SCREEN_DISPLAY_OFFSET,d0
	move.l	d0,display_window_address

	; Load background graphics.

	clr		-(sp)
	pea		background_image_filename
	move	#61,-(sp)
	trap	#1
	addq.l	#8,sp

	move	d0,d7

	pea		background_image
	move.l	#256*2*512,-(sp)
	move	d7,-(sp)
	move	#63,-(sp)
	trap	#1
	lea		12(sp),sp

	move	d7,-(sp)
	move	#62,-(sp)
	trap	#1
	addq.l	#4,sp

	; Load background graphics (wrapped part).
	
	clr		-(sp)
	pea		background_image_filename
	move	#61,-(sp)
	trap	#1
	addq.l	#8,sp

	move	d0,d7

	pea		background_image+256*2*512
	move.l	#256*2*256,-(sp)
	move	d7,-(sp)
	move	#63,-(sp)
	trap	#1
	lea		12(sp),sp

	move	d7,-(sp)
	move	#62,-(sp)
	trap	#1
	addq.l	#4,sp

	; Copy background graphics.

	lea		background_image,a0
	move.l	display_screen_address,a1
	add.l	#SCREEN_DISPLAY_OFFSET,a1
	move.l	work_screen_address,a2
	add.l	#SCREEN_DISPLAY_OFFSET,a2

	move	#512+256-1,d7

.copy_loop1:
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,(a1)
	movem.l	d0-d6/a3-a6,(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4(a1)
	movem.l	d0-d6/a3-a6,11*4(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*2(a1)
	movem.l	d0-d6/a3-a6,11*4*2(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*3(a1)
	movem.l	d0-d6/a3-a6,11*4*3(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*4(a1)
	movem.l	d0-d6/a3-a6,11*4*4(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*5(a1)
	movem.l	d0-d6/a3-a6,11*4*5(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*6(a1)
	movem.l	d0-d6/a3-a6,11*4*6(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*7(a1)
	movem.l	d0-d6/a3-a6,11*4*7(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*8(a1)
	movem.l	d0-d6/a3-a6,11*4*8(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*9(a1)
	movem.l	d0-d6/a3-a6,11*4*9(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*10(a1)
	movem.l	d0-d6/a3-a6,11*4*10(a2)
	movem.l	(a0)+,d0-d6
	movem.l	d0-d6,11*4*11(a1)
	movem.l	d0-d6,11*4*11(a2)

	add.l	#256*2*2,a1
	add.l	#256*2*2,a2

	dbf		d7,.copy_loop1

	move.l	display_screen_address,a0
	add.l	#SCREEN_DISPLAY_OFFSET,a0
	lea		background_image+SCREEN_DISPLAY_OFFSET,a1

	move	#512+256-1,d7

.copy_loop2:
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*2(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*3(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*4(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*5(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*6(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*7(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*8(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*9(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*10(a1)
	movem.l	(a0)+,d0-d6
	movem.l	d0-d6,11*4*11(a1)

	add.l	#256*2,a0
	add.l	#256*2*2,a1

	dbf		d7,.copy_loop2

	; The third screen: as the work screen.

	move.l	work_screen_address,a0
	move.l	spare_screen_address,a1
	move.l	#SCREEN_BUFFER_SIZE/16-1,d7

.copy_loop3:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	subq.l	#1,d7
	bpl.s	.copy_loop3

	; Build color translation table.

	lea		color_translation_table,a0
	clr.l	d0

.color_translation_loop:
	bfextu	d0{16+5:5},d1
	bfextu	d0{16+0:5},d2
	bfextu	d0{16+10:5},d3

	clr		d4

	bfins	d1,d4{16+0:5}
	bfins	d2,d4{16+5:5}
	bfins	d3,d4{16+11:5}

	move	d4,(a0)+

	addq	#1,d0
	bne		.color_translation_loop

	rts

; ------------------------------------------------------------------------------

release_graphics:
	; Free allocated graphics buffer.

	move.l	allocated_screen_address,-(sp)
	move	#73,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

; ------------------------------------------------------------------------------
;
; a0.l = compiled sprites struct address (the field of the drawing entry).
;
; Registers of the drawing code. Each colour has a register of its own for all
; sprites, so that sprites of the same palette can follow one another without
; loading it again (the palette chain, as in F030Arcade's CPS1 tile compiler):
;
; d0       colours 1 (low word) and 2 (high word): "swap d0" for colour 2,
;          and swapped back at the end. Colours 1 and 2 are the rarest.
; d1-d7    colours 3-9
; a0-a5    colours 10-15
; a6       the sprite's list entry on entry, then its screen address
;
; A palette (translated_palettes) holds each colour twice in a long; its
; colour 2 holds colour 1 in its low word. A list entry's palette address
; points at colour 2, so "movem.l (a5),d0-d7/a0-a5" loads them all.
;
; The code has three entries:
;
; partial  loads the colours the sprite uses (struct field + 64).
; full     loads all colours (drawing entry - 8): for a sprite that the next
;          one of the same palette follows.
; drawing  loads none (struct field): the previous sprite had the same palette.
;
; A transparent gap followed by a single pixel is drawn with a displacement,
; "move.w rx,d16(a6)", without moving a6.

convert_sprite_to_drawing_code:
	movem.l	d0-a6,-(sp)

	move.l	free_compiled_objects_address,a2

	tst.b	compiling_characters ; Characters have no palette of their own.
	bne		.drawing_entry

	; The registers of the colours the sprite uses: lowest in d2, highest in d3.

	lea		sprite_colors_count+2,a3 ; Colour 1.
	moveq	#14,d2
	moveq	#-1,d3
	moveq	#1,d0 ; Colour.

.colors_loop:
	tst		(a3)+
	beq.s	.color_not_used

	move	d0,d1
	subq	#2,d1 ; Colour 3 and up: d1, ...
	bpl.s	.register

	moveq	#0,d1 ; Colours 1 and 2: d0.

.register:
	cmp		d1,d2
	ble.s	.not_lowest

	move	d1,d2

.not_lowest:
	cmp		d1,d3
	bge.s	.color_not_used

	move	d1,d3

.color_not_used:
	addq	#1,d0
	cmp		#16,d0
	bne.s	.colors_loop

	; Partial entry.

	move.l	a2,64(a0)

	tst		d3
	bmi.s	.no_colors

	move.l	#$2a6e0004,(a2)+ ; "move.l 4(a6),a5".

	moveq	#-1,d1 ; Registers d2 to d3 (bit 0 = d0).
	addq	#1,d3
	lsl.l	d3,d1
	not.l	d1
	moveq	#-1,d0
	lsl.l	d2,d0
	and		d0,d1

	tst		d2
	bne.s	.displaced_movem

	move	#$4cd5,(a2)+ ; "movem.l (a5),rx-ry".
	move	d1,(a2)+

	bra.s	.no_colors

.displaced_movem:
	move	#$4ced,(a2)+ ; "movem.l x(a5),rx-ry".
	move	d1,(a2)+
	lsl		#2,d2
	move	d2,(a2)+ ; "x".

.no_colors:
	move	#$6008,(a2)+ ; "bra.s" to the drawing entry, over the full one.

	; Full entry.

	move.l	#$2a6e0004,(a2)+ ; "move.l 4(a6),a5".
	move.l	#$4cd53fff,(a2)+ ; "movem.l (a5),d0-d7/a0-a5".

.drawing_entry:
	move.l	a2,(a0)

	move	#$2c56,(a2)+ ; "move.l (a6),a6".

	; Pixels.

	lea		sprite_matrix,a1

	clr		d0 ; Gap offset.
	clr		d1
	clr		d4 ; d0 swapped (colour 2 in its low word).

	move	#16-1,d7

.lines_loop:
	move	#16-1,d6

.pixels_loop:
	move.b	(a1)+,d1
	bne		.process_pixel

	addq	#2,d0

	bra		.next_pixel

.process_pixel:
	move	d1,d3
	subq	#2,d3 ; Register.
	bgt.s	.no_swap

	; Colour 1 or 2: d0, with the colour in its low word.

	moveq	#0,d3
	moveq	#0,d5
	cmp		#2,d1
	seq		d5
	cmp.b	d4,d5
	beq.s	.no_swap

	move	#$4840,(a2)+ ; "swap d0".
	move.b	d5,d4

.no_swap:
	tst		d0
	beq		.draw_pixel

	; After a gap: a single pixel is drawn with a displacement.

	tst		d6
	beq.s	.displaced_pixel ; The last pixel of the line.

	tst.b	(a1)
	bne.s	.move_screen_address ; Not a single pixel.

.displaced_pixel:
	move	d3,d2
	add		#$3d40,d2 ; "move.w rx,x(a6)".
	move	d2,(a2)+
	move	d0,(a2)+ ; "x".
	addq	#2,d0

	bra.s	.next_pixel

.move_screen_address:
	cmp		#8,d0
	ble		.quick_add

	move	#$4dee,(a2)+ ; "lea x(a6),a6".
	move	d0,(a2)+ ; "x".

	bra		.draw_pixel_offset_done

.quick_add:
	and		#$7,d0
	lsl		#8,d0
	add		d0,d0
	add		#$508e,d0 ; "addq.l #x,a6".
	move	d0,(a2)+

.draw_pixel_offset_done:
	clr		d0

.draw_pixel:
	move	d3,d2
	add		#$3cc0,d2 ; "move.w rx,(a6)+".

	tst		d3
	beq.s	.set_draw_color_command ; d0 holds two colours.

	cmp		-2(a2),d2 ; Is the last opcode also "move.w rx,(a6)+"?
	bne		.set_draw_color_command

	sub		#$1000,d2 ; Convert the current opcode to "move.l rx,(a6)+".
	subq.l	#2,a2

.set_draw_color_command:
	move	d2,(a2)+

.next_pixel:
	dbf		d6,.pixels_loop

	add		#(256*2-16)*2,d0

	dbf		d7,.lines_loop

	tst.b	d4
	beq.s	.not_swapped

	move	#$4840,(a2)+ ; "swap d0": colour 1 in d0's low word again.

.not_swapped:
	move	#$4e75,(a2)+ ; "rts".

	move.l	a2,free_compiled_objects_address

	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------
;
; a0.l = compiled sprites struct address.

convert_sprite_to_restore_data:
	movem.l	d0-a6,-(sp)

	move.l	free_compiled_objects_address,a2
	move.l	a2,(a0)
	
	lea		sprite_matrix,a1
	
	clr		d0 ; Pixel offset.
	clr		d1 ; Jump offset.
	
	move	#16-1,d7

.lines_loop:
	move	#16-1,d6
	
.pixels_loop:
	tst.b	(a1)+
	beq		.no_pixel
	
	tst		d1
	bne		.skip_pixel_offset
	
	move	d0,(a2)+
	clr		d0

.skip_pixel_offset:
	subq	#2,d1

	bra		.next_pixel
	
.no_pixel:
	tst		d1
	beq		.skip_jump_offset
	
	move	d1,(a2)+
	clr		d1

.skip_jump_offset:
	addq	#2,d0

.next_pixel:
	dbf		d6,.pixels_loop
	
	tst		d1
	beq		.skip_jump_offset2
	
	move	d1,(a2)+
	clr		d1

.skip_jump_offset2:
	add		#(512-16)*2,d0

	dbf		d7,.lines_loop

	move	#-1,(a2)+
	
	move.l	a2,free_compiled_objects_address
	
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

build_sprite_mask:
	movem.l	d0-a6,-(sp)

	lea		sprite_matrix,a0
	lea		sprite_mask_bitmap,a1

	move	#16-1,d7

.loop:
	clr		d0

	move	#16-1,d6

.loop2:
	tst.b	(a0)+
	beq		.no_pixel

	bset	d6,d0

.no_pixel:
	dbf		d6,.loop2

	move	d0,(a1)+

	dbf		d7,.loop

	; Pack the mask into 11 DSP words (one per long).

	lea		packed_mask,a0
	lea		sprite_mask_bitmap,a1

	rept 5

	move.l	(a1)+,d0
	move	d0,d1
	lsr.l	#8,d0
	move.l	d0,(a0)+
	swap	d1
	move	(a1)+,d1
	move.l	d1,(a0)+

	endr

	move	(a1)+,d0
	lsl.l	#8,d0
	move.l	d0,(a0)+

	; Many sprites share a mask: keep each mask once, and give the sprite
	; the index of its mask (sprite_mask_index).

	lea		packed_mask,a0
	moveq	#0,d0
	moveq	#11-1,d7

.hash:
	move.l	(a0)+,d1
	eor.l	d1,d0
	rol.l	#5,d0
	dbf		d7,.hash

	move	d0,d1
	swap	d0
	eor		d1,d0

	and		#MASK_HASH_SIZE-1,d0
	lea		mask_hash_table,a2 ; Unique index + 1, 0 = empty.

.probe:
	move	(a2,d0.w*2),d5
	beq		.new

	subq	#1,d5
	moveq	#0,d1
	move	d5,d1
	mulu	#11*4,d1
	lea		unique_masks,a3
	add.l	d1,a3
	lea		packed_mask,a0
	moveq	#11-1,d7

.compare:
	cmpm.l	(a0)+,(a3)+
	dbne	d7,.compare
	beq		.found

	addq	#1,d0
	and		#MASK_HASH_SIZE-1,d0
	bra		.probe

.new:
	move	unique_mask_count,d5
	move	d5,d1
	addq	#1,d1
	move	d1,(a2,d0.w*2)

	moveq	#0,d1
	move	d5,d1
	mulu	#11*4,d1
	lea		unique_masks,a3
	add.l	d1,a3
	lea		packed_mask,a0

	rept 11
	move.l	(a0)+,(a3)+
	endr

	addq	#1,unique_mask_count

.found:
	move	d5,sprite_mask_index

	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

; Send the count and the unique masks to the DSP, once all sprites are
; compiled.

send_sprite_masks:
	movem.l	d0-d1/a0-a1,-(sp)

	lea		$ffffa204.w,a0
	lea		unique_masks,a1

	moveq	#0,d0
	move	unique_mask_count,d0

	btst	#1,$ffffa202.w
	beq		*-6
	move.l	d0,(a0)

	mulu	#11,d0
	subq.l	#1,d0

.loop:
	btst	#1,$ffffa202.w
	beq		*-6
	move.l	(a1)+,(a0)
	subq.l	#1,d0
	bpl		.loop

	jsr		send_music_tables

	movem.l	(sp)+,d0-d1/a0-a1

	rts

; ------------------------------------------------------------------------------
;
; d0.l = original sprite data address.
;

compile_sprite:
	movem.l	d0-a6,-(sp)

	; Create sprite matrix and count colors.

	move.l	(sp),a0
	lea		sprite_matrix,a1
	lea		sprite_colors_count+16*2,a2
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)

	move	#16-1,d7

.lines_loop1:
	move.l	(a0)+,d1
	bfextu	d1{0:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{4:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{8:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{12:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{16:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{20:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{24:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{28:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+

	move.l	16*4-4(a0),d1
	bfextu	d1{0:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{4:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{8:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{12:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{16:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{20:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{24:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{28:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+

	dbf		d7,.lines_loop1

	; Sprite mask for the DSP.

	jsr		build_sprite_mask

	; Create normal sprite.

	move.l	(sp),a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	; Create horizontally flipped sprite.

	lea		sprite_matrix,a0

	move	#16-1,d7

.flip_loop1:
	lea		16(a0),a1

	rept 8

	move.b	(a0),d0
	move.b	-(a1),(a0)+
	move.b	d0,(a1)

	endr

	addq.l	#8,a0

	dbf		d7,.flip_loop1

	move.l	(sp),a0
	addq.l	#4,a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	; Create horizontally and vertically flipped sprite.

	lea		sprite_matrix,a0
	lea		15*16(a0),a1

	move	#8-1,d7

.flip_loop2:
	rept 4

	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+

	endr

	sub.l	#16*2,a1

	dbf		d7,.flip_loop2

	move.l	(sp),a0
	add.l	#12,a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	; Create vertically flipped sprite.

	lea		sprite_matrix,a0

	move	#16-1,d7

.flip_loop3:
	lea		16(a0),a1

	rept 8

	move.b	(a0),d0
	move.b	-(a1),(a0)+
	move.b	d0,(a1)

	endr

	addq.l	#8,a0

	dbf		d7,.flip_loop3

	move.l	(sp),a0
	addq.l	#8,a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	addq.l	#8,a0
	move	sprite_mask_index,(a0) ; The DSP knows the sprite by its mask.
	addq	#1,sprite_count

	cmp		#TOTAL_NUMBER_OF_SPRITES,sprite_count
	bne		.not_last

	jsr		send_sprite_masks

.not_last:
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

compile_characters:
	movem.l	d0-a6,-(sp)

	; Reorder character graphics.
	
	move.l	TEXT_GRAPHICS_ADDRESS,a0
	
	clr		d0
	
.reorder_loop:
	lea		text_reorder_buffer,a1

	move	d0,d1
	lsl		#5,d1
	lea		(a0,d1.w),a2

	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	add.l	#16,a2
	
	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	sub.l	#16-1,a2
	
	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	add.l	#16,a2
	
	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	lea		text_reorder_buffer,a1
	sub.l	#16+1,a2

	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	addq	#4,d0
	cmp		#TOTAL_NUMBER_OF_CHARACTERS,d0
	bne		.reorder_loop
	
	; Compile characters: their code has only the drawing entry, as all
	; of them use the text palette, which draw_text loads.

	st		compiling_characters
	move.l	TEXT_GRAPHICS_ADDRESS,-(sp)
	
	move	#TOTAL_NUMBER_OF_CHARACTERS-1,d7
	
.characters_loop:

	; Clear sprite matrix.

	lea		sprite_matrix+16*16,a1

	moveq	#16-1,d6

.clear_loop:
	clr.l	-(a1)
	clr.l	-(a1)
	clr.l	-(a1)
	clr.l	-(a1)

	dbf		d6,.clear_loop

	; Clear color count table.

	lea		sprite_colors_count+16*2,a2
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)

	move.l	(sp),a0

	; Decode character graphics.

	moveq	#8-1,d6

.lines_loop:
	move.b	(a0)+,d3
	move.b	(a0)+,d2
	move.b	(a0)+,d1
	move.b	(a0)+,d0

	move	#8-1,d5

.pixels_loop:
	clr		d4

	add.b	d0,d0
	addx	d4,d4
	add.b	d1,d1
	addx	d4,d4
	add.b	d2,d2
	addx	d4,d4
	add.b	d3,d3
	addx	d4,d4

	addq	#1,(a2,d4.w*2)
	move.b	d4,(a1)+

	dbf		d5,.pixels_loop

	addq.l	#8,a1

	dbf		d6,.lines_loop

	; Create normal sprite.

	move.l	(sp),a0
	jsr		convert_sprite_to_drawing_code
	addq.l	#4,a0
	jsr		convert_sprite_to_restore_data

	add.l	#4*8,(sp)

	dbf		d7,.characters_loop

	sf		compiling_characters
	addq.l	#4,sp
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

prepare_sprite_infos:
	movem.l	d0-a6,-(sp)

	; Sort sprites.

	lea		SPRITE_DATA_TABLE,a0
	move.l	CURRENT_SPRITE_DATA_ENTRY,d7
	sub.l	a0,d7
	beq		.no_sprites

	move.l	d7,(sp) ; Return number of prepared sprites.

	; The slot for this list: an empty one, else the one with the oldest
	; list. A picture reads its list in one go (process_sprite_infos, in
	; the VBL handler or the game's VSYNC wait), so it never reads this one
	; while it is written here: it is not ready meanwhile.

	lea		list_ready,a1
	lea		list_vbls,a2
	moveq	#0,d0 ; The slot.
	moveq	#-1,d3 ; Its list's age in VBLs.
	moveq	#0,d1

.slot:
	tst.b	(a1,d1.w)
	beq.s	.empty_slot

	move	renderer_vbls,d2
	sub		(a2,d1.w*2),d2
	cmp		d3,d2
	ble.s	.next_slot

	move	d2,d3
	move	d1,d0

.next_slot:
	addq	#1,d1
	cmp		#LIST_SLOTS,d1
	bne.s	.slot

	bra.s	.slot_chosen

.empty_slot:
	move	d1,d0

.slot_chosen:
	sf		(a1,d0.w) ; Not ready while it is written.
	move	d0,list_writing
	lea		list_addresses,a3
	move.l	(a3,d0.w*4),a3

	lsr		#3,d7
	move	d7,(a3)+
	beq		.skip_all

	subq	#1,d7

	lea		sort_buffers,a1
	lea		sort_counts+32*2,a2

	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	
	addq.l	#6,a0
	
	clr		d0
	
.sort_loop:
	moveq	#$1f,d1
	and		(a0),d1
	
	move	(a2,d1.w*2),d2
	addq	#1,(a2,d1.w*2)
	swap	d1
	lsr.l	#7,d1
	add		d2,d1
	move	d0,(a1,d1.w*2)

	addq	#1,d0
	addq.l	#8,a0
	
	dbf		d7,.sort_loop

	; Reorder sprite data.

	lea		SPRITE_DATA_TABLE,a0
	
	move	#32-1,d7
	
.reorder_loop:
	move	(a2)+,d6
	beq		.skip_reorder
	
	lea     (a1,d6.w*2),a4
	subq	#1,d6
	
.reorder_loop2:
	move	-(a4),d0
	move.l	(a0,d0.w*8),(a3)+
	move.l	4(a0,d0.w*8),(a3)+

	dbf		d6,.reorder_loop2
	
.skip_reorder:
	lea		512*2(a1),a1

	dbf		d7,.reorder_loop
	
.skip_all:
	; The list is ready, with the VBL it belongs to and the CRTC's Y
	; scroll of the slow graphic layer. A frame without sprites leaves the
	; lists as they are.

	move	list_writing,d0
	lea		list_vbls,a0
	move	renderer_vbls,(a0,d0.w*2)
	lea		list_scrolls,a0
	move	L_00E80000+$22,(a0,d0.w*2)
	lea		list_ready,a0
	st		(a0,d0.w)
	addq	#1,game_list_serial ; A new list for render_idle.

.no_sprites:
	movem.l	(sp)+,d0-a6

	move.l	#SPRITE_DATA_TABLE,CURRENT_SPRITE_DATA_ENTRY

	clr.l	d0

	rts
	
; ------------------------------------------------------------------------------

process_sprite_infos:
	movem.l	d0-a6,-(sp)

	; The picture's list. A picture is shown PICTURE_LATENCY VBLs after the
	; VBL its list was finished in, so the sprites and the background move
	; on screen by as many game steps as VBLs have passed. The list wanted
	; is the one a cadence after the last picture's (every second list at a
	; cadence of 2 VBLs); if the game skipped that VBL, the next one. A list
	; that can no longer be shown in time is passed over for the newest,
	; and the cadence gets slower, as for a late picture (finish_picture).
	; If there is none from the wanted VBL on, the newest again only after a
	; few VBLs (for the text layer, in case the game stops sending sprites).
	; Meanwhile the game gets the time: its VBL routine runs once the
	; renderer returns.

	move	last_list_vbl,d5
	add		picture_wait,d5
	addq	#1,d5 ; The VBL of the list wanted.

	lea		list_ready,a1
	lea		list_vbls,a2
	moveq	#-1,d6 ; The first ready list from the wanted VBL on,
	move	#$7fff,d4 ; VBLs after it;
	moveq	#-1,d3 ; the newest list,
	move	#$7fff,d2 ; its age in VBLs.
	moveq	#LIST_SLOTS-1,d1

.find:
	tst.b	(a1,d1.w)
	beq.s	.find_next

	move	(a2,d1.w*2),d0
	sub		d5,d0
	bmi.s	.newest

	cmp		d4,d0
	bge.s	.newest

	move	d0,d4
	move	d1,d6

.newest:
	move	renderer_vbls,d0
	sub		(a2,d1.w*2),d0
	cmp		d2,d0
	bge.s	.find_next

	move	d0,d2
	move	d1,d3

.find_next:
	dbf		d1,.find

	tst		d3
	bmi		.not_now ; No list yet.

	tst		d6
	bpl.s	.wanted

	; Waiting for the wanted list. If the renderer waits already before
	; the list a faster cadence would take comes, and still when it is
	; there, it has time to spare (see finish_picture).

	tst		picture_wait
	beq.s	.no_spare

	move	(a2,d3.w*2),d0
	sub		last_list_vbl,d0
	cmp		picture_wait,d0
	bge.s	.faster_list

	st		renderer_waiting ; Before the faster cadence's list.

	bra.s	.no_spare

.faster_list:
	tst.b	renderer_waiting
	beq.s	.no_spare

	st		list_waited

.no_spare:
	move	renderer_vbls,d0
	sub		drawn_list_vbl,d0
	cmp		#REDRAW_VBLS,d0
	bcs		.not_now

	move	d3,d6 ; The newest again.

	bra.s	.take

.wanted:
	move	(a2,d6.w*2),d0
	add		#PICTURE_LATENCY,d0
	sub		renderer_vbls,d0
	subq	#1,d0 ; Its VBL less the next one.
	bpl.s	.take

	move	d3,d6 ; Too late: the newest.
	clr		early_pictures

	cmp		#PICTURE_VBLS_MAX-1,picture_wait
	bcc.s	.take

	addq	#1,picture_wait

.take:
	lea		list_addresses,a0
	move.l	(a0,d6.w*4),a0
	move.l	a0,picture_list
	move	(a2,d6.w*2),d0
	move	d0,last_list_vbl
	lea		list_scrolls,a1
	move	(a1,d6.w*2),picture_scroll

	; Due PICTURE_LATENCY VBLs after its list, but not before the next VBL:
	; an old list (the newest again, or the game had none for a while) is
	; due as if it had just come.

	add		#PICTURE_LATENCY,d0
	move	renderer_vbls,d1
	addq	#1,d1
	cmp		d1,d0
	bpl.s	.due_set

	move	renderer_vbls,d0
	add		#PICTURE_LATENCY,d0

.due_set:
	move	d0,picture_due

	clr.l	d7
	move	(a0)+,d7
	bne		.start

	movem.l	(sp)+,d0-a6

	rts

.start:
	move	game_list_serial,drawn_list_serial
	move	renderer_vbls,drawn_list_vbl
	move.b	list_waited,picture_spare
	sf		list_waited
	sf		renderer_waiting

	; Scrolling. Each screen holds the whole background (512 lines and
	; the first 256 again), and the display moves over it: the picture's
	; position is the background line at the sprites' line 0. The work
	; screen still has its last picture, at that picture's position: the
	; restore runs and the old text are taken away there, and the DSP gets
	; the lines the display has moved since (see dsprite.asm).

	move	picture_scroll,d0 ; The X68000 shows line (y + scroll) & 511.
	and		#$1ff,d0
	move	work_background_position,d1 ; Of the work screen's last picture.
	move	d0,work_background_position

	move	d0,d2
	sub		d1,d2
	move	d2,dsp_scroll_offset

	swap	d0
	clr		d0
	lsr.l	#6,d0 ; * 256*2*2
	swap	d1
	clr		d1
	lsr.l	#6,d1

	move.l	d1,d2
	sub.l	d0,d2
	move.l	d2,text_move ; From a cell's address to where it was drawn.

	move.l	work_screen_address,a2
	lea		(a2,d1.l),a5
	move.l	a5,restore_screen_address
	add.l	#background_image,d1
	move.l	d1,restore_background_address
	sf		restore_more

	move.l	SPRITE_DATA_ADDRESS,a1

	add.l	d0,a2

	lea		translated_palettes,a3
	move.l	work_sprite_infos_address_new,a4
	lea		$ffffa204+2.w,a6

	; The text lines with characters (bit 31 = line 0): the sprites that
	; touch them mark their cells for prepare_text.

	lea		text_bitmaps+32*4,a5
	moveq	#0,d6
	moveq	#32-1,d4

.text_lines:
	add.l	d6,d6
	tst.l	(a5)+
	beq.s	.no_text

	addq.l	#1,d6

.no_text:
	dbf		d4,.text_lines

	tst.l	d6
	beq.s	.covered

	move.l	a0,a5
	move	d7,d5
	subq	#1,d5

.cover_sprite:
	move	(a5),d0 ; X.
	move	2(a5),d1 ; Y.
	addq.l	#8,a5

	and		#$1ff,d1
	move.l	(cell_span.l,d1.w*4),d4
	and.l	d6,d4 ; Text lines the sprite touches.
	beq.s	.next_cover

	and		#$1ff,d0
	move.l	(cell_span.l,d0.w*4),d1 ; Its cells in a line.
	beq.s	.next_cover

.cover_line:
	bfffo	d4{0:32},d2
	moveq	#31,d3
	sub		d2,d3
	bclr	d3,d4
	or.l	d1,(text_cover.l,d2.w*4)

	tst.l	d4
	bne.s	.cover_line

.next_cover:
	dbf		d5,.cover_sprite

.covered:
	; The DSP may still be drawing the masks of the last list (draw_masks
	; in dsprite.asm) before it takes the next one. The palettes and the
	; text lists need no DSP: the 68030 does them meanwhile, and the rest
	; after the list once the DSP is ready (d5: bit 0 palettes, bit 1 text).

	moveq	#0,d5

	btst	#3,$ffffa202.w ; HF2: the DSP waits for a packet.
	bne.s	.dsp_ready

	jsr		translate_palettes
	bset	#0,d5

	btst	#3,$ffffa202.w
	bne.s	.dsp_ready

	jsr		prepare_text
	bset	#1,d5

	btst	#3,$ffffa202.w
	beq		*-6

.dsp_ready:

	jsr		send_music_packet ; Masks the VBL for its own packets.

	; The DSP renders no music during a transfer, which the 68030 paces: no
	; VBL in between when render_idle sends (the VBL handler already runs
	; at level 4).

	move	sr,-(sp)
	btst	#2,(sp)
	bne.s	.masked

	ori		#$0400,sr

.masked:
	move.l	d7,$ffffa204.w ; Send number of sprite infos to be sent to the DSP.

	btst	#2,$ffffa202.w ; TRDY: it has taken the count.
	beq		*-6

	move	dsp_scroll_offset,d0
	ext.l	d0
	move.l	d0,$ffffa204.w ; Scrolling offset -> DSP (24 bits, signed).

	subq	#1,d7

	; The list goes to the DSP first, in a loop of its own, so that the DSP
	; cuts the sprites out of its restore mask while the 68030 works out
	; the addresses, clears the text and draws: the runs are then ready
	; sooner. TXDE before each word, as this loop may outpace the DSP.

	move	d7,d4

.send:
	movem	(a0)+,d0-d3
	ext.l	d2
	lsl.l	#2+3+2,d2
	and		#$c000,d3
	or		32(a1,d2.l),d3

	btst	#1,$ffffa202.w
	beq.s	*-6
	move	d3,(a6) ; Flip info + mask index -> DSP.
	btst	#1,$ffffa202.w
	beq.s	*-6
	move	d0,(a6) ; X position -> DSP.
	btst	#1,$ffffa202.w
	beq.s	*-6
	move	d1,(a6) ; Y position -> DSP.

	dbf		d4,.send

	move	(sp)+,sr ; The transfer is over: the VBL may come again.

	move.l	picture_list,a0
	addq.l	#2,a0

	; The drawing entry of each sprite (see convert_sprite_to_drawing_code):
	; one that follows a sprite of the same palette loads no colours, and
	; that sprite then loads all of them; any other loads its own.

	suba.l	a6,a6 ; The previous sprite's drawing entry (none).

.loop:
	movem	(a0)+,d0-d3

	lea		(a2,d0.w*2),a5
	swap	d1
	clr		d1
	lsr.l	#6,d1
	add.l	d1,a5
	move.l	a5,(a4)+ ; Screen address.

	move	d3,d1
	lsr		#4,d1
	and		#$f0,d1
	lea		8(a3,d1.w*4),a5 ; Colour 2 (see convert_sprite_to_drawing_code).
	move.l	a5,(a4)+ ; Palette address.
	move.l	a5,d1

	ext.l	d2
	lsl.l	#2+3+2,d2
	lea		(a1,d2.l),a5 ; Sprite data.

	rol		#2,d3
	and		#$3,d3
	lea		(a5,d3.w*4),a5
	move.l	(a5),d2 ; Its drawing entry.

	move.l	a6,d4
	beq.s	.own_colours ; The first sprite.

	cmp.l	-24+4(a4),d1 ; a4: this entry + 8.
	bne.s	.own_colours ; Another palette than the previous sprite's.

	cmp.l	-24+8(a4),d4
	beq.s	.chained ; The previous sprite follows one of the same palette.

	subq.l	#8,d4 ; It loads all colours.
	move.l	d4,-24+8(a4)

.chained:
	move.l	d2,(a4)+ ; Sprite draw address: no colours.

	bra.s	.entry_set

.own_colours:
	move.l	64(a5),(a4)+ ; Sprite draw address: its colours.

.entry_set:
	move.l	d2,a6
	move.l	16(a5),(a4)+ ; Sprite restore address.

	dbf		d7,.loop

	; draw_sprites draws a group of sprites between its checks: fill the
	; last group with entries that draw nothing.

	move.l	a4,d0
	sub.l	work_sprite_infos_address_new,d0
	lsr.l	#4,d0
	neg		d0
	and		#SPRITE_GROUP-1,d0
	bra.s	.next_filler

.filler:
	move.l	a4,(a4)+ ; Screen address: not 0, which ends the list.
	move.l	a4,(a4)+
	move.l	#no_sprite,(a4)+
	move.l	#no_sprite,(a4)+

.next_filler:
	dbf		d0,.filler

	clr.l	(a4) ; End marker.

	btst	#0,d5
	bne.s	.palettes_done

	jsr		translate_palettes

.palettes_done:
	btst	#1,d5
	bne.s	.text_done

	jsr		prepare_text

.text_done:
	movem.l	(sp)+,d0-a6

	bra		clear_text

.not_now:
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

translate_palettes:
;	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES-60,$fffffa21.w
;	bcc		.start_translating
	
;	move.l	#translate_palettes,next_graphics_routine
	
;	rts

;.start_translating:
	movem.l	d0-a6,-(sp)

	; Only the palettes of 16 colours that the game has changed since the
	; last translation (the translation table is fixed after
	; initialize_graphics): the game changes some of them every frame, and
	; translating all 256 colours cost about 10k cycles a picture.

	lea		L_00E82000+$200,a0
	lea		translated_palette_source,a3
	lea		color_translation_table,a1
	lea		translated_palettes,a2

	clr.l	d0
	moveq	#16-1,d7

	tst.b	palette_translated
	beq.s	.translate ; The first time: all of them.

	; Colour 0 is transparent: no drawing code uses it. In the attract
	; demo the game changes colour 1 of most palettes every frame and
	; little else, so colour 1 is translated on its own.

.palette:
	move	2(a0),d0 ; Colour 1.
	cmp		2(a3),d0
	beq.s	.colours_2_15

	move	d0,2(a3)
	move	(a1,d0.l*2),d1
	move	d1,4(a2) ; Colour 1's own long, as .translate writes it,
	move	d1,6(a2)
	move	d1,2*4+2(a2) ; and colour 2's low word, which d0 uses (see below).

.colours_2_15:
	lea		2*2(a0),a4
	lea		2*2(a3),a5
	moveq	#14*2/4-1,d6

.compare:
	cmpm.l	(a4)+,(a5)+
	dbne	d6,.compare
	bne.s	.translate

	lea		16*2(a0),a0 ; Unchanged.
	lea		16*2(a3),a3
	lea		16*4(a2),a2

	dbf		d7,.palette

	bra		.done

.translate:
	rept 16

	move	(a0)+,d0
	move	d0,(a3)+
	move	(a1,d0.l*2),d1
	move	d1,(a2)+
	move	d1,(a2)+

	endr

	; Colour 2 holds colour 1 in its low word: the drawing code has d0
	; for both (see convert_sprite_to_drawing_code).

	move	-16*4+4(a2),-16*4+2*4+2(a2)

	tst.b	palette_translated
	beq.s	.next_palette

	dbf		d7,.palette

	bra.s	.done

.next_palette:
	dbf		d7,.translate

.done:
	st		palette_translated

	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

; The first stage that draws. The work screen is never the one on display
; (see finish_picture).

clear_text:
	movem.l	d0-a6,-(sp)

	lea		text_restores,a3

	bra		.start

.loop:
	move.l	d0,a2
	move.l	(a3)+,a1
	move.l	(a3)+,a0
	
	bra		.jump
	
.sprite_loop:
	add		d0,a1
	add		d0,a2
	
	move	(a0)+,d0
	jmp		.jump(pc,d0.w)

	rept 16

	move	(a1)+,(a2)+
	
	endr

.jump:
	move	(a0)+,d0
	bpl		.sprite_loop
	
.start:
	tst		raster_stages_left
	bgt		.start2

	move.l	a3,next_text_infos_address
	move.l	#.resume,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.resume:
	movem.l	d0-a6,-(sp)

	move.l	next_text_infos_address,a3
	
.start2:
	move.l	(a3)+,d0
	bne		.loop

	movem.l	(sp)+,d0-a6

	bra		draw_sprites
	
; ------------------------------------------------------------------------------

; The drawing code gets its list entry in a6, and the loop keeps the colour
; registers d0-d7/a0-a5 for the next sprite (see convert_sprite_to_drawing_code).
; A sprite may load no colours, so they are loaded here at the start of each
; stage.

draw_sprites:
	movem.l	d0-a6,-(sp)

	move.l	next_sprite_infos_address,a6

	tst.l	(a6)
	beq		.end

	move.l	4(a6),a5
	movem.l	(a5),d0-d7/a0-a5

.loop:
	rept SPRITE_GROUP ; The list has whole groups (process_sprite_infos).

	move.l	a6,-(sp)
	jsr		([8,a6])
	move.l	(sp)+,a6
	lea		16(a6),a6

	endr

	tst		raster_stages_left ; Once a group: after each sprite, the
	bgt		.start ; check cost about 40 cycles, mostly cache misses.
	
	move.l	a6,next_sprite_infos_address
	move.l	#draw_sprites,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.start:
	tst.l	(a6)
	bne		.loop

.end:

;	move.l	work_sprite_infos_address_old,d0 ; Fixme!
;	move.l	work_sprite_infos_address_new,work_sprite_infos_address_old
;	move.l	d0,work_sprite_infos_address_new

	movem.l	(sp)+,d0-a6

	move.l	#sprite_infos3,next_sprite_infos_address

	bra		clear_sprites_dsp

; ------------------------------------------------------------------------------

clear_sprites_dsp:
	movem.l	d0-a6,-(sp)

	move.l	work_sprite_infos_address_new,a0	
	tst.l	(a0)
	beq		.skip

.wait_for_dsp_loop:
	btst	#0,$ffffa202.w ; The DSP has sent the run count.
	bne		.start

	tst		raster_stages_left
	bgt		.wait_for_dsp_loop
	
	move.l	#clear_sprites_dsp,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.start:
	lea		$ffffa204+2.w,a1
	move.l	restore_background_address,a2
	move.l	restore_screen_address,a3

	move	(a1),d0 ; RLE count; bit 15: the DSP sends another list after
	bclr	#15,d0 ; this one (for a picture with very many runs).
	sne		restore_more

	; Restore now if the runs (about 16 a line) fit into the display lines
	; left before the throttle line. Read Timer B's count before the stage:
	; an interrupt in between then makes the estimate short, not long.

	moveq	#0,d1
	move.b	$fffffa21.w,d1 ; Events left in this stage.
	move	raster_stages_left,d2
	ble		.defer_rle

	move	raster_interrupts,d3
	cmp		raster_stages,d3
	bcs.s	.before_throttle

	; Past the throttle line, on render_idle's budget: Timer B counts
	; towards an event behind the VBL, so take the events left in the
	; frame, as the runs must not hold the VBL off.

	addq	#1,d3
	mulu	#SPRITE_THROTTLE_DISPLAY_LINES,d3
	sub		d1,d3 ; Events since the VBL.
	move	frame_events,d2
	sub		d3,d2
	bgt.s	.events_left

	bra.s	.defer_rle

.before_throttle:
	subq	#1,d2
	mulu	#SPRITE_THROTTLE_DISPLAY_LINES,d2
	add		d1,d2

.events_left:
	move	raster_stages,d1
	subq	#1,d1
	lsr		d1,d2 ; Display lines left (two events a line when doubled).

	move	d0,d1
	lsr		#4,d1
	cmp		d2,d1
	bcs		.send_runs

.defer_rle:
	st		runs_wait_vbl ; Not from render_idle before the VBL.
	move.l	#.clear_sprites_dsp2,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.clear_sprites_dsp2:
	movem.l	d0-a6,-(sp)

	lea		$ffffa204+2.w,a1
	move.l	restore_background_address,a2
	move.l	restore_screen_address,a3

.send_runs:
	jsr		send_music_packet ; The DSP takes music while it waits for HF1.

	move	sr,transfer_sr ; No VBL during the transfer (see process_sprite_infos);
	st		transfer_masked ; .skip restores the level.
	btst	#2,transfer_sr
	bne.s	.masked

	ori		#$0400,sr

.masked:
	bset	#4,$ffffa200.w ; HF1: the DSP may send the runs now; it
	btst	#0,$ffffa202.w ; renders no music while it does, so after the
	beq		*-6 ; first word they come without polling.

	bra		.rle_loop

	; Even-length runs jump into this block and finish at the BRA.W.
	; RLE_LONG_EVEN_BIAS in dsprite.asm must match the distance from
	; the branch to .rle_loop (the odd-run block plus the BRA.W).

	rept (16+256+16)/2

	move.l	(a2)+,(a3)+

	endr

	bra.w	.rle_loop

	; Odd-length runs jump into this block and finish with one word.

	rept (16+256+16-1)/2

	move.l	(a2)+,(a3)+

	endr

	move	(a2)+,(a3)+

	; Offsets are 0..$7fff bytes (the DSP splits longer gaps), so they
	; are read as words. The terminal run's displacement of 12 lands on
	; .skip, right behind this loop.

.rle_loop:
	move	(a1),d0
	adda.w	d0,a2
	adda.w	d0,a3

	move	(a1),d1

	jmp		.rle_loop(pc,d1.w)

.skip:
	bclr	#4,$ffffa200.w

	tst.b	transfer_masked
	beq.s	.unmasked

	sf		transfer_masked
	move	transfer_sr,sr

.unmasked:
	tst.b	restore_more
	beq.s	.restored

	sf		restore_more ; The next list goes on where this one ended.
	move.l	a2,restore_background_address
	move.l	a3,restore_screen_address

	bra		.wait_for_dsp_loop

.restored:
	move.l	work_sprite_infos_address_new,a0	
	clr.l	(a0)
	
	movem.l	(sp)+,d0-a6

	bra		draw_text

; ------------------------------------------------------------------------------

prepare_text:
	movem.l	d0-a6,-(sp)

	; The text work of this picture, from what the work screen shows
	; (its text state) and what the game wants now, as two lists: the
	; characters to restore (text_restores: clear_text, before the sprites)
	; and those to draw (text_draws: draw_text, after the restore runs). A
	; cell whose character has changed gets the old one restored and the
	; new one drawn. An unchanged cell is drawn again only if sprites touch
	; it: those of this picture, or those of the screen's last picture,
	; which the restore runs take away together with the character's pixels
	; on them. All other text stays as it is on the screen.
	;
	; The text does not scroll, so when the display has moved over the
	; screen since its last picture (text_move), every character shown is
	; restored where it was drawn and every character wanted is drawn at
	; its new place (.moved_line): while the background scrolls, that is
	; every picture.
	;
	; process_sprite_infos marks the cells by the sprites' coordinates.
	;
	; d0 the line's cells still to do, d1 the cells sprites touch, d2 the
	; wanted cells, d3 the shown cells (bit 31 = the left cell; bfffo's
	; offset is the cell), d4/d5 the shown/wanted character, d6 the cell,
	; d7 its screen address. a2 and a4 the draw and restore lists; the
	; font goes through TEXT_GRAPHICS_ADDRESS: per character its drawing
	; code and its restore data.

	lea		text_bitmaps+32*4,a0 ; The cells with a character, per line.
	lea		text_matrix,a1
	move.l	work_text_state_address,a3
	lea		TEXT_STATE_LINES(a3),a6
	lea		text_restores,a4
	lea		text_draws,a2
	move.l	work_screen_address,a5
	move.l	#background_image,d7
	sub.l	a5,d7 ; From a screen address to the background's.
	move.l	d7,text_background_offset
	add.l	#SCREEN_DISPLAY_OFFSET,a5
	moveq	#0,d0
	move	work_background_position,d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	d0,a5

	tst.l	text_move
	bne		.moved_line

.line:
	move.l	(a0),d2 ; Wanted.
	move.l	text_cover-text_bitmaps-32*4(a0),d1
	clr.l	text_cover-text_bitmaps-32*4(a0)
	move.l	4(a6),d0
	move.l	d1,4(a6) ; For this screen's next picture.
	or.l	d0,d1 ; Touched by sprites.
	move.l	(a6),d3 ; Shown.
	move.l	d2,d0
	or.l	d3,d0
	beq.s	.next_line

.cell:
	bfffo	d0{0:32},d6
	bfclr	d0{d6:1}

	moveq	#0,d4
	move.b	(a3,d6.w),d4 ; Shown (0: none).
	moveq	#0,d5
	bftst	d2{d6:1}
	beq.s	.compare

	move.b	(a1,d6.w),d5 ; Wanted.

.compare:
	move.l	d6,d7
	lsl.l	#4,d7 ; 8 pixels a cell.
	add.l	a5,d7

	cmp.b	d4,d5
	bne.s	.changed

	bftst	d1{d6:1}
	beq.s	.next_cell

	lsl		#5,d5
	beq.s	.next_cell

	move.l	d7,(a2)+ ; Draw it again.
	move.l	([TEXT_GRAPHICS_ADDRESS],d5.w),(a2)+

	bra.s	.next_cell

.changed:
	move.b	d5,(a3,d6.w)
	bfclr	d3{d6:1}

	lsl		#5,d4
	beq.s	.changed_draw

	move.l	d7,(a4)+ ; Restore the old one.
	move.l	text_background_offset,(a4)
	add.l	d7,(a4)+
	move.l	([TEXT_GRAPHICS_ADDRESS],d4.w,4),(a4)+

.changed_draw:
	lsl		#5,d5
	beq.s	.next_cell

	bfset	d3{d6:1}

	move.l	d7,(a2)+ ; Draw the new one.
	move.l	([TEXT_GRAPHICS_ADDRESS],d5.w),(a2)+

.next_cell:
	tst.l	d0
	bne.s	.cell

	move.l	d3,(a6)

.next_line:
	lea		32(a1),a1
	lea		32(a3),a3
	lea		256*2*2*8(a5),a5
	addq.l	#4,a0
	addq.l	#8,a6

	cmp.l	#text_bitmaps+2*32*4,a0
	bne		.line

	bra		.end

.moved_line:
	move.l	(a0),d2 ; Wanted.
	move.l	text_cover-text_bitmaps-32*4(a0),d1
	clr.l	text_cover-text_bitmaps-32*4(a0)
	move.l	d1,4(a6) ; For this screen's next picture.
	move.l	(a6),d3 ; Shown.
	move.l	d2,d0
	or.l	d3,d0
	beq.s	.moved_next_line

.moved_cell:
	bfffo	d0{0:32},d6
	bfclr	d0{d6:1}

	moveq	#0,d4
	move.b	(a3,d6.w),d4 ; Shown (0: none).
	moveq	#0,d5
	bftst	d2{d6:1}
	beq.s	.moved_wanted

	move.b	(a1,d6.w),d5 ; Wanted.

.moved_wanted:
	move.b	d5,(a3,d6.w)
	bfclr	d3{d6:1}

	move.l	d6,d7
	lsl.l	#4,d7 ; 8 pixels a cell.
	add.l	a5,d7

	lsl		#5,d4
	beq.s	.moved_draw

	move.l	d7,d1 ; The touched cells are not needed here.
	add.l	text_move,d1
	move.l	d1,(a4)+ ; Restore it where it was.
	add.l	text_background_offset,d1
	move.l	d1,(a4)+
	move.l	([TEXT_GRAPHICS_ADDRESS],d4.w,4),(a4)+

.moved_draw:
	lsl		#5,d5
	beq.s	.moved_next_cell

	bfset	d3{d6:1}

	move.l	d7,(a2)+ ; Draw it here.
	move.l	([TEXT_GRAPHICS_ADDRESS],d5.w),(a2)+

.moved_next_cell:
	tst.l	d0
	bne.s	.moved_cell

	move.l	d3,(a6)

.moved_next_line:
	lea		32(a1),a1
	lea		32(a3),a3
	lea		256*2*2*8(a5),a5
	addq.l	#4,a0
	addq.l	#8,a6

	cmp.l	#text_bitmaps+2*32*4,a0
	bne		.moved_line

.end:
	clr.l	(a4) ; End markers.
	clr.l	(a2)

	movem.l	(sp)+,d0-a6

	rts

no_sprite: ; Draw routine of an entry that fills draw_sprites' last group.
	rts

; The text cells a sprite's 16 pixels touch, for each X or Y (sprite
; coordinates: 16 is the display's left or top edge).

build_cell_span:
	movem.l	d0-d4/a0,-(sp)

	lea		cell_span,a0
	moveq	#0,d0

.loop:
	move	d0,d1
	sub		#16,d1
	asr		#3,d1 ; First cell.
	bpl.s	.first_ok

	moveq	#0,d1

.first_ok:
	move	d0,d2
	subq	#1,d2
	asr		#3,d2 ; Last cell.

	moveq	#0,d3
	tst		d2
	bmi.s	.store

	cmp		#31,d1
	bgt.s	.store

	cmp		#31,d2
	ble.s	.last_ok

	moveq	#31,d2

.last_ok:
	moveq	#-1,d3
	lsr.l	d1,d3
	moveq	#-1,d4
	addq	#1,d2
	lsr.l	d2,d4
	not.l	d4
	and.l	d4,d3

.store:
	move.l	d3,(a0)+

	addq	#1,d0
	cmp		#512,d0
	bne.s	.loop

	movem.l	(sp)+,d0-d4/a0

	rts
	
; ------------------------------------------------------------------------------

; The characters use the text palette (palette 0), loaded once a stage.

draw_text:
	movem.l	d0-a6,-(sp)

	lea		text_draws,a6

.colours:
	lea		translated_palettes+2*4,a5 ; Colour 2 (see convert_sprite_to_drawing_code).
	movem.l	(a5),d0-d7/a0-a5

.loop:
	tst.l	(a6)
	beq		.end

	move.l	a6,-(sp) ; The entry: screen address, drawing code.
	jsr		([4,a6])
	move.l	(sp)+,a6
	addq.l	#8,a6

	tst		raster_stages_left
	bgt		.loop
	
	move.l	a6,next_text_infos_address

	move.l	#.resume,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.resume:
	movem.l	d0-a6,-(sp)

	move.l	next_text_infos_address,a6

	bra		.colours

.end:
	movem.l	(sp)+,d0-a6

	bra		finish_picture

; ------------------------------------------------------------------------------
;
; The picture is drawn: show it at its VBL, picture_due, PICTURE_LATENCY VBLs
; after the VBL its list was finished in (process_sprite_infos). So the sprites
; and the scrolling move on the display by as many game steps as VBLs have
; passed, and evenly if the pictures also follow each other at the same
; distance: picture_wait + 1 is that cadence in VBLs, the distance between the
; lists the pictures take.
;
; A picture that is late for its VBL is shown at the next one and makes the
; cadence slower by one VBL. One that is ready early is held (flip_held) until
; the VBL handler shows it at its VBL (show_held_picture), and PICTURE_EARLY of
; them in a row make the cadence faster again, from the next list on.
;
; Three screens: the picture is queued (flip_pending until the VBL shows it,
; or flip_held), and the next one is drawn into the third screen meanwhile
; (rotate_screens). A picture that is finished while another one is queued
; waits here for that one's VBL: only then is the screen it leaves free.
;
; No VBL in between: renderer_vbls must not change here, and the VBL handler
; reads show_picture's address.

finish_picture:
	tst.b	flip_pending ; The queued picture is not on display yet.
	bne.s	.queue_busy
	tst.b	flip_held
	beq.s	.queue_free

.queue_busy:
	move.l	#finish_picture,next_graphics_routine

	rts

.queue_free:
	move.l	d0,-(sp)
	move	sr,-(sp)
	ori		#$0700,sr

	move	renderer_vbls,d0
	addq	#1,d0 ; The VBL that would show the picture.
	sub		picture_due,d0
	bmi.s	.early
	bne.s	.late

	; In time. At a slower cadence the picture's list comes about when the
	; last picture is shown, so it is seldom early: that the renderer
	; waited while the list for a faster cadence was there counts as early
	; too (process_sprite_infos).

	tst.b	picture_spare
	bne.s	.early

	clr		early_pictures

	bra.s	.show

.late:
	clr		early_pictures

	cmp		#PICTURE_VBLS_MAX-1,picture_wait
	bcc.s	.show

	addq	#1,picture_wait ; Late: slower by one VBL.

	bra.s	.show

.early:
	; The slower the cadence, the fewer early pictures it takes (a quarter
	; of them at 3 VBLs, an eighth at 4), as they are further apart. The
	; pictures keep to their lists' VBLs, so a faster cadence changes how
	; often the display moves, not how far it moves in a VBL.

	addq	#1,early_pictures

	cmp		#2,picture_wait
	bcs.s	.one_more
	beq.s	.two_more

	cmp		#PICTURE_EARLY/8,early_pictures
	bra.s	.counted

.two_more:
	cmp		#PICTURE_EARLY/4,early_pictures
	bra.s	.counted

.one_more:
	cmp		#PICTURE_EARLY,early_pictures

.counted:
	bcs.s	.counted_done

	clr		early_pictures

	tst		picture_wait
	beq.s	.counted_done

	subq	#1,picture_wait ; Faster by one VBL, from the next list on.

.counted_done:
	tst		d0
	bpl.s	.show ; In time.

	move	picture_due,queued_due
	bsr		rotate_screens
	st		flip_held

	move	(sp)+,sr
	move.l	(sp)+,d0

	rts

.show:
	bsr		rotate_screens
	bsr		show_picture

	move	(sp)+,sr
	move.l	(sp)+,d0

	rts

; Called by the VBL handler before it sets the display address: show the held
; picture if this is its VBL. The work screen is then free at once.

show_held_picture:
	tst.b	flip_held
	beq.s	.done

	move.l	d0,-(sp)

	move	renderer_vbls,d0
	addq	#1,d0 ; This VBL (restart_raster_throttle counts it later).
	sub		queued_due,d0
	bmi.s	.wait

	sf		flip_held

	bsr		show_picture

.wait:
	move.l	(sp)+,d0

.done:
	rts

; ------------------------------------------------------------------------------

; The work screen's picture is drawn: it becomes the display screen, the
; queued one, and the next picture goes into the spare screen. The screen that
; was the display screen is still on display (or about to be) and becomes the
; spare one: it is free once the queued picture is shown, which finish_picture
; waits for before it rotates again.

rotate_screens:
	move.l	d0,-(sp)

	move.l	work_screen_address,d0
	move.l	spare_screen_address,work_screen_address
	move.l	display_screen_address,spare_screen_address
	move.l	d0,display_screen_address

	move	work_background_position,d0
	move	spare_background_position,work_background_position
	move	display_background_position,spare_background_position
	move	d0,display_background_position

	move.l	work_text_state_address,d0
	move.l	spare_text_state_address,work_text_state_address
	move.l	display_text_state_address,spare_text_state_address
	move.l	d0,display_text_state_address

	move.l	(sp)+,d0

	move.l	#process_sprite_infos,next_graphics_routine

	rts

; The display screen's picture goes to the Videl at the next VBL.

show_picture:
	movem.l	d0-d1,-(sp)

	move	display_background_position,d0
	move.l	display_screen_address,d1
	add.l	#SCREEN_DISPLAY_OFFSET,d1
	swap	d0
	clr		d0
	lsr.l	#6,d0
	add.l	d0,d1
	move.l	d1,display_window_address
	st		flip_pending ; After the address: the VBL handler clears it.

	movem.l	(sp)+,d0-d1

	rts

; ------------------------------------------------------------------------------

clear_sprites:
	movem.l	d0-a6,-(sp)

	move.l	work_sprite_infos_address_old,a3
	lea		background_image,a4
	move.l	work_screen_address,d1
	
	bra		.start

.loop:
	addq.l	#8,a3
	move.l	(a3)+,a0
	
	move.l	d0,a2
	sub.l	d1,d0
	lea		(a4,d0.l),a1

	bra		.jump
	
.sprite_loop:
	add		d0,a1
	add		d0,a2
	
	move	(a0)+,d0
	jmp		.jump(pc,d0.w)

	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+

.jump:
	move	(a0)+,d0
	bpl		.sprite_loop
	
.start:
	move.l	(a3)+,d0
	bne		.loop

	move.l	work_sprite_infos_address_old,a0	
	clr.l	(a0)
	
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

graphics_engine:
	move.l	next_graphics_routine,-(sp)
	rts

; From the game's VSYNC wait (sz2.s XSP_VSYNC): go on with the picture while
; the game has nothing else to do, if one is in progress or the game has a new
; sprite list. The VBL handler leaves the renderer and the host port alone
; meanwhile (renderer_lock). Past the throttle line the stages get one stage
; of budget, which lasts until the VBL restarts the throttle: from then on
; they stop at the throttle line as they would in the VBL handler, while the
; game waits for that anyway.

render_idle:
	move.l	d0,-(sp)

	tst.b	runs_wait_vbl ; The restore runs wait for the next frame.
	bne.s	.done

	; A new picture may start while the last one waits for its VBL: it
	; goes into the third screen (see finish_picture).

	cmp.l	#process_sprite_infos,next_graphics_routine
	bne.s	.work ; A picture in progress.

	move	game_list_serial,d0
	cmp		drawn_list_serial,d0
	beq.s	.done ; Nothing new from the game.

.work:
	st		renderer_lock

	tst		raster_stages_left
	bgt.s	.budget

	move	#1,raster_stages_left

.budget:
	jsr		graphics_engine

	sf		renderer_lock

.done:
	move.l	(sp)+,d0

	rts

; ------------------------------------------------------------------------------
;
; Called by the VBL handler. The graphics stages yield once the display has
; reached SPRITE_THROTTLE_DISPLAY_LINES, so that the game keeps the rest of the
; frame. Timer B counts these lines in event count mode and interrupts every
; SPRITE_THROTTLE_DISPLAY_LINES events; the handler decrements
; raster_stages_left, and the stages yield when it is no longer positive.
;
; A line-doubled VGA mode shows each line twice, so Timer B may count two events
; per display line there (Hatari's Falcon timing counts one). raster_stages is
; therefore set from the events of the previous frame: about 240 means one
; stage, about 480 two. No events arrive during the vertical blank, so Timer B
; and raster_stages_left are stable here.
;

restart_raster_throttle:
	movem.l	d0-d1,-(sp)

	addq	#1,renderer_vbls

	move	raster_interrupts,d0 ; Timer B interrupts in the last frame.
	clr		raster_interrupts
	mulu	#SPRITE_THROTTLE_DISPLAY_LINES,d0
	add		#SPRITE_THROTTLE_DISPLAY_LINES,d0
	moveq	#0,d1
	move.b	$fffffa21.w,d1
	sub		d1,d0 ; Timer B events in the last frame.

	cmp		#300,d0
	bcs		.single_events

	cmp		#420,d0
	bcs		.restart ; In between (a late VBL): keep the current setting.

	move	#2,raster_stages
	move	d0,frame_events

	bra		.restart

.single_events:
	move	#1,raster_stages
	move	d0,frame_events

.restart:
	sf		runs_wait_vbl ; The deferred restore runs may go now.
	move	raster_stages,raster_stages_left

	clr.b	$fffffa1b.w
	move.b	#SPRITE_THROTTLE_DISPLAY_LINES,$fffffa21.w
	move.b	#8,$fffffa1b.w

	movem.l	(sp)+,d0-d1

	rts

; ------------------------------------------------------------------------------

draw_text_slow:
	movem.l	d0-a6,-(sp)

	lea		text_bitmaps,a0
	lea		L_00E00000,a1
	move.l	work_screen_address,a2
	add.l	#SCREEN_DISPLAY_OFFSET,a2
	lea		translated_palettes,a3

	move	#32-1,d7

.text_lines_loop:
	move.l	(a0),d0
	beq		.skip_text_line	

	move	#32-1,d6

.characters_loop:
	add.l	d0,d0
	bcc		.skip_character

	move	#8-1,d5

.lines_loop:
	move.l	a1,a4
	move.b	(a4),d1
	swap	d1

	add.l	#$20000,a4
	move.b	(a4),d1
	swap	d1

	add.l	#$20000,a4
	move.b	(a4),d2
	swap	d2

	add.l	#$20000,a4
	move.b	(a4),d2
	swap	d2

	move.l	a2,a4

	move	#8-1,d4

.pixels_loop:
	clr		d3

	swap	d2
	add.b	d2,d2
	addx	d3,d3
	swap	d2
	add.b	d2,d2
	addx	d3,d3
	swap	d1
	add.b	d1,d1
	addx	d3,d3
	swap	d1
	add.b	d1,d1
	addx	d3,d3
	beq		.skip_pixel

	move	(a3,d3.w*4),(a4)

.skip_pixel:
	addq.l	#2,a4

	dbf		d4,.pixels_loop

	add.l	#128,a1
	add.l	#256*2*2,a2

	dbf		d5,.lines_loop

	sub.l	#128*8,a1
	sub.l	#256*2*2*8,a2

.skip_character:
	addq.l	#1,a1
	add.l	#8*2,a2

	dbf		d6,.characters_loop

	add.l	#128*8-32,a1
	add.l	#256*2*2*8-256*2,a2

	bra		.next_text_line

.skip_text_line:
	add.l	#128*8,a1
	add.l	#256*2*2*8,a2

.next_text_line:
	move.l	32*4(a0),(a0)+

	dbf		d7,.text_lines_loop	

	movem.l	(sp)+,d0-a6

	rts
	
; ------------------------------------------------------------------------------
	data
; ------------------------------------------------------------------------------

background_image_filename:
	dc.b	'ETC_DAT\BACKGND.DAT',0

	even

next_graphics_routine:
	dc.l	process_sprite_infos
	
display_sprite_infos_address_new:
	dc.l	sprite_infos1

display_sprite_infos_address_old:
	dc.l	sprite_infos2

work_sprite_infos_address_new:
	dc.l	sprite_infos3

work_sprite_infos_address_old:
	dc.l	sprite_infos4

free_compiled_objects_address:
	dc.l	compiled_objects

next_sprite_infos_address:
	dc.l	sprite_infos3

list_addresses: ; The sorted sprite lists (prepare_sprite_infos): count, then x, y, pattern, info.
	dc.l	emulated_sprite_infos1,emulated_sprite_infos2,emulated_sprite_infos3,emulated_sprite_infos4

next_text_infos_address: ; Where clear_text or draw_text goes on.
	dc.l	text_restores

work_text_state_address:
	dc.l	text_state1
	
display_text_state_address:
	dc.l	text_state2

spare_text_state_address:
	dc.l	text_state3

raster_stages: ; Timer B interrupts until the throttle line: 1, or 2 if doubled.
	dc		1

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

physbase:
	ds.l	1

allocated_screen_address:
	ds.l	1

display_screen_address:
	ds.l	1

work_screen_address:
	ds.l	1

spare_screen_address: ; On display until the display screen's picture is shown.
	ds.l	1

display_window_address:
	ds.l	1

display_background_position: ; The background line at the sprites' line 0, for each
	ds		1 ; screen's last picture.

work_background_position:
	ds		1

spare_background_position:
	ds		1

list_vbls: ; renderer_vbls when the game finished the list in each slot.
	ds		LIST_SLOTS

list_scrolls: ; The CRTC's scroll register then.
	ds		LIST_SLOTS

list_ready: ; The slot holds a finished list.
	ds.b	LIST_SLOTS
	even

list_writing: ; The slot prepare_sprite_infos writes.
	ds		1

picture_list: ; The list of the current or last picture (process_sprite_infos).
	ds.l	1

picture_scroll: ; Its scroll register.
	ds		1

last_list_vbl: ; Its list's VBL.
	ds		1

picture_due: ; The VBL that shows it.
	ds		1

queued_due: ; The VBL that shows the held picture (show_held_picture).
	ds		1

renderer_waiting: ; The renderer waited for a list before the faster cadence's came.
	ds.b	1

list_waited: ; And it still waited when that list was there.
	ds.b	1

picture_spare: ; That was so before the current or last picture.
	ds.b	1
	even

dsp_scroll_offset: ; Lines the display has moved since the work screen's last picture.
	ds		1

text_move: ; The same in bytes, negated: from a text cell to where it was drawn.
	ds.l	1

raster_stages_left: ; Counted down by the Timer B interrupt.
	ds		1

raster_interrupts: ; Timer B interrupts since the VBL (render_idle changes raster_stages_left).
	ds		1

frame_events: ; Timer B events in a frame, as last measured.
	ds		1

game_list_serial: ; Sprite lists the game has finished (prepare_sprite_infos).
	ds		1

drawn_list_serial: ; The one the current or last picture draws.
	ds		1

drawn_list_vbl: ; renderer_vbls when that picture began.
	ds		1

renderer_vbls: ; VBLs, for the timed redraw (the game's WAIT_VBL clears vbl_wait_counter).
	ds		1

picture_wait: ; The picture cadence in VBLs, less 1.
	ds		1

early_pictures: ; Pictures in a row that were ready before their VBL.
	ds		1

flip_held: ; A drawn picture waits for queued_due (shown by the VBL handler).
	ds.b	1

renderer_lock: ; The game's VSYNC wait renders (render_idle): not the VBL.
	ds.b	1

flip_pending: ; show_picture's address is not in the Videl yet (cleared by the VBL handler).
	ds.b	1

runs_wait_vbl: ; clear_sprites_dsp put the restore runs off to the next frame.
	ds.b	1

transfer_masked: ; clear_sprites_dsp raised the interrupt level for the runs.
	ds.b	1
	even

transfer_sr:
	ds		1

palette_translated: ; translated_palette_source is valid.
	ds.b	1

restore_more: ; The DSP sends another list of restore runs for this picture.
	ds.b	1
	even

restore_background_address: ; Where the next list of restore runs starts.
	ds.l	1

restore_screen_address:
	ds.l	1

sprite_infos1: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

sprite_infos2: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

sprite_infos3: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

sprite_infos4: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

emulated_sprite_infos1:
	ds		1+512*4

emulated_sprite_infos2:
	ds		1+512*4

emulated_sprite_infos3:
	ds		1+512*4

emulated_sprite_infos4:
	ds		1+512*4

text_bitmaps:
	ds.l	2*32 ; Text clear bitmap infos followed by text draw bitmap infos.

text_cover: ; Behind text_bitmaps: per text line, the cells this picture's sprites touch.
	ds.l	32

text_matrix:
	ds.b	32*32

text_restores: ; The characters this picture restores (prepare_text): one entry a cell.
	ds.l	32*32*3+1 ; screen_address, background_address, restore data

text_draws: ; The characters this picture draws (prepare_text): one entry a cell.
	ds.l	32*32*2+1 ; screen_address, drawing code

text_background_offset: ; From a work screen address to the background's.
	ds.l	1

; What each screen shows of the text layer: the character of each cell (0:
; none), then for each text line the cells with a character and the cells the
; sprites of the screen's last picture touch (bit 31 = the left cell).

TEXT_STATE_LINES=32*32

text_state1:
	ds.b	32*32
	ds.l	32*2

text_state2:
	ds.b	32*32
	ds.l	32*2

text_state3:
	ds.b	32*32
	ds.l	32*2

cell_span: ; For a sprite's X or Y: the text cells its 16 pixels touch (bit 31 = cell 0).
	ds.l	512

text_reorder_buffer:
	ds.b	32*4

background_image:
	ds.b	SCREEN_BUFFER_SIZE

color_translation_table:
	ds		$10000

translated_palette_source: ; The game's palette as translate_palettes last saw it.
	ds		16*16

translated_palettes:
	ds.l	16*16

compiled_objects:
	ds.b	$300000

sprite_colors_count:
	ds		16

compiling_characters: ; convert_sprite_to_drawing_code makes only the drawing entry.
	ds.b	1
	even

sprite_matrix:
	ds.b	16*16

sprite_mask_bitmap:
	ds		16

sprite_count:
	ds		1

sprite_mask_index:
	ds		1

unique_mask_count:
	ds		1

packed_mask:
	ds.l	11

mask_hash_table:
	ds		MASK_HASH_SIZE

unique_masks:
	ds.l	TOTAL_NUMBER_OF_SPRITES*11

sort_buffers:
	ds		32*512
	
sort_counts:
	ds		32

sorted_sprite_data:
	ds		512*8

; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------
