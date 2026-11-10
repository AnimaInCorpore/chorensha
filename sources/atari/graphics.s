
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

	; Allocate screen buffers (16 bytes boundary, ST-RAM only).

	move	#0,-(sp)
	move.l	#SCREEN_BUFFER_SIZE*2+16,-(sp)
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
; a0.l = compiled sprites struct address.
;

; d0   #1
; d1   #2
; d2   #3
; d3   #4
; d4   #5
; d5   #6
; d6   #7
; d7   #8 
; a0   #9
; a1   #10
; a2   #11
; a3   #12
; a4   #13
; a5   palette_address / #14
; a6   screen_address
; sp   stack_pointer
; (sp) #15

convert_sprite_to_drawing_code:
	movem.l	d0-a6,-(sp)

	lea		sprite_matrix,a1
	move.l	free_compiled_objects_address,a2
	move.l	a2,(a0)
	lea		sprite_color_to_register_table,a0

	; Colors.

	lea		sprite_colors_count+2,a3 ; Start at index #1.
	clr		d0 ; Color index.
	clr		d1 ; Color register bitmap (for "movem.l", bit 0 = d0, ...).
	clr		d2 ; Gap offset.

	cmp		#15,sprite_color_count
	bne		.skip_color_fix1

	move	#$2f2d,(a2)+ ; "move.l x(a5),-(sp)".
	move	#15*4,(a2)+ ; "x".

.skip_color_fix1:
	move	#16-1-1,d7

.colors_loop:
	tst		(a3)+
	beq		.process_gap

	tst		d2
	beq		.count_colors

	cmp		#8,d2
	ble		.quick_add1

	move	#$4bed,(a2)+ ; "lea x(a5),a5".
	move	d2,(a2)+ ; "x".

	bra		.count_colors

.quick_add1:
	and		#$7,d2
	lsl		#8,d2
	add		d2,d2
	add		#$508d,d2 ; "addq.l #x,a5".
	move	d2,(a2)+

.count_colors:
	clr		d2

	move	2(a0,d0.w*2),d3
	cmp		#15,d3
	beq		.skip_color_fix2

	bset	d3,d1

.skip_color_fix2:
	bra		.next_color

.process_gap:
	tst		d1
	beq		.count_gaps

	move	#$4cdd,(a2)+ ; "movem.l (a5)+,rx-ry".
	move	d1,(a2)+ ; "rx-ry".

.count_gaps:
	clr		d1

	addq	#4,d2

.next_color:
	addq	#1,d0

	dbf		d7,.colors_loop

	tst		d1
	beq		.no_final_colors

	move	#$4cdd,(a2)+ ; "movem.l (a5)+,rx-ry".
	move	d1,(a2)+ ; "rx-ry".

.no_final_colors:
	; Pixels.

	clr		d0 ; Gap offset.
	clr		d1

	move	#16-1,d7

.lines_loop2:
	move	#16-1,d6

.pixels_loop:
	move.b	(a1)+,d1
	bne		.process_pixel

	addq	#2,d0

	bra		.next_pixel

.process_pixel:
	tst		d0
	beq		.draw_pixel

	cmp		#8,d0
	ble		.quick_add2

	move	#$4dee,(a2)+ ; "lea x(a6),a6".
	move	d0,(a2)+ ; "x".

	bra		.draw_pixel

.quick_add2:
	and		#$7,d0
	lsl		#8,d0
	add		d0,d0
	add		#$508e,d0 ; "addq.l #x,a6".
	move	d0,(a2)+

.draw_pixel:
	clr		d0

	move	(a0,d1.w*2),d2 ; "x".
	cmp		#15,d2
	bne		.skip_color_fix3

	move	#$3cd7,d2 ; "move.w (sp),(a6)+".
	cmp		-2(a2),d2 ; Is the last opcode also "move.w (sp),(a6)+"?
	bne		.set_draw_color_command

	move	#$2cd7,d2 ; "move.l (sp),(a6)+".
	subq.l	#2,a2

	bra		.set_draw_color_command

.skip_color_fix3:
	add		#$3cc0,d2 ; "move.w rx,(a6)+".

	cmp		-2(a2),d2 ; Is the last opcode also "move.w rx,(a6)+"?
	bne		.set_draw_color_command

	sub		#$1000,d2 ; Convert the current opcode to "move.l rx,(a6)+".
	subq.l	#2,a2

.set_draw_color_command:
	move	d2,(a2)+

.next_pixel:
	dbf		d6,.pixels_loop

	add		#(256*2-16)*2,d0

	dbf		d7,.lines_loop2

	cmp		#15,sprite_color_count
	bne		.skip_color_fix4

	move	#$588f,(a2)+ ; "addq.l #4,sp".

.skip_color_fix4:
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

	; Palette color counting.

	lea		sprite_colors_count+2,a0
	lea		sprite_color_to_register_table+2,a1
	clr		d0

	move	#16-1-1,d7

.count_loop:
	tst		(a0)+
	beq		.color_not_used

	move	d0,(a1)
	addq	#1,d0

.color_not_used:
	addq.l	#2,a1

	dbf		d7,.count_loop

	move	d0,sprite_color_count

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
	
	; Compile characters.

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

	; Palette color counting.

	lea		sprite_colors_count+2,a0
	lea		sprite_color_to_register_table+2,a1
	clr		d0

	moveq	#16-1-1,d6

.count_loop:
	tst		(a0)+
	beq		.color_not_used

	move	d0,(a1)
	addq	#1,d0

.color_not_used:
	addq.l	#2,a1

	dbf		d6,.count_loop

	move	d0,sprite_color_count

	; Create normal sprite.

	move.l	(sp),a0
	jsr		convert_sprite_to_drawing_code
	addq.l	#4,a0
	jsr		convert_sprite_to_restore_data

	add.l	#4*8,(sp)
	
	dbf		d7,.characters_loop
	
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
	beq		.skip_all

	move.l	d7,(sp) ; Return number of prepared sprites.

	move.l	work_sprite_infos_address,a3

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
	move.l	work_sprite_infos_address,d0
	move.l	display_sprite_infos_address,work_sprite_infos_address
	move.l	d0,display_sprite_infos_address
	addq	#1,game_list_serial ; A new list for render_idle.
	
	movem.l	(sp)+,d0-a6

	move.l	#SPRITE_DATA_TABLE,CURRENT_SPRITE_DATA_ENTRY

	clr.l	d0

	rts
	
; ------------------------------------------------------------------------------

process_sprite_infos:
	movem.l	d0-a6,-(sp)

	; A picture of a new sprite list from the game; the same list again only
	; after a few VBLs (for the text layer, in case the game stops sending
	; sprites). Meanwhile the game gets the time: its VBL routine runs once
	; the renderer returns.

	move	game_list_serial,d0
	cmp		drawn_list_serial,d0
	bne.s	.new

	move	renderer_vbls,d0
	sub		drawn_list_vbl,d0
	cmp		#REDRAW_VBLS,d0
	bcs		.not_now

.new:
	move.l	display_sprite_infos_address,a0

	clr.l	d7
	move	(a0)+,d7
	bne		.start

	movem.l	(sp)+,d0-a6

	rts

.start:
	move	game_list_serial,drawn_list_serial
	move	renderer_vbls,drawn_list_vbl

	move.l	#background_image+16*256*2*2,restore_background_address
	move.l	work_screen_address,d0
	add.l	#16*256*2*2,d0
	move.l	d0,restore_screen_address
	sf		restore_more

	move.l	SPRITE_DATA_ADDRESS,a1

	move.l	work_screen_address,a2
	move	work_background_position,d0
	swap	d0
	clr		d0
	lsr.l	#6,d0
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

	btst	#3,$ffffa202.w ; HF2: the DSP waits for a packet.
	beq		*-6

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

	btst	#2,$ffffa202.w ; TRDY: it has taken the count; the rest goes unpolled.
	beq		*-6

	subq	#1,d7

.loop:
	movem	(a0)+,d0-d3

	move	d1,d5

	lea		(a2,d0.w*2),a5
	swap	d1
	clr		d1
	lsr.l	#6,d1
	add.l	d1,a5
	move.l	a5,(a4)+ ; Screen address.

	move	d3,d1
	lsr		#4,d1
	and		#$f0,d1
	lea		4(a3,d1.w*4),a5
	move.l	a5,(a4)+ ; Palette address.

	ext.l	d2
	lsl.l	#2+3+2,d2
	lea		(a1,d2.l),a5 ; Sprite data.

	move	d3,d1
	and		#$c000,d1
	or		32(a5),d1
	; The DSP reads these without the 68030 polling; spacing them out
	; leaves it time for an SSI interrupt between two words.

	move	d1,(a6) ; Flip info + mask index -> DSP.
	rol		#2,d3
	and		#$3,d3
	move	d0,(a6) ; X position -> DSP.
	lea		(a5,d3.w*4),a5
	move	d5,(a6) ; Y position -> DSP.
	move.l	(a5),(a4)+ ; Sprite draw address.
	move.l	16(a5),(a4)+ ; Sprite restore address.

	move	d5,d4
	and		#$1ff,d4
	move.l	(cell_span.l,d4.w*4),d4
	and.l	d6,d4 ; Text lines the sprite touches.
	bne.s	.cover

.covered:
	dbf		d7,.loop

	move	(sp)+,sr

	clr.l	(a4) ; End marker.

	movem.l	(sp)+,d0-a6

	bra		update_background

.not_now:
	movem.l	(sp)+,d0-a6

	rts

.cover:
	move	d0,d1
	and		#$1ff,d1
	move.l	(cell_span.l,d1.w*4),d1 ; Its cells in a line.
	beq.s	.covered

.cover_line:
	bfffo	d4{0:32},d2
	moveq	#31,d3
	sub		d2,d3
	bclr	d3,d4
	or.l	d1,(text_cover.l,d2.w*4)

	tst.l	d4
	bne.s	.cover_line

	bra.s	.covered

; ------------------------------------------------------------------------------

update_background:
	movem.l	d0-d1,-(sp)

	move	#512-1,d0
	move	BACKGROUND_SCROLL_COUNTER,d1
	and		#$1ff,d1
	sub		d1,d0
	clr		d0 ; Fixme!
	move	d0,work_background_position

	movem.l	(sp)+,d0-d1

	bra		translate_palettes

; ------------------------------------------------------------------------------

translate_palettes:
;	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES-60,$fffffa21.w
;	bcc		.start_translating
	
;	move.l	#translate_palettes,next_graphics_routine
	
;	rts

;.start_translating:
	movem.l	d0-a6,-(sp)

	; Only if the game's palette has changed since the last translation
	; (the translation table is fixed after initialize_graphics).

	lea		L_00E82000+$200,a0
	lea		translated_palette_source,a3

	tst.b	palette_translated
	beq.s	.translate

	moveq	#16*16/2/4-1,d7

.compare:
	cmpm.l	(a0)+,(a3)+
	bne.s	.changed
	cmpm.l	(a0)+,(a3)+
	bne.s	.changed
	cmpm.l	(a0)+,(a3)+
	bne.s	.changed
	cmpm.l	(a0)+,(a3)+
	dbne	d7,.compare
	beq		.unchanged

.changed:
	lea		L_00E82000+$200,a0
	lea		translated_palette_source,a3

.translate:
	st		palette_translated

	lea		color_translation_table,a1
	lea		translated_palettes,a2

	clr.l	d0

	move	#16*16/16-1,d7

.loop:
	rept 16

	move	(a0)+,d0
	move	d0,(a3)+
	move	(a1,d0.l*2),d1
	move	d1,(a2)+
	move	d1,(a2)+

	endr

	dbf		d7,.loop

.unchanged:
	movem.l	(sp)+,d0-a6

	bra		prepare_text

; ------------------------------------------------------------------------------

clear_text:
	movem.l	d0-a6,-(sp)

	lea		text_infos,a3
	
	bra		.start

.loop:
	move.l	d0,a2
	move.l	(a3)+,a1
	addq.l	#4,a3
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

draw_sprites:
	movem.l	d0-a6,-(sp)

	move.l	next_sprite_infos_address,a0

	bra		.start

.loop:
	move.l	d0,a6
	move.l	(a0)+,a5
	move.l	(a0)+,a1

	pea		4(a0)

	jsr		(a1)

	move.l	(sp)+,a0

	tst		raster_stages_left
	bgt		.start
	
	move.l	a0,next_sprite_infos_address
	move.l	#draw_sprites,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.start:
	move.l	(a0)+,d0
	bne		.loop

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
	; (its text state) and what the game wants now. A cell whose character
	; has changed gets the old one restored (clear_text, before the
	; sprites) and the new one drawn (draw_text, after the restore runs).
	; An unchanged cell is drawn again only if sprites touch it: those of
	; this picture, or those of the screen's last picture, which the
	; restore runs take away together with the character's pixels on them.
	; All other text stays as it is on the screen.
	;
	; The text cells do not follow the background position (which is
	; always 0, see update_background); process_sprite_infos marks the
	; cells by the sprites' coordinates.

	lea		text_bitmaps+32*4,a0 ; The cells with a character, per line.
	lea		text_matrix,a1
	move.l	TEXT_GRAPHICS_ADDRESS,a2
	move.l	work_text_state_address,a3
	lea		TEXT_STATE_LINES(a3),a6
	lea		text_infos,a4
	move.l	work_screen_address,a5
	move.l	#background_image,d7
	sub.l	a5,d7 ; From a screen address to the background's.
	add.l	#SCREEN_DISPLAY_OFFSET,a5

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
	beq		.skip_line

	moveq	#32-1,d6 ; The cell's bit.

.cell:
	btst	d6,d0
	beq.s	.next_cell

	moveq	#0,d4
	move.b	(a3),d4 ; Shown (0: none).
	moveq	#0,d5
	btst	d6,d2
	beq.s	.compare

	move.b	(a1),d5 ; Wanted.

.compare:
	cmp.b	d4,d5
	bne.s	.changed

	btst	d6,d1
	beq.s	.next_cell

	lsl		#5,d5
	beq.s	.next_cell

	move.l	a5,(a4)+ ; Draw it again.
	clr.l	(a4)+
	move.l	(a2,d5.w),(a4)+
	move.l	#text_no_restore,(a4)+

	bra.s	.next_cell

.changed:
	move.b	d5,(a3)
	bclr	d6,d3

	move.l	a5,(a4)+
	move.l	a5,(a4)
	add.l	d7,(a4)+

	move.l	#text_no_draw,(a4)
	lsl		#5,d5
	beq.s	.no_draw

	bset	d6,d3
	move.l	(a2,d5.w),(a4)

.no_draw:
	addq.l	#4,a4

	move.l	#text_no_restore,(a4)
	lsl		#5,d4
	beq.s	.no_restore

	move.l	4(a2,d4.w),(a4)

.no_restore:
	addq.l	#4,a4

.next_cell:
	addq.l	#1,a1
	addq.l	#1,a3
	lea		8*2(a5),a5

	dbf		d6,.cell

	move.l	d3,(a6)
	lea		256*2*2*8-256*2(a5),a5

	bra.s	.next_line

.skip_line:
	lea		32(a1),a1
	lea		32(a3),a3
	lea		256*2*2*8(a5),a5

.next_line:
	addq.l	#4,a0
	addq.l	#8,a6

	cmp.l	#text_bitmaps+2*32*4,a0
	bne		.line

	clr.l	(a4) ; End marker.

	movem.l	(sp)+,d0-a6

	bra		clear_text

text_no_draw: ; Draw routine of a list entry that only restores.
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

draw_text:
	movem.l	d0-a6,-(sp)

	lea		text_infos,a0
	lea		translated_palettes+4,a5

.loop:
	move.l	(a0),d0
	beq		.end

	movem.l	a0/a5,-(sp)

	move.l	d0,a6
	move.l	8(a0),a0
	jsr		(a0)

	movem.l	(sp)+,a0/a5

	add.l	#4*4,a0

	tst		raster_stages_left
	bgt		.loop
	
	move.l	a0,next_text_infos_address

	move.l	#.resume,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.resume:
	movem.l	d0-a6,-(sp)

	move.l	next_text_infos_address,a0
	lea		translated_palettes+4,a5

	bra		.loop

.end:
	movem.l	(sp)+,d0-a6
	
	bra		flip_screen
	
; ------------------------------------------------------------------------------

flip_screen:
	movem.l	d0-d1,-(sp)

	move.l	work_screen_address,d0
	move.l	display_screen_address,work_screen_address
	move.l	d0,display_screen_address

	move	work_background_position,d0
	move	display_background_position,work_background_position
	move	d0,display_background_position

	move.l	work_text_state_address,d0
	move.l	display_text_state_address,work_text_state_address
	move.l	d0,display_text_state_address

;	move.l	work_sprite_infos_address_old,d0 ; Fixme!
;	move.l	display_sprite_infos_address_old,work_sprite_infos_address_old
;	move.l	d0,display_sprite_infos_address_old

;	move.l	work_sprite_infos_address_new,d0 ; Fixme!
;	move.l	display_sprite_infos_address_new,work_sprite_infos_address_new
;	move.l	d0,display_sprite_infos_address_new

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

	move.l	#process_sprite_infos,next_graphics_routine
	
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

	cmp.l	#process_sprite_infos,next_graphics_routine
	bne.s	.work ; A picture in progress.

	tst.b	flip_pending ; The work screen is still the one on display
	bne.s	.done ; until the VBL handler has set the new address.

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

display_sprite_infos_address:
	dc.l	emulated_sprite_infos1

work_sprite_infos_address:
	dc.l	emulated_sprite_infos2

next_text_infos_address:
	dc.l	text_infos

work_text_state_address:
	dc.l	text_state1
	
display_text_state_address:
	dc.l	text_state2

text_no_restore: ; Restore data of a list entry that only draws.
	dc		-1

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

display_window_address:
	ds.l	1

display_background_position:
	ds		1

work_background_position:
	ds		1

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

renderer_lock: ; The game's VSYNC wait renders (render_idle): not the VBL.
	ds.b	1

flip_pending: ; flip_screen's address is not in the Videl yet (cleared by the VBL handler).
	ds.b	1

runs_wait_vbl: ; clear_sprites_dsp put the restore runs off to the next frame.
	ds.b	1

transfer_masked: ; clear_sprites_dsp raised the interrupt level for the runs.
	ds.b	1

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

text_bitmaps:
	ds.l	2*32 ; Text clear bitmap infos followed by text draw bitmap infos.

text_cover: ; Behind text_bitmaps: per text line, the cells this picture's sprites touch.
	ds.l	32

text_matrix:
	ds.b	32*32

text_infos: ; This picture's text work (prepare_text).
	ds.l	32*32*4+1 ; screen_adress, background_address, text_draw_address, text_clear_address

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

sprite_color_count:
	ds		1

sprite_colors_count:
	ds		16

sprite_color_to_register_table:
	ds		16

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
