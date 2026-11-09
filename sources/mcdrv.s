;
; MCDRV 0.68, "X68k music creative driver" (c) 1993-97 CUL: the X68000 music
; driver that Cho Ren Sha 68k plays its BGM_DAT\*.MDC songs with (the game
; starts it with "MCDRV -B256" and calls it through trap #4).
;
; Disassembled from MCDRV.X on the game's system disk (CH68_101_A), which is
; packed with LZX 1.04: tools/mcdrv/unlzx.py runs the unpacking stub,
; tools/mcdrv/dis68k.py traces the code from the entry points, jump tables
; and handler pointers in tools/mcdrv/mcdrv_cfg.json. Linked at address 0
; without __ATARI__, the result is byte-identical to the unpacked program;
; the comments hold the original offsets and opcode words.
;

	text

	ifd __ATARI__

; The Falcon runs MCDRV on the 68030 (sources/atari/music.s): its OPM writes
; become stream words for the DSP's YM2151, and the VBL runs its timer A
; interrupt in DSP time. What it touches of the X68000 besides the OPM (the
; MFP, vectors, IOCS work) is left out. mcdrv_init does what installing
; "MCDRV -K -B32" does, without the parts for MIDI boards and ADPCM.

	xdef	mcdrv_init
	xdef	mcdrv_dispatch
	xdef	mcdrv_tick
	ifnd MCDRV_TEST
	xref	music_opm_write
	endif

MCDRV_BUFFER equ 32*1024 ; Song data; the game's songs are 10 KB at most.

mcdrv_init:
	movem.l D0-D7/A0-A6,-(A7)
	lea     (-$14,A7),A7 ; The options, as L_004DBA sets them.
	movea.l A7,A6
	move.l  #MCDRV_BUFFER+$10,(A6)
	move.w  #$40,($4,A6) ; Tracks.
	move.w  #$14,($6,A6)
	clr.b   ($8,A6)
	st      ($9,A6) ; -K: no hot keys.
	clr.l   ($c,A6)
	clr.l   ($10,A6)
	moveq   #$0,D6 ; No MIDI boards.
	bsr.w   L_0003D4
	lea     ($14,A7),A7
	lea     L_005E88(pc),A6
	bsr.w   L_00048E
	lea     L_00000C(pc),A0
	move.l  A0,(-$25e,A6)
	move.l  #$10000,D0
	bsr.w   L_001BBE
	move.l  #$ff00,D0
	bsr.w   L_001BF2
	move.b  #$1,(-$13c,A6) ; ADPCM through PCM8 (trap #2), which does nothing here.
	clr.b   (-$13a,A6)
	moveq   #$0,D1
	bsr.w   L_000558
	moveq   #$14,D1
	moveq   #$3f,D2
	bsr.w   L_002BC0
	movem.l (A7)+,D0-D7/A0-A6
	rts

	endif


L_000000:
	dc.b    $2D,$4D,$43,$44,$52,$56,$30,$2D,$00,$68,$00,$01; 00000000

	ifd __ATARI__
mcdrv_dispatch:
	endif
L_00000C:
	add.w   D0,D0                                 ; 0000000C D040
	add.w   D0,D0                                 ; 0000000E D040
	move.l  L_00001C(pc,D0.w),D0                  ; 00000010 203B 000A
	sub.l   A0,D0                                 ; 00000014 9088
	jsr     (A0,D0.l)                             ; 00000016 4EB0 0800
	rte                                           ; 0000001A 4E73

L_00001C:
	dc.l    L_000C0A                              ; 0000001C
	dc.l    L_0026B8                              ; 00000020
	dc.l    L_000992                              ; 00000024
	dc.l    L_002718                              ; 00000028
	dc.l    L_00065E                              ; 0000002C
	dc.l    L_0006C8                              ; 00000030
	dc.l    L_004B9C                              ; 00000034
	dc.l    L_00073C                              ; 00000038
	dc.l    L_004BA6                              ; 0000003C
	dc.l    L_004BB0                              ; 00000040
	dc.l    L_004BBA                              ; 00000044
	dc.l    L_004BC6                              ; 00000048
	dc.l    L_004C3E                              ; 0000004C
	dc.l    L_004BC0                              ; 00000050
	dc.l    L_004C72                              ; 00000054
	dc.l    L_004BCE                              ; 00000058
	dc.l    L_004BF0                              ; 0000005C
	dc.l    L_00079A                              ; 00000060
	dc.l    L_0007CE                              ; 00000064
	dc.l    L_004BFE                              ; 00000068
	dc.l    L_00077A                              ; 0000006C
	dc.l    L_000522                              ; 00000070
	dc.l    L_004C7C                              ; 00000074
	dc.l    L_004C82                              ; 00000078
	dc.l    L_004C10                              ; 0000007C
	dc.l    L_004C26                              ; 00000080
	dc.l    L_004C24                              ; 00000084
	dc.b    $00,$00,$00,$00                       ; 00000088
	dc.l    L_004AC0                              ; 0000008C
	dc.l    L_004ADA                              ; 00000090
	dc.l    L_004AE6                              ; 00000094
	dc.l    L_004C1E                              ; 00000098
	dc.l    L_000870                              ; 0000009C
	dc.l    L_000682                              ; 000000A0
	dc.l    L_004B82                              ; 000000A4
	dc.l    L_004B2E                              ; 000000A8
	dc.l    L_004B58                              ; 000000AC
	dc.l    L_000558                              ; 000000B0
	dc.l    L_0005E6                              ; 000000B4
	dc.l    L_00405C                              ; 000000B8
	dc.l    L_0040B8                              ; 000000BC
	dc.l    L_002822                              ; 000000C0
	dc.l    L_000608                              ; 000000C4
	dc.l    L_00062C                              ; 000000C8
	dc.l    L_000862                              ; 000000CC
	dc.l    L_000672                              ; 000000D0
	dc.l    L_000954                              ; 000000D4
	dc.l    L_00092A                              ; 000000D8
	dc.l    L_00073E                              ; 000000DC

L_0000E0:
	pea     L_004FCA(pc)                          ; 000000E0 487A 4EE8
	dc.w    $ff09                                 ; 000000E4 FF09
	clr.l   -(A7)                                 ; 000000E6 42A7
	dc.w    $ff20                                 ; 000000E8 FF20
	addq.l  #8,A7                                 ; 000000EA 508F
	bsr.w   L_004D12                              ; 000000EC 6100 4C24
	link    A5,#-$14                              ; 000000F0 4E55 FFEC
	movea.l A7,A6                                 ; 000000F4 2C4F
	bsr.w   L_004DBA                              ; 000000F6 6100 4CC2
	bsr.w   L_004D8C                              ; 000000FA 6100 4C90
	bmi.s   L_000108                              ; 000000FE 6B08
	pea     L_005027(pc)                          ; 00000100 487A 4F25
	bra.w   L_00051A                              ; 00000104 6000 0414

L_000108:
	cmpi.w  #$24ff,($90).w                        ; 00000108 0C78 24FF 0090
	beq.s   L_000118                              ; 0000010E 6708
	pea     L_005004(pc)                          ; 00000110 487A 4EF2
	bra.w   L_00051A                              ; 00000114 6000 0404

L_000118:
	move.l  ($c,A6),D6                            ; 00000118 2C2E 000C
	bsr.w   L_004C88                              ; 0000011C 6100 4B6A
	bsr.w   L_0003D4                              ; 00000120 6100 02B2
	unlk    A5                                    ; 00000124 4E5D
	lea     L_005E88(pc),A6                       ; 00000126 4DFA 5D60
	bsr.w   L_00048E                              ; 0000012A 6100 0362
	move.l  ($90).w,(-$262,A6)                    ; 0000012E 2D78 0090 FD9E
	lea     L_00000C(pc),A0                       ; 00000134 41FA FED6
	move.l  A0,($90).w                            ; 00000138 21C8 0090
	move.l  A0,(-$25e,A6)                         ; 0000013C 2D48 FDA2
	tst.b   (-$132,A6)                            ; 00000140 4A2E FECE
	bne.s   L_000168                              ; 00000144 6622
	move.l  ($10c).w,(-$266,A6)                   ; 00000146 2D78 010C FD9A
	lea     L_002A26(pc),A0                       ; 0000014C 41FA 28D8
	move.l  A0,($10c).w                           ; 00000150 21C8 010C
	move.l  #$10000,D0                            ; 00000154 203C 0001 0000
	bsr.w   L_001BBE                              ; 0000015A 6100 1A62
	move.l  #$ff00,D0                             ; 0000015E 203C 0000 FF00
	bsr.w   L_001BF2                              ; 00000164 6100 1A8C

L_000168:
	swap    D7                                    ; 00000168 4847
	move.b  D7,(-$13c,A6)                         ; 0000016A 1D47 FEC4
	bne.s   L_000180                              ; 0000016E 6610
	move.l  ($88).w,(-$25a,A6)                    ; 00000170 2D78 0088 FDA6
	clr.l   ($88).w                               ; 00000176 42B8 0088
	bsr.w   L_004106                              ; 0000017A 6100 3F8A
	bra.s   L_000196                              ; 0000017E 6016

L_000180:
	lea     L_000DC9(pc),A0                       ; 00000180 41FA 0C47
	pea     L_000DB3(pc)                          ; 00000184 487A 0C2D
	dc.w    $ff09                                 ; 00000188 FF09
	pea     (A0)                                  ; 0000018A 4850
	dc.w    $ff09                                 ; 0000018C FF09
	addq.l  #8,A7                                 ; 0000018E 508F
	move.w  #$1fe,D0                              ; 00000190 303C 01FE
	trap    #$2                                   ; 00000194 4E42

L_000196:
	clr.b   (-$13a,A6)                            ; 00000196 422E FEC6
	moveq   #$7,D1                                ; 0000019A 7207

L_00019C:
	moveq   #$f,D0                                ; 0000019C 700F
	and.b   D6,D0                                 ; 0000019E C006
	bset    D0,(-$13a,A6)                         ; 000001A0 01EE FEC6
	bne.s   L_0001B0                              ; 000001A4 660A
	add.w   D0,D0                                 ; 000001A6 D040
	move.w  L_0001BA(pc,D0.w),D0                  ; 000001A8 303B 0010
	jsr     L_0001BA(pc,D0.w)                     ; 000001AC 4EBB 000C

L_0001B0:
	ror.l   #4,D6                                 ; 000001B0 E89E
	dbra    D1,L_00019C                           ; 000001B2 51C9 FFE8
	bra.w   L_00026A                              ; 000001B6 6000 00B2

L_0001BA:
	dc.w    L_0001E8-L_0001BA                     ; 000001BA
	dc.w    L_0001DA-L_0001BA                     ; 000001BC
	dc.w    L_0001EA-L_0001BA                     ; 000001BE
	dc.w    L_0001FA-L_0001BA                     ; 000001C0
	dc.w    L_000206-L_0001BA                     ; 000001C2
	dc.w    L_00020E-L_0001BA                     ; 000001C4
	dc.w    L_000200-L_0001BA                     ; 000001C6
	dc.w    L_0001E8-L_0001BA                     ; 000001C8
	dc.w    L_0001E8-L_0001BA                     ; 000001CA
	dc.w    L_0001E8-L_0001BA                     ; 000001CC
	dc.w    L_0001E8-L_0001BA                     ; 000001CE
	dc.w    L_0001E8-L_0001BA                     ; 000001D0
	dc.w    L_0001E8-L_0001BA                     ; 000001D2
	dc.w    L_0001E8-L_0001BA                     ; 000001D4
	dc.w    L_0001E8-L_0001BA                     ; 000001D6
	dc.w    L_0001E8-L_0001BA                     ; 000001D8

L_0001DA:
	movea.l #$eafa01,A0                           ; 000001DA 207C 00EA FA01
	bsr.w   L_004812                              ; 000001E0 6100 4630
	bsr.w   L_0048A8                              ; 000001E4 6100 46C2

L_0001E8:
	rts                                           ; 000001E8 4E75

L_0001EA:
	movea.l #$eafa11,A0                           ; 000001EA 207C 00EA FA11
	bsr.w   L_004812                              ; 000001F0 6100 4620
	bsr.w   L_0048A8                              ; 000001F4 6100 46B2
	rts                                           ; 000001F8 4E75

L_0001FA:
	bsr.w   L_004596                              ; 000001FA 6100 439A
	rts                                           ; 000001FE 4E75

L_000200:
	bsr.w   L_0047B4                              ; 00000200 6100 45B2
	rts                                           ; 00000204 4E75

L_000206:
	move.w  #$301,D0                              ; 00000206 303C 0301
	trap    #$2                                   ; 0000020A 4E42
	rts                                           ; 0000020C 4E75

L_00020E:
	movem.l D0-D7/A0-A5,-(A7)                     ; 0000020E 48E7 FFFC
	bsr.w   L_002082                              ; 00000212 6100 1E6E
	movea.l (-$1ca,A6),A0                         ; 00000216 206E FE36
	clr.l   (-$1ca,A6)                            ; 0000021A 42AE FE36
	movea.l A0,A1                                 ; 0000021E 2248

L_000220:
	cmpi.b  #$20,(A1)+                            ; 00000220 0C19 0020
	bhi.s   L_000220                              ; 00000224 62FA
	sf      -(A1)                                 ; 00000226 51E1
	clr.w   -(A7)                                 ; 00000228 4267
	pea     (A0)                                  ; 0000022A 4850
	dc.w    $ff3d                                 ; 0000022C FF3D
	addq.l  #6,A7                                 ; 0000022E 5C8F
	move.l  D0,D7                                 ; 00000230 2E00
	bmi.s   L_000264                              ; 00000232 6B30
	move.w  #$2,-(A7)                             ; 00000234 3F3C 0002
	clr.l   -(A7)                                 ; 00000238 42A7
	move.w  D7,-(A7)                              ; 0000023A 3F07
	dc.w    $ff42                                 ; 0000023C FF42
	move.l  D0,D6                                 ; 0000023E 2C00
	clr.w   ($6,A7)                               ; 00000240 426F 0006
	dc.w    $ff42                                 ; 00000244 FF42
	addq.l  #8,A7                                 ; 00000246 508F
	move.l  D6,-(A7)                              ; 00000248 2F06
	dc.w    $ff48                                 ; 0000024A FF48
	addq.l  #4,A7                                 ; 0000024C 588F
	move.l  D0,D5                                 ; 0000024E 2A00
	bmi.s   L_000264                              ; 00000250 6B12
	move.l  D6,-(A7)                              ; 00000252 2F06
	move.l  D5,-(A7)                              ; 00000254 2F05
	move.w  D7,-(A7)                              ; 00000256 3F07
	dc.w    $ff3f                                 ; 00000258 FF3F
	dc.w    $ff3e                                 ; 0000025A FF3E
	lea     ($a,A7),A7                            ; 0000025C 4FEF 000A
	move.l  D5,(-$1ca,A6)                         ; 00000260 2D45 FE36

L_000264:
	movem.l (A7)+,D0-D7/A0-A5                     ; 00000264 4CDF 3FFF
	rts                                           ; 00000268 4E75

L_00026A:
	andi.b  #$fe,(-$13a,A6)                       ; 0000026A 022E 00FE FEC6
	move.b  (-$13a,A6),D1                         ; 00000270 122E FEC6
	beq.s   L_0002AC                              ; 00000274 6736
	lea     L_000D37(pc),A0                       ; 00000276 41FA 0ABF
	movea.l A0,A1                                 ; 0000027A 2248
	lsr.b   #1,D1                                 ; 0000027C E209

L_00027E:
	lsr.b   #1,D1                                 ; 0000027E E209
	bcs.s   L_00028A                              ; 00000280 6508
	beq.s   L_000296                              ; 00000282 6712

L_000284:
	tst.b   (A0)+                                 ; 00000284 4A18
	bne.s   L_000284                              ; 00000286 66FC
	bra.s   L_00027E                              ; 00000288 60F4

L_00028A:
	move.b  (A0)+,(A1)+                           ; 0000028A 12D8
	bne.s   L_00028A                              ; 0000028C 66FC
	move.b  #$2c,(-$1,A1)                         ; 0000028E 137C 002C FFFF
	bra.s   L_00027E                              ; 00000294 60E8

L_000296:
	lea     L_000D66(pc),A0                       ; 00000296 41FA 0ACE
	move.b  #$20,(-$1,A1)                         ; 0000029A 137C 0020 FFFF

L_0002A0:
	move.b  (A0)+,(A1)+                           ; 000002A0 12D8
	bne.s   L_0002A0                              ; 000002A2 66FC
	pea     L_000D22(pc)                          ; 000002A4 487A 0A7C
	dc.w    $ff09                                 ; 000002A8 FF09
	addq.l  #4,A7                                 ; 000002AA 588F

L_0002AC:
	move.l  (-$1ce,A6),D1                         ; 000002AC 222E FE32
	bsr.w   L_000558                              ; 000002B0 6100 02A6
	tst.b   (-$132,A6)                            ; 000002B4 4A2E FECE
	bne.s   L_0002DA                              ; 000002B8 6620
	movem.l D1-D2/A2,-(A7)                        ; 000002BA 48E7 6020
	bset    #$3,($e88015).l                       ; 000002BE 08F9 0003 00E8 8015
	bset    #$3,($e88009).l                       ; 000002C6 08F9 0003 00E8 8009
	moveq   #$14,D1                               ; 000002CE 7214
	moveq   #$3f,D2                               ; 000002D0 743F
	bsr.w   L_002BC0                              ; 000002D2 6100 28EC
	movem.l (A7)+,D1-D2/A2                        ; 000002D6 4CDF 0406

L_0002DA:
	pea     L_000D7D(pc)                          ; 000002DA 487A 0AA1
	dc.w    $ff09                                 ; 000002DE FF09
	addq.l  #4,A7                                 ; 000002E0 588F
	lea     L_000000(pc),A0                       ; 000002E2 41FA FD1C
	move.l  (-$f8,A0),D0                          ; 000002E6 2028 FF08
	sub.l   A0,D0                                 ; 000002EA 9088
	clr.w   -(A7)                                 ; 000002EC 4267
	move.l  D0,-(A7)                              ; 000002EE 2F00
	dc.w    $ff31                                 ; 000002F0 FF31

L_0002F2:
	movem.l D1-D7/A0-A3,-(A7)                     ; 000002F2 48E7 7FF0
	move.l  D0,D1                                 ; 000002F6 2200
	cmpa.l  A0,A1                                 ; 000002F8 B3C8
	bhi.s   L_000340                              ; 000002FA 6244
	beq.w   L_000382                              ; 000002FC 6700 0084
	andi.w  #$7f,D0                               ; 00000300 0240 007F
	lsr.l   #7,D1                                 ; 00000304 EE89
	bra.s   L_000332                              ; 00000306 602A

L_000308:
	movem.l (A0)+,D2-D7/A2-A3                     ; 00000308 4CD8 0CFC
	movem.l D2-D7/A2-A3,(A1)                      ; 0000030C 48D1 0CFC
	movem.l (A0)+,D2-D7/A2-A3                     ; 00000310 4CD8 0CFC
	movem.l D2-D7/A2-A3,($20,A1)                  ; 00000314 48E9 0CFC 0020
	movem.l (A0)+,D2-D7/A2-A3                     ; 0000031A 4CD8 0CFC
	movem.l D2-D7/A2-A3,($40,A1)                  ; 0000031E 48E9 0CFC 0040
	movem.l (A0)+,D2-D7/A2-A3                     ; 00000324 4CD8 0CFC
	movem.l D2-D7/A2-A3,($60,A1)                  ; 00000328 48E9 0CFC 0060
	lea     ($80,A1),A1                           ; 0000032E 43E9 0080

L_000332:
	subq.l  #1,D1                                 ; 00000332 5381
	bcc.s   L_000308                              ; 00000334 64D2
	bra.s   L_00033A                              ; 00000336 6002

L_000338:
	move.b  (A0)+,(A1)+                           ; 00000338 12D8

L_00033A:
	dbra    D0,L_000338                           ; 0000033A 51C8 FFFC
	bra.s   L_000382                              ; 0000033E 6042

L_000340:
	adda.l  D0,A0                                 ; 00000340 D1C0
	adda.l  D0,A1                                 ; 00000342 D3C0
	andi.w  #$7f,D0                               ; 00000344 0240 007F
	lsr.l   #7,D1                                 ; 00000348 EE89
	bra.s   L_00034E                              ; 0000034A 6002

L_00034C:
	move.b  -(A0),-(A1)                           ; 0000034C 1320

L_00034E:
	dbra    D0,L_00034C                           ; 0000034E 51C8 FFFC
	bra.s   L_00037E                              ; 00000352 602A

L_000354:
	lea     (-$80,A0),A0                          ; 00000354 41E8 FF80
	movem.l ($60,A0),D2-D7/A2-A3                  ; 00000358 4CE8 0CFC 0060
	movem.l D2-D7/A2-A3,-(A1)                     ; 0000035E 48E1 3F30
	movem.l ($40,A0),D2-D7/A2-A3                  ; 00000362 4CE8 0CFC 0040
	movem.l D2-D7/A2-A3,-(A1)                     ; 00000368 48E1 3F30
	movem.l ($20,A0),D2-D7/A2-A3                  ; 0000036C 4CE8 0CFC 0020
	movem.l D2-D7/A2-A3,-(A1)                     ; 00000372 48E1 3F30
	movem.l (A0),D2-D7/A2-A3                      ; 00000376 4CD0 0CFC
	movem.l D2-D7/A2-A3,-(A1)                     ; 0000037A 48E1 3F30

L_00037E:
	subq.l  #1,D1                                 ; 0000037E 5381
	bcc.s   L_000354                              ; 00000380 64D2

L_000382:
	movem.l (A7)+,D1-D7/A0-A3                     ; 00000382 4CDF 0FFE
	rts                                           ; 00000386 4E75

L_000388:
	movem.l D0-D7/A0-A2,-(A7)                     ; 00000388 48E7 FFE0
	moveq   #$0,D2                                ; 0000038C 7400
	move.l  D2,D3                                 ; 0000038E 2602
	move.l  D2,D4                                 ; 00000390 2802
	move.l  D2,D5                                 ; 00000392 2A02
	move.l  D2,D6                                 ; 00000394 2C02
	move.l  D2,D7                                 ; 00000396 2E02
	movea.l D2,A1                                 ; 00000398 2242
	movea.l D2,A2                                 ; 0000039A 2442
	adda.l  D0,A0                                 ; 0000039C D1C0
	moveq   #$7f,D1                               ; 0000039E 727F
	and.w   D0,D1                                 ; 000003A0 C240
	lsr.w   #1,D1                                 ; 000003A2 E249
	bcc.s   L_0003AC                              ; 000003A4 6406
	move.b  D2,-(A0)                              ; 000003A6 1102
	bra.s   L_0003AC                              ; 000003A8 6002

L_0003AA:
	move.w  D2,-(A0)                              ; 000003AA 3102

L_0003AC:
	dbra    D1,L_0003AA                           ; 000003AC 51C9 FFFC
	lsr.l   #7,D0                                 ; 000003B0 EE88
	bra.s   L_0003C4                              ; 000003B2 6010

L_0003B4:
	movem.l D2-D7/A1-A2,-(A0)                     ; 000003B4 48E0 3F60
	movem.l D2-D7/A1-A2,-(A0)                     ; 000003B8 48E0 3F60
	movem.l D2-D7/A1-A2,-(A0)                     ; 000003BC 48E0 3F60
	movem.l D2-D7/A1-A2,-(A0)                     ; 000003C0 48E0 3F60

L_0003C4:
	dbra    D0,L_0003B4                           ; 000003C4 51C8 FFEE
	addq.w  #1,D0                                 ; 000003C8 5240
	subq.l  #1,D0                                 ; 000003CA 5380
	bcc.s   L_0003B4                              ; 000003CC 64E6
	movem.l (A7)+,D0-D7/A0-A2                     ; 000003CE 4CDF 07FF
	rts                                           ; 000003D2 4E75

L_0003D4:
	movem.l D0-D7/A0-A6,-(A7)                     ; 000003D4 48E7 FFFE
	lea     L_004C88(pc),A0                       ; 000003D8 41FA 48AE
	moveq   #$0,D0                                ; 000003DC 7000
	move.w  ($4,A6),D0                            ; 000003DE 302E 0004
	lsl.w   #8,D0                                 ; 000003E2 E148
	add.l   #$1200,D0                             ; 000003E4 D0BC 0000 1200
	bsr.s   L_000388                              ; 000003EA 619C
	lea     L_005E88(pc),A0                       ; 000003EC 41FA 5A9A
	exg     A0,A6                                 ; 000003F0 C14E
	move.l  ($c,A0),(-$1ce,A6)                    ; 000003F2 2D68 000C FE32
	move.l  (A0)+,(-$332,A6)                      ; 000003F8 2D58 FCCE
	move.w  (A0)+,(-$70,A6)                       ; 000003FC 3D58 FF90
	move.w  (A0)+,(-$36a,A6)                      ; 00000400 3D58 FC96
	move.b  (A0)+,(-$132,A6)                      ; 00000404 1D58 FECE
	move.b  (A0)+,(-$12d,A6)                      ; 00000408 1D58 FED3
	move.l  ($6,A0),(-$1ca,A6)                    ; 0000040C 2D68 0006 FE36
	st      (-$3b7,A6)                            ; 00000412 50EE FC49
	move.w  #$30,(-$68,A6)                        ; 00000416 3D7C 0030 FF98
	moveq   #$78,D0                               ; 0000041C 7078
	move.w  D0,(-$66,A6)                          ; 0000041E 3D40 FF9A
	move.w  D0,(-$3b6,A6)                         ; 00000422 3D40 FC4A
	move.w  D0,(-$3b4,A6)                         ; 00000426 3D40 FC4C
	move.w  #$100,(-$6a,A6)                       ; 0000042A 3D7C 0100 FF96
	move.w  #$80,(-$348,A6)                       ; 00000430 3D7C 0080 FCB8
	move.w  #$80,(-$344,A6)                       ; 00000436 3D7C 0080 FCBC
	move.b  #$35,(-$127,A6)                       ; 0000043C 1D7C 0035 FED9
	lea     (-$fee,A6),A0                         ; 00000442 41EE F012
	moveq   #$10,D1                               ; 00000446 7210
	moveq   #$10,D2                               ; 00000448 7410
	move.l  #$fff0fff0,D3                         ; 0000044A 263C FFF0 FFF0
	moveq   #$7f,D0                               ; 00000450 707F

L_000452:
	move.w  D1,(A0)                               ; 00000452 3081
	move.l  D3,($4,A0)                            ; 00000454 2143 0004
	add.w   D2,D1                                 ; 00000458 D242
	adda.l  D2,A0                                 ; 0000045A D1C2
	dbra    D0,L_000452                           ; 0000045C 51C8 FFF4
	move.w  D3,(-$10,A0)                          ; 00000460 3143 FFF0
	move.l  D3,(-$ffe,A6)                         ; 00000464 2D43 F002
	move.l  D3,(-$38e,A6)                         ; 00000468 2D43 FC72
	movea.l A6,A0                                 ; 0000046C 204E
	move.w  (-$70,A6),D0                          ; 0000046E 302E FF90
	subq.w  #1,D0                                 ; 00000472 5340

L_000474:
	st      (A0)                                  ; 00000474 50D0
	move.b  #$40,($23,A0)                         ; 00000476 117C 0040 0023
	move.w  D3,($46,A0)                           ; 0000047C 3143 0046
	lea     ($100,A0),A0                          ; 00000480 41E8 0100
	dbra    D0,L_000474                           ; 00000484 51C8 FFEE
	movem.l (A7)+,D0-D7/A0-A6                     ; 00000488 4CDF 7FFF
	rts                                           ; 0000048C 4E75

L_00048E:
	movem.l D0-D7/A0-A6,-(A7)                     ; 0000048E 48E7 FFFE
	moveq   #$0,D0                                ; 00000492 7000
	move.w  (-$70,A6),D0                          ; 00000494 302E FF90
	lsl.w   #8,D0                                 ; 00000498 E148
	add.l   #$1200,D0                             ; 0000049A D0BC 0000 1200
	lea     L_004C88(pc),A0                       ; 000004A0 41FA 47E6
	adda.l  D0,A0                                 ; 000004A4 D1C0
	lea     (-$1ea,A6),A1                         ; 000004A6 43EE FE16
	moveq   #$7,D1                                ; 000004AA 7207

L_0004AC:
	moveq   #$f,D0                                ; 000004AC 700F
	and.b   D6,D0                                 ; 000004AE C006
	beq.s   L_0004C4                              ; 000004B0 6712
	lsl.w   #2,D0                                 ; 000004B2 E548
	move.l  A0,(-$4,A1,D0.w)                      ; 000004B4 2388 00FC
	clr.l   (A0)+                                 ; 000004B8 4298
	clr.l   (A0)+                                 ; 000004BA 4298
	clr.l   (A0)+                                 ; 000004BC 4298
	clr.l   (A0)+                                 ; 000004BE 4298
	lea     ($400,A0),A0                          ; 000004C0 41E8 0400

L_0004C4:
	ror.l   #4,D6                                 ; 000004C4 E89E
	dbra    D1,L_0004AC                           ; 000004C6 51C9 FFE4
	move.l  A0,(-$32e,A6)                         ; 000004CA 2D48 FCD2
	move.l  (-$332,A6),D0                         ; 000004CE 202E FCCE
	movea.l A0,A1                                 ; 000004D2 2248
	clr.l   (A1)+                                 ; 000004D4 4299
	clr.l   (A1)+                                 ; 000004D6 4299
	moveq   #-$10,D1                              ; 000004D8 72F0
	add.l   D0,D1                                 ; 000004DA D280
	move.l  D1,(A1)+                              ; 000004DC 22C1
	clr.l   (A1)+                                 ; 000004DE 4299
	lea     (-$1ea,A6),A0                         ; 000004E0 41EE FE16
	lea     L_0005C6(pc),A1                       ; 000004E4 43FA 00E0
	movea.l #$eafa01,A2                           ; 000004E8 247C 00EA FA01
	bsr.s   L_000506                              ; 000004EE 6116
	movea.l #$eafa11,A2                           ; 000004F0 247C 00EA FA11
	bsr.s   L_000506                              ; 000004F6 610E
	movea.l #$e98005,A2                           ; 000004F8 247C 00E9 8005
	bsr.s   L_000506                              ; 000004FE 6106
	movem.l (A7)+,D0-D7/A0-A6                     ; 00000500 4CDF 7FFF
	rts                                           ; 00000504 4E75

L_000506:
	move.l  (A0)+,D0                              ; 00000506 2018
	beq.s   L_000514                              ; 00000508 670A
	exg     D0,A2                                 ; 0000050A C18A
	move.l  D0,($8,A2)                            ; 0000050C 2540 0008
	addq.l  #2,A1                                 ; 00000510 5489
	bra.s   L_000518                              ; 00000512 6004

L_000514:
	move.w  #$30,(A1)+                            ; 00000514 32FC 0030

L_000518:
	rts                                           ; 00000518 4E75

L_00051A:
	dc.w    $ff09                                 ; 0000051A FF09
	move.w  #$1,-(A7)                             ; 0000051C 3F3C 0001
	dc.w    $ff4c                                 ; 00000520 FF4C

L_000522:
	movem.l D1-D3/A5-A6,-(A7)                     ; 00000522 48E7 7006
	lea     L_005E88(pc),A6                       ; 00000526 4DFA 5960
	swap    D1                                    ; 0000052A 4841
	cmpi.b  #$f,D1                                ; 0000052C 0C01 000F
	bne.s   L_000550                              ; 00000530 661E
	move.w  D1,D3                                 ; 00000532 3601
	andi.w  #$ff00,D3                             ; 00000534 0243 FF00
	lea     (A6,D3.w),A5                          ; 00000538 4BF6 3000
	move.w  ($10,A5),D0                           ; 0000053C 302D 0010
	bset    D1,D0                                 ; 00000540 03C0
	swap    D1                                    ; 00000542 4841
	move.b  D1,($21,A5)                           ; 00000544 1B41 0021
	move.w  D0,($10,A5)                           ; 00000548 3B40 0010
	moveq   #$0,D0                                ; 0000054C 7000
	bra.s   L_000552                              ; 0000054E 6002

L_000550:
	moveq   #-$1,D0                               ; 00000550 70FF

L_000552:
	movem.l (A7)+,D1-D3/A5-A6                     ; 00000552 4CDF 600E
	rts                                           ; 00000556 4E75

L_000558:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00000558 48E7 7FFE
	lea     L_005E88(pc),A6                       ; 0000055C 4DFA 592A
	move.l  D1,D6                                 ; 00000560 2C01
	move.l  D6,(-$1ce,A6)                         ; 00000562 2D46 FE32
	clr.l   (-$1d2,A6)                            ; 00000566 42AE FE2E
	lea     L_0005C4(pc),A0                       ; 0000056A 41FA 0058
	lea     L_0005B4(pc),A1                       ; 0000056E 43FA 0044
	moveq   #$0,D1                                ; 00000572 7200

L_000574:
	moveq   #$f,D0                                ; 00000574 700F
	and.b   D6,D0                                 ; 00000576 C006
	add.w   D0,D0                                 ; 00000578 D040
	move.w  D1,D2                                 ; 0000057A 3401
	add.w   D2,D2                                 ; 0000057C D442
	move.w  (A0,D0.w),(A1,D2.w)                   ; 0000057E 33B0 0000 2000
	tst.l   (-$1d2,A6)                            ; 00000584 4AAE FE2E
	bne.s   L_000596                              ; 00000588 660C
	lea     (-$1ea,A6),A2                         ; 0000058A 45EE FE16
	add.w   D0,D0                                 ; 0000058E D040
	move.l  (-$4,A2,D0.w),(-$1d2,A6)              ; 00000590 2D72 00FC FE2E

L_000596:
	ror.l   #4,D6                                 ; 00000596 E89E
	addq.w  #1,D1                                 ; 00000598 5241
	cmpi.w  #$8,D1                                ; 0000059A 0C41 0008
	bcs.s   L_000574                              ; 0000059E 65D4
	movem.l (A7)+,D1-D7/A0-A6                     ; 000005A0 4CDF 7FFE
	rts                                           ; 000005A4 4E75

L_0005A6:
	moveq   #$70,D1                               ; 000005A6 7270
	and.w   D6,D1                                 ; 000005A8 C246
	lsr.w   #3,D1                                 ; 000005AA E649
	move.w  L_0005B4(pc,D1.w),D1                  ; 000005AC 323B 1006
	jmp     L_0005B4(pc,D1.w)                     ; 000005B0 4EFB 1002

L_0005B4:
	dc.w    L_0005E4-L_0005B4                     ; 000005B4
	dc.w    L_0005E4-L_0005B4                     ; 000005B6
	dc.w    L_0005E4-L_0005B4                     ; 000005B8
	dc.w    L_0005E4-L_0005B4                     ; 000005BA
	dc.w    L_0005E4-L_0005B4                     ; 000005BC
	dc.w    L_0005E4-L_0005B4                     ; 000005BE
	dc.w    L_0005E4-L_0005B4                     ; 000005C0
	dc.w    L_0005E4-L_0005B4                     ; 000005C2

L_0005C4:
	dc.w    L_0005E4-L_0005B4                     ; 000005C4

L_0005C6:
	dc.w    L_0049E0-L_0005B4                     ; 000005C6
	dc.w    L_0049D8-L_0005B4                     ; 000005C8
	dc.w    L_0046DA-L_0005B4                     ; 000005CA
	dc.w    L_002380-L_0005B4                     ; 000005CC
	dc.w    L_001C48-L_0005B4                     ; 000005CE
	dc.w    L_0047C8-L_0005B4                     ; 000005D0
	dc.w    L_0005E4-L_0005B4                     ; 000005D2
	dc.w    L_0005E4-L_0005B4                     ; 000005D4
	dc.w    L_0005E4-L_0005B4                     ; 000005D6
	dc.w    L_0005E4-L_0005B4                     ; 000005D8
	dc.w    L_0005E4-L_0005B4                     ; 000005DA
	dc.w    L_0005E4-L_0005B4                     ; 000005DC
	dc.w    L_0005E4-L_0005B4                     ; 000005DE
	dc.w    L_0005E4-L_0005B4                     ; 000005E0
	dc.w    L_0005E4-L_0005B4                     ; 000005E2

L_0005E4:
	rts                                           ; 000005E4 4E75

L_0005E6:
	movem.l D1/D6/A0,-(A7)                        ; 000005E6 48E7 4280
	move.l  D1,D0                                 ; 000005EA 2001
	subq.w  #1,D0                                 ; 000005EC 5340
	bcs.s   L_000602                              ; 000005EE 6512
	swap    D0                                    ; 000005F0 4840
	move.b  D0,D6                                 ; 000005F2 1C00
	bpl.s   L_000602                              ; 000005F4 6A0C
	swap    D0                                    ; 000005F6 4840
	move    SR,-(A7)                              ; 000005F8 40E7
	ori     #$700,SR                              ; 000005FA 007C 0700
	bsr.s   L_0005A6                              ; 000005FE 61A6
	move    (A7)+,SR                              ; 00000600 46DF

L_000602:
	movem.l (A7)+,D1/D6/A0                        ; 00000602 4CDF 0142
	rts                                           ; 00000606 4E75

L_000608:
	movem.l D1/A6,-(A7)                           ; 00000608 48E7 4002
	lea     L_005E88(pc),A6                       ; 0000060C 4DFA 587A
	bsr.w   L_0006C8                              ; 00000610 6100 00B6
	bsr.w   L_000992                              ; 00000614 6100 037C
	tst.l   D0                                    ; 00000618 4A80
	bmi.s   L_000626                              ; 0000061A 6B0A
	move.w  D1,(-$342,A6)                         ; 0000061C 3D41 FCBE
	moveq   #-$1,D1                               ; 00000620 72FF
	bsr.w   L_004C10                              ; 00000622 6100 45EC

L_000626:
	movem.l (A7)+,D1/A6                           ; 00000626 4CDF 4002
	rts                                           ; 0000062A 4E75

L_00062C:
	movem.l D1-D2/A6,-(A7)                        ; 0000062C 48E7 6002
	lea     L_005E88(pc),A6                       ; 00000630 4DFA 5856
	move.l  (-$60,A6),D2                          ; 00000634 242E FFA0
	cmp.l   D2,D1                                 ; 00000638 B282
	bcc.s   L_00064A                              ; 0000063A 640E
	bsr.w   L_0006C8                              ; 0000063C 6100 008A
	bsr.w   L_000992                              ; 00000640 6100 0350
	bsr.w   L_004C10                              ; 00000644 6100 45CA
	bra.s   L_000658                              ; 00000648 600E

L_00064A:
	sub.l   D2,D1                                 ; 0000064A 9282
	bsr.w   L_004C10                              ; 0000064C 6100 45C2
	tst.b   (-$3b8,A6)                            ; 00000650 4A2E FC48
	beq.s   L_000658                              ; 00000654 6702
	bsr.s   L_00065E                              ; 00000656 6106

L_000658:
	movem.l (A7)+,D1-D2/A6                        ; 00000658 4CDF 4006
	rts                                           ; 0000065C 4E75

L_00065E:
	move.l  A6,-(A7)                              ; 0000065E 2F0E
	lea     L_005E88(pc),A6                       ; 00000660 4DFA 5826
	tst.b   (-$3b7,A6)                            ; 00000664 4A2E FC49
	bne.s   L_00066E                              ; 00000668 6604
	not.b   (-$3b8,A6)                            ; 0000066A 462E FC48

L_00066E:
	movea.l (A7)+,A6                              ; 0000066E 2C5F
	rts                                           ; 00000670 4E75

L_000672:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00000672 48E7 7FFE
	move.b  D1,D6                                 ; 00000676 1C01
	move.b  D2,D7                                 ; 00000678 1E02
	cmp.b   D6,D7                                 ; 0000067A BE06
	bge.s   L_00068A                              ; 0000067C 6C0C
	exg     D6,D7                                 ; 0000067E CD47
	bra.s   L_00068A                              ; 00000680 6008

L_000682:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00000682 48E7 7FFE
	moveq   #-$80,D6                              ; 00000686 7C80
	moveq   #$7f,D7                               ; 00000688 7E7F

L_00068A:
	lea     L_005E88(pc),A6                       ; 0000068A 4DFA 57FC
	bsr.s   L_0006EA                              ; 0000068E 615A
	move.l  (-$ffe,A6),-(A7)                      ; 00000690 2F2E F002
	move.l  (-$38e,A6),(-$ffe,A6)                 ; 00000694 2D6E FC72 F002
	move.w  (-$392,A6),-(A7)                      ; 0000069A 3F2E FC6E
	move.w  (-$390,A6),(-$392,A6)                 ; 0000069E 3D6E FC70 FC6E
	bsr.s   L_000702                              ; 000006A4 615C
	move.w  (-$392,A6),(-$390,A6)                 ; 000006A6 3D6E FC6E FC70
	move.w  (A7)+,(-$392,A6)                      ; 000006AC 3D5F FC6E
	move.l  (-$ffe,A6),(-$38e,A6)                 ; 000006B0 2D6E F002 FC72
	move.l  (A7)+,(-$ffe,A6)                      ; 000006B6 2D5F F002
	ifnd __ATARI__
	ori.b   #$8,($e88015).l                       ; 000006BA 0039 0008 00E8 8015
	endif
	movem.l (A7)+,D1-D7/A0-A6                     ; 000006C2 4CDF 7FFE
	rts                                           ; 000006C6 4E75

L_0006C8:
	movem.l D1-D7/A0-A6,-(A7)                     ; 000006C8 48E7 7FFE
	moveq   #$0,D6                                ; 000006CC 7C00
	moveq   #$0,D7                                ; 000006CE 7E00
	lea     L_005E88(pc),A6                       ; 000006D0 4DFA 57B6
	st      (-$3b7,A6)                            ; 000006D4 50EE FC49
	bsr.s   L_0006EA                              ; 000006D8 6110
	bsr.s   L_000702                              ; 000006DA 6126
	ifnd __ATARI__
	ori.b   #$8,($e88015).l                       ; 000006DC 0039 0008 00E8 8015
	endif
	movem.l (A7)+,D1-D7/A0-A6                     ; 000006E4 4CDF 7FFE
	rts                                           ; 000006E8 4E75

L_0006EA:
	move    SR,D0                                 ; 000006EA 40C0
	ori     #$700,SR                              ; 000006EC 007C 0700
	ifnd __ATARI__
	andi.b  #$f7,($e88015).l                      ; 000006F0 0239 00F7 00E8 8015
	tst.w   ($0).w                                ; 000006F8 4A78 0000
	endif
	nop                                           ; 000006FC 4E71
	move    D0,SR                                 ; 000006FE 46C0
	rts                                           ; 00000700 4E75

L_000702:
	bsr.w   L_000BDA                              ; 00000702 6100 04D6
	moveq   #$0,D0                                ; 00000706 7000
	move.w  (-$392,A6),D0                         ; 00000708 302E FC6E
	beq.s   L_00073A                              ; 0000070C 672C

L_00070E:
	lea     (-$1,A6,D0.l),A5                      ; 0000070E 4BF6 08FF
	cmp.b   ($7a,A5),D6                           ; 00000712 BC2D 007A
	bgt.s   L_000722                              ; 00000716 6E0A
	cmp.b   ($7a,A5),D7                           ; 00000718 BE2D 007A
	blt.s   L_000722                              ; 0000071C 6D04
	bsr.w   L_001A42                              ; 0000071E 6100 1322

L_000722:
	move.w  ($16,A5),D0                           ; 00000722 302D 0016
	bne.s   L_00070E                              ; 00000726 66E6
	lea     (-$1200,A6),A0                        ; 00000728 41EE EE00
	moveq   #$7,D6                                ; 0000072C 7C07

L_00072E:
	tst.w   (A0)+                                 ; 0000072E 4A58
	bne.s   L_000736                              ; 00000730 6604
	bsr.w   L_001A24                              ; 00000732 6100 12F0

L_000736:
	dbra    D6,L_00072E                           ; 00000736 51CE FFF6

L_00073A:
	rts                                           ; 0000073A 4E75

L_00073C:
	rts                                           ; 0000073C 4E75

L_00073E:
	movem.l D1-D2/A5-A6,-(A7)                     ; 0000073E 48E7 6006
	lea     L_005E88(pc),A6                       ; 00000742 4DFA 5744
	bsr.s   L_0006EA                              ; 00000746 61A2
	move.w  (-$390,A6),D0                         ; 00000748 302E FC70
	beq.s   L_00076C                              ; 0000074C 671E

L_00074E:
	lea     (-$1,A6,D0.w),A5                      ; 0000074E 4BF6 00FF
	cmp.b   ($7a,A5),D2                           ; 00000752 B42D 007A
	bne.s   L_000766                              ; 00000756 660E
	move.b  D1,($f3,A5)                           ; 00000758 1B41 00F3
	clr.b   ($f4,A5)                              ; 0000075C 422D 00F4
	ori.w   #$1000,($8,A5)                        ; 00000760 006D 1000 0008

L_000766:
	move.w  ($16,A5),D0                           ; 00000766 302D 0016
	bne.s   L_00074E                              ; 0000076A 66E2

L_00076C:
	ifnd __ATARI__
	ori.b   #$8,($e88015).l                       ; 0000076C 0039 0008 00E8 8015
	endif
	movem.l (A7)+,D1-D2/A5-A6                     ; 00000774 4CDF 6006
	rts                                           ; 00000778 4E75

L_00077A:
	move.l  A6,-(A7)                              ; 0000077A 2F0E
	lea     L_005E88(pc),A6                       ; 0000077C 4DFA 570A
	move.w  #$1,(-$34e,A6)                        ; 00000780 3D7C 0001 FCB2
	move.w  D1,(-$356,A6)                         ; 00000786 3D41 FCAA
	seq     D0                                    ; 0000078A 57C0
	ble.s   L_000790                              ; 0000078C 6F02
	addq.b  #1,D0                                 ; 0000078E 5200

L_000790:
	addq.b  #1,D0                                 ; 00000790 5200
	move.b  D0,(-$7d,A6)                          ; 00000792 1D40 FF83
	movea.l (A7)+,A6                              ; 00000796 2C5F
	rts                                           ; 00000798 4E75

L_00079A:
	move    SR,-(A7)                              ; 0000079A 40E7
	ori     #$700,SR                              ; 0000079C 007C 0700
	movem.l D1/A1/A6,-(A7)                        ; 000007A0 48E7 4042
	lea     L_005E88(pc),A6                       ; 000007A4 4DFA 56E2
	lea     (-$328,A6),A1                         ; 000007A8 43EE FCD8
	move.w  (-$32a,A6),D1                         ; 000007AC 322E FCD6
	moveq   #-$1,D0                               ; 000007B0 70FF
	cmpi.w  #$8,D1                                ; 000007B2 0C41 0008
	beq.s   L_0007C6                              ; 000007B6 670E
	add.w   D1,D1                                 ; 000007B8 D241
	add.w   D1,D1                                 ; 000007BA D241
	move.l  A0,(A1,D1.w)                          ; 000007BC 2388 1000
	addq.w  #1,(-$32a,A6)                         ; 000007C0 526E FCD6
	moveq   #$0,D0                                ; 000007C4 7000

L_0007C6:
	movem.l (A7)+,D1/A1/A6                        ; 000007C6 4CDF 4202
	move    (A7)+,SR                              ; 000007CA 46DF
	rts                                           ; 000007CC 4E75

L_0007CE:
	movem.l D1-D2/A1/A6,-(A7)                     ; 000007CE 48E7 6042
	lea     L_005E88(pc),A6                       ; 000007D2 4DFA 56B4
	tst.w   D1                                    ; 000007D6 4A41
	beq.s   L_0007E2                              ; 000007D8 6708
	subq.w  #2,D1                                 ; 000007DA 5541
	bcs.s   L_0007E6                              ; 000007DC 6508
	beq.s   L_000804                              ; 000007DE 6724
	bra.s   L_000814                              ; 000007E0 6032

L_0007E2:
	bsr.s   L_000820                              ; 000007E2 613C
	bra.s   L_00081A                              ; 000007E4 6034

L_0007E6:
	bsr.s   L_000820                              ; 000007E6 6138
	bpl.s   L_000814                              ; 000007E8 6A2A
	lea     (-$306,A6),A1                         ; 000007EA 43EE FCFA
	moveq   #$7,D0                                ; 000007EE 7007

L_0007F0:
	tst.l   (A1)+                                 ; 000007F0 4A99
	dbeq    D0,L_0007F0                           ; 000007F2 57C8 FFFC
	bne.s   L_000814                              ; 000007F6 661C
	move.l  A0,-(A1)                              ; 000007F8 2308
	move.l  D2,($20,A1)                           ; 000007FA 2342 0020
	addq.w  #1,(-$308,A6)                         ; 000007FE 526E FCF8
	bra.s   L_000818                              ; 00000802 6014

L_000804:
	bsr.s   L_000820                              ; 00000804 611A
	bmi.s   L_00081A                              ; 00000806 6B12
	subq.w  #1,(-$308,A6)                         ; 00000808 536E FCF8
	clr.l   (A1)                                  ; 0000080C 4291
	clr.l   (-$20,A1)                             ; 0000080E 42A9 FFE0
	bra.s   L_00081A                              ; 00000812 6006

L_000814:
	moveq   #-$1,D0                               ; 00000814 70FF
	bra.s   L_00081A                              ; 00000816 6002

L_000818:
	moveq   #$0,D0                                ; 00000818 7000

L_00081A:
	movem.l (A7)+,D1-D2/A1/A6                     ; 0000081A 4CDF 4206
	rts                                           ; 0000081E 4E75

L_000820:
	lea     (-$2e6,A6),A1                         ; 00000820 43EE FD1A
	moveq   #-$1,D0                               ; 00000824 70FF
	moveq   #$7,D1                                ; 00000826 7207

L_000828:
	cmp.l   (A1)+,D2                              ; 00000828 B499
	dbeq    D1,L_000828                           ; 0000082A 57C9 FFFC
	bne.s   L_000836                              ; 0000082E 6606
	subq.l  #4,A1                                 ; 00000830 5989
	move.l  (-$20,A1),D0                          ; 00000832 2029 FFE0

L_000836:
	tst.l   D0                                    ; 00000836 4A80
	rts                                           ; 00000838 4E75

L_00083A:
	movem.l D6-D7/A0/A5-A6,-(A7)                  ; 0000083A 48E7 0386
	lea     L_005E88(pc),A6                       ; 0000083E 4DFA 5648
	lea     (-$306,A6),A5                         ; 00000842 4BEE FCFA
	move.w  (-$308,A6),D7                         ; 00000846 3E2E FCF8
	bra.s   L_000858                              ; 0000084A 600C

L_00084C:
	move.l  (A5)+,D6                              ; 0000084C 2C1D
	dbne    D7,L_00084C                           ; 0000084E 56CF FFFC
	beq.s   L_00085C                              ; 00000852 6708
	movea.l D6,A0                                 ; 00000854 2046
	jsr     (A0)                                  ; 00000856 4E90

L_000858:
	dbra    D7,L_00084C                           ; 00000858 51CF FFF2

L_00085C:
	movem.l (A7)+,D6-D7/A0/A5-A6                  ; 0000085C 4CDF 61C0
	rts                                           ; 00000860 4E75

L_000862:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00000862 48E7 7FFE
	lsl.w   #8,D1                                 ; 00000866 E149
	move.w  D1,D3                                 ; 00000868 3601
	bpl.s   L_000876                              ; 0000086A 6A0A
	bmi.w   L_00091A                              ; 0000086C 6B00 00AC

L_000870:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00000870 48E7 7FFE
	moveq   #$0,D3                                ; 00000874 7600

L_000876:
	lea     L_005E88(pc),A6                       ; 00000876 4DFA 5610
	movea.l A0,A4                                 ; 0000087A 2848
	cmpi.l  #$4d44431a,(A0)                       ; 0000087C 0C90 4D44 431A
	bne.w   L_00091A                              ; 00000882 6600 0096
	move.w  ($4,A0),D0                            ; 00000886 3028 0004
	subq.w  #4,D0                                 ; 0000088A 5940
	bcs.w   L_00091A                              ; 0000088C 6500 008C
	subq.w  #4,D0                                 ; 00000890 5940
	bhi.w   L_00091A                              ; 00000892 6200 0086
	bsr.w   L_0006EA                              ; 00000896 6100 FE52
	adda.l  ($10,A0),A0                           ; 0000089A D1E8 0010
	move.w  (A0)+,D1                              ; 0000089E 3218
	subq.w  #1,D1                                 ; 000008A0 5341
	move.w  D1,D4                                 ; 000008A2 3801
	lea     ($4,A0),A1                            ; 000008A4 43E8 0004
	moveq   #$0,D2                                ; 000008A8 7400
	move.w  (-$70,A6),D2                          ; 000008AA 342E FF90
	subq.w  #1,D2                                 ; 000008AE 5342
	lsl.w   #8,D2                                 ; 000008B0 E14A

L_0008B2:
	tst.b   (A6,D2.l)                             ; 000008B2 4A36 2800
	bne.s   L_0008C0                              ; 000008B6 6608
	sub.w   #$100,D2                              ; 000008B8 947C 0100
	bcc.s   L_0008B2                              ; 000008BC 64F4
	bra.s   L_000912                              ; 000008BE 6052

L_0008C0:
	move.w  D2,-(A7)                              ; 000008C0 3F02
	move.b  (A7)+,(A1)                            ; 000008C2 129F
	addq.l  #8,A1                                 ; 000008C4 5089
	sub.w   #$100,D2                              ; 000008C6 947C 0100
	dbcs    D4,L_0008B2                           ; 000008CA 55CC FFE6
	bcs.s   L_00091A                              ; 000008CE 654A
	movea.l A4,A0                                 ; 000008D0 204C
	addq.b  #1,(-$126,A6)                         ; 000008D2 522E FEDA
	move.w  D3,D0                                 ; 000008D6 3003
	move.b  (-$126,A6),D0                         ; 000008D8 102E FEDA
	bsr.w   L_002398                              ; 000008DC 6100 1ABA
	move.w  D0,D3                                 ; 000008E0 3600

L_0008E2:
	lea     (-$1,A6,D0.w),A5                      ; 000008E2 4BF6 00FF
	bset    #$7,($fe,A5)                          ; 000008E6 08ED 0007 00FE
	move.w  ($16,A5),D0                           ; 000008EC 302D 0016
	bne.s   L_0008E2                              ; 000008F0 66F0
	move.w  (-$390,A6),D0                         ; 000008F2 302E FC70
	move.w  D3,(-$390,A6)                         ; 000008F6 3D43 FC70
	move.w  D0,($16,A5)                           ; 000008FA 3B40 0016
	beq.s   L_000910                              ; 000008FE 6710
	lea     (-$1,A6,D0.w),A0                      ; 00000900 41F6 00FF
	move.b  ($ff,A5),D0                           ; 00000904 102D 00FF
	lsl.w   #8,D0                                 ; 00000908 E148
	addq.w  #1,D0                                 ; 0000090A 5240
	move.w  D0,($44,A0)                           ; 0000090C 3140 0044

L_000910:
	moveq   #$0,D0                                ; 00000910 7000

L_000912:
	ori.b   #$a,(-$127,A6)                        ; 00000912 002E 000A FED9
	bra.s   L_00091C                              ; 00000918 6002

L_00091A:
	moveq   #-$1,D0                               ; 0000091A 70FF

L_00091C:
	ifnd __ATARI__
	ori.b   #$8,($e88015).l                       ; 0000091C 0039 0008 00E8 8015
	endif
	movem.l (A7)+,D1-D7/A0-A6                     ; 00000924 4CDF 7FFE
	rts                                           ; 00000928 4E75

L_00092A:
	movem.l D2/A0,-(A7)                           ; 0000092A 48E7 2080
	swap    D2                                    ; 0000092E 4842
	clr.w   D2                                    ; 00000930 4242
	swap    D2                                    ; 00000932 4842
	lsl.l   #3,D2                                 ; 00000934 E78A
	move.l  L_005B0E(pc),D0                       ; 00000936 203A 51D6
	ble.s   L_00094E                              ; 0000093A 6F12
	movea.l D0,A0                                 ; 0000093C 2040
	move.l  (A0,D2.l),D0                          ; 0000093E 2030 2800
	ble.s   L_00094E                              ; 00000942 6F0A
	move.l  ($4,A0,D2.l),D2                       ; 00000944 2430 2804
	ble.s   L_00094E                              ; 00000948 6F04
	adda.l  D0,A0                                 ; 0000094A D1C0
	bsr.s   L_000954                              ; 0000094C 6106

L_00094E:
	movem.l (A7)+,D2/A0                           ; 0000094E 4CDF 0104
	rts                                           ; 00000952 4E75

L_000954:
	movem.l A1/A6,-(A7)                           ; 00000954 48E7 0042
	lea     L_005E88(pc),A6                       ; 00000958 4DFA 552E
	movea.l A0,A1                                 ; 0000095C 2248
	bsr.w   L_0006EA                              ; 0000095E 6100 FD8A
	tst.b   (-$13c,A6)                            ; 00000962 4A2E FEC4
	beq.s   L_00096E                              ; 00000966 6706
	moveq   #$60,D0                               ; 00000968 7060
	trap    #$f                                   ; 0000096A 4E4F
	bra.s   L_000984                              ; 0000096C 6016

L_00096E:
	swap    D1                                    ; 0000096E 4841
	cmp.b   (-$152,A6),D1                         ; 00000970 B22E FEAE
	bge.s   L_00097A                              ; 00000974 6C04
	swap    D1                                    ; 00000976 4841
	bra.s   L_000984                              ; 00000978 600A

L_00097A:
	move.b  D1,(-$152,A6)                         ; 0000097A 1D41 FEAE
	swap    D1                                    ; 0000097E 4841
	bsr.w   L_004216                              ; 00000980 6100 3894

L_000984:
	ifnd __ATARI__
	ori.b   #$8,($e88015).l                       ; 00000984 0039 0008 00E8 8015
	endif
	movem.l (A7)+,A1/A6                           ; 0000098C 4CDF 4200
	rts                                           ; 00000990 4E75

L_000992:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00000992 48E7 7FFE
	lea     L_005E88(pc),A6                       ; 00000996 4DFA 54F0
	tst.b   (-$13e,A6)                            ; 0000099A 4A2E FEC2
	beq.w   L_000B88                              ; 0000099E 6700 01E8
	tst.b   (-$3b7,A6)                            ; 000009A2 4A2E FC49
	beq.w   L_000B88                              ; 000009A6 6700 01E0
	movea.l (-$382,A6),A4                         ; 000009AA 286E FC7E
	movea.l A4,A0                                 ; 000009AE 204C
	cmpi.l  #$4d44431a,(A0)+                      ; 000009B0 0C98 4D44 431A
	bne.w   L_000B88                              ; 000009B6 6600 01D0
	cmpi.w  #$4,(A0)                              ; 000009BA 0C50 0004
	bcs.w   L_000B88                              ; 000009BE 6500 01C8
	cmpi.w  #$8,(A0)                              ; 000009C2 0C50 0008
	bhi.w   L_000B88                              ; 000009C6 6200 01C0
	bsr.w   L_0006EA                              ; 000009CA 6100 FD1E
	move.w  ($2c,A4),D0                           ; 000009CE 302C 002C
	bne.s   L_0009D6                              ; 000009D2 6602
	moveq   #$30,D0                               ; 000009D4 7030

L_0009D6:
	move.w  D0,(-$68,A6)                          ; 000009D6 3D40 FF98
	move.l  ($28,A4),D0                           ; 000009DA 202C 0028
	bne.s   L_0009E2                              ; 000009DE 6602
	moveq   #-$1,D0                               ; 000009E0 70FF

L_0009E2:
	move.l  D0,(-$64,A6)                          ; 000009E2 2D40 FF9C
	move.l  ($10,A4),D0                           ; 000009E6 202C 0010
	beq.w   L_000B88                              ; 000009EA 6700 019C
	lea     (A4,D0.l),A0                          ; 000009EE 41F4 0800
	movea.l A0,A1                                 ; 000009F2 2248
	move.w  (-$70,A6),D0                          ; 000009F4 302E FF90
	cmp.w   (A0),D0                               ; 000009F8 B050
	bcs.w   L_000B88                              ; 000009FA 6500 018C
	sub.w   (-$6e,A6),D0                          ; 000009FE 906E FF92
	cmp.w   D0,D1                                 ; 00000A02 B240
	bls.s   L_000A0A                              ; 00000A04 6304
	bsr.w   L_000682                              ; 00000A06 6100 FC7A

L_000A0A:
	movea.l A4,A0                                 ; 00000A0A 204C
	moveq   #$0,D0                                ; 00000A0C 7000
	bsr.w   L_002398                              ; 00000A0E 6100 1988
	bmi.w   L_000B88                              ; 00000A12 6B00 0174
	move.w  D0,(-$392,A6)                         ; 00000A16 3D40 FC6E
	moveq   #$0,D0                                ; 00000A1A 7000
	lea     (-$40,A6),A0                          ; 00000A1C 41EE FFC0
	move.l  D0,(A0)+                              ; 00000A20 20C0
	move.l  D0,(A0)+                              ; 00000A22 20C0
	move.l  D0,(A0)+                              ; 00000A24 20C0
	move.l  D0,(A0)+                              ; 00000A26 20C0
	lea     (-$40,A6),A0                          ; 00000A28 41EE FFC0
	move.w  (-$392,A6),D0                         ; 00000A2C 302E FC6E

L_000A30:
	lea     (-$1,A6,D0.w),A1                      ; 00000A30 43F6 00FF
	moveq   #$0,D0                                ; 00000A34 7000
	move.b  ($ff,A1),D0                           ; 00000A36 1029 00FF
	moveq   #$7,D1                                ; 00000A3A 7207
	and.w   D0,D1                                 ; 00000A3C C240
	eor.w   D1,D0                                 ; 00000A3E B340
	eori.w  #$18,D0                               ; 00000A40 0A40 0018
	lsr.w   #3,D0                                 ; 00000A44 E648
	bset    D1,(A0,D0.w)                          ; 00000A46 03F0 0000
	move.w  ($16,A1),D0                           ; 00000A4A 3029 0016
	bne.s   L_000A30                              ; 00000A4E 66E0
	movem.l (-$40,A6),D0-D3                       ; 00000A50 4CEE 000F FFC0
	movem.l D0-D3,(-$3a2,A6)                      ; 00000A56 48EE 000F FC5E
	lea     (-$254,A6),A0                         ; 00000A5C 41EE FDAC
	move.l  A0,(-$38a,A6)                         ; 00000A60 2D48 FC76
	moveq   #$0,D0                                ; 00000A64 7000
	lea     (-$60,A6),A0                          ; 00000A66 41EE FFA0
	move.l  D0,(A0)+                              ; 00000A6A 20C0
	move.l  #$28b1,(A0)+                          ; 00000A6C 20FC 0000 28B1
	move.l  #$f423f,(A0)+                         ; 00000A72 20FC 000F 423F
	move.l  D0,(A0)+                              ; 00000A78 20C0
	move.w  #$78,D1                               ; 00000A7A 323C 0078
	move.w  D1,(-$66,A6)                          ; 00000A7E 3D41 FF9A
	move.w  D1,(-$3b6,A6)                         ; 00000A82 3D41 FC4A
	move.w  D1,(-$3b4,A6)                         ; 00000A86 3D41 FC4C
	move.w  #$80,D1                               ; 00000A8A 323C 0080
	move.w  D1,(-$358,A6)                         ; 00000A8E 3D41 FCA8
	move.w  D1,(-$354,A6)                         ; 00000A92 3D41 FCAC
	move.w  D1,(-$352,A6)                         ; 00000A96 3D41 FCAE
	move.w  D1,(-$350,A6)                         ; 00000A9A 3D41 FCB0
	move.w  D0,(-$6c,A6)                          ; 00000A9E 3D40 FF94
	move.l  D0,(-$336,A6)                         ; 00000AA2 2D40 FCCA
	move.l  D0,(-$33c,A6)                         ; 00000AA6 2D40 FCC4
	move.b  D0,(-$7c,A6)                          ; 00000AAA 1D40 FF84
	move.w  D0,(-$250,A6)                         ; 00000AAE 3D40 FDB0
	move.w  D0,(-$252,A6)                         ; 00000AB2 3D40 FDAE
	move.w  (-$348,A6),(-$346,A6)                 ; 00000AB6 3D6E FCB8 FCBA
	move.w  D0,(-$78,A6)                          ; 00000ABC 3D40 FF88
	bsr.w   L_00343A                              ; 00000AC0 6100 2978
	moveq   #$0,D0                                ; 00000AC4 7000
	bsr.w   L_000DE4                              ; 00000AC6 6100 031C
	moveq   #$0,D1                                ; 00000ACA 7200
	bsr.w   L_00077A                              ; 00000ACC 6100 FCAC
	moveq   #$38,D1                               ; 00000AD0 7238
	moveq   #$0,D2                                ; 00000AD2 7400

L_000AD4:
	bsr.w   L_002BC0                              ; 00000AD4 6100 20EA
	addq.b  #1,D1                                 ; 00000AD8 5201
	cmpi.b  #$40,D1                               ; 00000ADA 0C01 0040
	bne.s   L_000AD4                              ; 00000ADE 66F4
	moveq   #$0,D0                                ; 00000AE0 7000
	lea     L_002304(pc),A0                       ; 00000AE2 41FA 1820
	move.l  D0,(A0)+                              ; 00000AE6 20C0
	move.l  D0,(A0)+                              ; 00000AE8 20C0
	move.l  D0,(A0)+                              ; 00000AEA 20C0
	move.l  D0,(A0)+                              ; 00000AEC 20C0
	move.l  D0,(A0)+                              ; 00000AEE 20C0
	move.l  D0,(A0)+                              ; 00000AF0 20C0
	move.l  D0,(A0)+                              ; 00000AF2 20C0
	move.l  D0,(A0)+                              ; 00000AF4 20C0
	lea     L_001060(pc),A0                       ; 00000AF6 41FA 0568
	move.l  A0,(-$364,A6)                         ; 00000AFA 2D48 FC9C
	move.l  ($20,A4),D0                           ; 00000AFE 202C 0020
	beq.s   L_000B12                              ; 00000B02 670E
	lea     L_000F10(pc),A0                       ; 00000B04 41FA 040A
	move.l  A0,(-$364,A6)                         ; 00000B08 2D48 FC9C
	add.l   A4,D0                                 ; 00000B0C D08C
	move.l  D0,(-$368,A6)                         ; 00000B0E 2D40 FC98

L_000B12:
	tst.b   (-$132,A6)                            ; 00000B12 4A2E FECE
	beq.s   L_000B42                              ; 00000B16 672A
	clr.w   (-$3b8,A6)                            ; 00000B18 426E FC48
	movea.l (-$1ea,A6),A0                         ; 00000B1C 206E FE16
	bset    #$7,($6,A0)                           ; 00000B20 08E8 0007 0006
	tst.b   ($e9a001).l                           ; 00000B26 4A39 00E9 A001
	clr.b   ($eafa03).l                           ; 00000B2C 4239 00EA FA03
	tst.b   ($e9a001).l                           ; 00000B32 4A39 00E9 A001
	move.b  ($6,A0),($eafa0d).l                   ; 00000B38 13E8 0006 00EA FA0D
	bra.s   L_000B6E                              ; 00000B40 602C

L_000B42:
	moveq   #$14,D1                               ; 00000B42 7214
	moveq   #$0,D2                                ; 00000B44 7400
	bsr.w   L_002BC0                              ; 00000B46 6100 2078
	clr.w   (-$3b8,A6)                            ; 00000B4A 426E FC48
	lea     L_002A26(pc),A0                       ; 00000B4E 41FA 1ED6
	ifnd __ATARI__
	move.l  A0,($10c).w                           ; 00000B52 21C8 010C
	endif
	moveq   #$14,D1                               ; 00000B56 7214
	moveq   #$3f,D2                               ; 00000B58 743F
	bsr.w   L_002BC0                              ; 00000B5A 6100 2064
	ifnd __ATARI__
	bset    #$3,($e88009).l                       ; 00000B5E 08F9 0003 00E8 8009
	bset    #$3,($e88015).l                       ; 00000B66 08F9 0003 00E8 8015
	endif

L_000B6E:
	move.w  #$2,(-$80,A6)                         ; 00000B6E 3D7C 0002 FF80
	moveq   #$3,D0                                ; 00000B74 7003
	bsr.w   L_00083A                              ; 00000B76 6100 FCC2
	move.l  (-$340,A6),D1                         ; 00000B7A 222E FCC0
	beq.s   L_000B84                              ; 00000B7E 6704
	bsr.w   L_00062C                              ; 00000B80 6100 FAAA

L_000B84:
	moveq   #$0,D0                                ; 00000B84 7000
	bra.s   L_000B98                              ; 00000B86 6010

L_000B88:
	moveq   #$0,D0                                ; 00000B88 7000
	lea     (-$40,A6),A0                          ; 00000B8A 41EE FFC0
	move.l  D0,(A0)+                              ; 00000B8E 20C0
	move.l  D0,(A0)+                              ; 00000B90 20C0
	move.l  D0,(A0)+                              ; 00000B92 20C0
	move.l  D0,(A0)+                              ; 00000B94 20C0
	moveq   #-$1,D0                               ; 00000B96 70FF

L_000B98:
	movem.l (A7)+,D1-D7/A0-A6                     ; 00000B98 4CDF 7FFE
	rts                                           ; 00000B9C 4E75

L_000B9E:
	movem.l D0-D2/A0/A2,-(A7)                     ; 00000B9E 48E7 E0A0
	moveq   #$f,D1                                ; 00000BA2 720F
	moveq   #$0,D2                                ; 00000BA4 7400
	bsr.w   L_002BC0                              ; 00000BA6 6100 2018
	moveq   #$20,D1                               ; 00000BAA 7220
	moveq   #$0,D2                                ; 00000BAC 7400

L_000BAE:
	bsr.w   L_002BC0                              ; 00000BAE 6100 2010
	addq.b  #1,D1                                 ; 00000BB2 5201
	cmpi.b  #$40,D1                               ; 00000BB4 0C01 0040
	bne.s   L_000BAE                              ; 00000BB8 66F4
	moveq   #-$1,D2                               ; 00000BBA 74FF

L_000BBC:
	bsr.w   L_002BC0                              ; 00000BBC 6100 2002
	addq.b  #1,D1                                 ; 00000BC0 5201
	bcc.s   L_000BBC                              ; 00000BC2 64F8
	ifnd __ATARI__
	andi.b  #$fc,($9da).w                         ; 00000BC4 0238 00FC 09DA
	else
	andi.b  #$fc,mcdrv_opm_1b
	endif
	ifnd __ATARI__
	move.b  ($9da).w,D2                           ; 00000BCA 1438 09DA
	else
	move.b  mcdrv_opm_1b,D2
	endif
	moveq   #$1b,D1                               ; 00000BCE 721B
	bsr.w   L_002BC0                              ; 00000BD0 6100 1FEE
	movem.l (A7)+,D0-D2/A0/A2                     ; 00000BD4 4CDF 0507
	rts                                           ; 00000BD8 4E75

L_000BDA:
	movem.l D0-D7/A0-A6,-(A7)                     ; 00000BDA 48E7 FFFE
	lea     L_005E88(pc),A6                       ; 00000BDE 4DFA 52A8
	move.w  (-$ffe,A6),D0                         ; 00000BE2 302E F002
	bmi.s   L_000BEE                              ; 00000BE6 6B06
	moveq   #-$1,D7                               ; 00000BE8 7EFF
	bsr.w   L_000F6C                              ; 00000BEA 6100 0380

L_000BEE:
	movem.l (A7)+,D0-D7/A0-A6                     ; 00000BEE 4CDF 7FFF
	rts                                           ; 00000BF2 4E75

L_000BF4:
	tst.b   ($e88001).l                           ; 00000BF4 4A39 00E8 8001
	bpl.s   L_000BF4                              ; 00000BFA 6AF8

L_000BFC:
	tst.b   ($e88001).l                           ; 00000BFC 4A39 00E8 8001
	bmi.s   L_000BFC                              ; 00000C02 6BF8
	dbra    D0,L_000BF4                           ; 00000C04 51C8 FFEE
	rts                                           ; 00000C08 4E75

L_000C0A:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00000C0A 48E7 7FFE
	lea     L_005E88(pc),A6                       ; 00000C0E 4DFA 5278
	tst.w   (-$256,A6)                            ; 00000C12 4A6E FDAA
	bne.w   L_000D04                              ; 00000C16 6600 00EC
	moveq   #-$1,D0                               ; 00000C1A 70FF
	bsr.w   L_00083A                              ; 00000C1C 6100 FC1C
	bsr.w   L_002822                              ; 00000C20 6100 1C00
	move    SR,-(A7)                              ; 00000C24 40E7
	ori     #$700,SR                              ; 00000C26 007C 0700
	moveq   #$14,D1                               ; 00000C2A 7214
	moveq   #$30,D2                               ; 00000C2C 7430
	bsr.w   L_002BC0                              ; 00000C2E 6100 1F90
	bsr.w   L_000B9E                              ; 00000C32 6100 FF6A
	bsr.s   L_000BDA                              ; 00000C36 61A2
	tst.b   (-$13c,A6)                            ; 00000C38 4A2E FEC4
	beq.s   L_000C4A                              ; 00000C3C 670C
	move.w  #$101,D0                              ; 00000C3E 303C 0101
	trap    #$2                                   ; 00000C42 4E42
	move.w  #$100,D0                              ; 00000C44 303C 0100
	trap    #$2                                   ; 00000C48 4E42

L_000C4A:
	ifnd __ATARI__
	bclr    #$3,($e88009).l                       ; 00000C4A 08B9 0003 00E8 8009
	endif
	ifnd __ATARI__
	move.l  (-$25e,A6),D0                         ; 00000C52 202E FDA2
	cmp.l   ($90).w,D0                            ; 00000C56 B0B8 0090
	bne.w   L_000D04                              ; 00000C5A 6600 00A8
	move.l  (-$262,A6),($90).w                    ; 00000C5E 21EE FD9E 0090
	tst.b   (-$132,A6)                            ; 00000C64 4A2E FECE
	bne.s   L_000C70                              ; 00000C68 6606
	move.l  (-$266,A6),($10c).w                   ; 00000C6A 21EE FD9A 010C
	endif

L_000C70:
	move    (A7)+,SR                              ; 00000C70 46DF
	moveq   #-$80,D6                              ; 00000C72 7C80
	move.b  #$fe,-(A7)                            ; 00000C74 1F3C 00FE

L_000C78:
	movea.l A7,A0                                 ; 00000C78 204F
	moveq   #$0,D0                                ; 00000C7A 7000
	bsr.w   L_0005A6                              ; 00000C7C 6100 F928
	add.b   #$10,D6                               ; 00000C80 DC3C 0010
	bcc.s   L_000C78                              ; 00000C84 64F2
	addq.l  #2,A7                                 ; 00000C86 548F
	btst    #$1,(-$13a,A6)                        ; 00000C88 082E 0001 FEC6
	beq.s   L_000CA0                              ; 00000C8E 6710
	movea.l (-$1ea,A6),A0                         ; 00000C90 206E FE16
	bsr.s   L_000D0C                              ; 00000C94 6176
	movea.l #$eafa01,A0                           ; 00000C96 207C 00EA FA01
	bsr.w   L_004876                              ; 00000C9C 6100 3BD8

L_000CA0:
	btst    #$2,(-$13a,A6)                        ; 00000CA0 082E 0002 FEC6
	beq.s   L_000CB8                              ; 00000CA6 6710
	movea.l (-$1e6,A6),A0                         ; 00000CA8 206E FE1A
	bsr.s   L_000D0C                              ; 00000CAC 615E
	movea.l #$eafa11,A0                           ; 00000CAE 207C 00EA FA11
	bsr.w   L_004876                              ; 00000CB4 6100 3BC0

L_000CB8:
	btst    #$3,(-$13a,A6)                        ; 00000CB8 082E 0003 FEC6
	beq.s   L_000CCA                              ; 00000CBE 670A
	movea.l (-$1e2,A6),A0                         ; 00000CC0 206E FE1E
	bsr.s   L_000D0C                              ; 00000CC4 6146
	bsr.w   L_00461A                              ; 00000CC6 6100 3952

L_000CCA:
	btst    #$4,(-$13a,A6)                        ; 00000CCA 082E 0004 FEC6
	beq.s   L_000CD8                              ; 00000CD0 6706
	move.w  #$302,D0                              ; 00000CD2 303C 0302
	trap    #$2                                   ; 00000CD6 4E42

L_000CD8:
	move.l  (-$1ca,A6),-(A7)                      ; 00000CD8 2F2E FE36
	beq.s   L_000CE0                              ; 00000CDC 6702
	dc.w    $ff49                                 ; 00000CDE FF49

L_000CE0:
	addq.l  #4,A7                                 ; 00000CE0 588F
	tst.b   (-$13c,A6)                            ; 00000CE2 4A2E FEC4
	beq.s   L_000CF0                              ; 00000CE6 6708
	move.w  #$1ff,D0                              ; 00000CE8 303C 01FF
	trap    #$2                                   ; 00000CEC 4E42
	bra.s   L_000CFA                              ; 00000CEE 600A

L_000CF0:
	bsr.w   L_0041AA                              ; 00000CF0 6100 34B8
	ifnd __ATARI__
	move.l  (-$25a,A6),($88).w                    ; 00000CF4 21EE FDA6 0088
	endif

L_000CFA:
	pea     L_000000-$F0(pc)                      ; 00000CFA 487A F214
	dc.w    $ff49                                 ; 00000CFE FF49
	addq.l  #4,A7                                 ; 00000D00 588F
	bra.s   L_000D06                              ; 00000D02 6002

L_000D04:
	moveq   #-$1,D0                               ; 00000D04 70FF

L_000D06:
	movem.l (A7)+,D1-D7/A0-A6                     ; 00000D06 4CDF 7FFE
	rts                                           ; 00000D0A 4E75

L_000D0C:
	moveq   #$63,D1                               ; 00000D0C 7263

L_000D0E:
	tst.b   ($e,A0)                               ; 00000D0E 4A28 000E
	bne.s   L_000D16                              ; 00000D12 6602
	moveq   #$0,D1                                ; 00000D14 7200

L_000D16:
	moveq   #$1,D0                                ; 00000D16 7001
	bsr.w   L_000BF4                              ; 00000D18 6100 FEDA
	dbra    D1,L_000D0E                           ; 00000D1C 51C9 FFF0
	rts                                           ; 00000D20 4E75

L_000D22:
	dc.b    $4D,$49,$44,$49,$83,$43,$83,$93,$83,$5E,$81,$5B,$83,$74,$83,$46; 00000D22
	dc.b    $81,$5B,$83,$58,$20                   ; 00000D32

L_000D37:
	dc.b    $42,$4F,$41,$52,$44,$23,$31,$00,$42,$4F,$41,$52,$44,$23,$32,$00; 00000D37
	dc.b    $52,$53,$4D,$49,$44,$49,$00,$50,$4F,$4C,$59,$50,$48,$4F,$4E,$00; 00000D47
	dc.b    $49,$4E,$54,$45,$52,$4E,$41,$4C,$00,$54,$4D,$53,$49,$4F,$00; 00000D57

L_000D66:
	dc.b    $82,$C9,$82,$E6,$82,$E9,$8F,$6F,$97,$CD,$82,$AA,$89,$C2,$94,$5C; 00000D66
	dc.b    $82,$C5,$82,$B7,$0D,$0A,$00           ; 00000D76

L_000D7D:
	dc.b    $4D,$43,$44,$52,$56,$82,$AA,$8F,$ED,$92,$93,$82,$B5,$82,$DC,$82; 00000D7D
	dc.b    $B7,$0D,$0A,$0D,$0A,$00               ; 00000D8D

L_000D93:
	dc.b    $83,$81,$83,$82,$83,$8A,$82,$AA,$8A,$6D,$95,$DB,$82,$C5,$82,$AB; 00000D93
	dc.b    $82,$DC,$82,$B9,$82,$F1,$82,$C5,$82,$B5,$82,$BD,$0D,$0A,$0D,$0A; 00000DA3

L_000DB3:
	dc.b    $41,$44,$50,$43,$4D,$82,$CC,$91,$BD,$8F,$64,$2C,$89,$B9,$97,$CA; 00000DB3
	dc.b    $00,$26,$89,$B9,$92,$F6               ; 00000DC3

L_000DC9:
	dc.b    $95,$CF,$8A,$B7,$82,$C9,$82,$E6,$82,$E9,$8F,$6F,$97,$CD,$82,$AA; 00000DC9
	dc.b    $89,$C2,$94,$5C,$82,$C5,$82,$B7,$0D,$0A,$00; 00000DD9

L_000DE4:
	move.l  D0,(-$360,A6)                         ; 00000DE4 2D40 FCA0
	seq     D0                                    ; 00000DE8 57C0
	bge.s   L_000DEE                              ; 00000DEA 6C02
	addq.b  #1,D0                                 ; 00000DEC 5200

L_000DEE:
	addq.b  #1,D0                                 ; 00000DEE 5200
	move.b  D0,(-$7b,A6)                          ; 00000DF0 1D40 FF85
	rts                                           ; 00000DF4 4E75

L_000DF6:
	movem.l D0/A0/A5,-(A7)                        ; 00000DF6 48E7 8084
	move.w  (-$358,A6),D0                         ; 00000DFA 302E FCA8
	mulu.w  (-$354,A6),D0                         ; 00000DFE C0EE FCAC
	lsr.w   #7,D0                                 ; 00000E02 EE48
	move.w  D0,(-$352,A6)                         ; 00000E04 3D40 FCAE
	lea     L_000E8E(pc),A0                       ; 00000E08 41FA 0084
	move.b  (A0,D0.w),D0                          ; 00000E0C 1030 0000
	move.w  D0,(-$350,A6)                         ; 00000E10 3D40 FCB0
	move.w  (-$392,A6),D0                         ; 00000E14 302E FC6E
	beq.s   L_000E26                              ; 00000E18 670C

L_000E1A:
	lea     (-$1,A6,D0.w),A5                      ; 00000E1A 4BF6 00FF
	bsr.s   L_000E2C                              ; 00000E1E 610C
	move.w  ($16,A5),D0                           ; 00000E20 302D 0016
	bne.s   L_000E1A                              ; 00000E24 66F4

L_000E26:
	movem.l (A7)+,D0/A0/A5                        ; 00000E26 4CDF 2101
	rts                                           ; 00000E2A 4E75

L_000E2C:
	movem.l D0-D1,-(A7)                           ; 00000E2C 48E7 C000
	moveq   #$0,D0                                ; 00000E30 7000
	move.w  #$4000,D1                             ; 00000E32 323C 4000
	tst.b   ($3,A5)                               ; 00000E36 4A2D 0003
	bpl.s   L_000E54                              ; 00000E3A 6A18
	tst.b   ($fe,A5)                              ; 00000E3C 4A2D 00FE
	bmi.s   L_000E4A                              ; 00000E40 6B08
	move.w  (-$352,A6),D1                         ; 00000E42 322E FCAE
	mulu.w  (-$346,A6),D1                         ; 00000E46 C2EE FCBA

L_000E4A:
	move.b  ($f5,A5),D0                           ; 00000E4A 102D 00F5
	mulu.w  D0,D1                                 ; 00000E4E C2C0
	lsr.l   #7,D1                                 ; 00000E50 EE89
	bra.s   L_000E7A                              ; 00000E52 6026

L_000E54:
	tst.b   ($fe,A5)                              ; 00000E54 4A2D 00FE
	bmi.s   L_000E62                              ; 00000E58 6B08
	move.w  (-$350,A6),D1                         ; 00000E5A 322E FCB0
	mulu.w  (-$346,A6),D1                         ; 00000E5E C2EE FCBA

L_000E62:
	move.b  ($2b,A5),D0                           ; 00000E62 102D 002B
	move.b  L_000E8E(pc,D0.w),D0                  ; 00000E66 103B 0026
	mulu.w  D0,D1                                 ; 00000E6A C2C0
	lsl.l   #2,D1                                 ; 00000E6C E589
	swap    D1                                    ; 00000E6E 4841
	move.b  ($f5,A5),D0                           ; 00000E70 102D 00F5
	move.b  L_000E8E(pc,D0.w),D0                  ; 00000E74 103B 0018
	mulu.w  D0,D1                                 ; 00000E78 C2C0

L_000E7A:
	move.b  ($22,A5),D0                           ; 00000E7A 102D 0022
	mulu.w  D1,D0                                 ; 00000E7E C0C1
	lsl.l   #2,D0                                 ; 00000E80 E588
	swap    D0                                    ; 00000E82 4840
	move.b  D0,($7,A5)                            ; 00000E84 1B40 0007
	movem.l (A7)+,D0-D1                           ; 00000E88 4CDF 0003
	rts                                           ; 00000E8C 4E75

L_000E8E:
	dc.b    $00,$56,$56,$57,$57,$57,$58,$58,$58,$59,$59,$59,$5A,$5A,$5A,$5B; 00000E8E
	dc.b    '[[\\\]]]^^^___``'                    ; 00000E9E
	dc.b    '`aaabbbcccdddeee'                    ; 00000EAE
	dc.b    'fffggghhhiiijjjk'                    ; 00000EBE
	dc.b    'kklllmmmnnnooopp'                    ; 00000ECE
	dc.b    'pqqqrrrssstttuuu'                    ; 00000EDE
	dc.b    'vvvwwwxxxyyyzzz{'                    ; 00000EEE
	dc.b    $7B,$7B,$7C,$7C,$7C,$7D,$7D,$7D,$7E,$7E,$7E,$7F,$7F,$7F,$80,$80; 00000EFE
	dc.b    $80,$00                               ; 00000F0E

L_000F10:
	movem.l D0-D7/A0-A5,-(A7)                     ; 00000F10 48E7 FFFC
	move.l  (-$1d2,A6),D0                         ; 00000F14 202E FE2E
	beq.s   L_000F54                              ; 00000F18 673A
	movea.l (-$368,A6),A0                         ; 00000F1A 206E FC98
	cmpi.b  #-$2,(A0)                             ; 00000F1E 0C10 00FE
	beq.s   L_000F54                              ; 00000F22 6730
	movea.l A0,A1                                 ; 00000F24 2248
	moveq   #-$9,D1                               ; 00000F26 72F7

L_000F28:
	cmp.b   (A1)+,D1                              ; 00000F28 B219
	bne.s   L_000F28                              ; 00000F2A 66FC
	move.l  A1,(-$368,A6)                         ; 00000F2C 2D49 FC98
	move.l  A1,D0                                 ; 00000F30 2009
	sub.l   A0,D0                                 ; 00000F32 9088
	move.l  D0,D2                                 ; 00000F34 2400
	subq.w  #1,D0                                 ; 00000F36 5340
	beq.s   L_000F40                              ; 00000F38 6706
	moveq   #-$80,D6                              ; 00000F3A 7C80
	bsr.w   L_0005A6                              ; 00000F3C 6100 F668

L_000F40:
	move.w  (-$36a,A6),D0                         ; 00000F40 302E FC96
	mulu.w  #$3e8,D0                              ; 00000F44 C0FC 03E8
	mulu.w  #$140,D2                              ; 00000F48 C4FC 0140
	add.l   D2,D0                                 ; 00000F4C D082
	bsr.w   L_001B8C                              ; 00000F4E 6100 0C3C
	bra.s   L_000F66                              ; 00000F52 6012

L_000F54:
	move.l  #$3e8,D0                              ; 00000F54 203C 0000 03E8
	bsr.w   L_001B8C                              ; 00000F5A 6100 0C30
	lea     L_001060(pc),A0                       ; 00000F5E 41FA 0100
	move.l  A0,(-$364,A6)                         ; 00000F62 2D48 FC9C

L_000F66:
	movem.l (A7)+,D0-D7/A0-A5                     ; 00000F66 4CDF 3FFF
	rts                                           ; 00000F6A 4E75

L_000F6C:
	lea     (-$ff0,A6),A3                         ; 00000F6C 47EE F010

L_000F70:
	lea     (A3,D0.w),A1                          ; 00000F70 43F3 0000
	sub.w   D7,(A1)+                              ; 00000F74 9F59
	bls.s   L_000F7E                              ; 00000F76 6306

L_000F78:
	move.w  (A1),D0                               ; 00000F78 3011
	bpl.s   L_000F70                              ; 00000F7A 6AF4
	rts                                           ; 00000F7C 4E75

L_000F7E:
	tst.b   ($b,A1)                               ; 00000F7E 4A29 000B
	bmi.s   L_000F8E                              ; 00000F82 6B0A
	moveq   #$7c,D0                               ; 00000F84 707C
	and.w   ($8,A1),D0                            ; 00000F86 C069 0008
	jsr     L_000FF4(pc,D0.w)                     ; 00000F8A 4EBB 0068

L_000F8E:
	lea     (-$7e2,A6),A0                         ; 00000F8E 41EE F81E
	move.w  (A0),D0                               ; 00000F92 3010
	moveq   #$0,D1                                ; 00000F94 7200
	move.w  ($a,A1),D1                            ; 00000F96 3229 000A
	andi.w  #$ff7f,D1                             ; 00000F9A 0241 FF7F
	swap    D1                                    ; 00000F9E 4841
	move.b  ($8,A1),D1                            ; 00000FA0 1229 0008
	move.l  D1,($2,A0,D0.w)                       ; 00000FA4 2181 0002
	addq.w  #4,D0                                 ; 00000FA8 5840
	andi.w  #$3ff,D0                              ; 00000FAA 0240 03FF
	move.w  D0,(A0)                               ; 00000FAE 3080
	move.l  A1,D2                                 ; 00000FB0 2409
	sub.l   A3,D2                                 ; 00000FB2 948B
	subq.w  #2,D2                                 ; 00000FB4 5542
	movem.w ($4,A1),D0-D1                         ; 00000FB6 4CA9 0003 0004
	move.w  D0,($6,A3,D1.w)                       ; 00000FBC 3780 1006
	move.w  D1,($8,A3,D0.w)                       ; 00000FC0 3781 0008
	bpl.s   L_000FD0                              ; 00000FC4 6A0A
	move.w  ($a,A1),D1                            ; 00000FC6 3229 000A
	clr.b   D1                                    ; 00000FCA 4201
	move.w  D0,($46,A6,D1.w)                      ; 00000FCC 3D80 1046

L_000FD0:
	move.w  ($a,A1),D1                            ; 00000FD0 3229 000A
	clr.b   D1                                    ; 00000FD4 4201
	subq.b  #1,($2f,A6,D1.w)                      ; 00000FD6 5336 102F
	movem.w (A1),D0-D1                            ; 00000FDA 4C91 0003
	move.w  D0,($2,A3,D1.w)                       ; 00000FDE 3780 1002
	move.w  D1,($4,A3,D0.w)                       ; 00000FE2 3781 0004
	move.w  (-$ff4,A6),(A1)                       ; 00000FE6 32AE F00C
	move.w  D2,(-$ff4,A6)                         ; 00000FEA 3D42 F00C
	lea     ($2,A3,D1.w),A1                       ; 00000FEE 43F3 1002
	bra.s   L_000F78                              ; 00000FF2 6084

L_000FF4:
	bra.w   L_001004                              ; 00000FF4 6000 000E

L_000FF8:
	bra.w   L_00101A                              ; 00000FF8 6000 0020

L_000FFC:
	bra.w   L_001024                              ; 00000FFC 6000 0026

L_001000:
	bra.w   L_00103C                              ; 00001000 6000 003A

L_001004:
	moveq   #$8,D0                                ; 00001004 7008
	bsr.w   L_002BAC                              ; 00001006 6100 1BA4
	moveq   #$7,D0                                ; 0000100A 7007
	and.b   ($8,A1),D0                            ; 0000100C C029 0008
	bclr    D0,(-$7f0,A6)                         ; 00001010 01AE F810
	bsr.w   L_002BB6                              ; 00001014 6100 1BA0
	rts                                           ; 00001018 4E75

L_00101A:
	clr.w   (-$7ee,A6)                            ; 0000101A 426E F812
	bsr.w   L_004408                              ; 0000101E 6100 33E8
	rts                                           ; 00001022 4E75

L_001024:
	moveq   #$f,D0                                ; 00001024 700F
	and.b   ($8,A1),D0                            ; 00001026 C029 0008
	move.w  (-$7ee,A6),D1                         ; 0000102A 322E F812
	bclr    D0,D1                                 ; 0000102E 0181
	move.w  D1,(-$7ee,A6)                         ; 00001030 3D41 F812
	moveq   #$0,D1                                ; 00001034 7200
	moveq   #$0,D2                                ; 00001036 7400
	trap    #$2                                   ; 00001038 4E42
	rts                                           ; 0000103A 4E75

L_00103C:
	subq.l  #4,A7                                 ; 0000103C 598F
	movea.l A7,A0                                 ; 0000103E 204F
	move.b  ($8,A1),D6                            ; 00001040 1C29 0008
	moveq   #$f,D0                                ; 00001044 700F
	and.b   D6,D0                                 ; 00001046 C006
	ori.b   #$90,D0                               ; 00001048 0000 0090
	move.b  D0,(A0)+                              ; 0000104C 10C0
	move.b  ($b,A1),(A0)+                         ; 0000104E 10E9 000B
	sf      (A0)+                                 ; 00001052 51D8
	movea.l A7,A0                                 ; 00001054 204F
	moveq   #$2,D0                                ; 00001056 7002
	bsr.w   L_0005A6                              ; 00001058 6100 F54C
	addq.l  #4,A7                                 ; 0000105C 588F
	rts                                           ; 0000105E 4E75

L_001060:
	move.w  (-$392,A6),D0                         ; 00001060 302E FC6E
	beq.w   L_0014F2                              ; 00001064 6700 048C
	moveq   #$0,D6                                ; 00001068 7C00
	moveq   #$1,D7                                ; 0000106A 7E01
	move.l  (-$33c,A6),D0                         ; 0000106C 202E FCC4
	beq.w   L_001118                              ; 00001070 6700 00A6
	tst.b   (-$12e,A6)                            ; 00001074 4A2E FED2
	beq.s   L_001082                              ; 00001078 6708
	subq.l  #1,(-$33c,A6)                         ; 0000107A 53AE FCC4
	bra.w   L_001118                              ; 0000107E 6000 0098

L_001082:
	moveq   #-$1,D6                               ; 00001082 7CFF
	cmp.l   D0,D7                                 ; 00001084 BE80
	beq.s   L_00108C                              ; 00001086 6704
	bsr.w   L_00151A                              ; 00001088 6100 0490

L_00108C:
	move.w  (-$392,A6),D0                         ; 0000108C 302E FC6E
	lea     L_0012D6(pc),A1                       ; 00001090 43FA 0244

L_001094:
	lea     (-$1,A6,D0.w),A0                      ; 00001094 41F6 00FF
	move.l  A1,($c,A0)                            ; 00001098 2149 000C
	move.w  ($16,A0),D0                           ; 0000109C 3028 0016
	bne.s   L_001094                              ; 000010A0 66F2

L_0010A2:
	moveq   #$0,D7                                ; 000010A2 7E00
	not.w   D7                                    ; 000010A4 4647
	move.w  (-$392,A6),D0                         ; 000010A6 302E FC6E
	beq.w   L_0014F2                              ; 000010AA 6700 0446

L_0010AE:
	lea     (-$1,A6,D0.w),A0                      ; 000010AE 41F6 00FF
	cmp.w   ($a,A0),D7                            ; 000010B2 BE68 000A
	bls.s   L_0010C2                              ; 000010B6 630A
	move.w  ($a,A0),D7                            ; 000010B8 3E28 000A
	cmpi.w  #$1,D7                                ; 000010BC 0C47 0001
	beq.s   L_0010D2                              ; 000010C0 6710

L_0010C2:
	move.w  ($16,A0),D0                           ; 000010C2 3028 0016
	bne.s   L_0010AE                              ; 000010C6 66E6
	cmp.l   (-$33c,A6),D7                         ; 000010C8 BEAE FCC4
	bls.s   L_0010D2                              ; 000010CC 6304
	move.l  (-$33c,A6),D7                         ; 000010CE 2E2E FCC4

L_0010D2:
	sub.l   D7,(-$33c,A6)                         ; 000010D2 9FAE FCC4
	move.w  D7,(-$338,A6)                         ; 000010D6 3D47 FCC8
	move.w  (-$392,A6),D0                         ; 000010DA 302E FC6E
	bsr.s   L_001118                              ; 000010DE 6138
	tst.l   (-$33c,A6)                            ; 000010E0 4AAE FCC4
	bne.s   L_0010A2                              ; 000010E4 66BC
	move.w  (-$392,A6),D0                         ; 000010E6 302E FC6E
	beq.w   L_0014F2                              ; 000010EA 6700 0406

L_0010EE:
	lea     (-$1,A6,D0.w),A0                      ; 000010EE 41F6 00FF
	move.w  ($2,A0),D0                            ; 000010F2 3028 0002
	bmi.s   L_00110E                              ; 000010F6 6B16
	and.w   #$f0,D0                               ; 000010F8 C07C 00F0
	lsr.w   #3,D0                                 ; 000010FC E648
	lea     L_0024D6(pc),A1                       ; 000010FE 43FA 13D6
	move.w  (A1,D0.w),D0                          ; 00001102 3031 0000
	lea     (A1,D0.w),A1                          ; 00001106 43F1 0000
	move.l  A1,($c,A0)                            ; 0000110A 2149 000C

L_00110E:
	move.w  ($16,A0),D0                           ; 0000110E 3028 0016
	bne.s   L_0010EE                              ; 00001112 66DA
	moveq   #$0,D6                                ; 00001114 7C00
	moveq   #$1,D7                                ; 00001116 7E01

L_001118:
	lea     (-$60,A6),A0                          ; 00001118 41EE FFA0
	add.l   D7,(A0)+                              ; 0000111C DF98
	move.l  (A0)+,D0                              ; 0000111E 2018
	move.l  D7,D3                                 ; 00001120 2607

L_001122:
	sub.l   D0,(A0)                               ; 00001122 9190
	bcc.s   L_00114A                              ; 00001124 6424
	addi.l  #$f4240,(A0)                          ; 00001126 0690 000F 4240
	move.l  ($4,A0),D1                            ; 0000112C 2228 0004
	cmpi.w  #$3b,D1                               ; 00001130 0C41 003B
	bcs.s   L_00113A                              ; 00001134 6504
	move.w  #$ffff,D1                             ; 00001136 323C FFFF

L_00113A:
	addq.l  #1,D1                                 ; 0000113A 5281
	move.l  D1,($4,A0)                            ; 0000113C 2141 0004
	move.l  D0,-(A7)                              ; 00001140 2F00
	moveq   #$7,D0                                ; 00001142 7007
	bsr.w   L_00083A                              ; 00001144 6100 F6F4
	move.l  (A7)+,D0                              ; 00001148 201F

L_00114A:
	move.l  (-$360,A6),D2                         ; 0000114A 242E FCA0
	beq.s   L_00118A                              ; 0000114E 673A
	add.l   D2,(-$35c,A6)                         ; 00001150 D5AE FCA4
	move.w  (-$35c,A6),D1                         ; 00001154 322E FCA4
	cmp.w   (-$358,A6),D1                         ; 00001158 B26E FCA8
	beq.s   L_00118A                              ; 0000115C 672C
	tst.l   D2                                    ; 0000115E 4A82
	bpl.s   L_001174                              ; 00001160 6A12
	tst.w   D1                                    ; 00001162 4A41
	bgt.s   L_001182                              ; 00001164 6E1C
	moveq   #$0,D0                                ; 00001166 7000
	bsr.w   L_000DE4                              ; 00001168 6100 FC7A
	bsr.w   L_0006C8                              ; 0000116C 6100 F55A
	bra.w   L_0014F2                              ; 00001170 6000 0380

L_001174:
	tst.b   D1                                    ; 00001174 4A01
	bpl.s   L_001182                              ; 00001176 6A0A
	moveq   #$0,D0                                ; 00001178 7000
	bsr.w   L_000DE4                              ; 0000117A 6100 FC68
	move.w  #$80,D1                               ; 0000117E 323C 0080

L_001182:
	move.w  D1,(-$358,A6)                         ; 00001182 3D41 FCA8
	bsr.w   L_000DF6                              ; 00001186 6100 FC6E

L_00118A:
	subq.w  #1,D3                                 ; 0000118A 5343
	bne.s   L_001122                              ; 0000118C 6694

L_00118E:
	moveq   #$0,D5                                ; 0000118E 7A00
	move.w  (-$ffe,A6),D0                         ; 00001190 302E F002
	bmi.s   L_00119A                              ; 00001194 6B04
	bsr.w   L_000F6C                              ; 00001196 6100 FDD4

L_00119A:
	move.w  (-$392,A6),D0                         ; 0000119A 302E FC6E

L_00119E:
	lea     (-$1,A6,D0.w),A5                      ; 0000119E 4BF6 00FF
	movea.l A5,A3                                 ; 000011A2 264D
	tst.w   (A3)+                                 ; 000011A4 4A5B
	bne.s   L_0011D0                              ; 000011A6 6628
	move.w  (A3)+,D6                              ; 000011A8 3C1B
	move.w  (A3)+,D5                              ; 000011AA 3A1B
	move.w  (A3)+,D4                              ; 000011AC 381B
	move.w  (A3)+,D3                              ; 000011AE 361B
	bne.s   L_0011DE                              ; 000011B0 662C
	sub.w   D7,(A3)+                              ; 000011B2 9F5B
	beq.w   L_00128A                              ; 000011B4 6700 00D4
	lea     ($4,A3),A0                            ; 000011B8 41EB 0004
	cmp.l   (A0)+,D5                              ; 000011BC BA98
	bne.w   L_001286                              ; 000011BE 6600 00C6
	cmp.w   (A0)+,D4                              ; 000011C2 B858
	bne.w   L_001286                              ; 000011C4 6600 00C0
	move.w  (A0)+,D0                              ; 000011C8 3018
	bne.s   L_00119E                              ; 000011CA 66D2
	bra.w   L_0014F2                              ; 000011CC 6000 0324

L_0011D0:
	move.w  ($16,A5),D0                           ; 000011D0 302D 0016
	bne.s   L_00119E                              ; 000011D4 66C8
	bra.w   L_0014F2                              ; 000011D6 6000 031A

L_0011DA:
	move.w  ($8,A5),D3                            ; 000011DA 362D 0008

L_0011DE:
	bpl.s   L_0011E8                              ; 000011DE 6A08
	lea     ($80,A5),A1                           ; 000011E0 43ED 0080
	movea.l (A1)+,A0                              ; 000011E4 2059
	jmp     (A0)                                  ; 000011E6 4ED0

L_0011E8:
	add.w   D3,D3                                 ; 000011E8 D643
	bpl.s   L_0011F4                              ; 000011EA 6A08
	lea     ($9a,A5),A1                           ; 000011EC 43ED 009A
	movea.l (A1)+,A0                              ; 000011F0 2059
	jmp     (A0)                                  ; 000011F2 4ED0

L_0011F4:
	add.w   D3,D3                                 ; 000011F4 D643
	bpl.s   L_001218                              ; 000011F6 6A20
	lea     ($d2,A5),A0                           ; 000011F8 41ED 00D2
	subq.w  #1,(A0)+                              ; 000011FC 5358
	bne.s   L_001212                              ; 000011FE 6612
	clr.l   (A0)+                                 ; 00001200 4298
	move.w  (A0),D0                               ; 00001202 3010
	add.w   D0,D5                                 ; 00001204 DA40
	add.w   D0,($4,A5)                            ; 00001206 D16D 0004
	andi.w  #$dfff,($8,A5)                        ; 0000120A 026D DFFF 0008
	bra.s   L_001218                              ; 00001210 6006

L_001212:
	move.l  (A0)+,D0                              ; 00001212 2018
	add.l   D0,(A0)                               ; 00001214 D190
	add.w   (A0),D5                               ; 00001216 DA50

L_001218:
	add.w   D3,D3                                 ; 00001218 D643
	bpl.s   L_001246                              ; 0000121A 6A2A
	subq.b  #1,($f4,A5)                           ; 0000121C 532D 00F4
	bcc.s   L_001246                              ; 00001220 6424
	move.b  ($f3,A5),($f4,A5)                     ; 00001222 1B6D 00F3 00F4
	subq.b  #2,($f5,A5)                           ; 00001228 552D 00F5
	bne.s   L_00123A                              ; 0000122C 660C
	bsr.w   L_001A42                              ; 0000122E 6100 0812
	lea     ($16,A5),A3                           ; 00001232 47ED 0016
	bra.w   L_0014EC                              ; 00001236 6000 02B4

L_00123A:
	sub.w   ($6,A5),D4                            ; 0000123A 986D 0006
	bsr.w   L_000E2C                              ; 0000123E 6100 FBEC
	add.w   ($6,A5),D4                            ; 00001242 D86D 0006

L_001246:
	add.w   D3,D3                                 ; 00001246 D643
	bpl.s   L_001274                              ; 00001248 6A2A
	lea     ($ed,A5),A1                           ; 0000124A 43ED 00ED
	move.b  (A1)+,D1                              ; 0000124E 1219
	move.w  (A1)+,D0                              ; 00001250 3019
	cmp.b   (A1),D1                               ; 00001252 B211
	bne.s   L_001260                              ; 00001254 660A
	andi.w  #$f7ff,($8,A5)                        ; 00001256 026D F7FF 0008
	move.b  D1,D0                                 ; 0000125C 1001
	bra.s   L_001264                              ; 0000125E 6004

L_001260:
	add.w   D0,(A1)                               ; 00001260 D151
	move.b  (A1),D0                               ; 00001262 1011

L_001264:
	cmp.b   ($2e,A5),D0                           ; 00001264 B02D 002E
	beq.s   L_001274                              ; 00001268 670A
	move.b  D0,($2e,A5)                           ; 0000126A 1B40 002E
	ori.w   #$400,($10,A5)                        ; 0000126E 006D 0400 0010

L_001274:
	tst.l   D6                                    ; 00001274 4A86
	bpl.s   L_001282                              ; 00001276 6A0A
	subq.w  #1,D7                                 ; 00001278 5347
	bne.w   L_0011DA                              ; 0000127A 6600 FF5E
	move.w  (-$338,A6),D7                         ; 0000127E 3E2E FCC8

L_001282:
	sub.w   D7,(A3)+                              ; 00001282 9F5B
	beq.s   L_00128A                              ; 00001284 6704

L_001286:
	movea.l (A3)+,A0                              ; 00001286 205B
	jmp     (A0)                                  ; 00001288 4ED0

L_00128A:
	move.w  ($e0,A5),D0                           ; 0000128A 302D 00E0
	addq.w  #1,D0                                 ; 0000128E 5240
	move.w  ($52,A5),D3                           ; 00001290 362D 0052
	beq.s   L_0012C4                              ; 00001294 672E
	bpl.s   L_0012A4                              ; 00001296 6A0C
	cmp.w   ($ba,A5),D0                           ; 00001298 B06D 00BA
	bcs.s   L_0012A4                              ; 0000129C 6506
	ori.w   #$8000,($8,A5)                        ; 0000129E 006D 8000 0008

L_0012A4:
	add.w   D3,D3                                 ; 000012A4 D643
	bpl.s   L_0012B4                              ; 000012A6 6A0C
	cmp.w   ($bc,A5),D0                           ; 000012A8 B06D 00BC
	bcs.s   L_0012B4                              ; 000012AC 6506
	ori.w   #$4000,($8,A5)                        ; 000012AE 006D 4000 0008

L_0012B4:
	lsl.w   #3,D3                                 ; 000012B4 E74B
	bpl.s   L_0012C4                              ; 000012B6 6A0C
	cmp.w   ($ea,A5),D0                           ; 000012B8 B06D 00EA
	bcs.s   L_0012C4                              ; 000012BC 6506
	ori.w   #$800,($8,A5)                         ; 000012BE 006D 0800 0008

L_0012C4:
	move.w  ($e0,A5),D0                           ; 000012C4 302D 00E0
	cmp.w   ($dc,A5),D0                           ; 000012C8 B06D 00DC
	beq.w   L_002F8A                              ; 000012CC 6700 1CBC
	bsr.w   L_00178C                              ; 000012D0 6100 04BA
	bra.s   L_001286                              ; 000012D4 60B0

L_0012D6:
	move.w  ($16,A5),D0                           ; 000012D6 302D 0016
	bne.w   L_00119E                              ; 000012DA 6600 FEC2
	bra.w   L_0014F2                              ; 000012DE 6000 0212

L_0012E2:
	move.w  (A3)+,D3                              ; 000012E2 361B
	beq.s   L_001348                              ; 000012E4 6762
	bpl.s   L_0012F2                              ; 000012E6 6A0A
	bsr.w   L_0013AE                              ; 000012E8 6100 00C4
	move.b  ($21,A5),D0                           ; 000012EC 102D 0021
	bsr.s   L_001362                              ; 000012F0 6170

L_0012F2:
	add.w   D3,D3                                 ; 000012F2 D643
	bpl.s   L_001306                              ; 000012F4 6A10
	moveq   #$a,D1                                ; 000012F6 720A
	move.b  ($23,A5),D2                           ; 000012F8 142D 0023
	bsr.w   L_0013E2                              ; 000012FC 6100 00E4
	moveq   #$23,D0                               ; 00001300 7023
	bsr.w   L_001534                              ; 00001302 6100 0230

L_001306:
	add.w   D3,D3                                 ; 00001306 D643
	bpl.s   L_00131A                              ; 00001308 6A10
	moveq   #$5b,D1                               ; 0000130A 725B
	move.b  ($26,A5),D2                           ; 0000130C 142D 0026
	bsr.w   L_0013E2                              ; 00001310 6100 00D0
	moveq   #$26,D0                               ; 00001314 7026
	bsr.w   L_001534                              ; 00001316 6100 021C

L_00131A:
	add.w   D3,D3                                 ; 0000131A D643
	bpl.s   L_00132E                              ; 0000131C 6A10
	moveq   #$5d,D1                               ; 0000131E 725D
	move.b  ($27,A5),D2                           ; 00001320 142D 0027
	bsr.w   L_0013E2                              ; 00001324 6100 00BC
	moveq   #$27,D0                               ; 00001328 7027
	bsr.w   L_001534                              ; 0000132A 6100 0208

L_00132E:
	add.w   D3,D3                                 ; 0000132E D643
	bpl.s   L_001336                              ; 00001330 6A04
	bsr.w   L_0013FC                              ; 00001332 6100 00C8

L_001336:
	add.w   D3,D3                                 ; 00001336 D643
	bpl.s   L_001344                              ; 00001338 6A0A
	moveq   #$1,D1                                ; 0000133A 7201
	move.b  ($2e,A5),D2                           ; 0000133C 142D 002E
	bsr.w   L_0013E2                              ; 00001340 6100 00A0

L_001344:
	clr.w   ($10,A5)                              ; 00001344 426D 0010

L_001348:
	cmp.w   (A3)+,D5                              ; 00001348 BA5B
	beq.s   L_001350                              ; 0000134A 6704
	bsr.w   L_00158C                              ; 0000134C 6100 023E

L_001350:
	cmp.w   (A3)+,D4                              ; 00001350 B85B
	beq.s   L_001358                              ; 00001352 6704
	bsr.w   L_0015DE                              ; 00001354 6100 0288

L_001358:
	move.w  (A3)+,D0                              ; 00001358 301B
	bne.w   L_00119E                              ; 0000135A 6600 FE42
	bra.w   L_0014F2                              ; 0000135E 6000 0192

L_001362:
	move.b  D0,($21,A5)                           ; 00001362 1B40 0021
	moveq   #$21,D0                               ; 00001366 7021
	bsr.w   L_001534                              ; 00001368 6100 01CA
	tst.w   D6                                    ; 0000136C 4A46
	bmi.s   L_00137E                              ; 0000136E 6B0E
	tst.b   D6                                    ; 00001370 4A06
	bmi.s   L_001390                              ; 00001372 6B1C
	cmpi.b  #$10,D6                               ; 00001374 0C06 0010
	bcc.s   L_001380                              ; 00001378 6406
	bsr.w   L_001976                              ; 0000137A 6100 05FA

L_00137E:
	rts                                           ; 0000137E 4E75

L_001380:
	moveq   #$0,D0                                ; 00001380 7000
	move.b  ($21,A5),D0                           ; 00001382 102D 0021
	mulu.w  #$300,D0                              ; 00001386 C0FC 0300
	move.w  D0,($58,A5)                           ; 0000138A 3B40 0058
	rts                                           ; 0000138E 4E75

L_001390:
	subq.l  #4,A7                                 ; 00001390 598F
	movea.l A7,A0                                 ; 00001392 204F
	moveq   #$f,D0                                ; 00001394 700F
	and.b   D6,D0                                 ; 00001396 C006
	ori.b   #$c0,D0                               ; 00001398 0000 00C0
	move.b  D0,(A0)+                              ; 0000139C 10C0
	move.b  ($21,A5),(A0)+                        ; 0000139E 10ED 0021
	movea.l A7,A0                                 ; 000013A2 204F
	moveq   #$1,D0                                ; 000013A4 7001
	bsr.w   L_0005A6                              ; 000013A6 6100 F1FE
	addq.l  #4,A7                                 ; 000013AA 588F
	rts                                           ; 000013AC 4E75

L_0013AE:
	subq.l  #8,A7                                 ; 000013AE 518F
	movea.l A7,A0                                 ; 000013B0 204F
	moveq   #$f,D0                                ; 000013B2 700F
	and.b   D6,D0                                 ; 000013B4 C006
	ori.b   #$b0,D0                               ; 000013B6 0000 00B0
	move.b  D0,(A0)+                              ; 000013BA 10C0
	clr.b   (A0)+                                 ; 000013BC 4218
	move.b  ($20,A5),(A0)+                        ; 000013BE 10ED 0020
	move.b  #$20,(A0)+                            ; 000013C2 10FC 0020
	move.b  ($2c,A5),(A0)+                        ; 000013C6 10ED 002C
	movea.l A7,A0                                 ; 000013CA 204F
	moveq   #$4,D0                                ; 000013CC 7004
	bsr.w   L_0005A6                              ; 000013CE 6100 F1D6
	addq.l  #8,A7                                 ; 000013D2 508F
	moveq   #$20,D0                               ; 000013D4 7020
	bsr.w   L_001534                              ; 000013D6 6100 015C
	moveq   #$2c,D0                               ; 000013DA 702C
	bsr.w   L_001534                              ; 000013DC 6100 0156
	rts                                           ; 000013E0 4E75

L_0013E2:
	moveq   #$f,D0                                ; 000013E2 700F
	and.b   D6,D0                                 ; 000013E4 C006
	or.b    #$b0,D0                               ; 000013E6 803C 00B0
	move.b  D2,-(A7)                              ; 000013EA 1F02
	move.w  D1,-(A7)                              ; 000013EC 3F01
	move.b  D0,(A7)                               ; 000013EE 1E80
	movea.l A7,A0                                 ; 000013F0 204F
	moveq   #$2,D0                                ; 000013F2 7002
	bsr.w   L_0005A6                              ; 000013F4 6100 F1B0
	addq.l  #4,A7                                 ; 000013F8 588F
	rts                                           ; 000013FA 4E75

L_0013FC:
	moveq   #$2b,D0                               ; 000013FC 702B
	bsr.w   L_001534                              ; 000013FE 6100 0134
	tst.b   D6                                    ; 00001402 4A06
	bmi.s   L_001414                              ; 00001404 6B0E
	sub.w   ($6,A5),D4                            ; 00001406 986D 0006
	bsr.w   L_000E2C                              ; 0000140A 6100 FA20
	add.w   ($6,A5),D4                            ; 0000140E D86D 0006
	rts                                           ; 00001412 4E75

L_001414:
	move.b  ($2b,A5),D1                           ; 00001414 122D 002B
	subq.l  #4,A7                                 ; 00001418 598F
	movea.l A7,A0                                 ; 0000141A 204F
	moveq   #$f,D0                                ; 0000141C 700F
	and.b   D6,D0                                 ; 0000141E C006
	or.b    #$b0,D0                               ; 00001420 803C 00B0
	move.b  D0,(A0)+                              ; 00001424 10C0
	move.b  #$7,(A0)+                             ; 00001426 10FC 0007
	move.b  D1,(A0)+                              ; 0000142A 10C1
	movea.l A7,A0                                 ; 0000142C 204F
	moveq   #$2,D0                                ; 0000142E 7002
	bsr.w   L_0005A6                              ; 00001430 6100 F174
	addq.l  #4,A7                                 ; 00001434 588F
	rts                                           ; 00001436 4E75

L_001438:
	move.w  (A3)+,D0                              ; 00001438 301B
	beq.s   L_00144A                              ; 0000143A 670E
	clr.w   (-$2,A3)                              ; 0000143C 426B FFFE
	andi.w  #$800,D0                              ; 00001440 0240 0800
	beq.s   L_00144A                              ; 00001444 6704
	bsr.w   L_000E2C                              ; 00001446 6100 F9E4

L_00144A:
	cmp.w   ($14,A5),D4                           ; 0000144A B86D 0014
	beq.s   L_001488                              ; 0000144E 6738
	moveq   #$7f,D0                               ; 00001450 707F
	cmp.w   D0,D4                                 ; 00001452 B840
	bls.s   L_00145C                              ; 00001454 6306
	bgt.s   L_00145A                              ; 00001456 6E02
	clr.w   D0                                    ; 00001458 4240

L_00145A:
	move.w  D0,D4                                 ; 0000145A 3800

L_00145C:
	move.w  D4,($14,A5)                           ; 0000145C 3B44 0014
	tst.b   (-$13c,A6)                            ; 00001460 4A2E FEC4
	beq.s   L_001488                              ; 00001464 6722
	move.b  D4,D0                                 ; 00001466 1004
	bsr.w   L_003B32                              ; 00001468 6100 26C8
	cmp.b   ($65,A5),D0                           ; 0000146C B02D 0065
	beq.s   L_001488                              ; 00001470 6716
	move.b  D0,($65,A5)                           ; 00001472 1B40 0065
	moveq   #$0,D1                                ; 00001476 7200
	move.b  D0,D1                                 ; 00001478 1200
	swap    D1                                    ; 0000147A 4841
	not.w   D1                                    ; 0000147C 4641
	moveq   #$f,D0                                ; 0000147E 700F
	and.w   D6,D0                                 ; 00001480 C046
	ori.w   #$70,D0                               ; 00001482 0040 0070
	trap    #$2                                   ; 00001486 4E42

L_001488:
	move.w  ($16,A5),D0                           ; 00001488 302D 0016
	bne.w   L_00119E                              ; 0000148C 6600 FD10
	bra.s   L_0014F2                              ; 00001490 6060

L_001492:
	move.w  (A3)+,D3                              ; 00001492 361B
	beq.s   L_0014B0                              ; 00001494 671A
	bpl.s   L_00149C                              ; 00001496 6A04
	bsr.w   L_001976                              ; 00001498 6100 04DC

L_00149C:
	add.w   D3,D3                                 ; 0000149C D643
	bpl.s   L_0014A4                              ; 0000149E 6A04
	bsr.w   L_001B50                              ; 000014A0 6100 06AE

L_0014A4:
	lsl.w   #3,D3                                 ; 000014A4 E74B
	bpl.s   L_0014AC                              ; 000014A6 6A04
	bsr.w   L_000E2C                              ; 000014A8 6100 F982

L_0014AC:
	clr.w   ($10,A5)                              ; 000014AC 426D 0010

L_0014B0:
	cmp.w   (A3)+,D5                              ; 000014B0 BA5B
	beq.s   L_0014D2                              ; 000014B2 671E
	move.w  D5,($12,A5)                           ; 000014B4 3B45 0012
	add.w   ($50,A5),D5                           ; 000014B8 DA6D 0050
	addq.w  #5,D5                                 ; 000014BC 5A45
	cmpi.w  #$1fff,D5                             ; 000014BE 0C45 1FFF
	bls.s   L_0014CE                              ; 000014C2 630A
	ble.s   L_0014CC                              ; 000014C4 6F06
	move.w  #$1fff,D5                             ; 000014C6 3A3C 1FFF
	bra.s   L_0014CE                              ; 000014CA 6002

L_0014CC:
	moveq   #$0,D5                                ; 000014CC 7A00

L_0014CE:
	bsr.w   L_00161E                              ; 000014CE 6100 014E

L_0014D2:
	cmp.w   (A3)+,D4                              ; 000014D2 B85B
	beq.s   L_0014EC                              ; 000014D4 6716
	move.w  D4,($14,A5)                           ; 000014D6 3B44 0014
	moveq   #$7f,D0                               ; 000014DA 707F
	cmp.w   D0,D4                                 ; 000014DC B840
	bls.s   L_0014E6                              ; 000014DE 6306
	bgt.s   L_0014E4                              ; 000014E0 6E02
	clr.w   D0                                    ; 000014E2 4240

L_0014E4:
	move.w  D0,D4                                 ; 000014E4 3800

L_0014E6:
	move.w  D4,D0                                 ; 000014E6 3004
	bsr.w   L_001B2A                              ; 000014E8 6100 0640

L_0014EC:
	move.w  (A3)+,D0                              ; 000014EC 301B
	bne.w   L_00119E                              ; 000014EE 6600 FCAE

L_0014F2:
	rts                                           ; 000014F2 4E75

L_0014F4:
	tst.w   ($a,A5)                               ; 000014F4 4A6D 000A
	beq.w   L_002F92                              ; 000014F8 6700 1A98
	moveq   #$0,D0                                ; 000014FC 7000
	cmpi.b  #$1,($2f,A5)                          ; 000014FE 0C2D 0001 002F
	bhi.s   L_00150A                              ; 00001504 6204
	move.b  ($5e,A5),D0                           ; 00001506 102D 005E

L_00150A:
	move.b  D0,($5f,A5)                           ; 0000150A 1B40 005F
	move.l  A3,($1c,A5)                           ; 0000150E 2B4B 001C
	lea     ($c,A5),A3                            ; 00001512 47ED 000C
	bra.w   L_001286                              ; 00001516 6000 FD6E

L_00151A:
	tst.b   (-$13c,A6)                            ; 0000151A 4A2E FEC4
	beq.s   L_00152E                              ; 0000151E 670E
	move.w  #$101,D0                              ; 00001520 303C 0101
	trap    #$2                                   ; 00001524 4E42
	move.w  #$100,D0                              ; 00001526 303C 0100
	trap    #$2                                   ; 0000152A 4E42
	rts                                           ; 0000152C 4E75

L_00152E:
	bsr.w   L_004408                              ; 0000152E 6100 2ED8
	rts                                           ; 00001532 4E75

L_001534:
	moveq   #$0,D1                                ; 00001534 7200
	move.b  D6,D1                                 ; 00001536 1206
	add.w   D1,D1                                 ; 00001538 D241
	lea     (-$1200,A6),A0                        ; 0000153A 41EE EE00
	move.w  (A0,D1.w),D1                          ; 0000153E 3230 1000
	beq.s   L_00155E                              ; 00001542 671A

L_001544:
	lea     (-$1,A6,D1.w),A0                      ; 00001544 41F6 10FF
	move.w  ($7a,A5),D1                           ; 00001548 322D 007A
	cmp.w   ($7a,A0),D1                           ; 0000154C B268 007A
	bne.s   L_001558                              ; 00001550 6606
	move.b  (A5,D0.w),(A0,D0.w)                   ; 00001552 11B5 0000 0000

L_001558:
	move.w  ($48,A0),D1                           ; 00001558 3228 0048
	bne.s   L_001544                              ; 0000155C 66E6

L_00155E:
	rts                                           ; 0000155E 4E75

L_001560:
	moveq   #$0,D1                                ; 00001560 7200
	move.b  D6,D1                                 ; 00001562 1206
	add.w   D1,D1                                 ; 00001564 D241
	lea     (-$1200,A6),A0                        ; 00001566 41EE EE00
	move.w  (A0,D1.w),D1                          ; 0000156A 3230 1000
	beq.s   L_00158A                              ; 0000156E 671A

L_001570:
	lea     (-$1,A6,D1.w),A0                      ; 00001570 41F6 10FF
	move.w  ($7a,A5),D1                           ; 00001574 322D 007A
	cmp.w   ($7a,A0),D1                           ; 00001578 B268 007A
	bne.s   L_001584                              ; 0000157C 6606
	move.w  (A5,D0.w),(A0,D0.w)                   ; 0000157E 31B5 0000 0000

L_001584:
	move.w  ($48,A0),D1                           ; 00001584 3228 0048
	bne.s   L_001570                              ; 00001588 66E6

L_00158A:
	rts                                           ; 0000158A 4E75

L_00158C:
	move.w  #$2000,D0                             ; 0000158C 303C 2000
	add.w   D0,D5                                 ; 00001590 DA40
	cmpi.w  #$3fff,D5                             ; 00001592 0C45 3FFF
	bls.s   L_0015A2                              ; 00001596 630A
	ble.s   L_0015A0                              ; 00001598 6F06
	move.w  #$3fff,D5                             ; 0000159A 3A3C 3FFF
	bra.s   L_0015A2                              ; 0000159E 6002

L_0015A0:
	moveq   #$0,D5                                ; 000015A0 7A00

L_0015A2:
	sub.w   D0,D5                                 ; 000015A2 9A40
	cmp.w   ($12,A5),D5                           ; 000015A4 BA6D 0012
	beq.s   L_0015DC                              ; 000015A8 6732
	move.w  D5,($12,A5)                           ; 000015AA 3B45 0012
	move.w  D5,($30,A5)                           ; 000015AE 3B45 0030
	subq.l  #4,A7                                 ; 000015B2 598F
	movea.l A7,A0                                 ; 000015B4 204F
	moveq   #$f,D0                                ; 000015B6 700F
	and.b   D6,D0                                 ; 000015B8 C006
	ori.b   #$e0,D0                               ; 000015BA 0000 00E0
	move.b  D0,(A0)+                              ; 000015BE 10C0
	move.w  D5,D0                                 ; 000015C0 3005
	add.w   #$2000,D0                             ; 000015C2 D07C 2000
	add.w   D0,D0                                 ; 000015C6 D040
	lsr.b   #1,D0                                 ; 000015C8 E208
	move.b  D0,(A0)+                              ; 000015CA 10C0
	move.w  D0,(A0)+                              ; 000015CC 30C0
	movea.l A7,A0                                 ; 000015CE 204F
	moveq   #$2,D0                                ; 000015D0 7002
	bsr.w   L_0005A6                              ; 000015D2 6100 EFD2
	addq.l  #4,A7                                 ; 000015D6 588F
	moveq   #$30,D0                               ; 000015D8 7030
	bsr.s   L_001560                              ; 000015DA 6184

L_0015DC:
	rts                                           ; 000015DC 4E75

L_0015DE:
	moveq   #$7f,D0                               ; 000015DE 707F
	cmp.w   D0,D4                                 ; 000015E0 B840
	bls.s   L_0015EA                              ; 000015E2 6306
	bgt.s   L_0015E8                              ; 000015E4 6E02
	clr.w   D0                                    ; 000015E6 4240

L_0015E8:
	move.w  D0,D4                                 ; 000015E8 3800

L_0015EA:
	cmp.w   ($14,A5),D4                           ; 000015EA B86D 0014
	beq.s   L_00161C                              ; 000015EE 672C
	move.w  D4,($14,A5)                           ; 000015F0 3B44 0014
	move.w  D4,($32,A5)                           ; 000015F4 3B44 0032
	subq.l  #4,A7                                 ; 000015F8 598F
	movea.l A7,A0                                 ; 000015FA 204F
	moveq   #$f,D0                                ; 000015FC 700F
	and.b   D6,D0                                 ; 000015FE C006
	ori.b   #$b0,D0                               ; 00001600 0000 00B0
	move.b  D0,(A0)+                              ; 00001604 10C0
	move.b  #$b,(A0)+                             ; 00001606 10FC 000B
	move.b  D4,(A0)+                              ; 0000160A 10C4
	movea.l A7,A0                                 ; 0000160C 204F
	moveq   #$2,D0                                ; 0000160E 7002
	bsr.w   L_0005A6                              ; 00001610 6100 EF94
	addq.l  #4,A7                                 ; 00001614 588F
	moveq   #$32,D0                               ; 00001616 7032
	bsr.w   L_001560                              ; 00001618 6100 FF46

L_00161C:
	rts                                           ; 0000161C 4E75

L_00161E:
	moveq   #$30,D0                               ; 0000161E 7030
	or.b    D6,D0                                 ; 00001620 8006
	bsr.w   L_002BAC                              ; 00001622 6100 1588
	lea     (-$410,A6),A0                         ; 00001626 41EE FBF0
	adda.l  D0,A0                                 ; 0000162A D1C0
	move.w  D5,D0                                 ; 0000162C 3005
	add.b   D0,D0                                 ; 0000162E D000
	add.b   D0,D0                                 ; 00001630 D000
	bsr.w   L_002BB6                              ; 00001632 6100 1582
	move.b  D5,($8,A0)                            ; 00001636 1145 0008
	move.w  D5,D1                                 ; 0000163A 3205
	lsr.w   #6,D1                                 ; 0000163C EC49
	cmp.b   (A0),D1                               ; 0000163E B210
	beq.s   L_001658                              ; 00001640 6716
	moveq   #$28,D0                               ; 00001642 7028
	or.b    D6,D0                                 ; 00001644 8006
	bsr.w   L_002BAC                              ; 00001646 6100 1564
	move.b  D1,(A0)                               ; 0000164A 1081
	lea     L_001814(pc),A0                       ; 0000164C 41FA 01C6
	move.b  (A0,D1.w),D0                          ; 00001650 1030 1000
	bra.w   L_002BB6                              ; 00001654 6000 1560

L_001658:
	rts                                           ; 00001658 4E75

L_00165A:
	subq.w  #1,(A1)+                              ; 0000165A 5359
	beq.s   L_001668                              ; 0000165C 670A
	move.l  (A1)+,D0                              ; 0000165E 2019
	add.l   D0,(A1)                               ; 00001660 D191
	add.w   (A1),D5                               ; 00001662 DA51
	bra.w   L_0011E8                              ; 00001664 6000 FB82

L_001668:
	move.l  (A1)+,D0                              ; 00001668 2019
	add.l   (A1),D0                               ; 0000166A D091
	neg.l   D0                                    ; 0000166C 4480
	move.l  D0,(A1)                               ; 0000166E 2280
	add.w   (A1),D5                               ; 00001670 DA51
	move.w  ($94,A5),($84,A5)                     ; 00001672 3B6D 0094 0084
	bra.w   L_0011E8                              ; 00001678 6000 FB6E

L_00167C:
	subq.w  #1,(A1)+                              ; 0000167C 5359
	beq.s   L_001688                              ; 0000167E 6708
	move.l  (A1)+,(A1)                            ; 00001680 2299
	add.w   (A1),D5                               ; 00001682 DA51
	bra.w   L_0011E8                              ; 00001684 6000 FB62

L_001688:
	move.l  (A1)+,(A1)                            ; 00001688 2299
	add.w   (A1),D5                               ; 0000168A DA51
	neg.l   -(A1)                                 ; 0000168C 44A1
	move.w  ($94,A5),-(A1)                        ; 0000168E 332D 0094
	bra.w   L_0011E8                              ; 00001692 6000 FB54

L_001696:
	subq.w  #1,(A1)+                              ; 00001696 5359
	beq.s   L_0016A4                              ; 00001698 670A
	move.l  (A1)+,D0                              ; 0000169A 2019
	add.l   D0,(A1)                               ; 0000169C D191
	add.w   (A1),D5                               ; 0000169E DA51
	bra.w   L_0011E8                              ; 000016A0 6000 FB46

L_0016A4:
	move.l  (A1)+,D0                              ; 000016A4 2019
	add.l   D0,(A1)                               ; 000016A6 D191
	add.w   (A1),D5                               ; 000016A8 DA51
	neg.l   D0                                    ; 000016AA 4480
	move.l  D0,-(A1)                              ; 000016AC 2300
	move.w  ($94,A5),-(A1)                        ; 000016AE 332D 0094
	bra.w   L_0011E8                              ; 000016B2 6000 FB34

L_0016B6:
	subq.w  #1,(A1)+                              ; 000016B6 5359
	beq.s   L_0016C2                              ; 000016B8 6708
	add.w   ($8a,A5),D5                           ; 000016BA DA6D 008A
	bra.w   L_0011E8                              ; 000016BE 6000 FB28

L_0016C2:
	move.w  ($94,A5),-(A1)                        ; 000016C2 332D 0094
	bsr.w   L_00176A                              ; 000016C6 6100 00A2
	muls.w  ($86,A5),D0                           ; 000016CA C1ED 0086
	move.l  D0,($8a,A5)                           ; 000016CE 2B40 008A
	add.w   ($8a,A5),D5                           ; 000016D2 DA6D 008A
	bra.w   L_0011E8                              ; 000016D6 6000 FB10

L_0016DA:
	subq.w  #1,(A1)+                              ; 000016DA 5359
	beq.s   L_0016E8                              ; 000016DC 670A
	move.l  (A1)+,D0                              ; 000016DE 2019
	add.l   D0,(A1)                               ; 000016E0 D191
	add.w   (A1),D4                               ; 000016E2 D851
	bra.w   L_0011F4                              ; 000016E4 6000 FB0E

L_0016E8:
	move.l  ($ac,A5),($a4,A5)                     ; 000016E8 2B6D 00AC 00A4
	add.w   ($a4,A5),D4                           ; 000016EE D86D 00A4
	move.w  ($b0,A5),-(A1)                        ; 000016F2 332D 00B0
	bra.w   L_0011F4                              ; 000016F6 6000 FAFC

L_0016FA:
	subq.w  #1,(A1)+                              ; 000016FA 5359
	beq.s   L_001706                              ; 000016FC 6708
	add.w   ($a4,A5),D4                           ; 000016FE D86D 00A4
	bra.w   L_0011F4                              ; 00001702 6000 FAF0

L_001706:
	move.l  (A1)+,D0                              ; 00001706 2019
	add.l   D0,(A1)                               ; 00001708 D191
	add.w   (A1),D4                               ; 0000170A D851
	neg.l   -(A1)                                 ; 0000170C 44A1
	move.w  ($b0,A5),($9e,A5)                     ; 0000170E 3B6D 00B0 009E
	bra.w   L_0011F4                              ; 00001714 6000 FADE

L_001718:
	subq.w  #1,(A1)+                              ; 00001718 5359
	beq.s   L_001726                              ; 0000171A 670A
	move.l  (A1)+,D0                              ; 0000171C 2019
	add.l   D0,(A1)                               ; 0000171E D191
	add.w   (A1),D4                               ; 00001720 D851
	bra.w   L_0011F4                              ; 00001722 6000 FAD0

L_001726:
	move.l  (A1)+,D0                              ; 00001726 2019
	add.l   D0,(A1)                               ; 00001728 D191
	add.w   (A1),D4                               ; 0000172A D851
	neg.l   -(A1)                                 ; 0000172C 44A1
	move.w  ($b0,A5),-(A1)                        ; 0000172E 332D 00B0
	bra.w   L_0011F4                              ; 00001732 6000 FAC0

L_001736:
	subq.w  #1,(A1)+                              ; 00001736 5359
	beq.s   L_001742                              ; 00001738 6708
	add.w   ($a4,A5),D4                           ; 0000173A D86D 00A4
	bra.w   L_0011F4                              ; 0000173E 6000 FAB4

L_001742:
	move.w  ($b0,A5),-(A1)                        ; 00001742 332D 00B0
	bsr.s   L_00176A                              ; 00001746 6122
	andi.w  #$7fff,D0                             ; 00001748 0240 7FFF
	move.w  ($b4,A5),D1                           ; 0000174C 322D 00B4
	clr.b   D1                                    ; 00001750 4201
	muls.w  D1,D0                                 ; 00001752 C1C1
	swap    D0                                    ; 00001754 4840
	add.w   D0,D0                                 ; 00001756 D040
	clr.b   D0                                    ; 00001758 4200
	add.w   ($a0,A5),D0                           ; 0000175A D06D 00A0
	move.w  D0,($a4,A5)                           ; 0000175E 3B40 00A4
	add.w   ($a4,A5),D4                           ; 00001762 D86D 00A4
	bra.w   L_0011F4                              ; 00001766 6000 FA8C

L_00176A:
	move.l  (-$386,A6),D0                         ; 0000176A 202E FC7A
	move.l  D0,D1                                 ; 0000176E 2200
	add.w   D1,D1                                 ; 00001770 D241
	swap    D1                                    ; 00001772 4841
	clr.w   D1                                    ; 00001774 4241
	eor.l   D1,D0                                 ; 00001776 B380
	move.l  D0,D1                                 ; 00001778 2200
	add.w   D1,D1                                 ; 0000177A D241
	clr.w   D1                                    ; 0000177C 4241
	swap    D1                                    ; 0000177E 4841
	addx.l  D1,D1                                 ; 00001780 D381
	eor.l   D1,D0                                 ; 00001782 B380
	not.l   D0                                    ; 00001784 4680
	move.l  D0,(-$386,A6)                         ; 00001786 2D40 FC7A
	rts                                           ; 0000178A 4E75

L_00178C:
	movem.l D0-D4,-(A7)                           ; 0000178C 48E7 F800
	move.w  ($dc,A5),D0                           ; 00001790 302D 00DC
	beq.s   L_00180E                              ; 00001794 6778
	move.w  ($e0,A5),D1                           ; 00001796 322D 00E0
	moveq   #-$1,D2                               ; 0000179A 74FF
	moveq   #$0,D4                                ; 0000179C 7800
	tst.w   ($52,A5)                              ; 0000179E 4A6D 0052
	bpl.s   L_0017B6                              ; 000017A2 6A12
	move.w  ($ba,A5),D4                           ; 000017A4 382D 00BA
	subq.w  #1,D4                                 ; 000017A8 5344
	bls.s   L_0017B6                              ; 000017AA 630A
	cmp.w   D4,D0                                 ; 000017AC B044
	bcs.s   L_0017B6                              ; 000017AE 6506
	cmp.w   D4,D1                                 ; 000017B0 B244
	bcc.s   L_0017B6                              ; 000017B2 6402
	move.l  D4,D2                                 ; 000017B4 2404

L_0017B6:
	btst    #$6,($52,A5)                          ; 000017B6 082D 0006 0052
	beq.s   L_0017D4                              ; 000017BC 6716
	move.w  ($bc,A5),D4                           ; 000017BE 382D 00BC
	subq.w  #1,D4                                 ; 000017C2 5344
	bls.s   L_0017D4                              ; 000017C4 630E
	cmp.w   D4,D0                                 ; 000017C6 B044
	bcs.s   L_0017D4                              ; 000017C8 650A
	cmp.w   D4,D1                                 ; 000017CA B244
	bcc.s   L_0017D4                              ; 000017CC 6406
	cmp.w   D4,D2                                 ; 000017CE B444
	bls.s   L_0017D4                              ; 000017D0 6302
	move.l  D4,D2                                 ; 000017D2 2404

L_0017D4:
	btst    #$3,($52,A5)                          ; 000017D4 082D 0003 0052
	beq.s   L_0017F2                              ; 000017DA 6716
	move.w  ($ea,A5),D4                           ; 000017DC 382D 00EA
	subq.w  #1,D4                                 ; 000017E0 5344
	bls.s   L_0017F2                              ; 000017E2 630E
	cmp.w   D4,D0                                 ; 000017E4 B044
	bcs.s   L_0017F2                              ; 000017E6 650A
	cmp.w   D4,D1                                 ; 000017E8 B244
	bcc.s   L_0017F2                              ; 000017EA 6406
	cmp.w   D4,D2                                 ; 000017EC B444
	bls.s   L_0017F2                              ; 000017EE 6302
	move.l  D4,D2                                 ; 000017F0 2404

L_0017F2:
	tst.l   D2                                    ; 000017F2 4A82
	bpl.s   L_001804                              ; 000017F4 6A0E
	sub.w   D1,D0                                 ; 000017F6 9041
	move.w  D0,($a,A5)                            ; 000017F8 3B40 000A
	move.w  ($dc,A5),($e0,A5)                     ; 000017FC 3B6D 00DC 00E0
	bra.s   L_00180E                              ; 00001802 600A

L_001804:
	move.w  D2,($e0,A5)                           ; 00001804 3B42 00E0
	sub.w   D1,D2                                 ; 00001808 9441
	move.w  D2,($a,A5)                            ; 0000180A 3B42 000A

L_00180E:
	movem.l (A7)+,D0-D4                           ; 0000180E 4CDF 001F
	rts                                           ; 00001812 4E75

L_001814:
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 00001814
	dc.b    $01,$02,$04,$05,$06,$08,$09,$0A,$0C,$0D,$0E,$10,$11,$12,$14,$15; 00001824
	dc.b    $16,$18,$19,$1A,$1C,$1D,$1E,$20,$21,$22,$24,$25,$26,$28,$29,$2A; 00001834
	dc.b    ',-.01245689:<=>@'                    ; 00001844
	dc.b    'ABDEFHIJLMNPQRTU'                    ; 00001854
	dc.b    'VXYZ\]^`abdefhij'                    ; 00001864
	dc.b    'lmnpqrtuvxyz|}~~'                    ; 00001874
	dc.b    '~~~~~~~~~~~~~~~~'                    ; 00001884

L_001894:
	movem.l D0-D1,-(A7)                           ; 00001894 48E7 C000
	tst.b   ($5f,A5)                              ; 00001898 4A2D 005F
	bne.w   L_001960                              ; 0000189C 6600 00C2
	move.w  ($52,A5),D3                           ; 000018A0 362D 0052
	bpl.s   L_0018D2                              ; 000018A4 6A2C
	move.w  ($ba,A5),D1                           ; 000018A6 322D 00BA
	beq.s   L_0018CC                              ; 000018AA 6720
	andi.w  #$7fff,($8,A5)                        ; 000018AC 026D 7FFF 0008
	move.w  ($92,A5),($84,A5)                     ; 000018B2 3B6D 0092 0084
	move.l  ($8e,A5),($86,A5)                     ; 000018B8 2B6D 008E 0086
	sub.w   ($8a,A5),D5                           ; 000018BE 9A6D 008A
	moveq   #$0,D0                                ; 000018C2 7000
	move.l  D0,($8a,A5)                           ; 000018C4 2B40 008A
	subq.w  #1,D1                                 ; 000018C8 5341
	bne.s   L_0018D2                              ; 000018CA 6606

L_0018CC:
	ori.w   #$8000,($8,A5)                        ; 000018CC 006D 8000 0008

L_0018D2:
	add.w   D3,D3                                 ; 000018D2 D643
	bpl.s   L_00190A                              ; 000018D4 6A34
	tst.w   ($bc,A5)                              ; 000018D6 4A6D 00BC
	beq.s   L_001904                              ; 000018DA 6728
	move.w  ($b0,A5),($9e,A5)                     ; 000018DC 3B6D 00B0 009E
	move.l  ($a8,A5),($a0,A5)                     ; 000018E2 2B6D 00A8 00A0
	sub.w   ($a4,A5),D4                           ; 000018E8 986D 00A4
	move.l  ($ac,A5),($a4,A5)                     ; 000018EC 2B6D 00AC 00A4
	add.w   ($a4,A5),D4                           ; 000018F2 D86D 00A4
	andi.w  #$bfff,($8,A5)                        ; 000018F6 026D BFFF 0008
	cmpi.w  #$1,($bc,A5)                          ; 000018FC 0C6D 0001 00BC
	bne.s   L_00190A                              ; 00001902 6606

L_001904:
	ori.w   #$4000,($8,A5)                        ; 00001904 006D 4000 0008

L_00190A:
	add.w   D3,D3                                 ; 0000190A D643
	bpl.s   L_001920                              ; 0000190C 6A12
	tst.l   ($d4,A5)                              ; 0000190E 4AAD 00D4
	bne.s   L_001920                              ; 00001912 660C
	andi.w  #$dfff,($8,A5)                        ; 00001914 026D DFFF 0008
	andi.w  #$dfff,($52,A5)                       ; 0000191A 026D DFFF 0052

L_001920:
	add.w   D3,D3                                 ; 00001920 D643
	add.w   D3,D3                                 ; 00001922 D643
	bpl.s   L_001960                              ; 00001924 6A3A
	tst.w   ($ea,A5)                              ; 00001926 4A6D 00EA
	beq.s   L_00195A                              ; 0000192A 672E
	move.w  ($ec,A5),D0                           ; 0000192C 302D 00EC
	move.b  #$80,D0                               ; 00001930 103C 0080
	move.w  D0,($f0,A5)                           ; 00001934 3B40 00F0
	move.b  ($f2,A5),D0                           ; 00001938 102D 00F2
	cmp.b   ($2e,A5),D0                           ; 0000193C B02D 002E
	beq.s   L_00194C                              ; 00001940 670A
	move.b  D0,($2e,A5)                           ; 00001942 1B40 002E
	ori.w   #$400,($10,A5)                        ; 00001946 006D 0400 0010

L_00194C:
	andi.w  #$f7ff,($8,A5)                        ; 0000194C 026D F7FF 0008
	cmpi.w  #$1,($ea,A5)                          ; 00001952 0C6D 0001 00EA
	bne.s   L_001960                              ; 00001958 6606

L_00195A:
	ori.w   #$8000,($8,A5)                        ; 0000195A 006D 8000 0008

L_001960:
	movem.l (A7)+,D0-D1                           ; 00001960 4CDF 0003
	rts                                           ; 00001964 4E75

L_001966:
	move.w  (-$7e2,A6),D0                         ; 00001966 302E F81E
	addq.w  #4,D0                                 ; 0000196A 5840
	andi.w  #$3ff,D0                              ; 0000196C 0240 03FF
	move.w  D0,(-$7e2,A6)                         ; 00001970 3D40 F81E
	rts                                           ; 00001974 4E75

L_001976:
	move.w  ($20,A5),D2                           ; 00001976 342D 0020
	add.w   #$80,D2                               ; 0000197A D47C 0080
	and.w   #$7f7f,D2                             ; 0000197E C47C 7F7F
	move.l  ($40,A5),D0                           ; 00001982 202D 0040
	beq.w   L_001A22                              ; 00001986 6700 009A
	movea.l D0,A1                                 ; 0000198A 2240
	addq.l  #4,A1                                 ; 0000198C 5889
	move.w  (A1)+,D1                              ; 0000198E 3219
	bra.s   L_00199A                              ; 00001990 6008

L_001992:
	cmp.w   ($2,A1),D2                            ; 00001992 B469 0002
	beq.s   L_0019AA                              ; 00001996 6712
	adda.w  (A1),A1                               ; 00001998 D2D1

L_00199A:
	dbra    D1,L_001992                           ; 0000199A 51C9 FFF6
	bra.w   L_001A22                              ; 0000199E 6000 0082

L_0019A2:
	dc.b    $10,$10,$10,$10,$30,$70,$70,$F0       ; 000019A2

L_0019AA:
	addq.l  #4,A1                                 ; 000019AA 5889
	bsr.s   L_001A24                              ; 000019AC 6176
	move.l  A1,($54,A5)                           ; 000019AE 2B49 0054
	moveq   #$3f,D2                               ; 000019B2 743F
	and.b   (A1)+,D2                              ; 000019B4 C419
	move.b  D2,($61,A5)                           ; 000019B6 1B42 0061
	moveq   #$7,D0                                ; 000019BA 7007
	and.b   D2,D0                                 ; 000019BC C002
	move.b  L_0019A2(pc,D0.w),($74,A5)            ; 000019BE 1B7B 00E2 0074
	or.b    ($70,A5),D2                           ; 000019C4 842D 0070
	moveq   #$20,D1                               ; 000019C8 7220
	add.b   D6,D1                                 ; 000019CA D206
	bsr.w   L_002BC0                              ; 000019CC 6100 11F2
	moveq   #$f,D1                                ; 000019D0 720F
	and.b   (A1)+,D1                              ; 000019D2 C219
	lsl.b   #3,D1                                 ; 000019D4 E709
	move.b  D1,($62,A5)                           ; 000019D6 1B41 0062
	moveq   #$40,D1                               ; 000019DA 7240
	add.b   D6,D1                                 ; 000019DC D206
	moveq   #$3,D0                                ; 000019DE 7003

L_0019E0:
	move.b  (A1)+,D2                              ; 000019E0 1419
	bsr.w   L_002BC0                              ; 000019E2 6100 11DC
	addq.b  #8,D1                                 ; 000019E6 5001
	dbra    D0,L_0019E0                           ; 000019E8 51C8 FFF6
	move.b  ($74,A5),D0                           ; 000019EC 102D 0074
	lea     ($75,A5),A0                           ; 000019F0 41ED 0075

L_0019F4:
	move.b  (A1)+,D2                              ; 000019F4 1419
	move.b  D2,(A0)+                              ; 000019F6 10C2
	add.b   D0,D0                                 ; 000019F8 D000
	bcc.s   L_0019FE                              ; 000019FA 6402
	moveq   #$7f,D2                               ; 000019FC 747F

L_0019FE:
	bsr.w   L_002BC0                              ; 000019FE 6100 11C0
	addq.b  #8,D1                                 ; 00001A02 5001
	bpl.s   L_0019F4                              ; 00001A04 6AEE

L_001A06:
	move.b  (A1)+,D2                              ; 00001A06 1419
	bsr.w   L_002BC0                              ; 00001A08 6100 11B6
	addq.b  #8,D1                                 ; 00001A0C 5001
	bcc.s   L_001A06                              ; 00001A0E 64F6
	st      ($14,A5)                              ; 00001A10 50ED 0014
	moveq   #$7,D0                                ; 00001A14 7007
	and.b   D6,D0                                 ; 00001A16 C006
	lea     (-$3c0,A6),A0                         ; 00001A18 41EE FC40
	move.b  #$0,(A0,D0.w)                         ; 00001A1C 11BC 0000 0000

L_001A22:
	rts                                           ; 00001A22 4E75

L_001A24:
	moveq   #-$1,D2                               ; 00001A24 74FF
	moveq   #-$20,D1                              ; 00001A26 72E0
	add.b   D6,D1                                 ; 00001A28 D206
	bsr.w   L_002BC0                              ; 00001A2A 6100 1194
	addq.b  #8,D1                                 ; 00001A2E 5001
	bsr.w   L_002BC0                              ; 00001A30 6100 118E
	addq.b  #8,D1                                 ; 00001A34 5001
	bsr.w   L_002BC0                              ; 00001A36 6100 1188
	addq.b  #8,D1                                 ; 00001A3A 5001
	bsr.w   L_002BC0                              ; 00001A3C 6100 1182
	rts                                           ; 00001A40 4E75

L_001A42:
	movem.l D0-D2/D6/A0-A4,-(A7)                  ; 00001A42 48E7 E2F8
	move.w  ($2,A5),D6                            ; 00001A46 3C2D 0002
	st      (A5)                                  ; 00001A4A 50D5
	move.w  ($44,A5),D0                           ; 00001A4C 302D 0044
	lea     ($15,A6,D0.w),A0                      ; 00001A50 41F6 0015
	bne.s   L_001A5A                              ; 00001A54 6604
	lea     (-$392,A6),A0                         ; 00001A56 41EE FC6E

L_001A5A:
	move.w  ($16,A5),(A0)                         ; 00001A5A 30AD 0016
	move.w  ($16,A5),D0                           ; 00001A5E 302D 0016
	beq.s   L_001A6C                              ; 00001A62 6708
	lea     ($43,A6,D0.w),A0                      ; 00001A64 41F6 0043
	move.w  ($44,A5),(A0)                         ; 00001A68 30AD 0044

L_001A6C:
	moveq   #$0,D0                                ; 00001A6C 7000
	move.b  ($ff,A5),D0                           ; 00001A6E 102D 00FF
	moveq   #$7,D1                                ; 00001A72 7207
	and.w   D0,D1                                 ; 00001A74 C240
	eor.w   D1,D0                                 ; 00001A76 B340
	eori.w  #$18,D0                               ; 00001A78 0A40 0018
	lsr.w   #3,D0                                 ; 00001A7C E648
	bclr    D1,(-$40,A6,D0.w)                     ; 00001A7E 03B6 00C0
	lea     (-$3a2,A6),A0                         ; 00001A82 41EE FC5E
	bclr    D1,(A0,D0.w)                          ; 00001A86 03B0 0000
	tst.b   ($fe,A5)                              ; 00001A8A 4A2D 00FE
	bpl.s   L_001AC6                              ; 00001A8E 6A36
	move.w  ($7a,A5),D1                           ; 00001A90 322D 007A
	move.w  (-$392,A6),D0                         ; 00001A94 302E FC6E
	beq.s   L_001AC2                              ; 00001A98 6728

L_001A9A:
	lea     (-$1,A6,D0.w),A0                      ; 00001A9A 41F6 00FF
	cmp.w   ($7a,A0),D1                           ; 00001A9E B268 007A
	beq.s   L_001AC6                              ; 00001AA2 6722
	move.w  ($16,A0),D0                           ; 00001AA4 3028 0016
	bne.s   L_001A9A                              ; 00001AA8 66F0
	move.w  (-$392,A6),D0                         ; 00001AAA 302E FC6E

L_001AAE:
	lea     (-$1,A6,D0.w),A0                      ; 00001AAE 41F6 00FF
	cmp.w   ($7a,A0),D1                           ; 00001AB2 B268 007A
	bcc.s   L_001ABC                              ; 00001AB6 6404
	subq.b  #1,($7b,A0)                           ; 00001AB8 5328 007B

L_001ABC:
	move.w  ($16,A0),D0                           ; 00001ABC 3028 0016
	bne.s   L_001AAE                              ; 00001AC0 66EC

L_001AC2:
	subq.b  #1,(-$126,A6)                         ; 00001AC2 532E FEDA

L_001AC6:
	tst.w   (-$392,A6)                            ; 00001AC6 4A6E FC6E
	bne.s   L_001AFC                              ; 00001ACA 6630
	tst.b   ($fe,A5)                              ; 00001ACC 4A2D 00FE
	bmi.s   L_001AF6                              ; 00001AD0 6B24
	clr.w   (-$80,A6)                             ; 00001AD2 426E FF80
	move.l  #$10000,D0                            ; 00001AD6 203C 0001 0000
	bsr.w   L_001B8C                              ; 00001ADC 6100 00AE
	st      (-$3b7,A6)                            ; 00001AE0 50EE FC49
	move.w  #$ffff,(-$6c,A6)                      ; 00001AE4 3D7C FFFF FF94
	bsr.w   L_000BDA                              ; 00001AEA 6100 F0EE
	moveq   #$2,D0                                ; 00001AEE 7002
	bsr.w   L_00083A                              ; 00001AF0 6100 ED48
	bra.s   L_001AFC                              ; 00001AF4 6006

L_001AF6:
	andi.b  #$f5,(-$127,A6)                       ; 00001AF6 022E 00F5 FED9

L_001AFC:
	subq.w  #1,(-$6e,A6)                          ; 00001AFC 536E FF92
	bsr.w   L_00257C                              ; 00001B00 6100 0A7A
	movem.l (A7)+,D0-D2/D6/A0-A4                  ; 00001B04 4CDF 1F47
	rts                                           ; 00001B08 4E75

L_001B0A:
	tst.b   (-$13c,A6)                            ; 00001B0A 4A2E FEC4
	beq.s   L_001B28                              ; 00001B0E 6718
	ext.w   D4                                    ; 00001B10 4884
	lea     L_003B4C(pc),A0                       ; 00001B12 41FA 2038
	move.b  (A0,D4.w),D1                          ; 00001B16 1230 4000
	ext.w   D1                                    ; 00001B1A 4881
	swap    D1                                    ; 00001B1C 4841
	move.w  ($4c,A5),D1                           ; 00001B1E 322D 004C
	moveq   #$70,D0                               ; 00001B22 7070
	or.b    D6,D0                                 ; 00001B24 8006
	trap    #$2                                   ; 00001B26 4E42

L_001B28:
	rts                                           ; 00001B28 4E75

L_001B2A:
	eori.b  #$7f,D0                               ; 00001B2A 0A00 007F
	moveq   #$60,D1                               ; 00001B2E 7260
	or.b    D6,D1                                 ; 00001B30 8206
	move.b  ($74,A5),D3                           ; 00001B32 162D 0074
	lea     ($75,A5),A0                           ; 00001B36 41ED 0075

L_001B3A:
	move.b  (A0)+,D2                              ; 00001B3A 1418
	add.b   D3,D3                                 ; 00001B3C D603
	bcc.s   L_001B4A                              ; 00001B3E 640A
	add.b   D0,D2                                 ; 00001B40 D400
	bpl.s   L_001B46                              ; 00001B42 6A02
	moveq   #$7f,D2                               ; 00001B44 747F

L_001B46:
	bsr.w   L_002BC0                              ; 00001B46 6100 1078

L_001B4A:
	addq.b  #8,D1                                 ; 00001B4A 5001
	bpl.s   L_001B3A                              ; 00001B4C 6AEC
	rts                                           ; 00001B4E 4E75

L_001B50:
	moveq   #$20,D0                               ; 00001B50 7020
	or.b    D6,D0                                 ; 00001B52 8006
	bsr.w   L_002BAC                              ; 00001B54 6100 1056
	moveq   #$40,D0                               ; 00001B58 7040
	cmpi.b  #$10,($23,A5)                         ; 00001B5A 0C2D 0010 0023
	bcs.s   L_001B6E                              ; 00001B60 650C
	moveq   #-$40,D0                              ; 00001B62 70C0
	cmpi.b  #$70,($23,A5)                         ; 00001B64 0C2D 0070 0023
	bcs.s   L_001B6E                              ; 00001B6A 6502
	moveq   #-$80,D0                              ; 00001B6C 7080

L_001B6E:
	move.b  D0,($70,A5)                           ; 00001B6E 1B40 0070
	or.b    ($61,A5),D0                           ; 00001B72 802D 0061
	bra.w   L_002BB6                              ; 00001B76 6000 103E

L_001B7A:
	tst.w   D0                                    ; 00001B7A 4A40
	bne.s   L_001B80                              ; 00001B7C 6602
	moveq   #$1,D0                                ; 00001B7E 7001

L_001B80:
	mulu.w  (-$68,A6),D0                          ; 00001B80 C0EE FF98
	mulu.w  (-$6a,A6),D0                          ; 00001B84 C0EE FF96
	lsr.l   #8,D0                                 ; 00001B88 E088
	bsr.s   L_001B94                              ; 00001B8A 6108

L_001B8C:
	tst.b   (-$132,A6)                            ; 00001B8C 4A2E FECE
	beq.s   L_001BBE                              ; 00001B90 672C
	bra.s   L_001C08                              ; 00001B92 6074

L_001B94:
	move.l  #$3938700,D1                          ; 00001B94 223C 0393 8700

L_001B9A:
	lsr.l   #1,D0                                 ; 00001B9A E288
	bcs.s   L_001BA4                              ; 00001B9C 6506
	lsr.l   #1,D1                                 ; 00001B9E E289
	bcc.s   L_001B9A                              ; 00001BA0 64F8
	addx.l  D1,D1                                 ; 00001BA2 D381

L_001BA4:
	addx.l  D0,D0                                 ; 00001BA4 D180
	move.w  D1,D2                                 ; 00001BA6 3401
	clr.w   D1                                    ; 00001BA8 4241
	swap    D1                                    ; 00001BAA 4841
	divu.w  D0,D1                                 ; 00001BAC 82C0
	eor.w   D1,D2                                 ; 00001BAE B342
	eor.w   D2,D1                                 ; 00001BB0 B541
	eor.w   D1,D2                                 ; 00001BB2 B342
	divu.w  D0,D1                                 ; 00001BB4 82C0
	move.w  D2,D0                                 ; 00001BB6 3002
	swap    D0                                    ; 00001BB8 4840
	move.w  D1,D0                                 ; 00001BBA 3001
	rts                                           ; 00001BBC 4E75

L_001BBE:
	addq.l  #8,D0                                 ; 00001BBE 5080
	move.l  D0,D1                                 ; 00001BC0 2200
	moveq   #$11,D0                               ; 00001BC2 7011
	bsr.w   L_002BAC                              ; 00001BC4 6100 0FE6
	move.l  D1,D0                                 ; 00001BC8 2001
	lsr.l   #4,D0                                 ; 00001BCA E888
	lsl.l   #2,D1                                 ; 00001BCC E589
	swap    D1                                    ; 00001BCE 4841
	move.w  D1,(-$250,A6)                         ; 00001BD0 3D41 FDB0
	addq.w  #1,D1                                 ; 00001BD4 5241
	divu.w  D1,D0                                 ; 00001BD6 80C1
	neg.w   D0                                    ; 00001BD8 4440
	move.w  D0,D1                                 ; 00001BDA 3200
	and.w   #$3,D0                                ; 00001BDC C07C 0003
	bsr.w   L_002BB6                              ; 00001BE0 6100 0FD4
	lsr.w   #2,D1                                 ; 00001BE4 E449
	moveq   #$10,D0                               ; 00001BE6 7010
	bsr.w   L_002BAC                              ; 00001BE8 6100 0FC2
	move.w  D1,D0                                 ; 00001BEC 3001
	bra.w   L_002BB6                              ; 00001BEE 6000 0FC6

L_001BF2:
	move.l  D0,D1                                 ; 00001BF2 2200
	moveq   #$12,D0                               ; 00001BF4 7012
	bsr.w   L_002BAC                              ; 00001BF6 6100 0FB4
	move.l  D1,D0                                 ; 00001BFA 2001
	lsr.l   #8,D0                                 ; 00001BFC E088
	bcc.s   L_001C02                              ; 00001BFE 6402
	addq.w  #1,D0                                 ; 00001C00 5240

L_001C02:
	not.w   D0                                    ; 00001C02 4640
	bra.w   L_002BB6                              ; 00001C04 6000 0FB0

L_001C08:
	moveq   #$0,D1                                ; 00001C08 7200

L_001C0A:
	cmpi.l  #$20000,D0                            ; 00001C0A 0C80 0002 0000
	bcs.s   L_001C1A                              ; 00001C10 6508
	lsr.l   #1,D0                                 ; 00001C12 E288
	add.w   D1,D1                                 ; 00001C14 D241
	addq.w  #1,D1                                 ; 00001C16 5241
	bra.s   L_001C0A                              ; 00001C18 60F0

L_001C1A:
	lsr.l   #3,D0                                 ; 00001C1A E688
	move    SR,-(A7)                              ; 00001C1C 40E7
	ori     #$700,SR                              ; 00001C1E 007C 0700
	move.b  #$8,($eafa03).l                       ; 00001C22 13FC 0008 00EA FA03
	tst.b   ($e9a001).l                           ; 00001C2A 4A39 00E9 A001
	move.b  D0,($eafa09).l                        ; 00001C30 13C0 00EA FA09
	tst.b   ($e9a001).l                           ; 00001C36 4A39 00E9 A001
	lsr.w   #8,D0                                 ; 00001C3C E048
	move.b  D0,($eafa0b).l                        ; 00001C3E 13C0 00EA FA0B
	move    (A7)+,SR                              ; 00001C44 46DF
	rts                                           ; 00001C46 4E75

L_001C48:
	movem.l D0-D7/A0-A2,-(A7)                     ; 00001C48 48E7 FFE0
	move.w  D0,D7                                 ; 00001C4C 3E00

L_001C4E:
	move.b  (A0)+,D0                              ; 00001C4E 1018
	bmi.s   L_001C5A                              ; 00001C50 6B08
	move.b  L_00237E(pc),D0                       ; 00001C52 103A 072A
	subq.l  #1,A0                                 ; 00001C56 5388
	bra.s   L_001C66                              ; 00001C58 600C

L_001C5A:
	cmpi.b  #-$10,D0                              ; 00001C5A 0C00 00F0
	bcc.s   L_001C66                              ; 00001C5E 6406
	move.b  D0,L_00237E                           ; 00001C60 13C0 0000 237E

L_001C66:
	moveq   #$f,D1                                ; 00001C66 720F
	and.w   D0,D1                                 ; 00001C68 C240
	and.w   #$70,D0                               ; 00001C6A C07C 0070
	lsr.w   #3,D0                                 ; 00001C6E E648
	move.w  L_001C7C(pc,D0.w),D0                  ; 00001C70 303B 000A
	jsr     L_001C7C(pc,D0.w)                     ; 00001C74 4EBB 0006
	bcc.s   L_001C4E                              ; 00001C78 64D4
	bra.s   L_001C8C                              ; 00001C7A 6010

L_001C7C:
	dc.w    L_001C92-L_001C7C                     ; 00001C7C
	dc.w    L_001D4E-L_001C7C                     ; 00001C7E
	dc.w    L_001E5E-L_001C7C                     ; 00001C80
	dc.w    L_001E64-L_001C7C                     ; 00001C82
	dc.w    L_001F4E-L_001C7C                     ; 00001C84
	dc.w    L_001F7A-L_001C7C                     ; 00001C86
	dc.w    L_001F80-L_001C7C                     ; 00001C88
	dc.w    L_001FF6-L_001C7C                     ; 00001C8A

L_001C8C:
	movem.l (A7)+,D0-D7/A0-A2                     ; 00001C8C 4CDF 07FF
	rts                                           ; 00001C90 4E75

L_001C92:
	cmpi.w  #$2,D7                                ; 00001C92 0C47 0002
	bcs.s   L_001CBA                              ; 00001C96 6522

L_001C98:
	move.b  (A0),D2                               ; 00001C98 1410
	lea     L_0022AC(pc),A1                       ; 00001C9A 43FA 0610
	moveq   #$7,D0                                ; 00001C9E 7007

L_001CA0:
	cmp.b   (A1)+,D1                              ; 00001CA0 B219
	dbeq    D0,L_001CA0                           ; 00001CA2 57C8 FFFC
	bne.s   L_001CBA                              ; 00001CA6 6612
	cmp.b   ($7,A1),D2                            ; 00001CA8 B429 0007
	dbeq    D0,L_001CA0                           ; 00001CAC 57C8 FFF2
	bne.s   L_001CBA                              ; 00001CB0 6608
	neg.w   D0                                    ; 00001CB2 4440
	addq.w  #7,D0                                 ; 00001CB4 5E40
	bsr.w   L_00223E                              ; 00001CB6 6100 0586

L_001CBA:
	subq.w  #3,D7                                 ; 00001CBA 5747
	addq.l  #2,A0                                 ; 00001CBC 5488
	rts                                           ; 00001CBE 4E75

L_001CC0:
	tst.b   (-$13c,A6)                            ; 00001CC0 4A2E FEC4
	beq.w   L_001E58                              ; 00001CC4 6700 0192
	moveq   #$7f,D3                               ; 00001CC8 767F
	and.b   (A0),D3                               ; 00001CCA C610
	subi.b  #$1b,D3                               ; 00001CCC 0403 001B
	bcs.w   L_001E58                              ; 00001CD0 6500 0186
	cmpi.b  #$3d,D3                               ; 00001CD4 0C03 003D
	bcc.w   L_001E58                              ; 00001CD8 6400 017E
	bsr.w   L_0021CA                              ; 00001CDC 6100 04EC
	lea     L_00236E(pc),A1                       ; 00001CE0 43FA 068C
	move.b  D1,(A1,D0.w)                          ; 00001CE4 1381 0000
	move.b  D3,($8,A1,D0.w)                       ; 00001CE8 1383 0008
	move.l  (-$1ca,A6),D1                         ; 00001CEC 222E FE36
	beq.w   L_001E58                              ; 00001CF0 6700 0166
	movea.l D1,A1                                 ; 00001CF4 2241
	moveq   #$0,D1                                ; 00001CF6 7200
	move.b  D3,D1                                 ; 00001CF8 1203
	lsl.w   #3,D1                                 ; 00001CFA E749
	move.l  ($4,A1,D1.l),D2                       ; 00001CFC 2431 1804
	beq.w   L_001E58                              ; 00001D00 6700 0156
	adda.l  (A1,D1.l),A1                          ; 00001D04 D3F1 1800
	movem.l D0/D2-D3,-(A7)                        ; 00001D08 48E7 B000
	moveq   #$7f,D1                               ; 00001D0C 727F
	and.b   ($1,A0),D1                            ; 00001D0E C228 0001
	moveq   #$0,D2                                ; 00001D12 7400
	move.b  L_0022CD(pc),D2                       ; 00001D14 143A 05B7
	moveq   #$0,D3                                ; 00001D18 7600
	move.b  L_0022DD(pc),D3                       ; 00001D1A 163A 05C1
	move.w  D1,D0                                 ; 00001D1E 3001
	and.w   D2,D0                                 ; 00001D20 C042
	and.w   D3,D0                                 ; 00001D22 C043
	bne.s   L_001D2A                              ; 00001D24 6604
	moveq   #-$1,D1                               ; 00001D26 72FF
	bra.s   L_001D3A                              ; 00001D28 6010

L_001D2A:
	addq.b  #1,D1                                 ; 00001D2A 5201
	addq.b  #1,D2                                 ; 00001D2C 5202
	addq.b  #1,D3                                 ; 00001D2E 5203
	mulu.w  D3,D2                                 ; 00001D30 C4C3
	mulu.w  D2,D1                                 ; 00001D32 C2C2
	swap    D1                                    ; 00001D34 4841
	addq.w  #3,D1                                 ; 00001D36 5641
	lsr.w   #2,D1                                 ; 00001D38 E449

L_001D3A:
	movem.l (A7)+,D0/D2-D3                        ; 00001D3A 4CDF 000D
	tst.w   D1                                    ; 00001D3E 4A41
	bmi.s   L_001D4A                              ; 00001D40 6B08
	swap    D1                                    ; 00001D42 4841
	move.w  #$403,D1                              ; 00001D44 323C 0403
	trap    #$2                                   ; 00001D48 4E42

L_001D4A:
	bra.w   L_001E58                              ; 00001D4A 6000 010C

L_001D4E:
	cmpi.w  #$2,D7                                ; 00001D4E 0C47 0002
	bcs.w   L_001E58                              ; 00001D52 6500 0104
	tst.b   ($1,A0)                               ; 00001D56 4A28 0001
	beq.w   L_001C98                              ; 00001D5A 6700 FF3C
	lea     L_002344(pc),A1                       ; 00001D5E 43FA 05E4
	tst.b   (A1,D1.w)                             ; 00001D62 4A31 1000
	bne.w   L_001CC0                              ; 00001D66 6600 FF58
	bsr.w   L_00221E                              ; 00001D6A 6100 04B2
	lea     L_0022AC(pc),A1                       ; 00001D6E 43FA 053C
	move.b  D1,(A1,D0.w)                          ; 00001D72 1381 0000
	move.b  (A0),($8,A1,D0.w)                     ; 00001D76 1390 0008
	move.b  ($1,A0),($10,A1,D0.w)                 ; 00001D7A 13A8 0001 0010
	movem.l D0-D2,-(A7)                           ; 00001D80 48E7 E000
	lea     L_002334(pc),A1                       ; 00001D84 43FA 05AE
	moveq   #$7f,D2                               ; 00001D88 747F
	and.b   (A1,D1.w),D2                          ; 00001D8A C431 1000
	lea     L_002C50(pc),A1                       ; 00001D8E 43FA 0EC0
	move.b  (A1,D2.w),D2                          ; 00001D92 1431 2000
	mulu.w  #$1a,D2                               ; 00001D96 C4FC 001A
	lea     ($80,A1),A1                           ; 00001D9A 43E9 0080
	adda.l  D2,A1                                 ; 00001D9E D3C2
	move.l  A0,-(A7)                              ; 00001DA0 2F08
	lea     L_002354(pc),A0                       ; 00001DA2 41FA 05B0
	move.b  ($1,A1),D1                            ; 00001DA6 1229 0001
	lsr.b   #4,D1                                 ; 00001DAA E809
	move.b  D1,(A0,D0.w)                          ; 00001DAC 1181 0000
	movea.l (A7)+,A0                              ; 00001DB0 205F
	move.b  D0,D1                                 ; 00001DB2 1200
	andi.w  #$7,D1                                ; 00001DB4 0241 0007
	add.w   #$20,D1                               ; 00001DB8 D27C 0020
	move.b  (A1)+,D2                              ; 00001DBC 1419
	ori.b   #$c0,D2                               ; 00001DBE 0002 00C0
	bsr.w   L_002BC0                              ; 00001DC2 6100 0DFC
	addq.l  #1,A1                                 ; 00001DC6 5289
	moveq   #$3,D0                                ; 00001DC8 7003
	add.w   #$20,D1                               ; 00001DCA D27C 0020

L_001DCE:
	move.b  (A1)+,D2                              ; 00001DCE 1419
	bsr.w   L_002BC0                              ; 00001DD0 6100 0DEE
	addq.b  #8,D1                                 ; 00001DD4 5001
	dbra    D0,L_001DCE                           ; 00001DD6 51C8 FFF6
	addq.l  #4,A1                                 ; 00001DDA 5889
	moveq   #$f,D0                                ; 00001DDC 700F
	add.w   #$20,D1                               ; 00001DDE D27C 0020

L_001DE2:
	move.b  (A1)+,D2                              ; 00001DE2 1419
	bsr.w   L_002BC0                              ; 00001DE4 6100 0DDA
	addq.b  #8,D1                                 ; 00001DE8 5001
	dbra    D0,L_001DE2                           ; 00001DEA 51C8 FFF6
	and.w   #$7,D1                                ; 00001DEE C27C 0007
	add.w   #$28,D1                               ; 00001DF2 D27C 0028
	moveq   #$0,D0                                ; 00001DF6 7000
	move.b  (A0),D0                               ; 00001DF8 1010
	lea     L_001814(pc),A1                       ; 00001DFA 43FA FA18
	move.b  (A1,D0.w),D2                          ; 00001DFE 1431 0000
	bsr.w   L_002BC0                              ; 00001E02 6100 0DBC
	movem.l (A7)+,D0-D2                           ; 00001E06 4CDF 0007
	move.w  D1,D3                                 ; 00001E0A 3601
	move.w  D0,D1                                 ; 00001E0C 3200
	bsr.w   L_0020FC                              ; 00001E0E 6100 02EC
	bsr.w   L_0021A6                              ; 00001E12 6100 0392
	move.w  D0,D2                                 ; 00001E16 3400
	moveq   #$8,D1                                ; 00001E18 7208
	andi.w  #$7,D2                                ; 00001E1A 0242 0007
	bsr.w   L_002BC0                              ; 00001E1E 6100 0DA0
	ori.w   #$78,D2                               ; 00001E22 0042 0078
	bsr.w   L_002BC0                              ; 00001E26 6100 0D98
	move.w  D0,D1                                 ; 00001E2A 3200
	add.w   #$30,D1                               ; 00001E2C D27C 0030
	add.w   D3,D3                                 ; 00001E30 D643
	lea     L_002304(pc),A1                       ; 00001E32 43FA 04D0
	move.w  (A1,D3.w),D0                          ; 00001E36 3031 3000
	move.w  D0,D2                                 ; 00001E3A 3400
	lsl.w   #2,D2                                 ; 00001E3C E54A
	bsr.w   L_002BC0                              ; 00001E3E 6100 0D80
	subq.b  #8,D1                                 ; 00001E42 5101
	lsr.w   #6,D0                                 ; 00001E44 EC48
	add.b   (A0),D0                               ; 00001E46 D010
	and.w   #$7f,D0                               ; 00001E48 C07C 007F
	lea     L_001814(pc),A1                       ; 00001E4C 43FA F9C6
	move.b  (A1,D0.w),D2                          ; 00001E50 1431 0000
	bsr.w   L_002BC0                              ; 00001E54 6100 0D6A

L_001E58:
	subq.w  #3,D7                                 ; 00001E58 5747
	addq.l  #2,A0                                 ; 00001E5A 5488
	rts                                           ; 00001E5C 4E75

L_001E5E:
	subq.w  #3,D7                                 ; 00001E5E 5747
	addq.l  #2,A0                                 ; 00001E60 5488
	rts                                           ; 00001E62 4E75

L_001E64:
	addq.l  #2,A0                                 ; 00001E64 5488
	cmpi.w  #$2,D7                                ; 00001E66 0C47 0002
	bcs.w   L_001F4A                              ; 00001E6A 6500 00DE
	move.b  (-$2,A0),D0                           ; 00001E6E 1028 FFFE
	cmpi.b  #$1,D0                                ; 00001E72 0C00 0001
	bne.s   L_001EA4                              ; 00001E76 662C
	lea     L_001E9C(pc),A1                       ; 00001E78 43FA 0022
	move.b  (-$1,A0),D0                           ; 00001E7C 1028 FFFF
	moveq   #$0,D2                                ; 00001E80 7400

L_001E82:
	cmp.b   (A1)+,D0                              ; 00001E82 B019
	bls.s   L_001E8A                              ; 00001E84 6304
	addq.b  #1,D2                                 ; 00001E86 5202
	bra.s   L_001E82                              ; 00001E88 60F8

L_001E8A:
	lsl.w   #4,D2                                 ; 00001E8A E94A
	lea     L_002324(pc),A1                       ; 00001E8C 43FA 0496
	move.b  D2,(A1,D1.w)                          ; 00001E90 1382 1000
	bsr.w   L_00217E                              ; 00001E94 6100 02E8
	bra.w   L_001F4A                              ; 00001E98 6000 00B0

L_001E9C:
	dc.b    $00,$04,$08,$10,$20,$40,$7F,$7F       ; 00001E9C

L_001EA4:
	cmpi.b  #$6,D0                                ; 00001EA4 0C00 0006
	bne.s   L_001EC0                              ; 00001EA8 6616
	lea     L_0022F4(pc),A1                       ; 00001EAA 43FA 0448
	tst.b   (A1,D1.w)                             ; 00001EAE 4A31 1000
	bne.w   L_001F4A                              ; 00001EB2 6600 0096
	move.b  (-$1,A0),(-$10,A1,D1.w)               ; 00001EB6 13A8 FFFF 10F0
	bra.w   L_001F4A                              ; 00001EBC 6000 008C

L_001EC0:
	cmpi.b  #$7,D0                                ; 00001EC0 0C00 0007
	bne.s   L_001ED6                              ; 00001EC4 6610
	lea     L_0022C4(pc),A1                       ; 00001EC6 43FA 03FC
	move.b  (-$1,A0),(A1,D1.w)                    ; 00001ECA 13A8 FFFF 1000
	bsr.w   L_0020D4                              ; 00001ED0 6100 0202
	bra.s   L_001F4A                              ; 00001ED4 6074

L_001ED6:
	cmpi.b  #$b,D0                                ; 00001ED6 0C00 000B
	bne.s   L_001EEC                              ; 00001EDA 6610
	lea     L_0022D4(pc),A1                       ; 00001EDC 43FA 03F6
	move.b  (-$1,A0),(A1,D1.w)                    ; 00001EE0 13A8 FFFF 1000
	bsr.w   L_0020D4                              ; 00001EE6 6100 01EC
	bra.s   L_001F4A                              ; 00001EEA 605E

L_001EEC:
	cmpi.b  #$65,D0                               ; 00001EEC 0C00 0065
	bne.s   L_001F0A                              ; 00001EF0 6618
	lea     L_0022F4(pc),A1                       ; 00001EF2 43FA 0400
	bclr    #$7,(A1,D1.w)                         ; 00001EF6 08B1 0007 1000
	tst.b   (-$1,A0)                              ; 00001EFC 4A28 FFFF
	beq.s   L_001F4A                              ; 00001F00 6748
	bset    #$7,(A1,D1.w)                         ; 00001F02 08F1 0007 1000
	bra.s   L_001F4A                              ; 00001F08 6040

L_001F0A:
	cmpi.b  #$64,D0                               ; 00001F0A 0C00 0064
	bne.s   L_001F28                              ; 00001F0E 6618
	lea     L_0022F4(pc),A1                       ; 00001F10 43FA 03E2
	bclr    #$0,(A1,D1.w)                         ; 00001F14 08B1 0000 1000
	tst.b   (-$1,A0)                              ; 00001F1A 4A28 FFFF
	beq.s   L_001F4A                              ; 00001F1E 672A
	bset    #$0,(A1,D1.w)                         ; 00001F20 08F1 0000 1000
	bra.s   L_001F4A                              ; 00001F26 6022

L_001F28:
	cmpi.b  #$63,D0                               ; 00001F28 0C00 0063
	bne.s   L_001F3A                              ; 00001F2C 660C
	lea     L_0022F4(pc),A1                       ; 00001F2E 43FA 03C4
	move.b  #$81,(A1,D1.w)                        ; 00001F32 13BC 0081 1000
	bra.s   L_001F4A                              ; 00001F38 6010

L_001F3A:
	cmpi.b  #$62,D0                               ; 00001F3A 0C00 0062
	bne.s   L_001F4A                              ; 00001F3E 660A
	lea     L_0022F4(pc),A1                       ; 00001F40 43FA 03B2
	move.b  #$81,(A1,D1.w)                        ; 00001F44 13BC 0081 1000

L_001F4A:
	subq.w  #3,D7                                 ; 00001F4A 5747
	rts                                           ; 00001F4C 4E75

L_001F4E:
	lea     L_002334(pc),A1                       ; 00001F4E 43FA 03E4
	move.b  (A0)+,(A1,D1.w)                       ; 00001F52 1398 1000
	moveq   #$18,D1                               ; 00001F56 7218
	moveq   #-$31,D2                              ; 00001F58 74CF
	bsr.w   L_002BC0                              ; 00001F5A 6100 0C64
	moveq   #$19,D1                               ; 00001F5E 7219
	moveq   #-$6c,D2                              ; 00001F60 7494
	bsr.w   L_002BC0                              ; 00001F62 6100 0C5C
	moveq   #$1b,D1                               ; 00001F66 721B
	moveq   #-$40,D2                              ; 00001F68 74C0
	ifnd __ATARI__
	and.b   ($9da).w,D2                           ; 00001F6A C438 09DA
	else
	and.b   mcdrv_opm_1b,D2
	endif
	ori.b   #$2,D2                                ; 00001F6E 0002 0002
	bsr.w   L_002BC0                              ; 00001F72 6100 0C4C
	subq.w  #2,D7                                 ; 00001F76 5547
	rts                                           ; 00001F78 4E75

L_001F7A:
	addq.l  #1,A0                                 ; 00001F7A 5288
	subq.w  #2,D7                                 ; 00001F7C 5547
	rts                                           ; 00001F7E 4E75

L_001F80:
	moveq   #$0,D0                                ; 00001F80 7000
	move.b  ($1,A0),D0                            ; 00001F82 1028 0001
	lsl.w   #8,D0                                 ; 00001F86 E148
	move.b  (A0),D0                               ; 00001F88 1010
	addq.l  #2,A0                                 ; 00001F8A 5488
	cmpi.w  #$2,D7                                ; 00001F8C 0C47 0002
	bcs.s   L_001FF2                              ; 00001F90 6560
	add.b   D0,D0                                 ; 00001F92 D000
	lsr.w   #1,D0                                 ; 00001F94 E248
	sub.w   #$2000,D0                             ; 00001F96 907C 2000
	lea     L_0022E4(pc),A1                       ; 00001F9A 43FA 0348
	moveq   #$0,D2                                ; 00001F9E 7400
	move.b  (A1,D1.w),D2                          ; 00001FA0 1431 1000
	muls.w  D2,D0                                 ; 00001FA4 C1C2
	asr.l   #7,D0                                 ; 00001FA6 EE80
	move.w  D1,D2                                 ; 00001FA8 3401
	add.w   D2,D2                                 ; 00001FAA D442
	move.w  D0,($20,A1,D2.w)                      ; 00001FAC 3380 2020
	move.w  D0,D3                                 ; 00001FB0 3600
	lea     L_0022AC(pc),A1                       ; 00001FB2 43FA 02F8
	moveq   #$7,D0                                ; 00001FB6 7007

L_001FB8:
	cmp.b   (A1)+,D1                              ; 00001FB8 B219
	dbeq    D0,L_001FB8                           ; 00001FBA 57C8 FFFC
	bne.s   L_001FF2                              ; 00001FBE 6632
	movem.l D0-D3/A1,-(A7)                        ; 00001FC0 48E7 F040
	moveq   #$37,D1                               ; 00001FC4 7237
	sub.b   D0,D1                                 ; 00001FC6 9200
	move.b  D3,D2                                 ; 00001FC8 1403
	lsl.b   #2,D2                                 ; 00001FCA E50A
	bsr.w   L_002BC0                              ; 00001FCC 6100 0BF2
	subq.w  #8,D1                                 ; 00001FD0 5141
	move.w  D3,D2                                 ; 00001FD2 3403
	lsr.w   #6,D2                                 ; 00001FD4 EC4A
	add.b   ($7,A1),D2                            ; 00001FD6 D429 0007
	and.w   #$7f,D2                               ; 00001FDA C47C 007F
	lea     L_001814(pc),A1                       ; 00001FDE 43FA F834
	move.b  (A1,D2.w),D2                          ; 00001FE2 1431 2000
	bsr.w   L_002BC0                              ; 00001FE6 6100 0BD8
	movem.l (A7)+,D0-D3/A1                        ; 00001FEA 4CDF 020F
	dbra    D0,L_001FB8                           ; 00001FEE 51C8 FFC8

L_001FF2:
	subq.w  #3,D7                                 ; 00001FF2 5747
	rts                                           ; 00001FF4 4E75

L_001FF6:
	tst.b   D1                                    ; 00001FF6 4A01
	bne.w   L_00207E                              ; 00001FF8 6600 0084
	subq.w  #1,D7                                 ; 00001FFC 5347
	bcc.s   L_002002                              ; 00001FFE 6402
	rts                                           ; 00002000 4E75

L_002002:
	movem.l A0-A1,-(A7)                           ; 00002002 48E7 00C0
	lea     L_0020CC(pc),A1                       ; 00002006 43FA 00C4
	moveq   #$6,D0                                ; 0000200A 7006

L_00200C:
	cmpm.b  (A0)+,(A1)+                           ; 0000200C B308
	dbne    D0,L_00200C                           ; 0000200E 56C8 FFFC
	bne.s   L_002018                              ; 00002012 6604
	bsr.s   L_002082                              ; 00002014 616C
	bra.s   L_00206E                              ; 00002016 6056

L_002018:
	movem.l (A7),A0-A1                            ; 00002018 4CD7 0300
	lea     L_0020CC(pc),A1                       ; 0000201C 43FA 00AE
	moveq   #$3,D0                                ; 00002020 7003

L_002022:
	cmpm.b  (A0)+,(A1)+                           ; 00002022 B308
	dbne    D0,L_002022                           ; 00002024 56C8 FFFC
	bne.s   L_00206E                              ; 00002028 6644
	moveq   #$0,D0                                ; 0000202A 7000
	move.b  (A0)+,D0                              ; 0000202C 1018
	lsl.w   #8,D0                                 ; 0000202E E148
	move.b  (A0)+,D0                              ; 00002030 1018
	cmp.w   #$4010,D0                             ; 00002032 B07C 4010
	bcs.s   L_00206E                              ; 00002036 6536
	cmp.w   #$4020,D0                             ; 00002038 B07C 4020
	bcc.s   L_00206E                              ; 0000203C 6430
	moveq   #$0,D0                                ; 0000203E 7000
	move.b  (A0)+,D0                              ; 00002040 1018
	sub.w   #$15,D0                               ; 00002042 907C 0015
	bgt.s   L_00206E                              ; 00002046 6E26
	neg.w   D0                                    ; 00002048 4440
	move.w  D7,D1                                 ; 0000204A 3207
	subq.w  #8,D1                                 ; 0000204C 5141
	cmp.w   D0,D1                                 ; 0000204E B240
	bls.s   L_00206E                              ; 00002050 631C
	moveq   #$f,D1                                ; 00002052 720F
	and.b   (-$2,A0),D1                           ; 00002054 C228 FFFE
	cmp.b   #$9,D1                                ; 00002058 B23C 0009
	bhi.s   L_002064                              ; 0000205C 6206
	subq.b  #1,D1                                 ; 0000205E 5301
	bcc.s   L_002064                              ; 00002060 6402
	moveq   #$9,D1                                ; 00002062 7209

L_002064:
	lea     L_002344(pc),A1                       ; 00002064 43FA 02DE
	move.b  (A0,D0.w),(A1,D1.w)                   ; 00002068 13B0 0000 1000

L_00206E:
	movem.l (A7)+,A0-A1                           ; 0000206E 4CDF 0300

L_002072:
	cmpi.b  #-$9,(A0)+                            ; 00002072 0C18 00F7
	dbeq    D7,L_002072                           ; 00002076 57CF FFFA
	beq.s   L_00207E                              ; 0000207A 6702
	moveq   #$0,D7                                ; 0000207C 7E00

L_00207E:
	subq.w  #1,D7                                 ; 0000207E 5347
	rts                                           ; 00002080 4E75

L_002082:
	movem.l D0/A0-A1,-(A7)                        ; 00002082 48E7 80C0
	lea     L_0022AC(pc),A0                       ; 00002086 41FA 0224
	moveq   #$f,D0                                ; 0000208A 700F

L_00208C:
	move.b  #$7f,($18,A0)                         ; 0000208C 117C 007F 0018
	move.b  #$64,($28,A0)                         ; 00002092 117C 0064 0028
	move.b  #$2,($38,A0)                          ; 00002098 117C 0002 0038
	move.b  #$81,($48,A0)                         ; 0000209E 117C 0081 0048
	sf      ($58,A0)                              ; 000020A4 51E8 0058
	sf      ($68,A0)                              ; 000020A8 51E8 0068
	sf      ($78,A0)                              ; 000020AC 51E8 0078
	sf      ($88,A0)                              ; 000020B0 51E8 0088
	sf      ($98,A0)                              ; 000020B4 51E8 0098
	st      (A0)+                                 ; 000020B8 50D8
	dbra    D0,L_00208C                           ; 000020BA 51C8 FFD0
	lea     L_00234D(pc),A0                       ; 000020BE 41FA 028D
	move.b  #$1,(A0)                              ; 000020C2 10BC 0001
	movem.l (A7)+,D0/A0-A1                        ; 000020C6 4CDF 0301
	rts                                           ; 000020CA 4E75

L_0020CC:
	dc.b    $41,$10,$42,$12,$40,$00,$7F,$00       ; 000020CC

L_0020D4:
	movem.l D0-D1/D6-D7/A0-A1,-(A7)               ; 000020D4 48E7 C3C0
	moveq   #$7,D7                                ; 000020D8 7E07
	move.l  D1,D6                                 ; 000020DA 2C01
	lea     L_0022C4(pc),A1                       ; 000020DC 43FA 01E6
	lea     L_0022AC(pc),A0                       ; 000020E0 41FA 01CA

L_0020E4:
	cmp.b   (A0)+,D6                              ; 000020E4 BC18
	dbeq    D7,L_0020E4                           ; 000020E6 57CF FFFC
	bne.s   L_0020F6                              ; 000020EA 660A
	moveq   #$7,D1                                ; 000020EC 7207
	sub.b   D7,D1                                 ; 000020EE 9207
	bsr.s   L_0020FC                              ; 000020F0 610A
	dbra    D7,L_0020E4                           ; 000020F2 51CF FFF0

L_0020F6:
	movem.l (A7)+,D0-D1/D6-D7/A0-A1               ; 000020F6 4CDF 03C3
	rts                                           ; 000020FA 4E75

L_0020FC:
	movem.l D0-D3/A0-A1,-(A7)                     ; 000020FC 48E7 F0C0
	lea     L_0022AC(pc),A0                       ; 00002100 41FA 01AA
	moveq   #$0,D3                                ; 00002104 7600
	move.b  (A0,D1.w),D3                          ; 00002106 1630 1000
	moveq   #$0,D0                                ; 0000210A 7000
	move.b  ($10,A0,D1.w),D0                      ; 0000210C 1030 1010
	lea     L_0022C4(pc),A0                       ; 00002110 41FA 01B2
	moveq   #$0,D2                                ; 00002114 7400
	move.b  (A0,D3.w),D2                          ; 00002116 1430 3000
	mulu.w  D2,D0                                 ; 0000211A C0C2
	move.b  ($10,A0,D3.w),D2                      ; 0000211C 1430 3010
	mulu.w  D2,D0                                 ; 00002120 C0C2
	lsl.l   #2,D0                                 ; 00002122 E588
	swap    D0                                    ; 00002124 4840
	lea     L_000E8E(pc),A0                       ; 00002126 41FA ED66
	move.b  (A0,D0.w),D0                          ; 0000212A 1030 0000
	eori.b  #$7f,D0                               ; 0000212E 0A00 007F
	lea     L_002334(pc),A0                       ; 00002132 41FA 0200
	moveq   #$7f,D2                               ; 00002136 747F
	and.b   (A0,D3.w),D2                          ; 00002138 C430 3000
	lea     L_002C50(pc),A0                       ; 0000213C 41FA 0B12
	move.b  (A0,D2.w),D2                          ; 00002140 1430 2000
	mulu.w  #$1a,D2                               ; 00002144 C4FC 001A
	lea     ($80,A0),A0                           ; 00002148 41E8 0080
	adda.l  D2,A0                                 ; 0000214C D1C2
	moveq   #$7,D3                                ; 0000214E 7607
	and.b   (A0),D3                               ; 00002150 C610
	lea     L_0019A2(pc),A1                       ; 00002152 43FA F84E
	move.b  (A1,D3.w),D3                          ; 00002156 1631 3000
	addq.l  #6,A0                                 ; 0000215A 5C88
	ori.w   #$60,D1                               ; 0000215C 0041 0060
	moveq   #$7f,D2                               ; 00002160 747F

L_002162:
	move.b  (A0)+,D2                              ; 00002162 1418
	add.b   D3,D3                                 ; 00002164 D603
	bcc.s   L_00216E                              ; 00002166 6406
	add.b   D0,D2                                 ; 00002168 D400
	bpl.s   L_00216E                              ; 0000216A 6A02
	moveq   #$7f,D2                               ; 0000216C 747F

L_00216E:
	bsr.w   L_002BC0                              ; 0000216E 6100 0A50
	addq.b  #8,D1                                 ; 00002172 5001
	tst.b   D3                                    ; 00002174 4A03
	bne.s   L_002162                              ; 00002176 66EA
	movem.l (A7)+,D0-D3/A0-A1                     ; 00002178 4CDF 030F
	rts                                           ; 0000217C 4E75

L_00217E:
	movem.l D0-D1/D6-D7/A0-A1,-(A7)               ; 0000217E 48E7 C3C0
	moveq   #$7,D7                                ; 00002182 7E07
	move.l  D1,D6                                 ; 00002184 2C01
	lea     L_002324(pc),A1                       ; 00002186 43FA 019C
	lea     L_0022AC(pc),A0                       ; 0000218A 41FA 0120

L_00218E:
	cmp.b   (A0)+,D6                              ; 0000218E BC18
	dbeq    D7,L_00218E                           ; 00002190 57CF FFFC
	bne.s   L_0021A0                              ; 00002194 660A
	moveq   #$7,D1                                ; 00002196 7207
	sub.b   D7,D1                                 ; 00002198 9207
	bsr.s   L_0021A6                              ; 0000219A 610A
	dbra    D7,L_00218E                           ; 0000219C 51CF FFF0

L_0021A0:
	movem.l (A7)+,D0-D1/D6-D7/A0-A1               ; 000021A0 4CDF 03C3
	rts                                           ; 000021A4 4E75

L_0021A6:
	movem.l D0-D3/A0,-(A7)                        ; 000021A6 48E7 F080
	lea     L_0022AC(pc),A0                       ; 000021AA 41FA 0100
	moveq   #$0,D3                                ; 000021AE 7600
	move.b  (A0,D1.w),D3                          ; 000021B0 1630 1000
	lea     L_002324(pc),A0                       ; 000021B4 41FA 016E
	move.b  (A0,D3.w),D2                          ; 000021B8 1430 3000
	ori.b   #$38,D1                               ; 000021BC 0001 0038
	bsr.w   L_002BC0                              ; 000021C0 6100 09FE
	movem.l (A7)+,D0-D3/A0                        ; 000021C4 4CDF 010F
	rts                                           ; 000021C8 4E75

L_0021CA:
	move.l  A0,-(A7)                              ; 000021CA 2F08
	lea     L_002365(pc),A0                       ; 000021CC 41FA 0197
	moveq   #$0,D0                                ; 000021D0 7000
	move.b  (A0),D0                               ; 000021D2 1010
	bpl.s   L_0021DC                              ; 000021D4 6A06
	move.b  ($8,A0),D0                            ; 000021D6 1028 0008
	bsr.s   L_0021EC                              ; 000021DA 6110

L_0021DC:
	lea     L_002366(pc),A0                       ; 000021DC 41FA 0188

L_0021E0:
	move.b  (A0)+,(-$2,A0)                        ; 000021E0 1158 FFFE
	bpl.s   L_0021E0                              ; 000021E4 6AFA
	move.b  D0,-(A0)                              ; 000021E6 1100
	movea.l (A7)+,A0                              ; 000021E8 205F
	rts                                           ; 000021EA 4E75

L_0021EC:
	movem.l D1-D2/A0,-(A7)                        ; 000021EC 48E7 6080
	ext.w   D0                                    ; 000021F0 4880
	lea     L_00236E(pc),A0                       ; 000021F2 41FA 017A
	st      (A0,D0.w)                             ; 000021F6 50F0 0000
	movem.l D0-D2,-(A7)                           ; 000021FA 48E7 E000
	moveq   #$0,D1                                ; 000021FE 7200
	moveq   #$0,D2                                ; 00002200 7400
	trap    #$2                                   ; 00002202 4E42
	movem.l (A7)+,D0-D2                           ; 00002204 4CDF 0007
	lea     L_00236E(pc),A0                       ; 00002208 41FA 0164

L_00220C:
	cmp.b   -(A0),D0                              ; 0000220C B020
	bne.s   L_00220C                              ; 0000220E 66FC

L_002210:
	move.b  -(A0),($1,A0)                         ; 00002210 1160 0001
	bpl.s   L_002210                              ; 00002214 6AFA
	move.b  D0,(A0)                               ; 00002216 1080
	movem.l (A7)+,D1-D2/A0                        ; 00002218 4CDF 0106
	rts                                           ; 0000221C 4E75

L_00221E:
	move.l  A0,-(A7)                              ; 0000221E 2F08
	lea     L_00235C(pc),A0                       ; 00002220 41FA 013A
	moveq   #$0,D0                                ; 00002224 7000
	move.b  (A0),D0                               ; 00002226 1010
	bpl.s   L_00222E                              ; 00002228 6A04
	bsr.s   L_00226A                              ; 0000222A 613E
	bsr.s   L_00223E                              ; 0000222C 6110

L_00222E:
	lea     L_00235D(pc),A0                       ; 0000222E 41FA 012D

L_002232:
	move.b  (A0)+,(-$2,A0)                        ; 00002232 1158 FFFE
	bpl.s   L_002232                              ; 00002236 6AFA
	move.b  D0,-(A0)                              ; 00002238 1100
	movea.l (A7)+,A0                              ; 0000223A 205F
	rts                                           ; 0000223C 4E75

L_00223E:
	movem.l D1-D2/A0,-(A7)                        ; 0000223E 48E7 6080
	ext.w   D0                                    ; 00002242 4880
	lea     L_0022AC(pc),A0                       ; 00002244 41FA 0066
	st      (A0,D0.w)                             ; 00002248 50F0 0000
	move.w  D0,D2                                 ; 0000224C 3400
	moveq   #$8,D1                                ; 0000224E 7208
	bsr.w   L_002BC0                              ; 00002250 6100 096E
	lea     L_002365(pc),A0                       ; 00002254 41FA 010F

L_002258:
	cmp.b   -(A0),D0                              ; 00002258 B020
	bne.s   L_002258                              ; 0000225A 66FC

L_00225C:
	move.b  -(A0),($1,A0)                         ; 0000225C 1160 0001
	bpl.s   L_00225C                              ; 00002260 6AFA
	move.b  D0,(A0)                               ; 00002262 1080
	movem.l (A7)+,D1-D2/A0                        ; 00002264 4CDF 0106
	rts                                           ; 00002268 4E75

L_00226A:
	movem.l D1-D2/A0-A1,-(A7)                     ; 0000226A 48E7 60C0
	lea     L_00235C(pc),A0                       ; 0000226E 41FA 00EC
	moveq   #$0,D0                                ; 00002272 7000

L_002274:
	moveq   #$7,D2                                ; 00002274 7407

L_002276:
	move.b  ($1,A0,D2.w),D0                       ; 00002276 1030 2001
	bmi.s   L_00228C                              ; 0000227A 6B10
	tst.b   (-$8,A0,D0.w)                         ; 0000227C 4A30 00F8
	dbeq    D2,L_002276                           ; 00002280 57CA FFF4
	bne.s   L_00228C                              ; 00002284 6606
	movem.l (A7)+,D1-D2/A0-A1                     ; 00002286 4CDF 0306
	rts                                           ; 0000228A 4E75

L_00228C:
	bsr.s   L_002290                              ; 0000228C 6102
	bra.s   L_002274                              ; 0000228E 60E4

L_002290:
	movem.l D0/A0,-(A7)                           ; 00002290 48E7 8080
	lea     L_002354(pc),A0                       ; 00002294 41FA 00BE
	moveq   #$7,D0                                ; 00002298 7007

L_00229A:
	tst.b   (A0)+                                 ; 0000229A 4A18
	beq.s   L_0022A2                              ; 0000229C 6704
	subq.b  #1,(-$1,A0)                           ; 0000229E 5328 FFFF

L_0022A2:
	dbra    D0,L_00229A                           ; 000022A2 51C8 FFF6
	movem.l (A7)+,D0/A0                           ; 000022A6 4CDF 0101
	rts                                           ; 000022AA 4E75

L_0022AC:
	dc.b    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; 000022AC
	dc.b    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF       ; 000022BC

L_0022C4:
	dc.b    'ddddddddd'                           ; 000022C4

L_0022CD:
	dc.b    'ddddddd'                             ; 000022CD

L_0022D4:
	dc.b    $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F   ; 000022D4

L_0022DD:
	dc.b    $7F,$7F,$7F,$7F,$7F,$7F,$7F           ; 000022DD

L_0022E4:
	dc.b    $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02; 000022E4

L_0022F4:
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 000022F4

L_002304:
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 00002304
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 00002314

L_002324:
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 00002324

L_002334:
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 00002334

L_002344:
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00   ; 00002344

L_00234D:
	dc.b    $00,$00,$00,$00,$00,$00,$00           ; 0000234D

L_002354:
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00       ; 00002354

L_00235C:
	dc.b    $00                                   ; 0000235C

L_00235D:
	dc.b    $01,$02,$03,$04,$05,$06,$07,$FF       ; 0000235D

L_002365:
	dc.b    $00                                   ; 00002365

L_002366:
	dc.b    $01,$02,$03,$04,$05,$06,$07,$FF       ; 00002366

L_00236E:
	dc.b    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; 0000236E

L_00237E:
	dc.b    $00,$00                               ; 0000237E

L_002380:
	movem.l D1-D2/A1,-(A7)                        ; 00002380 48E7 6040
	movea.l A0,A1                                 ; 00002384 2248
	move.l  D0,D2                                 ; 00002386 2400
	addq.l  #1,D2                                 ; 00002388 5282
	moveq   #$0,D1                                ; 0000238A 7200
	move.w  #$304,D0                              ; 0000238C 303C 0304
	trap    #$2                                   ; 00002390 4E42
	movem.l (A7)+,D1-D2/A1                        ; 00002392 4CDF 0206
	rts                                           ; 00002396 4E75

L_002398:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00002398 48E7 7FFE
	move.l  D0,D4                                 ; 0000239C 2800
	move.l  ($18,A0),D5                           ; 0000239E 2A28 0018
	beq.s   L_0023A6                              ; 000023A2 6702
	add.l   A0,D5                                 ; 000023A4 DA88

L_0023A6:
	adda.l  ($10,A0),A0                           ; 000023A6 D1E8 0010
	lea     L_005E88(pc),A6                       ; 000023AA 4DFA 3ADC
	moveq   #$0,D6                                ; 000023AE 7C00
	movea.l A0,A4                                 ; 000023B0 2848
	movea.l A0,A3                                 ; 000023B2 2648
	move.w  (A3)+,D7                              ; 000023B4 3E1B
	beq.w   L_0024A8                              ; 000023B6 6700 00F0
	add.w   D7,(-$6e,A6)                          ; 000023BA DF6E FF92
	subq.w  #1,D7                                 ; 000023BE 5347

L_0023C0:
	move.w  ($4,A3),D0                            ; 000023C0 302B 0004
	andi.w  #$7f00,D0                             ; 000023C4 0240 7F00
	lea     (A6,D0.w),A5                          ; 000023C8 4BF6 0000
	movea.l A5,A0                                 ; 000023CC 204D
	moveq   #$0,D0                                ; 000023CE 7000
	moveq   #$3f,D1                               ; 000023D0 723F

L_0023D2:
	move.l  D0,(A0)+                              ; 000023D2 20C0
	dbra    D1,L_0023D2                           ; 000023D4 51C9 FFFC
	move.l  (A3)+,D0                              ; 000023D8 201B
	add.l   A4,D0                                 ; 000023DA D08C
	move.l  D0,($1c,A5)                           ; 000023DC 2B40 001C
	move.b  (A3),($ff,A5)                         ; 000023E0 1B53 00FF
	move.w  D6,($44,A5)                           ; 000023E4 3B46 0044
	move.w  (A3),D6                               ; 000023E8 3C13
	move.b  #$1,D6                                ; 000023EA 1C3C 0001
	move.b  ($1,A3),D0                            ; 000023EE 102B 0001
	move.b  D0,($3,A5)                            ; 000023F2 1B40 0003
	subq.b  #7,D0                                 ; 000023F6 5F00
	bne.s   L_002402                              ; 000023F8 6608
	moveq   #$0,D2                                ; 000023FA 7400
	moveq   #$f,D1                                ; 000023FC 720F
	bsr.w   L_002BC0                              ; 000023FE 6100 07C0

L_002402:
	move.w  ($8,A3),D0                            ; 00002402 302B 0008
	andi.w  #$7f00,D0                             ; 00002406 0240 7F00
	addq.w  #1,D0                                 ; 0000240A 5240
	tst.w   D7                                    ; 0000240C 4A47
	bne.s   L_002412                              ; 0000240E 6602
	moveq   #$0,D0                                ; 00002410 7000

L_002412:
	move.w  D0,($16,A5)                           ; 00002412 3B40 0016
	move.w  #$1,($a,A5)                           ; 00002416 3B7C 0001 000A
	move.l  D5,($40,A5)                           ; 0000241C 2B45 0040
	move.w  D4,($7a,A5)                           ; 00002420 3B44 007A
	move.b  #$c0,($70,A5)                         ; 00002424 1B7C 00C0 0070
	move.b  #$40,($23,A5)                         ; 0000242A 1B7C 0040 0023
	move.b  #$8,($65,A5)                          ; 00002430 1B7C 0008 0065
	move.b  #$6a,($7,A5)                          ; 00002436 1B7C 006A 0007
	move.b  #$6a,($22,A5)                         ; 0000243C 1B7C 006A 0022
	move.b  #$88,($68,A5)                         ; 00002442 1B7C 0088 0068
	move.b  #$88,($67,A5)                         ; 00002448 1B7C 0088 0067
	moveq   #$7f,D0                               ; 0000244E 707F
	move.b  D0,($2b,A5)                           ; 00002450 1B40 002B
	move.b  D0,($6d,A5)                           ; 00002454 1B40 006D
	move.b  D0,($6c,A5)                           ; 00002458 1B40 006C
	move.b  D0,($6b,A5)                           ; 0000245C 1B40 006B
	move.b  #$80,($f5,A5)                         ; 00002460 1B7C 0080 00F5
	move.b  #$c,($2d,A5)                          ; 00002466 1B7C 000C 002D
	move.w  #$fff0,($46,A5)                       ; 0000246C 3B7C FFF0 0046
	move.w  #$202,($b6,A5)                        ; 00002472 3B7C 0202 00B6
	move.w  #$403,($4c,A5)                        ; 00002478 3B7C 0403 004C
	lea     L_0011E8(pc),A1                       ; 0000247E 43FA ED68
	move.l  A1,($80,A5)                           ; 00002482 2B49 0080
	lea     L_0011F4(pc),A1                       ; 00002486 43FA ED6C
	move.l  A1,($9a,A5)                           ; 0000248A 2B49 009A
	bsr.w   L_000E2C                              ; 0000248E 6100 E99C
	bsr.s   L_0024F6                              ; 00002492 6162
	clr.w   (A5)                                  ; 00002494 4255
	addq.l  #4,A3                                 ; 00002496 588B
	dbra    D7,L_0023C0                           ; 00002498 51CF FF26
	move.w  ($6,A4),D0                            ; 0000249C 302C 0006
	andi.w  #$7f00,D0                             ; 000024A0 0240 7F00
	addq.w  #1,D0                                 ; 000024A4 5240
	bra.s   L_0024AA                              ; 000024A6 6002

L_0024A8:
	moveq   #-$1,D0                               ; 000024A8 70FF

L_0024AA:
	movem.l (A7)+,D1-D7/A0-A6                     ; 000024AA 4CDF 7FFE
	rts                                           ; 000024AE 4E75

L_0024B0:
	movem.l D0-D2/A0,-(A7)                        ; 000024B0 48E7 E080
	lea     L_0012D6(pc),A0                       ; 000024B4 41FA EE20
	move.w  ($2,A5),D0                            ; 000024B8 302D 0002
	bmi.s   L_0024CC                              ; 000024BC 6B0E
	andi.w  #$f0,D0                               ; 000024BE 0240 00F0
	lsr.w   #3,D0                                 ; 000024C2 E648
	move.w  L_0024D6(pc,D0.w),D0                  ; 000024C4 303B 0010
	lea     L_0024D6(pc,D0.w),A0                  ; 000024C8 41FB 000C

L_0024CC:
	move.l  A0,($c,A5)                            ; 000024CC 2B48 000C
	movem.l (A7)+,D0-D2/A0                        ; 000024D0 4CDF 0107
	rts                                           ; 000024D4 4E75

L_0024D6:
	dc.w    L_001492-L_0024D6                     ; 000024D6
	dc.w    L_001438-L_0024D6                     ; 000024D8
	dc.w    L_0012D6-L_0024D6                     ; 000024DA
	dc.w    L_0012D6-L_0024D6                     ; 000024DC
	dc.w    L_0012D6-L_0024D6                     ; 000024DE
	dc.w    L_0012D6-L_0024D6                     ; 000024E0
	dc.w    L_0012D6-L_0024D6                     ; 000024E2
	dc.w    L_0012D6-L_0024D6                     ; 000024E4
	dc.w    L_0012E2-L_0024D6                     ; 000024E6
	dc.w    L_0012E2-L_0024D6                     ; 000024E8
	dc.w    L_0012E2-L_0024D6                     ; 000024EA
	dc.w    L_0012D6-L_0024D6                     ; 000024EC
	dc.w    L_0012D6-L_0024D6                     ; 000024EE
	dc.w    L_0012D6-L_0024D6                     ; 000024F0
	dc.w    L_0012D6-L_0024D6                     ; 000024F2
	dc.w    L_0012D6-L_0024D6                     ; 000024F4

L_0024F6:
	movem.l D0-D2/A0-A1/A5,-(A7)                  ; 000024F6 48E7 E0C4
	moveq   #$0,D0                                ; 000024FA 7000
	move.b  ($3,A5),D0                            ; 000024FC 102D 0003
	add.w   D0,D0                                 ; 00002500 D040
	lea     (-$1200,A6),A0                        ; 00002502 41EE EE00
	adda.l  D0,A0                                 ; 00002506 D1C0
	movea.l A0,A1                                 ; 00002508 2248
	moveq   #$0,D1                                ; 0000250A 7200
	move.w  ($7a,A5),D2                           ; 0000250C 342D 007A
	move.w  (A0),D0                               ; 00002510 3010
	beq.s   L_00252A                              ; 00002512 6716

L_002514:
	lea     (-$1,A6,D0.w),A0                      ; 00002514 41F6 00FF
	move.w  D0,D1                                 ; 00002518 3200
	swap    D1                                    ; 0000251A 4841
	cmp.w   ($7a,A0),D2                           ; 0000251C B468 007A
	bcc.s   L_00252A                              ; 00002520 6408
	move.w  ($48,A0),D0                           ; 00002522 3028 0048
	bne.s   L_002514                              ; 00002526 66EC
	swap    D1                                    ; 00002528 4841

L_00252A:
	moveq   #$0,D0                                ; 0000252A 7000
	move.b  ($ff,A5),D0                           ; 0000252C 102D 00FF
	lsl.w   #8,D0                                 ; 00002530 E148
	addq.w  #1,D0                                 ; 00002532 5240
	tst.w   D1                                    ; 00002534 4A41
	bne.s   L_002560                              ; 00002536 6628
	move.l  #$80008000,($12,A5)                   ; 00002538 2B7C 8000 8000 0012
	move.w  (A1),($48,A5)                         ; 00002540 3B51 0048
	move.w  D0,(A1)                               ; 00002544 3280
	move.w  ($7a,A5),D1                           ; 00002546 322D 007A

L_00254A:
	move.w  ($48,A5),D0                           ; 0000254A 302D 0048
	beq.s   L_002572                              ; 0000254E 6722
	lea     (-$1,A6,D0.w),A5                      ; 00002550 4BF6 00FF
	cmp.w   ($7a,A5),D1                           ; 00002554 B26D 007A
	beq.s   L_002572                              ; 00002558 6718
	bsr.w   L_002606                              ; 0000255A 6100 00AA
	bra.s   L_00254A                              ; 0000255E 60EA

L_002560:
	move.w  ($47,A6,D1.w),($48,A5)                ; 00002560 3B76 1047 0048
	move.w  D0,($47,A6,D1.w)                      ; 00002566 3D80 1047
	bsr.w   L_002606                              ; 0000256A 6100 009A
	bra.s   L_002572                              ; 0000256E 6002
	dc.b    $70,$FF                               ; 00002570

L_002572:
	movem.l (A7)+,D0-D2/A0-A1/A5                  ; 00002572 4CDF 2307
	bsr.w   L_0024B0                              ; 00002576 6100 FF38
	rts                                           ; 0000257A 4E75

L_00257C:
	movem.l D0-D1/A0-A1/A5,-(A7)                  ; 0000257C 48E7 C0C4
	moveq   #$0,D0                                ; 00002580 7000
	move.b  ($3,A5),D0                            ; 00002582 102D 0003
	tst.b   ($fe,A5)                              ; 00002586 4A2D 00FE
	bpl.s   L_00259A                              ; 0000258A 6A0E
	cmpi.b  #$8,D0                                ; 0000258C 0C00 0008
	bcc.s   L_00259A                              ; 00002590 6408
	exg     D0,D6                                 ; 00002592 C146
	bsr.w   L_001A24                              ; 00002594 6100 F48E
	exg     D0,D6                                 ; 00002598 C146

L_00259A:
	add.w   D0,D0                                 ; 0000259A D040
	lea     (-$1200,A6),A0                        ; 0000259C 41EE EE00
	adda.l  D0,A0                                 ; 000025A0 D1C0
	movea.l A0,A1                                 ; 000025A2 2248
	moveq   #$0,D1                                ; 000025A4 7200
	move.w  (A0),D0                               ; 000025A6 3010
	beq.s   L_0025FC                              ; 000025A8 6752

L_0025AA:
	lea     (-$1,A6,D0.w),A0                      ; 000025AA 41F6 00FF
	move.w  D0,D1                                 ; 000025AE 3200
	swap    D1                                    ; 000025B0 4841
	cmpa.l  A0,A5                                 ; 000025B2 BBC8
	beq.s   L_0025BE                              ; 000025B4 6708
	move.w  ($48,A0),D0                           ; 000025B6 3028 0048
	bne.s   L_0025AA                              ; 000025BA 66EE
	bra.s   L_0025FC                              ; 000025BC 603E

L_0025BE:
	tst.w   D1                                    ; 000025BE 4A41
	bne.s   L_0025F4                              ; 000025C0 6632
	move.w  ($48,A5),(A1)                         ; 000025C2 32AD 0048
	moveq   #$0,D1                                ; 000025C6 7200
	move.w  ($7a,A5),D1                           ; 000025C8 322D 007A
	move.w  ($48,A5),D0                           ; 000025CC 302D 0048
	beq.s   L_0025FE                              ; 000025D0 672C
	lea     (-$1,A6,D0.w),A5                      ; 000025D2 4BF6 00FF
	cmp.w   ($7a,A5),D1                           ; 000025D6 B26D 007A
	beq.s   L_0025FE                              ; 000025DA 6722
	move.w  ($7a,A5),D1                           ; 000025DC 322D 007A

L_0025E0:
	bsr.s   L_002630                              ; 000025E0 614E
	move.w  ($48,A5),D0                           ; 000025E2 302D 0048
	beq.s   L_0025FE                              ; 000025E6 6716
	lea     (-$1,A6,D0.w),A5                      ; 000025E8 4BF6 00FF
	cmp.w   ($7a,A5),D1                           ; 000025EC B26D 007A
	beq.s   L_0025E0                              ; 000025F0 67EE
	bra.s   L_0025FE                              ; 000025F2 600A

L_0025F4:
	move.w  ($48,A5),($47,A6,D1.w)                ; 000025F4 3DAD 0048 1047
	bra.s   L_0025FE                              ; 000025FA 6002

L_0025FC:
	moveq   #-$1,D0                               ; 000025FC 70FF

L_0025FE:
	bsr.s   L_00265C                              ; 000025FE 615C
	movem.l (A7)+,D0-D1/A0-A1/A5                  ; 00002600 4CDF 2303
	rts                                           ; 00002604 4E75

L_002606:
	movem.l D0-D6/A0-A4,-(A7)                     ; 00002606 48E7 FEF8
	move.w  ($2,A5),D6                            ; 0000260A 3C2D 0002
	bmi.s   L_00261C                              ; 0000260E 6B0C
	cmpi.b  #$8,D6                                ; 00002610 0C06 0008
	bcc.s   L_00261A                              ; 00002614 6404
	bsr.w   L_001A24                              ; 00002616 6100 F40C

L_00261A:
	bsr.s   L_00265C                              ; 0000261A 6140

L_00261C:
	ori.b   #$90,($2,A5)                          ; 0000261C 002D 0090 0002
	lea     L_0012D6(pc),A0                       ; 00002622 41FA ECB2
	move.l  A0,($c,A5)                            ; 00002626 2B48 000C
	movem.l (A7)+,D0-D6/A0-A4                     ; 0000262A 4CDF 1F7F
	rts                                           ; 0000262E 4E75

L_002630:
	movem.l D0-D7/A0-A4,-(A7)                     ; 00002630 48E7 FFF8
	move    SR,D7                                 ; 00002634 40C7
	ori     #$700,SR                              ; 00002636 007C 0700
	andi.b  #$0,($2,A5)                           ; 0000263A 022D 0000 0002
	move.w  #$ffff,($10,A5)                       ; 00002640 3B7C FFFF 0010
	st      ($14,A5)                              ; 00002646 50ED 0014
	move.w  #$8000,($12,A5)                       ; 0000264A 3B7C 8000 0012
	bsr.w   L_0024B0                              ; 00002650 6100 FE5E
	move    D7,SR                                 ; 00002654 46C7
	movem.l (A7)+,D0-D7/A0-A4                     ; 00002656 4CDF 1FFF
	rts                                           ; 0000265A 4E75

L_00265C:
	movem.l D0-D6/A0-A4,-(A7)                     ; 0000265C 48E7 FEF8
	lea     (-$ff0,A6),A3                         ; 00002660 47EE F010
	move.w  ($46,A5),D0                           ; 00002664 302D 0046
	bmi.s   L_002688                              ; 00002668 6B1E

L_00266A:
	lea     ($2,A3,D0.w),A1                       ; 0000266A 43F3 0002
	moveq   #$7c,D0                               ; 0000266E 707C
	and.w   ($8,A1),D0                            ; 00002670 C069 0008
	lea     L_000FF4(pc),A0                       ; 00002674 41FA E97E
	jsr     (A0,D0.w)                             ; 00002678 4EB0 0000
	ori.b   #$80,($b,A1)                          ; 0000267C 0029 0080 000B
	move.w  ($4,A1),D0                            ; 00002682 3029 0004
	bpl.s   L_00266A                              ; 00002686 6AE2

L_002688:
	movem.l (A7)+,D0-D6/A0-A4                     ; 00002688 4CDF 1F7F
	rts                                           ; 0000268C 4E75

L_00268E:
	movem.l D1/A0/A6,-(A7)                        ; 0000268E 48E7 4082
	lea     L_005E88(pc),A6                       ; 00002692 4DFA 37F4
	move.l  (-$32e,A6),D1                         ; 00002696 222E FCD2
	beq.s   L_0026B0                              ; 0000269A 6714

L_00269C:
	movea.l D1,A0                                 ; 0000269C 2041
	cmp.b   ($d,A0),D0                            ; 0000269E B028 000D
	beq.s   L_0026AC                              ; 000026A2 6708
	move.l  ($4,A0),D1                            ; 000026A4 2228 0004
	beq.s   L_0026B0                              ; 000026A8 6706
	bra.s   L_00269C                              ; 000026AA 60F0

L_0026AC:
	move.l  A0,D0                                 ; 000026AC 2008
	bra.s   L_0026B2                              ; 000026AE 6002

L_0026B0:
	moveq   #-$1,D0                               ; 000026B0 70FF

L_0026B2:
	movem.l (A7)+,D1/A0/A6                        ; 000026B2 4CDF 4102
	rts                                           ; 000026B6 4E75

L_0026B8:
	movem.l D1-D7/A0-A6,-(A7)                     ; 000026B8 48E7 7FFE
	lea     L_005E88(pc),A6                       ; 000026BC 4DFA 37CA
	clr.l   (-$1c6,A6)                            ; 000026C0 42AE FE3A
	move.l  (-$372,A6),D0                         ; 000026C4 202E FC8E
	beq.s   L_0026D8                              ; 000026C8 670E
	clr.l   (-$372,A6)                            ; 000026CA 42AE FC8E
	move.l  D1,-(A7)                              ; 000026CE 2F01
	move.l  D0,D1                                 ; 000026D0 2200
	bsr.w   L_003FA0                              ; 000026D2 6100 18CC
	move.l  (A7)+,D1                              ; 000026D6 221F

L_0026D8:
	tst.l   D1                                    ; 000026D8 4A81
	bne.s   L_0026E0                              ; 000026DA 6604
	movea.l A0,A1                                 ; 000026DC 2248
	bra.s   L_0026FC                              ; 000026DE 601C

L_0026E0:
	bsr.w   L_003E68                              ; 000026E0 6100 1786
	bmi.s   L_00270C                              ; 000026E4 6B26
	move.l  D0,(-$372,A6)                         ; 000026E6 2D40 FC8E
	movea.l D0,A1                                 ; 000026EA 2240
	ori.b   #$1,(-$3,A1)                          ; 000026EC 0029 0001 FFFD
	move.l  A0,D0                                 ; 000026F2 2008
	beq.s   L_0026FC                              ; 000026F4 6706
	move.l  D1,D0                                 ; 000026F6 2001
	bsr.w   L_0002F2                              ; 000026F8 6100 DBF8

L_0026FC:
	move.l  A1,(-$382,A6)                         ; 000026FC 2D49 FC7E
	move.l  D1,(-$37e,A6)                         ; 00002700 2D41 FC82
	move.l  A1,D0                                 ; 00002704 2009
	sne     (-$13e,A6)                            ; 00002706 56EE FEC2
	bra.s   L_002712                              ; 0000270A 6006

L_00270C:
	moveq   #-$1,D0                               ; 0000270C 70FF
	clr.b   (-$13e,A6)                            ; 0000270E 422E FEC2

L_002712:
	movem.l (A7)+,D1-D7/A0-A6                     ; 00002712 4CDF 7FFE
	rts                                           ; 00002716 4E75

L_002718:
	movem.l D1-D7/A0-A6,-(A7)                     ; 00002718 48E7 7FFE
	lea     L_005E88(pc),A6                       ; 0000271C 4DFA 376A
	clr.l   (-$1c6,A6)                            ; 00002720 42AE FE3A
	move.l  (-$36e,A6),D0                         ; 00002724 202E FC92
	beq.s   L_002738                              ; 00002728 670E
	clr.l   (-$36e,A6)                            ; 0000272A 42AE FC92
	move.l  D1,-(A7)                              ; 0000272E 2F01
	move.l  D0,D1                                 ; 00002730 2200
	bsr.w   L_003FA0                              ; 00002732 6100 186C
	move.l  (A7)+,D1                              ; 00002736 221F

L_002738:
	sf      (-$129,A6)                            ; 00002738 51EE FED7
	cmpi.l  #$105a6d41,(A0)                       ; 0000273C 0C90 105A 6D41
	bne.w   L_0027DE                              ; 00002742 6600 009A
	cmpi.l  #$6470436d,($4,A0)                    ; 00002746 0CA8 6470 436D 0004
	bne.w   L_0027DE                              ; 0000274E 6600 008E
	move.b  #$1,(-$129,A6)                        ; 00002752 1D7C 0001 FED7
	movea.l A0,A2                                 ; 00002758 2448
	moveq   #$0,D6                                ; 0000275A 7C00
	moveq   #$0,D7                                ; 0000275C 7E00
	bra.s   L_00276A                              ; 0000275E 600A

L_002760:
	move.w  (A2)+,D6                              ; 00002760 3C1A
	bmi.s   L_00276E                              ; 00002762 6B0A
	cmp.w   D6,D7                                 ; 00002764 BE46
	bcc.s   L_00276A                              ; 00002766 6402
	move.w  D6,D7                                 ; 00002768 3E06

L_00276A:
	addq.l  #8,A2                                 ; 0000276A 508A
	bra.s   L_002760                              ; 0000276C 60F2

L_00276E:
	and.w   #$ff80,D7                             ; 0000276E CE7C FF80
	add.w   #$80,D7                               ; 00002772 DE7C 0080
	lsl.l   #3,D7                                 ; 00002776 E78F
	move.l  A0,D4                                 ; 00002778 2808
	sub.l   A2,D4                                 ; 0000277A 988A
	movea.l A2,A3                                 ; 0000277C 264A
	add.l   D4,D1                                 ; 0000277E D284
	move.l  D1,D2                                 ; 00002780 2401
	add.l   D7,D1                                 ; 00002782 D287
	bsr.w   L_003F28                              ; 00002784 6100 17A2
	bmi.w   L_002816                              ; 00002788 6B00 008C
	add.l   D7,D4                                 ; 0000278C D887
	move.l  D0,(-$36e,A6)                         ; 0000278E 2D40 FC92
	movea.l D0,A1                                 ; 00002792 2240
	movea.l A1,A2                                 ; 00002794 2449
	move.w  D7,D5                                 ; 00002796 3A07
	moveq   #$0,D6                                ; 00002798 7C00
	lsr.w   #3,D5                                 ; 0000279A E64D
	subq.w  #1,D5                                 ; 0000279C 5345

L_00279E:
	move.l  D6,(A1)+                              ; 0000279E 22C6
	move.l  D6,(A1)+                              ; 000027A0 22C6
	dbra    D5,L_00279E                           ; 000027A2 51CD FFFA
	exg     A0,A3                                 ; 000027A6 C14B
	move.l  D2,D0                                 ; 000027A8 2002
	bsr.w   L_0002F2                              ; 000027AA 6100 DB46
	exg     A0,A3                                 ; 000027AE C14B
	movea.l A0,A3                                 ; 000027B0 2648
	subq.l  #4,D4                                 ; 000027B2 5984
	addq.l  #8,A0                                 ; 000027B4 5088

L_0027B6:
	move.w  (A0)+,D2                              ; 000027B6 3418
	bmi.s   L_0027D0                              ; 000027B8 6B16
	lsl.w   #3,D2                                 ; 000027BA E74A
	move.l  (A0)+,D3                              ; 000027BC 2618
	move.l  (A0)+,D0                              ; 000027BE 2018
	add.l   D4,D3                                 ; 000027C0 D684
	add.l   A0,D3                                 ; 000027C2 D688
	sub.l   A3,D3                                 ; 000027C4 968B
	move.l  D3,(A2,D2.w)                          ; 000027C6 2583 2000
	move.l  D0,($4,A2,D2.w)                       ; 000027CA 2580 2004
	bra.s   L_0027B6                              ; 000027CE 60E6

L_0027D0:
	move.l  A2,(-$37a,A6)                         ; 000027D0 2D4A FC86
	move.l  D1,(-$376,A6)                         ; 000027D4 2D41 FC8A
	st      (-$13d,A6)                            ; 000027D8 50EE FEC3
	bra.s   L_00281C                              ; 000027DC 603E

L_0027DE:
	tst.l   D1                                    ; 000027DE 4A81
	bne.s   L_0027EA                              ; 000027E0 6608
	clr.b   (-$24a,A6)                            ; 000027E2 422E FDB6
	movea.l A0,A1                                 ; 000027E6 2248
	bra.s   L_002806                              ; 000027E8 601C

L_0027EA:
	bsr.w   L_003F28                              ; 000027EA 6100 173C
	bmi.s   L_002816                              ; 000027EE 6B26
	move.l  D0,(-$36e,A6)                         ; 000027F0 2D40 FC92
	movea.l D0,A1                                 ; 000027F4 2240
	ori.b   #$2,(-$3,A1)                          ; 000027F6 0029 0002 FFFD
	move.l  A0,D0                                 ; 000027FC 2008
	beq.s   L_002806                              ; 000027FE 6706
	move.l  D1,D0                                 ; 00002800 2001
	bsr.w   L_0002F2                              ; 00002802 6100 DAEE

L_002806:
	move.l  A1,(-$37a,A6)                         ; 00002806 2D49 FC86
	move.l  D1,(-$376,A6)                         ; 0000280A 2D41 FC8A
	move.l  A1,D0                                 ; 0000280E 2009
	sne     (-$13d,A6)                            ; 00002810 56EE FEC3
	bra.s   L_00281C                              ; 00002814 6006

L_002816:
	moveq   #-$1,D0                               ; 00002816 70FF
	clr.b   (-$13d,A6)                            ; 00002818 422E FEC3

L_00281C:
	movem.l (A7)+,D1-D7/A0-A6                     ; 0000281C 4CDF 7FFE
	rts                                           ; 00002820 4E75

L_002822:
	movem.l D1/A0,-(A7)                           ; 00002822 48E7 4080
	bsr.w   L_0006C8                              ; 00002826 6100 DEA0
	suba.l  A0,A0                                 ; 0000282A 91C8
	moveq   #$0,D1                                ; 0000282C 7200
	bsr.w   L_0026B8                              ; 0000282E 6100 FE88
	bsr.w   L_002718                              ; 00002832 6100 FEE4
	movem.l (A7)+,D1/A0                           ; 00002836 4CDF 0102
	rts                                           ; 0000283A 4E75

L_00283C:
	move.b  D0,(-$12a,A6)                         ; 0000283C 1D40 FED6
	add.w   D0,D0                                 ; 00002840 D040
	move.w  L_002854(pc,D0.w),D0                  ; 00002842 303B 0010
	jmp     L_002854(pc,D0.w)                     ; 00002846 4EFB 000C

L_00284A:
	move.w  (-$66,A6),(-$3b6,A6)                  ; 0000284A 3D6E FF9A FC4A
	bra.w   L_002AB2                              ; 00002850 6000 0260

L_002854:
	dc.w    L_00284A-L_002854                     ; 00002854
	dc.w    L_00284A-L_002854                     ; 00002856
	dc.w    L_00284A-L_002854                     ; 00002858
	dc.w    L_00284A-L_002854                     ; 0000285A
	dc.w    L_0028C8-L_002854                     ; 0000285C
	dc.w    L_0028A4-L_002854                     ; 0000285E
	dc.w    L_0028B6-L_002854                     ; 00002860
	dc.w    L_0028A4-L_002854                     ; 00002862
	dc.w    L_00294C-L_002854                     ; 00002864
	dc.w    L_002874-L_002854                     ; 00002866
	dc.w    L_002882-L_002854                     ; 00002868
	dc.w    L_00284A-L_002854                     ; 0000286A
	dc.w    L_00284A-L_002854                     ; 0000286C
	dc.w    L_00284A-L_002854                     ; 0000286E
	dc.w    L_00284A-L_002854                     ; 00002870
	dc.w    L_00284A-L_002854                     ; 00002872

L_002874:
	st      (-$12a,A6)                            ; 00002874 50EE FED6
	moveq   #$1,D0                                ; 00002878 7001
	move.l  D0,(-$33c,A6)                         ; 0000287A 2D40 FCC4
	bra.w   L_002AB2                              ; 0000287E 6000 0232

L_002882:
	st      (-$12a,A6)                            ; 00002882 50EE FED6
	tst.l   (-$33c,A6)                            ; 00002886 4AAE FCC4
	bne.w   L_002AB2                              ; 0000288A 6600 0226
	tst.w   (-$3b8,A6)                            ; 0000288E 4A6E FC48
	bne.w   L_002AB2                              ; 00002892 6600 021E
	moveq   #$0,D0                                ; 00002896 7000
	move.w  (-$68,A6),D0                          ; 00002898 302E FF98
	move.l  D0,(-$33c,A6)                         ; 0000289C 2D40 FCC4
	bra.w   L_002AB2                              ; 000028A0 6000 0210

L_0028A4:
	st      (-$12a,A6)                            ; 000028A4 50EE FED6
	move.w  (-$66,A6),D0                          ; 000028A8 302E FF9A
	lsr.w   #1,D0                                 ; 000028AC E248
	move.w  D0,(-$3b6,A6)                         ; 000028AE 3D40 FC4A
	bra.w   L_002AB2                              ; 000028B2 6000 01FE

L_0028B6:
	st      (-$12a,A6)                            ; 000028B6 50EE FED6
	move.w  (-$66,A6),D0                          ; 000028BA 302E FF9A
	lsr.w   #2,D0                                 ; 000028BE E448
	move.w  D0,(-$3b6,A6)                         ; 000028C0 3D40 FC4A
	bra.w   L_002AB2                              ; 000028C4 6000 01EC

L_0028C8:
	btst    #$5,(-$12c,A6)                        ; 000028C8 082E 0005 FED4
	bne.s   L_0028F2                              ; 000028CE 6622
	btst    #$6,(-$12c,A6)                        ; 000028D0 082E 0006 FED4
	bne.s   L_0028FC                              ; 000028D6 6624
	tst.b   (-$12c,A6)                            ; 000028D8 4A2E FED4
	bmi.s   L_002942                              ; 000028DC 6B64
	btst    #$1,(-$12b,A6)                        ; 000028DE 082E 0001 FED5
	beq.s   L_002904                              ; 000028E4 671E
	bsr.w   L_0006C8                              ; 000028E6 6100 DDE0
	bsr.w   L_000992                              ; 000028EA 6100 E0A6
	bra.w   L_002AB2                              ; 000028EE 6000 01C2

L_0028F2:
	move.l  (-$60,A6),(-$340,A6)                  ; 000028F2 2D6E FFA0 FCC0
	bra.w   L_002AB2                              ; 000028F8 6000 01B8

L_0028FC:
	clr.l   (-$340,A6)                            ; 000028FC 42AE FCC0
	bra.w   L_002AB2                              ; 00002900 6000 01B0

L_002904:
	btst    #$0,(-$12b,A6)                        ; 00002904 082E 0000 FED5
	beq.w   L_00284A                              ; 0000290A 6700 FF3E
	move.b  (-$12a,A6),D2                         ; 0000290E 142E FED6
	st      (-$12a,A6)                            ; 00002912 50EE FED6
	tst.l   (-$33c,A6)                            ; 00002916 4AAE FCC4
	bne.w   L_00284A                              ; 0000291A 6600 FF2E
	move.l  (-$60,A6),D1                          ; 0000291E 222E FFA0
	sub.l   (-$336,A6),D1                         ; 00002922 92AE FCCA
	moveq   #$0,D0                                ; 00002926 7000
	move.w  (-$68,A6),D0                          ; 00002928 302E FF98
	lsl.l   #3,D0                                 ; 0000292C E788
	sub.l   D0,D1                                 ; 0000292E 9280
	bcc.s   L_002938                              ; 00002930 6406
	move.b  D2,(-$12a,A6)                         ; 00002932 1D42 FED6
	moveq   #$0,D1                                ; 00002936 7200

L_002938:
	move.l  D1,D0                                 ; 00002938 2001
	bsr.w   L_00062C                              ; 0000293A 6100 DCF0
	bra.w   L_002AB2                              ; 0000293E 6000 0172

L_002942:
	moveq   #$8,D1                                ; 00002942 7208
	bsr.w   L_00077A                              ; 00002944 6100 DE34
	bra.w   L_002AB2                              ; 00002948 6000 0168

L_00294C:
	tst.b   (-$12c,A6)                            ; 0000294C 4A2E FED4
	bmi.s   L_002964                              ; 00002950 6B12
	btst    #$1,(-$12b,A6)                        ; 00002952 082E 0001 FED5
	beq.w   L_00284A                              ; 00002958 6700 FEF0
	bsr.w   L_00065E                              ; 0000295C 6100 DD00
	bra.w   L_002AB2                              ; 00002960 6000 0150

L_002964:
	tst.b   (-$3b7,A6)                            ; 00002964 4A2E FC49
	beq.s   L_00297A                              ; 00002968 6710
	bsr.w   L_000992                              ; 0000296A 6100 E026
	tst.w   D0                                    ; 0000296E 4A40
	bmi.w   L_002AB2                              ; 00002970 6B00 0140
	clr.w   (-$354,A6)                            ; 00002974 426E FCAC
	bra.s   L_002984                              ; 00002978 600A

L_00297A:
	tst.b   (-$3b8,A6)                            ; 0000297A 4A2E FC48
	beq.s   L_002984                              ; 0000297E 6704
	bsr.w   L_00065E                              ; 00002980 6100 DCDC

L_002984:
	moveq   #-$8,D1                               ; 00002984 72F8
	bsr.w   L_00077A                              ; 00002986 6100 DDF2
	bra.w   L_002AB2                              ; 0000298A 6000 0126

L_00298E:
	tst.w   (-$390,A6)                            ; 0000298E 4A6E FC70
	beq.s   L_0029D4                              ; 00002992 6740
	move.w  D7,-(A7)                              ; 00002994 3F07
	move.l  (-$33c,A6),-(A7)                      ; 00002996 2F2E FCC4
	clr.l   (-$33c,A6)                            ; 0000299A 42AE FCC4
	move.l  (-$ffe,A6),-(A7)                      ; 0000299E 2F2E F002
	move.l  (-$38e,A6),(-$ffe,A6)                 ; 000029A2 2D6E FC72 F002
	move.w  (-$392,A6),-(A7)                      ; 000029A8 3F2E FC6E
	move.w  (-$390,A6),(-$392,A6)                 ; 000029AC 3D6E FC70 FC6E
	moveq   #$0,D6                                ; 000029B2 7C00
	moveq   #$1,D7                                ; 000029B4 7E01
	bsr.w   L_00118E                              ; 000029B6 6100 E7D6
	move.w  (-$392,A6),(-$390,A6)                 ; 000029BA 3D6E FC6E FC70
	move.w  (A7)+,(-$392,A6)                      ; 000029C0 3D5F FC6E
	move.l  (-$ffe,A6),(-$38e,A6)                 ; 000029C4 2D6E F002 FC72
	move.l  (A7)+,(-$ffe,A6)                      ; 000029CA 2D5F F002
	move.l  (A7)+,(-$33c,A6)                      ; 000029CE 2D5F FCC4
	move.w  (A7)+,D7                              ; 000029D2 3E1F

L_0029D4:
	add.b   D7,D7                                 ; 000029D4 DE07
	bmi.w   L_002A7A                              ; 000029D6 6B00 00A2
	bra.w   L_002B9C                              ; 000029DA 6000 01C0

L_0029DE:
	movem.l D0-D7/A0-A6,-(A7)                     ; 000029DE 48E7 FFFE
	lea     L_005E88(pc),A6                       ; 000029E2 4DFA 34A4
	tst.b   (-$130,A6)                            ; 000029E6 4A2E FED0
	st      (-$130,A6)                            ; 000029EA 50EE FED0
	bne.s   L_002A06                              ; 000029EE 6616
	moveq   #$7,D1                                ; 000029F0 7207
	and.b   ($3c,A7),D1                           ; 000029F2 C22F 003C
	add.w   D1,D1                                 ; 000029F6 D241
	move    SR,D0                                 ; 000029F8 40C0
	or.w    L_002A0C(pc,D1.w),D0                  ; 000029FA 807B 1010
	move    D0,SR                                 ; 000029FE 46C0
	st      (-$132,A6)                            ; 00002A00 50EE FECE
	bra.s   L_002A7A                              ; 00002A04 6074

L_002A06:
	movem.l (A7)+,D0-D7/A0-A6                     ; 00002A06 4CDF 7FFF
	rte                                           ; 00002A0A 4E73

L_002A0C:
	dc.b    $02,$00,$02,$00,$02,$00,$03,$00,$04,$00,$07,$00,$06,$00,$07,$00; 00002A0C

L_002A1C:
	move.w  #$feff,(-$130,A6)                     ; 00002A1C 3D7C FEFF FED0
	movea.l (A7)+,A6                              ; 00002A22 2C5F
	rte                                           ; 00002A24 4E73

	ifd __ATARI__
mcdrv_tick:
	endif
L_002A26:
	move.l  A6,-(A7)                              ; 00002A26 2F0E
	lea     L_005E88(pc),A6                       ; 00002A28 4DFA 345E
	subq.b  #1,(-$130,A6)                         ; 00002A2C 532E FED0
	bcc.s   L_002A1C                              ; 00002A30 64EA
	movem.l D0-D7/A0-A5,-(A7)                     ; 00002A32 48E7 FFFC

L_002A36:
	ifnd __ATARI__
	tst.b   ($e9a001).l                           ; 00002A36 4A39 00E9 A001

L_002A3C:
	tst.b   ($e90003).l                           ; 00002A3C 4A39 00E9 0003
	bmi.s   L_002A3C                              ; 00002A42 6BF8
	move.b  #$14,($e90001).l                      ; 00002A44 13FC 0014 00E9 0001
	endif
	moveq   #$7,D1                                ; 00002A4C 7207
	and.b   ($3c,A7),D1                           ; 00002A4E C22F 003C
	move.b  D1,(-$12e,A6)                         ; 00002A52 1D41 FED2
	add.w   D1,D1                                 ; 00002A56 D241
	move    SR,D0                                 ; 00002A58 40C0
	andi.w  #$f8ff,D0                             ; 00002A5A 0240 F8FF
	or.w    L_002A0C(pc,D1.w),D0                  ; 00002A5E 807B 10AC

L_002A62:
	ifnd __ATARI__
	move.b  ($e90003).l,D7                        ; 00002A62 1E39 00E9 0003
	bmi.s   L_002A62                              ; 00002A68 6BF8
	move.b  (-$127,A6),($e90003).l                ; 00002A6A 13EE FED9 00E9 0003
	else
	moveq   #$14,D1
	move.b  (-$127,A6),D2
	jsr     music_opm_write
	moveq   #$1,D7
	endif
	move    D0,SR                                 ; 00002A72 46C0
	ror.b   #2,D7                                 ; 00002A74 E41F
	bcs.w   L_00298E                              ; 00002A76 6500 FF16

L_002A7A:
	move.w  (-$250,A6),D0                         ; 00002A7A 302E FDB0
	beq.s   L_002A8C                              ; 00002A7E 670C
	subq.w  #1,(-$252,A6)                         ; 00002A80 536E FDAE
	bcc.w   L_002B7C                              ; 00002A84 6400 00F6
	move.w  D0,(-$252,A6)                         ; 00002A88 3D40 FDAE

L_002A8C:
	lea     (-$12d,A6),A0                         ; 00002A8C 41EE FED3
	tst.b   (A0)+                                 ; 00002A90 4A18
	bne.s   L_002AB2                              ; 00002A92 661E
	move.w  ($80a).w,D0                           ; 00002A94 3038 080A
	andi.w  #$e003,D0                             ; 00002A98 0240 E003
	cmp.w   (A0)+,D0                              ; 00002A9C B058
	beq.s   L_002AA6                              ; 00002A9E 6706
	move.w  D0,(-$12c,A6)                         ; 00002AA0 3D40 FED4
	st      (A0)                                  ; 00002AA4 50D0

L_002AA6:
	moveq   #$f,D0                                ; 00002AA6 700F
	and.b   ($80e).w,D0                           ; 00002AA8 C038 080E
	cmp.b   (A0)+,D0                              ; 00002AAC B018
	bne.w   L_00283C                              ; 00002AAE 6600 FD8C

L_002AB2:
	tst.w   (-$3b8,A6)                            ; 00002AB2 4A6E FC48
	beq.s   L_002AF8                              ; 00002AB6 6740
	bpl.w   L_002B7C                              ; 00002AB8 6A00 00C2
	andi.b  #$7f,(-$3b8,A6)                       ; 00002ABC 022E 007F FC48
	beq.s   L_002ADA                              ; 00002AC2 6716
	move.w  #$1,(-$80,A6)                         ; 00002AC4 3D7C 0001 FF80
	clr.w   (-$346,A6)                            ; 00002ACA 426E FCBA
	bsr.w   L_00151A                              ; 00002ACE 6100 EA4A
	moveq   #$4,D0                                ; 00002AD2 7004
	bsr.w   L_00083A                              ; 00002AD4 6100 DD64
	bra.s   L_002B52                              ; 00002AD8 6078

L_002ADA:
	move.w  #$2,(-$80,A6)                         ; 00002ADA 3D7C 0002 FF80
	move.w  (-$348,A6),(-$346,A6)                 ; 00002AE0 3D6E FCB8 FCBA
	tst.w   (-$356,A6)                            ; 00002AE6 4A6E FCAA
	bne.s   L_002AF8                              ; 00002AEA 660C
	tst.w   (-$354,A6)                            ; 00002AEC 4A6E FCAC
	bne.s   L_002AF8                              ; 00002AF0 6606
	move.w  #$80,(-$354,A6)                       ; 00002AF2 3D7C 0080 FCAC

L_002AF8:
	move.w  (-$356,A6),D0                         ; 00002AF8 302E FCAA
	beq.s   L_002B52                              ; 00002AFC 6754
	subq.w  #1,(-$34e,A6)                         ; 00002AFE 536E FCB2
	bne.s   L_002B52                              ; 00002B02 664E
	st      (-$344,A6)                            ; 00002B04 50EE FCBC
	move.w  (-$356,A6),D0                         ; 00002B08 302E FCAA
	bmi.s   L_002B2E                              ; 00002B0C 6B20
	move.w  D0,(-$34e,A6)                         ; 00002B0E 3D40 FCB2
	subq.w  #2,(-$354,A6)                         ; 00002B12 556E FCAC
	bgt.s   L_002B52                              ; 00002B16 6E3A
	clr.w   (-$354,A6)                            ; 00002B18 426E FCAC
	moveq   #$0,D1                                ; 00002B1C 7200
	bsr.w   L_00077A                              ; 00002B1E 6100 DC5A
	bsr.w   L_00065E                              ; 00002B22 6100 DB3A
	moveq   #$5,D0                                ; 00002B26 7005
	bsr.w   L_00083A                              ; 00002B28 6100 DD10
	bra.s   L_002B7C                              ; 00002B2C 604E

L_002B2E:
	neg.w   D0                                    ; 00002B2E 4440
	move.w  D0,(-$34e,A6)                         ; 00002B30 3D40 FCB2
	addq.w  #2,(-$354,A6)                         ; 00002B34 546E FCAC
	cmpi.w  #$80,(-$354,A6)                       ; 00002B38 0C6E 0080 FCAC
	bcs.s   L_002B52                              ; 00002B3E 6512
	moveq   #$0,D1                                ; 00002B40 7200
	bsr.w   L_00077A                              ; 00002B42 6100 DC36
	move.w  #$80,(-$354,A6)                       ; 00002B46 3D7C 0080 FCAC
	moveq   #$6,D0                                ; 00002B4C 7006
	bsr.w   L_00083A                              ; 00002B4E 6100 DCEA

L_002B52:
	move.w  (-$346,A6),D0                         ; 00002B52 302E FCBA
	cmp.w   (-$344,A6),D0                         ; 00002B56 B06E FCBC
	beq.s   L_002B64                              ; 00002B5A 6708
	move.w  D0,(-$344,A6)                         ; 00002B5C 3D40 FCBC
	bsr.w   L_000DF6                              ; 00002B60 6100 E294

L_002B64:
	movea.l (-$364,A6),A0                         ; 00002B64 206E FC9C
	jsr     (A0)                                  ; 00002B68 4E90
	move.w  (-$3b6,A6),D0                         ; 00002B6A 302E FC4A
	cmp.w   (-$3b4,A6),D0                         ; 00002B6E B06E FC4C
	beq.s   L_002B9C                              ; 00002B72 6728
	move.w  D0,(-$3b4,A6)                         ; 00002B74 3D40 FC4C
	bsr.w   L_001B7A                              ; 00002B78 6100 F000

L_002B7C:
	move.w  (-$32a,A6),D1                         ; 00002B7C 322E FCD6
	beq.s   L_002B9C                              ; 00002B80 671A
	lea     (-$328,A6),A0                         ; 00002B82 41EE FCD8
	clr.w   (-$32a,A6)                            ; 00002B86 426E FCD6
	subq.w  #1,D1                                 ; 00002B8A 5341

L_002B8C:
	movea.l (A0)+,A1                              ; 00002B8C 2258
	movem.l D1/A0/A6,-(A7)                        ; 00002B8E 48E7 4082
	jsr     (A1)                                  ; 00002B92 4E91
	movem.l (A7)+,D1/A0/A6                        ; 00002B94 4CDF 4102
	dbra    D1,L_002B8C                           ; 00002B98 51C9 FFF2

L_002B9C:
	addq.b  #1,(-$130,A6)                         ; 00002B9C 522E FED0
	bcc.s   L_002BA8                              ; 00002BA0 6406
	movem.l (A7)+,D0-D7/A0-A6                     ; 00002BA2 4CDF 7FFF
	rte                                           ; 00002BA6 4E73

L_002BA8:
	bra.w   L_002A36                              ; 00002BA8 6000 FE8C

L_002BAC:
	ifnd __ATARI__
	bsr.s   L_002BD2                              ; 00002BAC 6124
	move.b  D0,($e90001).l                        ; 00002BAE 13C0 00E9 0001
	else
	move.b  D0,mcdrv_opm_address
	endif
	rts                                           ; 00002BB4 4E75

L_002BB6:
	ifnd __ATARI__
	bsr.s   L_002BD8                              ; 00002BB6 6120
	move.b  D0,($e90003).l                        ; 00002BB8 13C0 00E9 0003
	else
	movem.l D1-D2,-(A7)
	move.b  mcdrv_opm_address,D1
	move.b  D0,D2
	jsr     music_opm_write
	movem.l (A7)+,D1-D2
	endif
	rts                                           ; 00002BBE 4E75

L_002BC0:
	ifnd __ATARI__
	bsr.s   L_002BD2                              ; 00002BC0 6110
	move.b  D1,($e90001).l                        ; 00002BC2 13C1 00E9 0001
	bsr.s   L_002BD8                              ; 00002BC8 610E
	move.b  D2,($e90003).l                        ; 00002BCA 13C2 00E9 0003
	else
	move.b  D1,mcdrv_opm_address
	jsr     music_opm_write
	endif
	rts                                           ; 00002BD0 4E75

L_002BD2:
	ifnd __ATARI__
	tst.b   ($e9a001).l                           ; 00002BD2 4A39 00E9 A001

L_002BD8:
	tst.b   ($e90003).l                           ; 00002BD8 4A39 00E9 0003
	bmi.s   L_002BD8                              ; 00002BDE 6BF8
	endif
	rts                                           ; 00002BE0 4E75

L_002BE2:
	moveq   #$7,D1                                ; 00002BE2 7207
	and.b   D6,D1                                 ; 00002BE4 C206
	lea     (-$3c0,A6),A1                         ; 00002BE6 43EE FC40
	cmp.b   (A1,D1.w),D0                          ; 00002BEA B031 1000
	beq.s   L_002C4E                              ; 00002BEE 675E
	move.b  D0,(A1,D1.w)                          ; 00002BF0 1380 1000
	movea.l ($54,A5),A1                           ; 00002BF4 226D 0054
	eori.b  #$7f,D0                               ; 00002BF8 0A00 007F
	tst.b   D3                                    ; 00002BFC 4A03
	bpl.s   L_002C10                              ; 00002BFE 6A10
	move.b  ($6,A1),D2                            ; 00002C00 1429 0006
	add.b   D0,D2                                 ; 00002C04 D400
	bpl.s   L_002C0A                              ; 00002C06 6A02
	moveq   #$7f,D2                               ; 00002C08 747F

L_002C0A:
	moveq   #$60,D1                               ; 00002C0A 7260
	or.b    D6,D1                                 ; 00002C0C 8206
	bsr.s   L_002BC0                              ; 00002C0E 61B0

L_002C10:
	add.b   D3,D3                                 ; 00002C10 D603
	bpl.s   L_002C24                              ; 00002C12 6A10
	move.b  ($7,A1),D2                            ; 00002C14 1429 0007
	add.b   D0,D2                                 ; 00002C18 D400
	bpl.s   L_002C1E                              ; 00002C1A 6A02
	moveq   #$7f,D2                               ; 00002C1C 747F

L_002C1E:
	moveq   #$68,D1                               ; 00002C1E 7268
	or.b    D6,D1                                 ; 00002C20 8206
	bsr.s   L_002BC0                              ; 00002C22 619C

L_002C24:
	add.b   D3,D3                                 ; 00002C24 D603
	bpl.s   L_002C38                              ; 00002C26 6A10
	move.b  ($8,A1),D2                            ; 00002C28 1429 0008
	add.b   D0,D2                                 ; 00002C2C D400
	bpl.s   L_002C32                              ; 00002C2E 6A02
	moveq   #$7f,D2                               ; 00002C30 747F

L_002C32:
	moveq   #$70,D1                               ; 00002C32 7270
	or.b    D6,D1                                 ; 00002C34 8206
	bsr.s   L_002BC0                              ; 00002C36 6188

L_002C38:
	add.b   D3,D3                                 ; 00002C38 D603
	bpl.s   L_002C4E                              ; 00002C3A 6A12
	move.b  ($9,A1),D2                            ; 00002C3C 1429 0009
	add.b   D0,D2                                 ; 00002C40 D400
	bpl.s   L_002C46                              ; 00002C42 6A02
	moveq   #$7f,D2                               ; 00002C44 747F

L_002C46:
	moveq   #$78,D1                               ; 00002C46 7278
	or.b    D6,D1                                 ; 00002C48 8206
	bra.w   L_002BC0                              ; 00002C4A 6000 FF74

L_002C4E:
	rts                                           ; 00002C4E 4E75

L_002C50:
	dc.b    $0E,$0E,$0E,$0E,$0D,$0D,$10,$10,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C; 00002C50
	dc.b    $0B,$0B,$0B,$0B,$00,$00,$00,$00,$09,$09,$09,$0A,$09,$03,$04,$04; 00002C60
	dc.b    $08,$08,$08,$08,$08,$08,$08,$08,$07,$07,$07,$07,$02,$02,$02,$02; 00002C70
	dc.b    $07,$07,$07,$07,$07,$07,$07,$07,$0F,$0F,$0F,$05,$05,$05,$05,$05; 00002C80
	dc.b    $01,$01,$01,$01,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06; 00002C90
	dc.b    $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06; 00002CA0
	dc.b    $06,$06,$0C,$06,$06,$06,$06,$07,$09,$09,$09,$09,$09,$01,$07,$01; 00002CB0
	dc.b    $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E; 00002CC0
	dc.b    $38,$20,$6A,$11,$0A,$02,$1A,$20,$26,$00,$14,$0F,$14,$0F,$05,$02; 00002CD0
	dc.b    $08,$08,$00,$00,$00,$00,$A6,$16,$16,$17,$12,$32,$31,$77,$10,$02; 00002CE0
	dc.b    $1E,$1F,$26,$00,$96,$96,$96,$93,$0E,$0E,$0C,$03,$00,$00,$00,$00; 00002CF0
	dc.b    $13,$13,$F8,$47,$29,$10,$02,$02,$01,$01,$19,$2D,$23,$00,$1F,$1F; 00002D00
	dc.b    $1F,$19,$01,$03,$03,$0D,$02,$05,$05,$09,$30,$30,$30,$A6,$28,$20; 00002D10
	dc.b    $33,$51,$01,$01,$19,$1E,$1C,$00,$10,$1A,$13,$1B,$1F,$1F,$1F,$1F; 00002D20
	dc.b    $01,$01,$01,$01,$33,$03,$03,$08,$04,$20,$70,$01,$01,$32,$00,$05; 00002D30
	dc.b    $00,$00,$19,$19,$1F,$1F,$0F,$0F,$0A,$0A,$01,$01,$01,$01,$13,$13; 00002D40
	dc.b    $2A,$2A,$3D,$20,$02,$02,$01,$04,$1C,$0B,$08,$08,$12,$1F,$1F,$14; 00002D50
	dc.b    $07,$02,$02,$0A,$05,$05,$05,$05,$25,$27,$27,$A7,$04,$22,$71,$32; 00002D60
	dc.b    $01,$31,$20,$20,$05,$05,$12,$12,$12,$12,$00,$00,$00,$00,$00,$00; 00002D70
	dc.b    $00,$00,$06,$06,$07,$07,$3D,$20,$61,$03,$34,$72,$1B,$1E,$19,$00; 00002D80
	dc.b    $14,$8F,$0F,$0F,$08,$05,$05,$05,$00,$00,$00,$00,$12,$27,$27,$27; 00002D90
	dc.b    $3D,$30,$02,$02,$01,$04,$1C,$00,$00,$05,$1F,$1F,$1F,$1F,$0D,$0C; 00002DA0
	dc.b    $0C,$0C,$0D,$0A,$0A,$0A,$F6,$A7,$A7,$A7,$00,$10,$03,$01,$01,$01; 00002DB0
	dc.b    $1C,$22,$1A,$00,$5F,$5F,$5F,$1F,$08,$0A,$0A,$0A,$00,$00,$00,$05; 00002DC0
	dc.b    $F5,$F5,$F5,$37,$30,$10,$03,$01,$71,$03,$1D,$1E,$20,$00,$14,$19; 00002DD0
	dc.b    $0F,$1F,$0A,$00,$0C,$0A,$01,$01,$01,$01,$33,$33,$33,$3A,$07,$20; 00002DE0
	dc.b    $04,$00,$02,$01,$0F,$05,$0A,$00,$1F,$1F,$1F,$1F,$02,$05,$02,$03; 00002DF0
	dc.b    $00,$00,$00,$00,$37,$27,$37,$27,$07,$10,$31,$3E,$34,$71,$03,$03; 00002E00
	dc.b    $03,$03,$1F,$5F,$1F,$1F,$14,$10,$14,$14,$07,$15,$0B,$07,$27,$F6; 00002E10
	dc.b    $27,$27,$3C,$10,$62,$21,$52,$12,$21,$14,$28,$00,$9F,$5F,$56,$56; 00002E20
	dc.b    $08,$08,$02,$02,$02,$02,$03,$03,$50,$50,$27,$27,$34,$10,$71,$31; 00002E30
	dc.b    $71,$31,$19,$14,$00,$00,$54,$5C,$52,$59,$03,$03,$0A,$0A,$02,$02; 00002E40
	dc.b    $05,$08,$23,$20,$27,$27,$3A,$20,$51,$11,$08,$01,$1C,$32,$28,$00; 00002E50
	dc.b    $0F,$10,$10,$12,$08,$00,$0A,$06,$01,$01,$01,$01,$26,$26,$26,$88; 00002E60
	dc.b    $02,$10,$07,$04,$04,$01,$1A,$23,$19,$00,$5F,$5F,$5F,$9F,$0A,$05; 00002E70
	dc.b    $05,$0A,$03,$03,$03,$04,$A5,$A5,$55,$68; 00002E80
	dc.w    L_003398-L_002F8A                     ; 00002E8A
	dc.w    L_0030E4-L_002F8A                     ; 00002E8C
	dc.w    L_00357A-L_002F8A                     ; 00002E8E
	dc.w    L_00357A-L_002F8A                     ; 00002E90
	dc.w    L_00357A-L_002F8A                     ; 00002E92
	dc.w    L_00357A-L_002F8A                     ; 00002E94
	dc.w    L_00341C-L_002F8A                     ; 00002E96
	dc.w    L_00357A-L_002F8A                     ; 00002E98
	dc.w    L_003464-L_002F8A                     ; 00002E9A
	dc.w    L_00348E-L_002F8A                     ; 00002E9C
	dc.w    L_0034D2-L_002F8A                     ; 00002E9E
	dc.w    L_0034F0-L_002F8A                     ; 00002EA0
	dc.w    L_003D3C-L_002F8A                     ; 00002EA2
	dc.w    L_003458-L_002F8A                     ; 00002EA4
	dc.w    L_0033EC-L_002F8A                     ; 00002EA6
	dc.w    L_0033D0-L_002F8A                     ; 00002EA8
	dc.w    L_00357A-L_002F8A                     ; 00002EAA
	dc.w    L_00357A-L_002F8A                     ; 00002EAC
	dc.w    L_00357A-L_002F8A                     ; 00002EAE
	dc.w    L_00357A-L_002F8A                     ; 00002EB0
	dc.w    L_00357A-L_002F8A                     ; 00002EB2
	dc.w    L_00357A-L_002F8A                     ; 00002EB4
	dc.w    L_00357A-L_002F8A                     ; 00002EB6
	dc.w    L_00357A-L_002F8A                     ; 00002EB8
	dc.w    L_00357A-L_002F8A                     ; 00002EBA
	dc.w    L_00357A-L_002F8A                     ; 00002EBC
	dc.w    L_00357A-L_002F8A                     ; 00002EBE
	dc.w    L_00357A-L_002F8A                     ; 00002EC0
	dc.w    L_00357A-L_002F8A                     ; 00002EC2
	dc.w    L_00357A-L_002F8A                     ; 00002EC4
	dc.w    L_00357A-L_002F8A                     ; 00002EC6
	dc.w    L_00357A-L_002F8A                     ; 00002EC8
	dc.w    L_003A88-L_002F8A                     ; 00002ECA
	dc.w    L_003A78-L_002F8A                     ; 00002ECC
	dc.w    L_003AF8-L_002F8A                     ; 00002ECE
	dc.w    L_003ADA-L_002F8A                     ; 00002ED0
	dc.w    L_003AC4-L_002F8A                     ; 00002ED2
	dc.w    L_003AB4-L_002F8A                     ; 00002ED4
	dc.w    L_003BBE-L_002F8A                     ; 00002ED6
	dc.w    L_003BAC-L_002F8A                     ; 00002ED8
	dc.w    L_003424-L_002F8A                     ; 00002EDA
	dc.w    L_00357A-L_002F8A                     ; 00002EDC
	dc.w    L_003518-L_002F8A                     ; 00002EDE
	dc.w    L_00357A-L_002F8A                     ; 00002EE0
	dc.w    L_003598-L_002F8A                     ; 00002EE2
	dc.w    L_00357A-L_002F8A                     ; 00002EE4
	dc.w    L_003C4C-L_002F8A                     ; 00002EE6
	dc.w    L_00357A-L_002F8A                     ; 00002EE8
	dc.w    L_00359E-L_002F8A                     ; 00002EEA
	dc.w    L_00357A-L_002F8A                     ; 00002EEC
	dc.w    L_00358C-L_002F8A                     ; 00002EEE
	dc.w    L_00357A-L_002F8A                     ; 00002EF0
	dc.w    L_00357A-L_002F8A                     ; 00002EF2
	dc.w    L_00357A-L_002F8A                     ; 00002EF4
	dc.w    L_00357A-L_002F8A                     ; 00002EF6
	dc.w    L_00357A-L_002F8A                     ; 00002EF8
	dc.w    L_0035F0-L_002F8A                     ; 00002EFA
	dc.w    L_00357A-L_002F8A                     ; 00002EFC
	dc.w    L_0039F6-L_002F8A                     ; 00002EFE
	dc.w    L_003A26-L_002F8A                     ; 00002F00
	dc.w    L_003A32-L_002F8A                     ; 00002F02
	dc.w    L_00357A-L_002F8A                     ; 00002F04
	dc.w    L_00357A-L_002F8A                     ; 00002F06
	dc.w    L_00357A-L_002F8A                     ; 00002F08
	dc.w    L_003652-L_002F8A                     ; 00002F0A
	dc.w    L_00369C-L_002F8A                     ; 00002F0C
	dc.w    L_0036B2-L_002F8A                     ; 00002F0E
	dc.w    L_00357A-L_002F8A                     ; 00002F10
	dc.w    L_0036C0-L_002F8A                     ; 00002F12
	dc.w    L_0037E0-L_002F8A                     ; 00002F14
	dc.w    L_003830-L_002F8A                     ; 00002F16
	dc.w    L_003846-L_002F8A                     ; 00002F18
	dc.w    L_00357A-L_002F8A                     ; 00002F1A
	dc.w    L_00384E-L_002F8A                     ; 00002F1C
	dc.w    L_00357A-L_002F8A                     ; 00002F1E
	dc.w    L_00357A-L_002F8A                     ; 00002F20
	dc.w    L_00357A-L_002F8A                     ; 00002F22
	dc.w    L_00357A-L_002F8A                     ; 00002F24
	dc.w    L_00357A-L_002F8A                     ; 00002F26
	dc.w    L_00357A-L_002F8A                     ; 00002F28
	dc.w    L_00357A-L_002F8A                     ; 00002F2A
	dc.w    L_00357A-L_002F8A                     ; 00002F2C
	dc.w    L_00357A-L_002F8A                     ; 00002F2E
	dc.w    L_00357A-L_002F8A                     ; 00002F30
	dc.w    L_00357A-L_002F8A                     ; 00002F32
	dc.w    L_00357A-L_002F8A                     ; 00002F34
	dc.w    L_00357A-L_002F8A                     ; 00002F36
	dc.w    L_00357A-L_002F8A                     ; 00002F38
	dc.w    L_00357A-L_002F8A                     ; 00002F3A
	dc.w    L_00357A-L_002F8A                     ; 00002F3C
	dc.w    L_00357A-L_002F8A                     ; 00002F3E
	dc.w    L_00357A-L_002F8A                     ; 00002F40
	dc.w    L_00357A-L_002F8A                     ; 00002F42
	dc.w    L_00357A-L_002F8A                     ; 00002F44
	dc.w    L_00357A-L_002F8A                     ; 00002F46
	dc.w    L_00357A-L_002F8A                     ; 00002F48
	dc.w    L_003580-L_002F8A                     ; 00002F4A
	dc.w    L_00357A-L_002F8A                     ; 00002F4C
	dc.w    L_003DD0-L_002F8A                     ; 00002F4E
	dc.w    L_00357A-L_002F8A                     ; 00002F50
	dc.w    L_00357A-L_002F8A                     ; 00002F52
	dc.w    L_003BEE-L_002F8A                     ; 00002F54
	dc.w    L_003BF8-L_002F8A                     ; 00002F56
	dc.w    L_00395C-L_002F8A                     ; 00002F58
	dc.w    L_0039D8-L_002F8A                     ; 00002F5A
	dc.w    L_00357A-L_002F8A                     ; 00002F5C
	dc.w    L_00357A-L_002F8A                     ; 00002F5E
	dc.w    L_00357A-L_002F8A                     ; 00002F60
	dc.w    L_003DE2-L_002F8A                     ; 00002F62
	dc.w    L_00357A-L_002F8A                     ; 00002F64
	dc.w    L_00357A-L_002F8A                     ; 00002F66
	dc.w    L_0033C0-L_002F8A                     ; 00002F68
	dc.w    L_003CF0-L_002F8A                     ; 00002F6A
	dc.w    L_003CD4-L_002F8A                     ; 00002F6C
	dc.w    L_00357A-L_002F8A                     ; 00002F6E
	dc.w    L_00357A-L_002F8A                     ; 00002F70
	dc.w    L_003C30-L_002F8A                     ; 00002F72
	dc.w    L_003C0A-L_002F8A                     ; 00002F74
	dc.w    L_00342C-L_002F8A                     ; 00002F76
	dc.w    L_00357A-L_002F8A                     ; 00002F78
	dc.w    L_00357A-L_002F8A                     ; 00002F7A
	dc.w    L_00357A-L_002F8A                     ; 00002F7C
	dc.w    L_003E3E-L_002F8A                     ; 00002F7E
	dc.w    L_00357A-L_002F8A                     ; 00002F80
	dc.w    L_003DC2-L_002F8A                     ; 00002F82
	dc.w    L_003542-L_002F8A                     ; 00002F84
	dc.w    L_003C62-L_002F8A                     ; 00002F86
	dc.w    L_002FA8-L_002F8A                     ; 00002F88

L_002F8A:
	movea.l ($1c,A5),A3                           ; 00002F8A 266D 001C
	clr.b   ($5e,A5)                              ; 00002F8E 422D 005E

L_002F92:
	addq.b  #1,($2a,A5)                           ; 00002F92 522D 002A
	move.b  (A3)+,D0                              ; 00002F96 101B
	bpl.w   L_0030F8                              ; 00002F98 6A00 015E
	ext.w   D0                                    ; 00002F9C 4880
	add.w   D0,D0                                 ; 00002F9E D040
	move.w  L_002F8A(pc,D0.w),D0                  ; 00002FA0 303B 00E8
	jmp     L_002F8A(pc,D0.w)                     ; 00002FA4 4EFB 00E4

L_002FA8:
	bra.s   L_002F92                              ; 00002FA8 60E8

L_002FAA:
	tst.b   ($5f,A5)                              ; 00002FAA 4A2D 005F
	bne.w   L_0030E0                              ; 00002FAE 6600 0130
	tst.b   (-$13d,A6)                            ; 00002FB2 4A2E FEC3
	beq.w   L_0030E0                              ; 00002FB6 6700 0128
	tst.l   (-$33c,A6)                            ; 00002FBA 4AAE FCC4
	bne.w   L_0030E0                              ; 00002FBE 6600 0120
	tst.w   D6                                    ; 00002FC2 4A46
	bmi.w   L_0030E0                              ; 00002FC4 6B00 011A
	sub.w   ($6,A5),D4                            ; 00002FC8 986D 0006
	bsr.w   L_000E2C                              ; 00002FCC 6100 DE5E
	add.w   ($6,A5),D4                            ; 00002FD0 D86D 0006
	move.b  (A1),D3                               ; 00002FD4 1611
	bsr.w   L_003344                              ; 00002FD6 6100 036C
	moveq   #$8,D0                                ; 00002FDA 7008
	tst.b   (-$13c,A6)                            ; 00002FDC 4A2E FEC4
	bne.s   L_002FE4                              ; 00002FE0 6602
	moveq   #$4,D0                                ; 00002FE2 7004

L_002FE4:
	move.b  D0,($b,A0)                            ; 00002FE4 1140 000B
	moveq   #$f,D1                                ; 00002FE8 720F
	and.b   D6,D1                                 ; 00002FEA C206
	move.w  (-$7ee,A6),D0                         ; 00002FEC 302E F812
	bset    D1,D0                                 ; 00002FF0 03C0
	move.w  D0,(-$7ee,A6)                         ; 00002FF2 3D40 F812
	move.b  (A1),($d,A0)                          ; 00002FF6 1151 000D
	move.w  D2,(A0)                               ; 00002FFA 3082
	movea.l A0,A1                                 ; 00002FFC 2248
	move.w  D4,D0                                 ; 00002FFE 3004
	bmi.s   L_003014                              ; 00003000 6B12
	bsr.w   L_003B32                              ; 00003002 6100 0B2E
	moveq   #$0,D1                                ; 00003006 7200
	tst.b   (-$13c,A6)                            ; 00003008 4A2E FEC4
	bne.s   L_003010                              ; 0000300C 6602
	moveq   #$4,D1                                ; 0000300E 7204

L_003010:
	cmp.b   D1,D0                                 ; 00003010 B001
	bge.s   L_00301E                              ; 00003012 6C0A

L_003014:
	ori.b   #$80,($d,A1)                          ; 00003014 0029 0080 000D
	bra.w   L_0030E0                              ; 0000301A 6000 00C4

L_00301E:
	move.b  D0,($65,A6)                           ; 0000301E 1D40 0065
	moveq   #$0,D0                                ; 00003022 7000
	move.b  D3,D0                                 ; 00003024 1003
	movea.l (-$37a,A6),A0                         ; 00003026 206E FC86
	lsl.w   #3,D0                                 ; 0000302A E748
	add.w   ($58,A5),D0                           ; 0000302C D06D 0058
	tst.b   (-$129,A6)                            ; 00003030 4A2E FED7
	beq.s   L_00304C                              ; 00003034 6716
	move.l  (A0,D0.l),D1                          ; 00003036 2230 0800
	beq.w   L_0030E0                              ; 0000303A 6700 00A4
	lea     (A0,D1.l),A1                          ; 0000303E 43F0 1800
	move.l  ($4,A0,D0.l),D2                       ; 00003042 2430 0804
	beq.w   L_0030E0                              ; 00003046 6700 0098
	bra.s   L_003060                              ; 0000304A 6014

L_00304C:
	move.l  (-$78,A0,D0.l),D1                     ; 0000304C 2230 0888
	beq.w   L_0030E0                              ; 00003050 6700 008E
	lea     (A0,D1.l),A1                          ; 00003054 43F0 1800
	move.l  (-$74,A0,D0.l),D2                     ; 00003058 2430 088C
	beq.w   L_0030E0                              ; 0000305C 6700 0082

L_003060:
	tst.l   (-$33c,A6)                            ; 00003060 4AAE FCC4
	bne.s   L_0030E0                              ; 00003064 667A
	tst.w   D6                                    ; 00003066 4A46
	bmi.s   L_0030E0                              ; 00003068 6B76
	bsr.w   L_001966                              ; 0000306A 6100 E8FA
	move.b  ($65,A5),D0                           ; 0000306E 102D 0065
	tst.b   (-$13c,A6)                            ; 00003072 4A2E FEC4
	beq.s   L_0030C8                              ; 00003076 6750
	move.b  ($65,A6),D0                           ; 00003078 102E 0065
	moveq   #$0,D1                                ; 0000307C 7200
	move.b  D0,D1                                 ; 0000307E 1200
	swap    D1                                    ; 00003080 4841
	move.w  ($4c,A5),D1                           ; 00003082 322D 004C
	cmpi.b  #$4,($4c,A5)                          ; 00003086 0C2D 0004 004C
	bne.s   L_0030C0                              ; 0000308C 6632
	move.l  (-$1c6,A6),D0                         ; 0000308E 202E FE3A
	beq.s   L_0030C0                              ; 00003092 672C
	movea.l D0,A0                                 ; 00003094 2040
	moveq   #$0,D0                                ; 00003096 7000
	add.b   D3,D0                                 ; 00003098 D003
	move.w  (A0)+,D3                              ; 0000309A 3618
	subq.w  #1,D3                                 ; 0000309C 5343

L_00309E:
	cmp.l   (A0),D0                               ; 0000309E B090
	addq.l  #8,A0                                 ; 000030A0 5088
	dbeq    D3,L_00309E                           ; 000030A2 57CB FFFA
	bne.s   L_0030C0                              ; 000030A6 6618
	ifnd __ATARI__
	eori.w  #$3e,($e82200).l                      ; 000030A8 0A79 003E 00E8 2200
	endif
	movea.l -(A0),A1                              ; 000030B0 2260
	lsl.l   #2,D2                                 ; 000030B2 E58A
	eori.w  #$100,D1                              ; 000030B4 0A41 0100
	ifnd __ATARI__
	eori.w  #$3e,($e82200).l                      ; 000030B8 0A79 003E 00E8 2200
	endif

L_0030C0:
	moveq   #$f,D0                                ; 000030C0 700F
	and.w   D6,D0                                 ; 000030C2 C046
	trap    #$2                                   ; 000030C4 4E42
	bra.s   L_0030E0                              ; 000030C6 6018

L_0030C8:
	tst.b   (-$152,A6)                            ; 000030C8 4A2E FEAE
	bgt.s   L_0030E0                              ; 000030CC 6E12
	clr.b   (-$152,A6)                            ; 000030CE 422E FEAE
	moveq   #$0,D1                                ; 000030D2 7200
	bsr.w   L_0043CA                              ; 000030D4 6100 12F4
	move.w  ($4c,A5),D1                           ; 000030D8 322D 004C
	bsr.w   L_004216                              ; 000030DC 6100 1138

L_0030E0:
	bra.w   L_0014F4                              ; 000030E0 6000 E412

L_0030E4:
	moveq   #$0,D2                                ; 000030E4 7400
	move.b  ($6d,A5),D2                           ; 000030E6 142D 006D
	swap    D2                                    ; 000030EA 4842
	move.b  (A3)+,D2                              ; 000030EC 141B
	bsr.w   L_003E50                              ; 000030EE 6100 0D60
	exg     D0,D2                                 ; 000030F2 C142
	move.l  D2,D1                                 ; 000030F4 2202
	bra.s   L_003124                              ; 000030F6 602C

L_0030F8:
	moveq   #$0,D2                                ; 000030F8 7400
	move.b  (A3)+,D2                              ; 000030FA 141B
	bmi.s   L_003116                              ; 000030FC 6B18
	bne.s   L_003104                              ; 000030FE 6604
	move.b  ($6d,A5),D2                           ; 00003100 142D 006D

L_003104:
	swap    D2                                    ; 00003104 4842
	move.w  D0,D2                                 ; 00003106 3400
	bsr.w   L_003E50                              ; 00003108 6100 0D46
	move.l  D0,D1                                 ; 0000310C 2200
	bsr.w   L_003E50                              ; 0000310E 6100 0D40
	exg     D0,D2                                 ; 00003112 C142
	bra.s   L_003124                              ; 00003114 600E

L_003116:
	swap    D0                                    ; 00003116 4840
	move.b  ($6d,A5),D0                           ; 00003118 102D 006D
	swap    D0                                    ; 0000311C 4840
	andi.w  #$7f,D2                               ; 0000311E 0242 007F
	move.l  D2,D1                                 ; 00003122 2202

L_003124:
	tst.b   ($fe,A5)                              ; 00003124 4A2D 00FE
	bne.s   L_003144                              ; 00003128 661A
	ext.w   D0                                    ; 0000312A 4880
	move.b  ($71,A5),D3                           ; 0000312C 162D 0071
	ext.w   D3                                    ; 00003130 4883
	add.w   D3,D0                                 ; 00003132 D043
	add.w   (-$76,A6),D0                          ; 00003134 D06E FF8A
	moveq   #$7f,D3                               ; 00003138 767F
	cmp.w   D3,D0                                 ; 0000313A B043
	bls.s   L_003144                              ; 0000313C 6306
	bgt.s   L_003142                              ; 0000313E 6E02
	clr.w   D3                                    ; 00003140 4243

L_003142:
	move.w  D3,D0                                 ; 00003142 3003

L_003144:
	tst.b   ($5e,A5)                              ; 00003144 4A2D 005E
	beq.s   L_00314E                              ; 00003148 6704
	moveq   #-$1,D2                               ; 0000314A 74FF
	bra.s   L_003174                              ; 0000314C 6026

L_00314E:
	tst.w   D2                                    ; 0000314E 4A42
	beq.s   L_003174                              ; 00003150 6722
	move.b  ($64,A5),D3                           ; 00003152 162D 0064
	beq.s   L_003174                              ; 00003156 671C
	ext.w   D3                                    ; 00003158 4883
	bmi.s   L_003168                              ; 0000315A 6B0C
	subq.w  #1,D2                                 ; 0000315C 5342
	bcs.s   L_003164                              ; 0000315E 6504
	mulu.w  D3,D2                                 ; 00003160 C4C3
	lsr.l   #3,D2                                 ; 00003162 E68A

L_003164:
	addq.w  #1,D2                                 ; 00003164 5242
	bra.s   L_003174                              ; 00003166 600C

L_003168:
	neg.w   D3                                    ; 00003168 4443
	cmp.w   D3,D2                                 ; 0000316A B443
	bls.s   L_003172                              ; 0000316C 6304
	sub.w   D3,D2                                 ; 0000316E 9443
	bra.s   L_003174                              ; 00003170 6002

L_003172:
	moveq   #$1,D2                                ; 00003172 7401

L_003174:
	move.w  ($d8,A5),D3                           ; 00003174 362D 00D8
	beq.s   L_003184                              ; 00003178 670A
	sub.w   D3,($4,A5)                            ; 0000317A 976D 0004
	sub.w   D3,D5                                 ; 0000317E 9A43
	clr.w   ($d8,A5)                              ; 00003180 426D 00D8

L_003184:
	clr.b   -(A7)                                 ; 00003184 4227
	move.w  ($46,A5),D3                           ; 00003186 362D 0046
	bmi.s   L_0031A6                              ; 0000318A 6B1A
	lea     (-$ff0,A6),A0                         ; 0000318C 41EE F010

L_003190:
	cmp.b   ($d,A0,D3.w),D0                       ; 00003190 B030 300D
	beq.s   L_00319E                              ; 00003194 6708
	move.w  ($6,A0,D3.w),D3                       ; 00003196 3630 3006
	bpl.s   L_003190                              ; 0000319A 6AF4
	bra.s   L_0031A6                              ; 0000319C 6008

L_00319E:
	move.w  D2,(A0,D3.w)                          ; 0000319E 3182 3000
	st      (A7)                                  ; 000031A2 50D7
	bra.s   L_0031B8                              ; 000031A4 6012

L_0031A6:
	tst.b   ($5f,A5)                              ; 000031A6 4A2D 005F
	bne.s   L_0031B8                              ; 000031AA 660C
	cmpi.b  #$1,($2f,A5)                          ; 000031AC 0C2D 0001 002F
	bhi.s   L_0031B8                              ; 000031B2 6204
	bsr.w   L_001894                              ; 000031B4 6100 E6DE

L_0031B8:
	moveq   #$7f,D3                               ; 000031B8 767F
	and.w   D0,D3                                 ; 000031BA C640
	lsl.w   #6,D3                                 ; 000031BC ED4B
	tst.b   ($5f,A5)                              ; 000031BE 4A2D 005F
	beq.s   L_0031EE                              ; 000031C2 672A
	add.w   D1,($dc,A5)                           ; 000031C4 D36D 00DC
	sub.w   ($50,A5),D3                           ; 000031C8 966D 0050
	tst.b   D6                                    ; 000031CC 4A06
	bpl.s   L_0031DC                              ; 000031CE 6A0C
	ext.l   D3                                    ; 000031D0 48C3
	asl.l   #7,D3                                 ; 000031D2 EF83
	moveq   #$0,D1                                ; 000031D4 7200
	move.b  ($2d,A5),D1                           ; 000031D6 122D 002D
	divs.w  D1,D3                                 ; 000031DA 87C1

L_0031DC:
	move.w  ($4e,A5),D1                           ; 000031DC 322D 004E
	move.w  D3,($4e,A5)                           ; 000031E0 3B43 004E
	sub.w   D1,D3                                 ; 000031E4 9641
	add.w   D3,($4,A5)                            ; 000031E6 D76D 0004
	add.w   D3,D5                                 ; 000031EA DA43
	bra.s   L_003208                              ; 000031EC 601A

L_0031EE:
	clr.w   ($e0,A5)                              ; 000031EE 426D 00E0
	move.w  D1,($dc,A5)                           ; 000031F2 3B41 00DC
	move.w  D3,($50,A5)                           ; 000031F6 3B43 0050
	move.w  ($4e,A5),D1                           ; 000031FA 322D 004E
	sub.w   D1,($4,A5)                            ; 000031FE 936D 0004
	sub.w   D1,D5                                 ; 00003202 9A41
	clr.w   ($4e,A5)                              ; 00003204 426D 004E

L_003208:
	bsr.w   L_00178C                              ; 00003208 6100 E582
	tst.w   D2                                    ; 0000320C 4A42
	beq.s   L_00322A                              ; 0000320E 671A
	move.w  ($46,A5),D3                           ; 00003210 362D 0046
	bmi.s   L_00322A                              ; 00003214 6B14
	lea     (-$ff0,A6),A0                         ; 00003216 41EE F010

L_00321A:
	tst.w   (A0,D3.w)                             ; 0000321A 4A70 3000
	bne.s   L_003224                              ; 0000321E 6604
	move.w  D2,(A0,D3.w)                          ; 00003220 3182 3000

L_003224:
	move.w  ($6,A0,D3.w),D3                       ; 00003224 3630 3006
	bpl.s   L_00321A                              ; 00003228 6AF0

L_00322A:
	tst.b   (A7)+                                 ; 0000322A 4A1F
	bne.w   L_0014F4                              ; 0000322C 6600 E2C6
	tst.b   ($5f,A5)                              ; 00003230 4A2D 005F
	beq.s   L_003254                              ; 00003234 671E
	cmpi.b  #$1,($2f,A5)                          ; 00003236 0C2D 0001 002F
	bhi.s   L_003254                              ; 0000323C 6216
	move.w  ($46,A5),D3                           ; 0000323E 362D 0046
	bmi.s   L_003276                              ; 00003242 6B32
	lea     (-$ff0,A6),A0                         ; 00003244 41EE F010

L_003248:
	move.w  D2,(A0,D3.w)                          ; 00003248 3182 3000
	move.w  ($6,A0,D3.w),D3                       ; 0000324C 3630 3006
	bpl.s   L_003248                              ; 00003250 6AF6
	bra.s   L_003276                              ; 00003252 6022

L_003254:
	tst.l   (-$33c,A6)                            ; 00003254 4AAE FCC4
	bne.s   L_003276                              ; 00003258 661C
	tst.w   D6                                    ; 0000325A 4A46
	bmi.s   L_003276                              ; 0000325C 6B18
	lea     (-$7e2,A6),A0                         ; 0000325E 41EE F81E
	move.w  (A0),D3                               ; 00003262 3610
	lea     ($2,A0,D3.w),A1                       ; 00003264 43F0 3002
	move.b  ($ff,A5),(A1)+                        ; 00003268 12ED 00FF
	move.b  D0,(A1)+                              ; 0000326C 12C0
	swap    D0                                    ; 0000326E 4840
	move.b  D0,(A1)+                              ; 00003270 12C0
	move.b  D6,(A1)+                              ; 00003272 12C6
	subq.l  #3,A1                                 ; 00003274 5789

L_003276:
	tst.b   D6                                    ; 00003276 4A06
	bmi.s   L_0032EE                              ; 00003278 6B74
	cmpi.b  #$10,D6                               ; 0000327A 0C06 0010
	bge.w   L_002FAA                              ; 0000327E 6C00 FD2A
	tst.b   ($5f,A5)                              ; 00003282 4A2D 005F
	bne.s   L_0032EA                              ; 00003286 6662
	tst.l   (-$33c,A6)                            ; 00003288 4AAE FCC4
	bne.s   L_0032EA                              ; 0000328C 665C
	tst.w   D6                                    ; 0000328E 4A46
	bmi.s   L_0032EA                              ; 00003290 6B58
	bsr.w   L_001966                              ; 00003292 6100 E6D2
	bsr.w   L_003344                              ; 00003296 6100 00AC
	sf      ($b,A0)                               ; 0000329A 51E8 000B
	move.b  (A1),($d,A0)                          ; 0000329E 1151 000D
	move.w  D2,(A0)                               ; 000032A2 3082
	move.b  ($1,A1),D0                            ; 000032A4 1029 0001
	move.b  ($74,A5),D3                           ; 000032A8 162D 0074
	not.b   D3                                    ; 000032AC 4603
	bsr.w   L_002BE2                              ; 000032AE 6100 F932
	tst.w   D6                                    ; 000032B2 4A46
	bmi.s   L_0032EA                              ; 000032B4 6B34
	move.w  D5,D2                                 ; 000032B6 3405
	move.w  ($50,A5),D5                           ; 000032B8 3A2D 0050
	addq.w  #5,D5                                 ; 000032BC 5A45
	bsr.w   L_00161E                              ; 000032BE 6100 E35E
	move.w  D2,D5                                 ; 000032C2 3A02
	moveq   #$8,D1                                ; 000032C4 7208
	move.w  D6,D2                                 ; 000032C6 3406
	or.b    ($62,A5),D2                           ; 000032C8 842D 0062
	bsr.w   L_002BC0                              ; 000032CC 6100 F8F2
	clr.w   ($12,A5)                              ; 000032D0 426D 0012
	bset    D6,(-$7f0,A6)                         ; 000032D4 0DEE F810
	move.b  ($72,A5),D2                           ; 000032D8 142D 0072
	beq.s   L_0032EA                              ; 000032DC 670C
	moveq   #$1,D1                                ; 000032DE 7201
	bsr.w   L_002BC0                              ; 000032E0 6100 F8DE
	moveq   #$0,D2                                ; 000032E4 7400
	bsr.w   L_002BC0                              ; 000032E6 6100 F8D8

L_0032EA:
	bra.w   L_0014F4                              ; 000032EA 6000 E208

L_0032EE:
	cmp.w   ($12,A5),D5                           ; 000032EE BA6D 0012
	beq.s   L_003300                              ; 000032F2 670C
	movem.l D0-D1/A0,-(A7)                        ; 000032F4 48E7 C080
	bsr.w   L_00158C                              ; 000032F8 6100 E292
	movem.l (A7)+,D0-D1/A0                        ; 000032FC 4CDF 0103

L_003300:
	tst.b   ($5f,A5)                              ; 00003300 4A2D 005F
	bne.s   L_003340                              ; 00003304 663A
	tst.w   D6                                    ; 00003306 4A46
	bmi.s   L_003340                              ; 00003308 6B36
	tst.l   (-$33c,A6)                            ; 0000330A 4AAE FCC4
	bne.s   L_003340                              ; 0000330E 6630
	bsr.w   L_001966                              ; 00003310 6100 E654
	subq.l  #4,A7                                 ; 00003314 598F
	movea.l A7,A0                                 ; 00003316 204F
	moveq   #$f,D0                                ; 00003318 700F
	and.w   D6,D0                                 ; 0000331A C046
	ori.w   #$90,D0                               ; 0000331C 0040 0090
	move.b  D0,(A0)+                              ; 00003320 10C0
	move.b  (A1),(A0)+                            ; 00003322 10D1
	move.b  ($1,A1),(A0)+                         ; 00003324 10E9 0001
	movea.l A7,A0                                 ; 00003328 204F
	moveq   #$2,D0                                ; 0000332A 7002
	bsr.w   L_0005A6                              ; 0000332C 6100 D278
	addq.l  #4,A7                                 ; 00003330 588F
	bsr.s   L_003344                              ; 00003332 6110
	move.b  #$c,($b,A0)                           ; 00003334 117C 000C 000B
	move.w  D2,(A0)                               ; 0000333A 3082
	move.b  (A1),($d,A0)                          ; 0000333C 1151 000D

L_003340:
	bra.w   L_0014F4                              ; 00003340 6000 E1B2

L_003344:
	move.w  D0,-(A7)                              ; 00003344 3F00
	move.w  D1,-(A7)                              ; 00003346 3F01
	lea     (-$ff0,A6),A0                         ; 00003348 41EE F010
	move.w  (-$ff4,A6),D0                         ; 0000334C 302E F00C
	move.w  ($2,A0,D0.w),(-$ff4,A6)               ; 00003350 3D70 0002 F00C
	move.w  (-$ffe,A6),D1                         ; 00003356 322E F002
	move.w  D0,(-$ffe,A6)                         ; 0000335A 3D40 F002
	move.w  D1,($2,A0,D0.w)                       ; 0000335E 3181 0002
	move.w  ($4,A0,D1.w),($4,A0,D0.w)             ; 00003362 31B0 1004 0004
	move.w  D0,($4,A0,D1.w)                       ; 00003368 3180 1004
	move.w  ($46,A5),D1                           ; 0000336C 322D 0046
	move.w  D0,($46,A5)                           ; 00003370 3B40 0046
	move.w  #$fff0,($8,A0,D0.w)                   ; 00003374 31BC FFF0 0008
	move.w  D1,($6,A0,D0.w)                       ; 0000337A 3181 0006
	move.w  D0,($8,A0,D1.w)                       ; 0000337E 3180 1008
	adda.w  D0,A0                                 ; 00003382 D0C0
	move.b  D6,($a,A0)                            ; 00003384 1146 000A
	move.b  ($ff,A5),($c,A0)                      ; 00003388 116D 00FF 000C
	addq.b  #1,($2f,A5)                           ; 0000338E 522D 002F
	move.w  (A7)+,D1                              ; 00003392 321F
	move.w  (A7)+,D0                              ; 00003394 301F
	rts                                           ; 00003396 4E75

L_003398:
	bsr.w   L_003E50                              ; 00003398 6100 0AB6
	add.w   D0,($dc,A5)                           ; 0000339C D16D 00DC
	bsr.w   L_00178C                              ; 000033A0 6100 E3EA
	tst.b   ($5f,A5)                              ; 000033A4 4A2D 005F
	beq.s   L_0033BC                              ; 000033A8 6712
	tst.b   ($5e,A5)                              ; 000033AA 4A2D 005E
	beq.s   L_0033B2                              ; 000033AE 6702
	moveq   #-$1,D0                               ; 000033B0 70FF

L_0033B2:
	lea     (-$ff0,A6),A0                         ; 000033B2 41EE F010
	adda.w  ($46,A5),A0                           ; 000033B6 D0ED 0046
	move.w  D0,(A0)                               ; 000033BA 3080

L_0033BC:
	bra.w   L_0014F4                              ; 000033BC 6000 E136

L_0033C0:
	lea     ($fe,A5),A0                           ; 000033C0 41ED 00FE
	moveq   #-$80,D0                              ; 000033C4 7080
	and.b   (A0),D0                               ; 000033C6 C010
	or.b    (A3)+,D0                              ; 000033C8 801B
	move.b  D0,(A0)                               ; 000033CA 1080
	bra.w   L_002F92                              ; 000033CC 6000 FBC4

L_0033D0:
	move.l  A3,D0                                 ; 000033D0 200B
	addq.l  #2,D0                                 ; 000033D2 5480
	move.l  D0,($e4,A5)                           ; 000033D4 2B40 00E4

L_0033D8:
	move.b  (A3)+,-(A7)                           ; 000033D8 1F1B
	move.w  (A7)+,D0                              ; 000033DA 301F
	move.b  (A3)+,D0                              ; 000033DC 101B
	adda.w  D0,A3                                 ; 000033DE D6C0
	cmpi.b  #-$71,(A3)                            ; 000033E0 0C13 008F
	bne.w   L_002F92                              ; 000033E4 6600 FBAC
	addq.l  #1,A3                                 ; 000033E8 528B
	bra.s   L_0033D8                              ; 000033EA 60EC

L_0033EC:
	clr.b   ($2a,A5)                              ; 000033EC 422D 002A
	addq.w  #1,($28,A5)                           ; 000033F0 526D 0028
	move.w  (-$342,A6),D0                         ; 000033F4 302E FCBE
	beq.s   L_003408                              ; 000033F8 670E
	cmp.w   ($28,A5),D0                           ; 000033FA B06D 0028
	bhi.s   L_003408                              ; 000033FE 6208
	clr.w   (-$342,A6)                            ; 00003400 426E FCBE
	clr.l   (-$33c,A6)                            ; 00003404 42AE FCC4

L_003408:
	move.l  ($e4,A5),D0                           ; 00003408 202D 00E4
	beq.w   L_002F92                              ; 0000340C 6700 FB84
	movea.l D0,A3                                 ; 00003410 2640
	moveq   #$0,D0                                ; 00003412 7000
	move.l  D0,($e4,A5)                           ; 00003414 2B40 00E4
	bra.w   L_002F92                              ; 00003418 6000 FB78

L_00341C:
	st      ($5e,A5)                              ; 0000341C 50ED 005E
	bra.w   L_002F92                              ; 00003420 6000 FB70

L_003424:
	move.b  (A3)+,($71,A5)                        ; 00003424 1B5B 0071
	bra.w   L_002F92                              ; 00003428 6000 FB68

L_00342C:
	move.b  (A3)+,D0                              ; 0000342C 101B
	ext.w   D0                                    ; 0000342E 4880
	move.w  D0,(-$78,A6)                          ; 00003430 3D40 FF88
	bsr.s   L_00343A                              ; 00003434 6104
	bra.w   L_002F92                              ; 00003436 6000 FB5A

L_00343A:
	move.w  (-$7a,A6),D0                          ; 0000343A 302E FF86
	add.w   (-$78,A6),D0                          ; 0000343E D06E FF88
	cmpi.w  #$7f,D0                               ; 00003442 0C40 007F
	ble.s   L_00344A                              ; 00003446 6F02
	moveq   #$7f,D0                               ; 00003448 707F

L_00344A:
	cmpi.w  #-$7f,D0                              ; 0000344A 0C40 FF81
	bge.s   L_003452                              ; 0000344E 6C02
	moveq   #-$7f,D0                              ; 00003450 7081

L_003452:
	move.w  D0,(-$76,A6)                          ; 00003452 3D40 FF8A
	rts                                           ; 00003456 4E75

L_003458:
	move.b  (A3)+,-(A7)                           ; 00003458 1F1B
	move.w  (A7)+,D0                              ; 0000345A 301F
	move.b  (A3)+,D0                              ; 0000345C 101B
	adda.w  D0,A3                                 ; 0000345E D6C0
	bra.w   L_002F92                              ; 00003460 6000 FB30

L_003464:
	moveq   #$0,D0                                ; 00003464 7000
	lea     ($c6,A5),A0                           ; 00003466 41ED 00C6
	move.b  (A0),D0                               ; 0000346A 1010
	addq.b  #1,D0                                 ; 0000346C 5200
	moveq   #$a,D1                                ; 0000346E 720A
	cmp.b   D1,D0                                 ; 00003470 B001
	bls.s   L_003476                              ; 00003472 6302
	move.b  D1,D0                                 ; 00003474 1001

L_003476:
	move.b  D0,(A0)                               ; 00003476 1080
	move.b  #$1,(A0,D0.w)                         ; 00003478 11BC 0001 0000
	move.w  ($d0,A5),D1                           ; 0000347E 322D 00D0
	bclr    D0,D1                                 ; 00003482 0181
	move.w  D1,($d0,A5)                           ; 00003484 3B41 00D0
	addq.l  #2,A3                                 ; 00003488 548B
	bra.w   L_002F92                              ; 0000348A 6000 FB06

L_00348E:
	move.b  (A3)+,-(A7)                           ; 0000348E 1F1B
	move.w  (A7)+,D0                              ; 00003490 301F
	move.b  (A3)+,D0                              ; 00003492 101B
	lea     ($3,A3,D0.w),A0                       ; 00003494 41F3 0003
	lea     ($c6,A5),A1                           ; 00003498 43ED 00C6
	moveq   #$0,D1                                ; 0000349C 7200
	move.b  (A1),D1                               ; 0000349E 1211
	beq.w   L_002F92                              ; 000034A0 6700 FAF0
	move.b  (-$2,A0),D0                           ; 000034A4 1028 FFFE
	cmp.b   (A1,D1.w),D0                          ; 000034A8 B031 1000
	bne.s   L_0034B4                              ; 000034AC 6606
	subq.b  #1,(A1)                               ; 000034AE 5311
	bra.w   L_002F92                              ; 000034B0 6000 FAE0

L_0034B4:
	movea.l A0,A3                                 ; 000034B4 2648
	addq.b  #1,(A1,D1.w)                          ; 000034B6 5231 1000
	cmp.b   (A1,D1.w),D0                          ; 000034BA B031 1000
	bne.w   L_002F92                              ; 000034BE 6600 FAD2
	move.b  (A1),D0                               ; 000034C2 1011
	move.w  ($d0,A5),D1                           ; 000034C4 322D 00D0
	bset    D0,D1                                 ; 000034C8 01C1
	move.w  D1,($d0,A5)                           ; 000034CA 3B41 00D0
	bra.w   L_002F92                              ; 000034CE 6000 FAC2

L_0034D2:
	move.b  (A3)+,-(A7)                           ; 000034D2 1F1B
	move.w  (A7)+,D0                              ; 000034D4 301F
	move.b  (A3)+,D0                              ; 000034D6 101B
	lea     (A3,D0.w),A0                          ; 000034D8 41F3 0000
	move.b  ($c6,A5),D0                           ; 000034DC 102D 00C6
	move.w  ($d0,A5),D1                           ; 000034E0 322D 00D0
	btst    D0,D1                                 ; 000034E4 0101
	beq.w   L_002F92                              ; 000034E6 6700 FAAA
	movea.l A0,A3                                 ; 000034EA 2648
	bra.w   L_002F92                              ; 000034EC 6000 FAA4

L_0034F0:
	move.b  (A3)+,D0                              ; 000034F0 101B
	lea     ($c6,A5),A1                           ; 000034F2 43ED 00C6
	moveq   #$0,D1                                ; 000034F6 7200
	move.b  (A1),D1                               ; 000034F8 1211
	cmp.b   (A1,D1.w),D0                          ; 000034FA B031 1000
	bne.s   L_003506                              ; 000034FE 6606
	addq.l  #2,A3                                 ; 00003500 548B
	bra.w   L_002F92                              ; 00003502 6000 FA8E

L_003506:
	move.b  (A3)+,-(A7)                           ; 00003506 1F1B
	move.w  (A7)+,D0                              ; 00003508 301F
	move.b  (A3)+,D0                              ; 0000350A 101B
	cmpi.b  #-$75,(A3)                            ; 0000350C 0C13 008B
	beq.s   L_0034F0                              ; 00003510 67DE
	adda.w  D0,A3                                 ; 00003512 D6C0
	bra.w   L_002F92                              ; 00003514 6000 FA7C

L_003518:
	move.b  (A3)+,D0                              ; 00003518 101B
	move.b  D0,($2d,A5)                           ; 0000351A 1B40 002D
	lea     L_00353A(pc),A0                       ; 0000351E 41FA 001A
	move.b  D0,($6,A0)                            ; 00003522 1140 0006
	moveq   #$f,D0                                ; 00003526 700F
	and.b   D6,D0                                 ; 00003528 C006
	ori.b   #$b0,D0                               ; 0000352A 0000 00B0
	move.b  D0,(A0)                               ; 0000352E 1080
	moveq   #$6,D0                                ; 00003530 7006
	bsr.w   L_0005A6                              ; 00003532 6100 D072
	bra.w   L_002F92                              ; 00003536 6000 FA5A

L_00353A:
	dc.b    $00,$65,$00,$64,$00,$06,$00,$00       ; 0000353A

L_003542:
	moveq   #$0,D0                                ; 00003542 7000
	move.b  (A3)+,-(A7)                           ; 00003544 1F1B
	move.w  (A7)+,D1                              ; 00003546 321F
	move.b  (A3)+,D1                              ; 00003548 121B
	ext.l   D1                                    ; 0000354A 48C1
	beq.s   L_003572                              ; 0000354C 6724
	spl     D3                                    ; 0000354E 5AC3
	bpl.s   L_003554                              ; 00003550 6A02
	neg.w   D1                                    ; 00003552 4441

L_003554:
	moveq   #$0,D0                                ; 00003554 7000
	tas     D0                                    ; 00003556 4AC0
	divu.w  D1,D0                                 ; 00003558 80C1
	move.w  D0,D2                                 ; 0000355A 3400
	clr.w   D0                                    ; 0000355C 4240
	divu.w  D1,D0                                 ; 0000355E 80C1
	swap    D2                                    ; 00003560 4842
	move.w  D0,D2                                 ; 00003562 3400
	move.l  D2,D0                                 ; 00003564 2002
	move.w  (-$358,A6),(-$35c,A6)                 ; 00003566 3D6E FCA8 FCA4
	tst.b   D3                                    ; 0000356C 4A03
	beq.s   L_003572                              ; 0000356E 6702
	neg.l   D0                                    ; 00003570 4480

L_003572:
	bsr.w   L_000DE4                              ; 00003572 6100 D870
	bra.w   L_002F92                              ; 00003576 6000 FA1A

L_00357A:
	addq.l  #1,A3                                 ; 0000357A 528B
	bra.w   L_002F92                              ; 0000357C 6000 FA14

L_003580:
	moveq   #$0,D0                                ; 00003580 7000
	move.b  (A3)+,D0                              ; 00003582 101B
	bsr.w   L_001362                              ; 00003584 6100 DDDC
	bra.w   L_002F92                              ; 00003588 6000 FA08

L_00358C:
	move.b  (A3)+,-(A7)                           ; 0000358C 1F1B
	move.w  (A7)+,D0                              ; 0000358E 301F
	move.b  (A3)+,D0                              ; 00003590 101B
	move.w  D0,($24,A5)                           ; 00003592 3B40 0024
	bra.s   L_0035A8                              ; 00003596 6010

L_003598:
	move.b  (A3)+,D0                              ; 00003598 101B
	ext.w   D0                                    ; 0000359A 4880
	bra.s   L_0035A4                              ; 0000359C 6006

L_00359E:
	move.b  (A3)+,-(A7)                           ; 0000359E 1F1B
	move.w  (A7)+,D0                              ; 000035A0 301F
	move.b  (A3)+,D0                              ; 000035A2 101B

L_0035A4:
	move.w  D0,($4a,A5)                           ; 000035A4 3B40 004A

L_0035A8:
	move.w  ($5c,A5),D0                           ; 000035A8 302D 005C
	sub.w   D0,D5                                 ; 000035AC 9A40
	sub.w   D0,($4,A5)                            ; 000035AE 916D 0004
	bsr.s   L_0035C2                              ; 000035B2 610E
	add.w   D0,D5                                 ; 000035B4 DA40
	add.w   D0,($4,A5)                            ; 000035B6 D16D 0004
	move.w  D0,($5c,A5)                           ; 000035BA 3B40 005C
	bra.w   L_002F92                              ; 000035BE 6000 F9D2

L_0035C2:
	tst.b   D6                                    ; 000035C2 4A06
	bmi.s   L_0035D8                              ; 000035C4 6B12
	moveq   #$0,D0                                ; 000035C6 7000
	move.b  ($2d,A5),D0                           ; 000035C8 102D 002D
	muls.w  ($24,A5),D0                           ; 000035CC C1ED 0024
	asr.l   #7,D0                                 ; 000035D0 EE80
	add.w   ($4a,A5),D0                           ; 000035D2 D06D 004A
	rts                                           ; 000035D6 4E75

L_0035D8:
	moveq   #$0,D0                                ; 000035D8 7000
	move.b  ($2d,A5),D0                           ; 000035DA 102D 002D
	move.w  D0,-(A7)                              ; 000035DE 3F00
	move.w  ($4a,A5),D0                           ; 000035E0 302D 004A
	ext.l   D0                                    ; 000035E4 48C0
	asl.l   #7,D0                                 ; 000035E6 EF80
	divs.w  (A7)+,D0                              ; 000035E8 81DF
	add.w   ($24,A5),D0                           ; 000035EA D06D 0024
	rts                                           ; 000035EE 4E75

L_0035F0:
	move.b  (A3)+,-(A7)                           ; 000035F0 1F1B
	move.w  (A7)+,D1                              ; 000035F2 321F
	move.b  (A3)+,D1                              ; 000035F4 121B
	bsr.w   L_003E50                              ; 000035F6 6100 0858
	tst.w   D0                                    ; 000035FA 4A40
	beq.s   L_00364E                              ; 000035FC 6750
	ext.l   D1                                    ; 000035FE 48C1
	beq.s   L_00364E                              ; 00003600 674C
	smi     D3                                    ; 00003602 5BC3
	bpl.s   L_003608                              ; 00003604 6A02
	neg.l   D1                                    ; 00003606 4481

L_003608:
	tst.b   D6                                    ; 00003608 4A06
	bpl.s   L_003618                              ; 0000360A 6A0C
	moveq   #$0,D2                                ; 0000360C 7400
	move.b  ($2d,A5),D2                           ; 0000360E 142D 002D
	asl.l   #7,D1                                 ; 00003612 EF81
	divu.w  D2,D1                                 ; 00003614 82C2
	ext.l   D1                                    ; 00003616 48C1

L_003618:
	divu.w  D0,D1                                 ; 00003618 82C0
	move.l  D1,D2                                 ; 0000361A 2401
	clr.w   D1                                    ; 0000361C 4241
	divu.w  D0,D1                                 ; 0000361E 82C0
	swap    D2                                    ; 00003620 4842
	move.w  D1,D2                                 ; 00003622 3401
	tst.b   D3                                    ; 00003624 4A03
	beq.s   L_00362A                              ; 00003626 6702
	neg.l   D2                                    ; 00003628 4482

L_00362A:
	move.l  D2,($d4,A5)                           ; 0000362A 2B42 00D4
	move.w  ($d8,A5),D1                           ; 0000362E 322D 00D8
	sub.w   D1,D5                                 ; 00003632 9A41
	sub.w   D1,($4,A5)                            ; 00003634 936D 0004
	move.w  D0,($d2,A5)                           ; 00003638 3B40 00D2
	moveq   #$0,D0                                ; 0000363C 7000
	move.l  D0,($d8,A5)                           ; 0000363E 2B40 00D8
	ori.w   #$2000,($8,A5)                        ; 00003642 006D 2000 0008
	ori.w   #$2000,($52,A5)                       ; 00003648 006D 2000 0052

L_00364E:
	bra.w   L_002F92                              ; 0000364E 6000 F942

L_003652:
	move.b  (A3)+,D0                              ; 00003652 101B
	bmi.s   L_00365E                              ; 00003654 6B08
	move.b  D0,($b6,A5)                           ; 00003656 1B40 00B6
	bra.w   L_002F92                              ; 0000365A 6000 F936

L_00365E:
	lsr.b   #1,D0                                 ; 0000365E E208
	bcs.s   L_003678                              ; 00003660 6516
	moveq   #$7f,D1                               ; 00003662 727F
	and.b   D1,($52,A5)                           ; 00003664 C32D 0052
	and.b   D1,($8,A5)                            ; 00003668 C32D 0008
	sub.w   ($8a,A5),D5                           ; 0000366C 9A6D 008A
	clr.l   ($8a,A5)                              ; 00003670 42AD 008A
	bra.w   L_002F92                              ; 00003674 6000 F91C

L_003678:
	move.w  ($92,A5),($84,A5)                     ; 00003678 3B6D 0092 0084
	move.l  ($8e,A5),($86,A5)                     ; 0000367E 2B6D 008E 0086
	sub.w   ($8a,A5),D5                           ; 00003684 9A6D 008A
	clr.l   ($8a,A5)                              ; 00003688 42AD 008A
	ori.w   #$8000,($8,A5)                        ; 0000368C 006D 8000 0008
	ori.w   #$8000,($52,A5)                       ; 00003692 006D 8000 0052
	bra.w   L_002F92                              ; 00003698 6000 F8F8

L_00369C:
	bsr.w   L_003E50                              ; 0000369C 6100 07B2
	move.w  D0,($96,A5)                           ; 000036A0 3B40 0096
	cmpi.b  #-$3e,(A3)+                           ; 000036A4 0C1B 00C2
	beq.s   L_0036B2                              ; 000036A8 6708
	subq.l  #1,A3                                 ; 000036AA 538B
	bsr.s   L_0036CC                              ; 000036AC 611E
	bra.w   L_002F92                              ; 000036AE 6000 F8E2

L_0036B2:
	move.b  (A3)+,-(A7)                           ; 000036B2 1F1B
	move.w  (A7)+,D0                              ; 000036B4 301F
	move.b  (A3)+,D0                              ; 000036B6 101B
	move.w  D0,($98,A5)                           ; 000036B8 3B40 0098
	bsr.s   L_0036CC                              ; 000036BC 610E
	bra.s   L_003678                              ; 000036BE 60B8

L_0036C0:
	bsr.w   L_003E50                              ; 000036C0 6100 078E
	move.w  D0,($ba,A5)                           ; 000036C4 3B40 00BA
	bra.w   L_002F92                              ; 000036C8 6000 F8C8

L_0036CC:
	moveq   #$0,D0                                ; 000036CC 7000
	move.w  ($98,A5),D0                           ; 000036CE 302D 0098
	bpl.s   L_0036D6                              ; 000036D2 6A02
	neg.w   D0                                    ; 000036D4 4440

L_0036D6:
	tst.b   D6                                    ; 000036D6 4A06
	bpl.s   L_0036DE                              ; 000036D8 6A04
	bsr.w   L_0037CC                              ; 000036DA 6100 00F0

L_0036DE:
	moveq   #$0,D1                                ; 000036DE 7200
	move.b  ($b6,A5),D1                           ; 000036E0 122D 00B6
	add.w   D1,D1                                 ; 000036E4 D241
	move.w  L_0036EE(pc,D1.w),D1                  ; 000036E6 323B 1006
	jmp     L_0036EE(pc,D1.w)                     ; 000036EA 4EFB 1002

L_0036EE:
	dc.w    L_0036F6-L_0036EE                     ; 000036EE
	dc.w    L_003732-L_0036EE                     ; 000036F0
	dc.w    L_003762-L_0036EE                     ; 000036F2
	dc.w    L_00379E-L_0036EE                     ; 000036F4

L_0036F6:
	lea     L_00165A(pc),A0                       ; 000036F6 41FA DF62
	move.l  A0,($80,A5)                           ; 000036FA 2B48 0080
	move.l  D0,D2                                 ; 000036FE 2400
	move.w  ($96,A5),D1                           ; 00003700 322D 0096
	add.w   D1,D1                                 ; 00003704 D241
	divs.w  D1,D2                                 ; 00003706 85C1
	move.w  D2,D0                                 ; 00003708 3002
	swap    D0                                    ; 0000370A 4840
	clr.w   D2                                    ; 0000370C 4242
	divu.w  D1,D2                                 ; 0000370E 84C1
	move.w  D2,D0                                 ; 00003710 3002
	tst.b   ($98,A5)                              ; 00003712 4A2D 0098
	bpl.s   L_00371A                              ; 00003716 6A02
	neg.l   D0                                    ; 00003718 4480

L_00371A:
	move.l  D0,($8e,A5)                           ; 0000371A 2B40 008E
	move.l  D0,($86,A5)                           ; 0000371E 2B40 0086
	move.w  D1,($84,A5)                           ; 00003722 3B41 0084
	move.w  D1,($92,A5)                           ; 00003726 3B41 0092
	add.w   D1,D1                                 ; 0000372A D241
	move.w  D1,($94,A5)                           ; 0000372C 3B41 0094
	rts                                           ; 00003730 4E75

L_003732:
	lea     L_00167C(pc),A0                       ; 00003732 41FA DF48
	move.l  A0,($80,A5)                           ; 00003736 2B48 0080
	tst.w   ($98,A5)                              ; 0000373A 4A6D 0098
	bpl.s   L_003742                              ; 0000373E 6A02
	neg.w   D0                                    ; 00003740 4440

L_003742:
	swap    D0                                    ; 00003742 4840
	clr.w   D0                                    ; 00003744 4240
	move.l  D0,($8e,A5)                           ; 00003746 2B40 008E
	move.l  D0,($86,A5)                           ; 0000374A 2B40 0086
	move.w  ($96,A5),D1                           ; 0000374E 322D 0096
	add.w   D1,D1                                 ; 00003752 D241
	move.w  D1,($84,A5)                           ; 00003754 3B41 0084
	move.w  D1,($92,A5)                           ; 00003758 3B41 0092
	move.w  D1,($94,A5)                           ; 0000375C 3B41 0094
	rts                                           ; 00003760 4E75

L_003762:
	lea     L_001696(pc),A0                       ; 00003762 41FA DF32
	move.l  A0,($80,A5)                           ; 00003766 2B48 0080
	move.l  D0,D2                                 ; 0000376A 2400
	move.w  ($96,A5),D1                           ; 0000376C 322D 0096
	beq.s   L_00379C                              ; 00003770 672A
	divu.w  D1,D2                                 ; 00003772 84C1
	move.w  D2,D0                                 ; 00003774 3002
	swap    D0                                    ; 00003776 4840
	clr.w   D2                                    ; 00003778 4242
	divu.w  D1,D2                                 ; 0000377A 84C1
	move.w  D2,D0                                 ; 0000377C 3002
	tst.b   ($98,A5)                              ; 0000377E 4A2D 0098
	bpl.s   L_003786                              ; 00003782 6A02
	neg.l   D0                                    ; 00003784 4480

L_003786:
	move.l  D0,($8e,A5)                           ; 00003786 2B40 008E
	move.l  D0,($86,A5)                           ; 0000378A 2B40 0086
	move.w  D1,($84,A5)                           ; 0000378E 3B41 0084
	move.w  D1,($92,A5)                           ; 00003792 3B41 0092
	add.w   D1,D1                                 ; 00003796 D241
	move.w  D1,($94,A5)                           ; 00003798 3B41 0094

L_00379C:
	rts                                           ; 0000379C 4E75

L_00379E:
	lea     L_0016B6(pc),A0                       ; 0000379E 41FA DF16
	move.l  A0,($80,A5)                           ; 000037A2 2B48 0080
	tst.w   ($98,A5)                              ; 000037A6 4A6D 0098
	bpl.s   L_0037AE                              ; 000037AA 6A02
	neg.w   D0                                    ; 000037AC 4440

L_0037AE:
	swap    D0                                    ; 000037AE 4840
	clr.w   D0                                    ; 000037B0 4240
	move.l  D0,($8e,A5)                           ; 000037B2 2B40 008E
	move.l  D0,($86,A5)                           ; 000037B6 2B40 0086
	move.w  ($96,A5),D1                           ; 000037BA 322D 0096
	move.w  D1,($84,A5)                           ; 000037BE 3B41 0084
	move.w  D1,($92,A5)                           ; 000037C2 3B41 0092
	move.w  D1,($94,A5)                           ; 000037C6 3B41 0094
	rts                                           ; 000037CA 4E75

L_0037CC:
	ext.l   D0                                    ; 000037CC 48C0
	asl.l   #7,D0                                 ; 000037CE EF80
	moveq   #$0,D1                                ; 000037D0 7200
	move.b  ($2d,A5),D1                           ; 000037D2 122D 002D
	divs.w  D1,D0                                 ; 000037D6 81C1
	bvc.s   L_0037DC                              ; 000037D8 6802
	moveq   #$0,D0                                ; 000037DA 7000

L_0037DC:
	ext.l   D0                                    ; 000037DC 48C0
	rts                                           ; 000037DE 4E75

L_0037E0:
	move.b  (A3)+,D0                              ; 000037E0 101B
	bmi.s   L_0037EC                              ; 000037E2 6B08
	move.b  D0,($b7,A5)                           ; 000037E4 1B40 00B7
	bra.w   L_002F92                              ; 000037E8 6000 F7A8

L_0037EC:
	lsr.b   #1,D0                                 ; 000037EC E208
	bcs.s   L_003806                              ; 000037EE 6516
	moveq   #-$41,D1                              ; 000037F0 72BF
	and.b   D1,($52,A5)                           ; 000037F2 C32D 0052
	and.b   D1,($8,A5)                            ; 000037F6 C32D 0008
	sub.w   ($a4,A5),D4                           ; 000037FA 986D 00A4
	clr.w   ($a4,A5)                              ; 000037FE 426D 00A4
	bra.w   L_002F92                              ; 00003802 6000 F78E

L_003806:
	move.w  ($b0,A5),($9e,A5)                     ; 00003806 3B6D 00B0 009E
	move.l  ($a8,A5),($a0,A5)                     ; 0000380C 2B6D 00A8 00A0
	sub.w   ($a4,A5),D4                           ; 00003812 986D 00A4
	move.l  ($ac,A5),($a4,A5)                     ; 00003816 2B6D 00AC 00A4
	add.w   ($a4,A5),D4                           ; 0000381C D86D 00A4
	ori.w   #$4000,($8,A5)                        ; 00003820 006D 4000 0008
	ori.w   #$4000,($52,A5)                       ; 00003826 006D 4000 0052
	bra.w   L_002F92                              ; 0000382C 6000 F764

L_003830:
	bsr.w   L_003E50                              ; 00003830 6100 061E
	move.w  D0,($b2,A5)                           ; 00003834 3B40 00B2
	cmpi.b  #-$39,(A3)+                           ; 00003838 0C1B 00C7
	beq.s   L_003846                              ; 0000383C 6708
	subq.l  #1,A3                                 ; 0000383E 538B
	bsr.s   L_00385A                              ; 00003840 6118
	bra.w   L_002F92                              ; 00003842 6000 F74E

L_003846:
	move.b  (A3)+,($b4,A5)                        ; 00003846 1B5B 00B4
	bsr.s   L_00385A                              ; 0000384A 610E
	bra.s   L_003806                              ; 0000384C 60B8

L_00384E:
	bsr.w   L_003E50                              ; 0000384E 6100 0600
	move.w  D0,($bc,A5)                           ; 00003852 3B40 00BC
	bra.w   L_002F92                              ; 00003856 6000 F73A

L_00385A:
	lea     ($9a,A5),A1                           ; 0000385A 43ED 009A
	move.w  ($b2,A5),D1                           ; 0000385E 322D 00B2
	moveq   #$0,D0                                ; 00003862 7000
	move.b  ($b7,A5),D0                           ; 00003864 102D 00B7
	add.w   D0,D0                                 ; 00003868 D040
	move.w  L_003872(pc,D0.w),D0                  ; 0000386A 303B 0006
	jmp     L_003872(pc,D0.w)                     ; 0000386E 4EFB 0002

L_003872:
	dc.w    L_00387A-L_003872                     ; 00003872
	dc.w    L_0038C0-L_003872                     ; 00003874
	dc.w    L_0038EC-L_003872                     ; 00003876
	dc.w    L_003930-L_003872                     ; 00003878

L_00387A:
	lea     L_0016DA(pc),A0                       ; 0000387A 41FA DE5E
	move.l  A0,(A1)                               ; 0000387E 2288
	moveq   #$0,D2                                ; 00003880 7400
	move.b  ($b4,A5),D2                           ; 00003882 142D 00B4
	bpl.s   L_00388A                              ; 00003886 6A02
	neg.b   D2                                    ; 00003888 4402

L_00388A:
	add.w   D1,D1                                 ; 0000388A D241
	add.w   D1,D1                                 ; 0000388C D241
	move.l  D2,D0                                 ; 0000388E 2002
	divu.w  D1,D0                                 ; 00003890 80C1
	move.w  D0,D2                                 ; 00003892 3400
	swap    D2                                    ; 00003894 4842
	clr.w   D0                                    ; 00003896 4240
	divu.w  D1,D0                                 ; 00003898 80C1
	move.w  D0,D2                                 ; 0000389A 3400
	moveq   #$0,D0                                ; 0000389C 7000
	move.b  ($b4,A5),D0                           ; 0000389E 102D 00B4
	bmi.s   L_0038AA                              ; 000038A2 6B06
	moveq   #$0,D0                                ; 000038A4 7000
	neg.l   D2                                    ; 000038A6 4482
	bra.s   L_0038AE                              ; 000038A8 6004

L_0038AA:
	ext.w   D0                                    ; 000038AA 4880
	swap    D0                                    ; 000038AC 4840

L_0038AE:
	move.l  D2,($a8,A5)                           ; 000038AE 2B42 00A8
	move.l  D2,($a0,A5)                           ; 000038B2 2B42 00A0
	move.w  D1,($b0,A5)                           ; 000038B6 3B41 00B0
	move.l  D0,($ac,A5)                           ; 000038BA 2B40 00AC
	rts                                           ; 000038BE 4E75

L_0038C0:
	lea     L_0016FA(pc),A0                       ; 000038C0 41FA DE38
	move.l  A0,(A1)                               ; 000038C4 2288
	add.w   D1,D1                                 ; 000038C6 D241
	moveq   #$0,D2                                ; 000038C8 7400
	move.b  ($b4,A5),D2                           ; 000038CA 142D 00B4
	ext.w   D2                                    ; 000038CE 4882
	neg.w   D2                                    ; 000038D0 4442
	swap    D2                                    ; 000038D2 4842
	move.l  D2,($a8,A5)                           ; 000038D4 2B42 00A8
	move.l  D2,($a0,A5)                           ; 000038D8 2B42 00A0
	neg.l   D2                                    ; 000038DC 4482
	bmi.s   L_0038E2                              ; 000038DE 6B02
	moveq   #$0,D2                                ; 000038E0 7400

L_0038E2:
	move.l  D2,($ac,A5)                           ; 000038E2 2B42 00AC
	move.w  D1,($b0,A5)                           ; 000038E6 3B41 00B0
	rts                                           ; 000038EA 4E75

L_0038EC:
	lea     L_001718(pc),A0                       ; 000038EC 41FA DE2A
	move.l  A0,(A1)                               ; 000038F0 2288
	moveq   #$0,D2                                ; 000038F2 7400
	move.b  ($b4,A5),D2                           ; 000038F4 142D 00B4
	bpl.s   L_0038FC                              ; 000038F8 6A02
	neg.b   D2                                    ; 000038FA 4402

L_0038FC:
	add.w   D1,D1                                 ; 000038FC D241
	move.l  D2,D0                                 ; 000038FE 2002
	divu.w  D1,D0                                 ; 00003900 80C1
	move.w  D0,D2                                 ; 00003902 3400
	swap    D2                                    ; 00003904 4842
	clr.w   D0                                    ; 00003906 4240
	divu.w  D1,D0                                 ; 00003908 80C1
	move.w  D0,D2                                 ; 0000390A 3400
	moveq   #$0,D0                                ; 0000390C 7000
	move.b  ($b4,A5),D0                           ; 0000390E 102D 00B4
	bmi.s   L_00391A                              ; 00003912 6B06
	moveq   #$0,D0                                ; 00003914 7000
	neg.l   D2                                    ; 00003916 4482
	bra.s   L_00391E                              ; 00003918 6004

L_00391A:
	ext.w   D0                                    ; 0000391A 4880
	swap    D0                                    ; 0000391C 4840

L_00391E:
	move.l  D2,($a8,A5)                           ; 0000391E 2B42 00A8
	move.l  D2,($a0,A5)                           ; 00003922 2B42 00A0
	move.w  D1,($b0,A5)                           ; 00003926 3B41 00B0
	move.l  D0,($ac,A5)                           ; 0000392A 2B40 00AC
	rts                                           ; 0000392E 4E75

L_003930:
	lea     L_001736(pc),A0                       ; 00003930 41FA DE04
	move.l  A0,(A1)                               ; 00003934 2288
	move.w  ($b4,A5),D2                           ; 00003936 342D 00B4
	clr.b   D2                                    ; 0000393A 4202
	neg.w   D2                                    ; 0000393C 4442
	bpl.s   L_003944                              ; 0000393E 6A04
	moveq   #$0,D0                                ; 00003940 7000
	bra.s   L_00394A                              ; 00003942 6006

L_003944:
	move.w  D2,D0                                 ; 00003944 3002
	neg.w   D0                                    ; 00003946 4440
	moveq   #$0,D2                                ; 00003948 7400

L_00394A:
	move.w  D2,($a8,A5)                           ; 0000394A 3B42 00A8
	move.w  D2,($a0,A5)                           ; 0000394E 3B42 00A0
	move.w  D1,($b0,A5)                           ; 00003952 3B41 00B0
	move.w  D0,($ac,A5)                           ; 00003956 3B40 00AC
	rts                                           ; 0000395A 4E75

L_00395C:
	move.b  (A3)+,D0                              ; 0000395C 101B
	bclr    #$7,D0                                ; 0000395E 0880 0007
	bne.s   L_0039BE                              ; 00003962 665A
	st      (-$133,A6)                            ; 00003964 50EE FECD
	bclr    #$6,D0                                ; 00003968 0880 0006
	sne     ($72,A5)                              ; 0000396C 56ED 0072
	andi.b  #$2,($72,A5)                          ; 00003970 022D 0002 0072
	andi.b  #$3,D0                                ; 00003976 0200 0003
	move.b  D0,(-$137,A6)                         ; 0000397A 1D40 FEC9
	moveq   #$1b,D1                               ; 0000397E 721B
	ifnd __ATARI__
	move.b  ($9da).w,D2                           ; 00003980 1438 09DA
	else
	move.b  mcdrv_opm_1b,D2
	endif
	andi.b  #$c0,D2                               ; 00003984 0202 00C0
	or.b    D0,D2                                 ; 00003988 8400
	bsr.w   L_002BC0                              ; 0000398A 6100 F234
	ifnd __ATARI__
	move.b  D2,($9da).w                           ; 0000398E 11C2 09DA
	else
	move.b  D2,mcdrv_opm_1b
	endif
	move.b  (A3)+,D2                              ; 00003992 141B
	move.b  D2,(-$136,A6)                         ; 00003994 1D42 FECA
	moveq   #$18,D1                               ; 00003998 7218
	bsr.w   L_002BC0                              ; 0000399A 6100 F224
	move.b  (A3)+,D2                              ; 0000399E 141B
	move.b  D2,(-$135,A6)                         ; 000039A0 1D42 FECB
	moveq   #$19,D1                               ; 000039A4 7219
	bsr.w   L_002BC0                              ; 000039A6 6100 F218
	move.b  (A3)+,D2                              ; 000039AA 141B
	move.b  D2,(-$134,A6)                         ; 000039AC 1D42 FECC
	moveq   #$19,D1                               ; 000039B0 7219
	bsr.w   L_002BC0                              ; 000039B2 6100 F20C
	move.b  (A3)+,D0                              ; 000039B6 101B
	move.b  D0,($73,A5)                           ; 000039B8 1B40 0073
	bra.s   L_0039C6                              ; 000039BC 6008

L_0039BE:
	tst.b   D0                                    ; 000039BE 4A00
	sne     D0                                    ; 000039C0 56C0
	and.b   ($73,A5),D0                           ; 000039C2 C02D 0073

L_0039C6:
	move.b  D0,($2e,A5)                           ; 000039C6 1B40 002E
	moveq   #$38,D1                               ; 000039CA 7238
	or.b    D6,D1                                 ; 000039CC 8206
	move.b  D0,D2                                 ; 000039CE 1400
	bsr.w   L_002BC0                              ; 000039D0 6100 F1EE
	bra.w   L_002F92                              ; 000039D4 6000 F5BC

L_0039D8:
	move.b  (A3)+,D1                              ; 000039D8 121B
	move.b  (A3)+,D2                              ; 000039DA 141B
	cmpi.b  #$1b,D1                               ; 000039DC 0C01 001B
	bne.s   L_0039EE                              ; 000039E0 660C
	and.b   #$3,D2                                ; 000039E2 C43C 0003
	moveq   #-$40,D0                              ; 000039E6 70C0
	ifnd __ATARI__
	and.b   ($9da).w,D0                           ; 000039E8 C038 09DA
	else
	and.b   mcdrv_opm_1b,D0
	endif
	or.b    D0,D2                                 ; 000039EC 8400

L_0039EE:
	bsr.w   L_002BC0                              ; 000039EE 6100 F1D0
	bra.w   L_002F92                              ; 000039F2 6000 F59E

L_0039F6:
	move.b  (A3)+,D1                              ; 000039F6 121B
	move.b  D1,($ec,A5)                           ; 000039F8 1B41 00EC
	move.b  (A3)+,D2                              ; 000039FC 141B
	move.b  D2,($ed,A5)                           ; 000039FE 1B42 00ED
	sub.b   D1,D2                                 ; 00003A02 9401
	lsl.w   #8,D2                                 ; 00003A04 E14A
	ext.l   D2                                    ; 00003A06 48C2
	bsr.w   L_003E50                              ; 00003A08 6100 0446
	move.w  D0,($e8,A5)                           ; 00003A0C 3B40 00E8
	divs.w  D0,D2                                 ; 00003A10 85C0
	move.w  D2,($ee,A5)                           ; 00003A12 3B42 00EE

L_003A16:
	ori.w   #$800,($52,A5)                        ; 00003A16 006D 0800 0052
	ori.w   #$800,($8,A5)                         ; 00003A1C 006D 0800 0008
	bra.w   L_002F92                              ; 00003A22 6000 F56E

L_003A26:
	bsr.w   L_003E50                              ; 00003A26 6100 0428
	move.w  D0,($ea,A5)                           ; 00003A2A 3B40 00EA
	bra.w   L_002F92                              ; 00003A2E 6000 F562

L_003A32:
	move.b  (A3)+,D0                              ; 00003A32 101B
	bpl.s   L_003A5E                              ; 00003A34 6A28
	lsr.b   #1,D0                                 ; 00003A36 E208
	bcs.s   L_003A16                              ; 00003A38 65DC
	andi.w  #$f7ff,($52,A5)                       ; 00003A3A 026D F7FF 0052
	andi.w  #$f7ff,($8,A5)                        ; 00003A40 026D F7FF 0008
	move.b  ($f2,A5),D0                           ; 00003A46 102D 00F2
	cmp.b   ($2e,A5),D0                           ; 00003A4A B02D 002E
	beq.s   L_003A5A                              ; 00003A4E 670A
	move.b  D0,($2e,A5)                           ; 00003A50 1B40 002E
	ori.w   #$400,($10,A5)                        ; 00003A54 006D 0400 0010

L_003A5A:
	bra.w   L_002F92                              ; 00003A5A 6000 F536

L_003A5E:
	move.b  D0,($f2,A5)                           ; 00003A5E 1B40 00F2
	move.b  D0,($2e,A5)                           ; 00003A62 1B40 002E
	btst    #$3,($8,A6)                           ; 00003A66 082E 0003 0008
	bne.s   L_003A74                              ; 00003A6C 6606
	ori.w   #$400,($10,A5)                        ; 00003A6E 006D 0400 0010

L_003A74:
	bra.w   L_002F92                              ; 00003A74 6000 F51C

L_003A78:
	move.b  (A3)+,D0                              ; 00003A78 101B
	move.b  ($6b,A5),D1                           ; 00003A7A 122D 006B
	move.b  ($6c,A5),D2                           ; 00003A7E 142D 006C
	bsr.w   L_003B5C                              ; 00003A82 6100 00D8
	bra.s   L_003A8E                              ; 00003A86 6006

L_003A88:
	move.b  (A3)+,D0                              ; 00003A88 101B
	move.b  D0,($6c,A5)                           ; 00003A8A 1B40 006C

L_003A8E:
	move.b  D0,($6b,A5)                           ; 00003A8E 1B40 006B
	bpl.s   L_003A9C                              ; 00003A92 6A08
	andi.w  #$f,D0                                ; 00003A94 0240 000F
	move.b  L_003AA4(pc,D0.w),D0                  ; 00003A98 103B 000A

L_003A9C:
	move.b  D0,($6d,A5)                           ; 00003A9C 1B40 006D
	bra.w   L_002F92                              ; 00003AA0 6000 F4F0

L_003AA4:
	dc.b    $07,$0F,$17,$1F,$27,$2F,$37,$3F,$47,$4F,$57,$5F,$67,$6F,$77,$7F; 00003AA4

L_003AB4:
	move.b  (A3)+,D0                              ; 00003AB4 101B
	move.b  ($69,A5),D1                           ; 00003AB6 122D 0069
	move.b  ($6a,A5),D2                           ; 00003ABA 142D 006A
	bsr.w   L_003B5C                              ; 00003ABE 6100 009C
	bra.s   L_003ACA                              ; 00003AC2 6006

L_003AC4:
	move.b  (A3)+,D0                              ; 00003AC4 101B
	move.b  D0,($6a,A5)                           ; 00003AC6 1B40 006A

L_003ACA:
	move.b  D0,($69,A5)                           ; 00003ACA 1B40 0069
	move.b  D0,($2b,A5)                           ; 00003ACE 1B40 002B
	bsr.w   L_0013FC                              ; 00003AD2 6100 D928
	bra.w   L_002F92                              ; 00003AD6 6000 F4BA

L_003ADA:
	move.b  (A3)+,D0                              ; 00003ADA 101B
	move.b  ($67,A5),D1                           ; 00003ADC 122D 0067
	move.b  ($68,A5),D2                           ; 00003AE0 142D 0068
	bsr.s   L_003B5C                              ; 00003AE4 6176
	bra.s   L_003AFE                              ; 00003AE6 6016

L_003AE8:
	dc.b    'UWZ]_begjmoruwz}'                    ; 00003AE8

L_003AF8:
	move.b  (A3)+,D0                              ; 00003AF8 101B
	move.b  D0,($68,A5)                           ; 00003AFA 1B40 0068

L_003AFE:
	move.b  D0,($67,A5)                           ; 00003AFE 1B40 0067
	bpl.s   L_003B18                              ; 00003B02 6A14
	lea     L_003AE8(pc),A0                       ; 00003B04 41FA FFE2
	tst.b   D6                                    ; 00003B08 4A06
	bpl.s   L_003B10                              ; 00003B0A 6A04
	lea     L_003AA4(pc),A0                       ; 00003B0C 41FA FF96

L_003B10:
	andi.w  #$f,D0                                ; 00003B10 0240 000F
	move.b  (A0,D0.w),D0                          ; 00003B14 1030 0000

L_003B18:
	move.b  D0,($22,A5)                           ; 00003B18 1B40 0022
	sub.w   ($6,A5),D4                            ; 00003B1C 986D 0006
	bsr.w   L_000E2C                              ; 00003B20 6100 D30A
	add.w   ($6,A5),D4                            ; 00003B24 D86D 0006
	moveq   #$22,D0                               ; 00003B28 7022
	bsr.w   L_001534                              ; 00003B2A 6100 DA08
	bra.w   L_002F92                              ; 00003B2E 6000 F462

L_003B32:
	move.l  D1,-(A7)                              ; 00003B32 2F01
	lea     L_003B4C(pc),A0                       ; 00003B34 41FA 0016
	moveq   #-$10,D1                              ; 00003B38 72F0

L_003B3A:
	cmp.b   (A0)+,D0                              ; 00003B3A B018
	bcs.s   L_003B42                              ; 00003B3C 6504
	addq.w  #1,D1                                 ; 00003B3E 5241
	bcc.s   L_003B3A                              ; 00003B40 64F8

L_003B42:
	moveq   #$f,D0                                ; 00003B42 700F
	add.w   D1,D0                                 ; 00003B44 D041
	movem.l (A7)+,D1                              ; 00003B46 4CDF 0002
	rts                                           ; 00003B4A 4E75

L_003B4C:
	dc.b    'UWZ]_begjmoruwz}'                    ; 00003B4C

L_003B5C:
	ext.w   D0                                    ; 00003B5C 4880
	bne.s   L_003B64                              ; 00003B5E 6604
	move.b  D2,D0                                 ; 00003B60 1002
	bra.s   L_003BAA                              ; 00003B62 6046

L_003B64:
	ext.w   D1                                    ; 00003B64 4881
	bmi.s   L_003B78                              ; 00003B66 6B10
	add.w   D1,D0                                 ; 00003B68 D041
	bmi.s   L_003B74                              ; 00003B6A 6B08
	tst.b   D0                                    ; 00003B6C 4A00
	bpl.s   L_003B76                              ; 00003B6E 6A06
	moveq   #$7f,D0                               ; 00003B70 707F
	bra.s   L_003B76                              ; 00003B72 6002

L_003B74:
	moveq   #$0,D0                                ; 00003B74 7000

L_003B76:
	bra.s   L_003BAA                              ; 00003B76 6032

L_003B78:
	cmpi.b  #-$10,D1                              ; 00003B78 0C01 00F0
	bcc.s   L_003B94                              ; 00003B7C 6416
	moveq   #$f,D2                                ; 00003B7E 740F
	and.w   D2,D1                                 ; 00003B80 C242
	add.w   D1,D0                                 ; 00003B82 D041
	bmi.s   L_003B8E                              ; 00003B84 6B08
	cmp.w   D2,D0                                 ; 00003B86 B042
	bls.s   L_003B90                              ; 00003B88 6306
	moveq   #$f,D0                                ; 00003B8A 700F
	bra.s   L_003B90                              ; 00003B8C 6002

L_003B8E:
	moveq   #$0,D0                                ; 00003B8E 7000

L_003B90:
	tas     D0                                    ; 00003B90 4AC0
	bra.s   L_003BAA                              ; 00003B92 6016

L_003B94:
	moveq   #$3,D2                                ; 00003B94 7403
	and.w   D2,D1                                 ; 00003B96 C242
	add.w   D1,D0                                 ; 00003B98 D041
	bmi.s   L_003BA4                              ; 00003B9A 6B08
	cmp.w   D2,D0                                 ; 00003B9C B042
	bls.s   L_003BA6                              ; 00003B9E 6306
	moveq   #$3,D0                                ; 00003BA0 7003
	bra.s   L_003BA6                              ; 00003BA2 6002

L_003BA4:
	moveq   #$0,D0                                ; 00003BA4 7000

L_003BA6:
	ori.b   #$f0,D0                               ; 00003BA6 0000 00F0

L_003BAA:
	rts                                           ; 00003BAA 4E75

L_003BAC:
	move.b  (A3)+,D0                              ; 00003BAC 101B
	move.b  ($6f,A5),D1                           ; 00003BAE 122D 006F
	move.b  ($6e,A5),D2                           ; 00003BB2 142D 006E
	bsr.s   L_003B5C                              ; 00003BB6 61A4
	bra.s   L_003BC6                              ; 00003BB8 600C

L_003BBA:
	dc.b    $FF,$00,$7F,$40                       ; 00003BBA

L_003BBE:
	moveq   #$0,D0                                ; 00003BBE 7000
	move.b  (A3)+,D0                              ; 00003BC0 101B
	move.b  D0,($6e,A5)                           ; 00003BC2 1B40 006E

L_003BC6:
	move.b  D0,($6f,A5)                           ; 00003BC6 1B40 006F
	bpl.s   L_003BD8                              ; 00003BCA 6A0C
	andi.b  #$3,D0                                ; 00003BCC 0200 0003
	move.b  D0,($4d,A5)                           ; 00003BD0 1B40 004D
	move.b  L_003BBA(pc,D0.w),D0                  ; 00003BD4 103B 00E4

L_003BD8:
	move.b  D0,($23,A5)                           ; 00003BD8 1B40 0023
	cmpi.b  #$10,D6                               ; 00003BDC 0C06 0010
	bge.w   L_002F92                              ; 00003BE0 6C00 F3B0
	ori.b   #$40,($10,A5)                         ; 00003BE4 002D 0040 0010
	bra.w   L_002F92                              ; 00003BEA 6000 F3A6

L_003BEE:
	move.b  (A3)+,D0                              ; 00003BEE 101B
	move.b  D0,($4c,A5)                           ; 00003BF0 1B40 004C
	bra.w   L_002F92                              ; 00003BF4 6000 F39C

L_003BF8:
	move.b  (A3)+,D2                              ; 00003BF8 141B
	moveq   #$f,D1                                ; 00003BFA 720F
	tst.w   D6                                    ; 00003BFC 4A46
	bmi.w   L_002F92                              ; 00003BFE 6B00 F392
	bsr.w   L_002BC0                              ; 00003C02 6100 EFBC
	bra.w   L_002F92                              ; 00003C06 6000 F38A

L_003C0A:
	bclr    #$5,($60,A5)                          ; 00003C0A 08AD 0005 0060
	bne.s   L_003C28                              ; 00003C10 6616
	st      ($1,A5)                               ; 00003C12 50ED 0001
	move.w  #$1,($a,A5)                           ; 00003C16 3B7C 0001 000A
	clr.w   ($dc,A5)                              ; 00003C1C 426D 00DC
	clr.w   ($e0,A5)                              ; 00003C20 426D 00E0
	bra.w   L_0014F4                              ; 00003C24 6000 D8CE

L_003C28:
	sf      ($1,A5)                               ; 00003C28 51ED 0001
	bra.w   L_002F92                              ; 00003C2C 6000 F364

L_003C30:
	move.b  (A3)+,D0                              ; 00003C30 101B
	lsl.w   #8,D0                                 ; 00003C32 E148
	lea     (A6,D0.w),A0                          ; 00003C34 41F6 0000
	tst.b   ($1,A0)                               ; 00003C38 4A28 0001
	bne.s   L_003C44                              ; 00003C3C 6606
	bset    #$5,($60,A0)                          ; 00003C3E 08E8 0005 0060

L_003C44:
	sf      ($1,A0)                               ; 00003C44 51E8 0001
	bra.w   L_002F92                              ; 00003C48 6000 F348

L_003C4C:
	move.b  (A3)+,D0                              ; 00003C4C 101B
	cmpi.b  #$8,D0                                ; 00003C4E 0C00 0008
	bne.s   L_003C56                              ; 00003C52 6602
	moveq   #$0,D0                                ; 00003C54 7000

L_003C56:
	move.b  D0,($63,A5)                           ; 00003C56 1B40 0063
	move.b  D0,($64,A5)                           ; 00003C5A 1B40 0064
	bra.w   L_002F92                              ; 00003C5E 6000 F332

L_003C62:
	move.b  (A3)+,-(A7)                           ; 00003C62 1F1B
	move.w  (A7)+,D0                              ; 00003C64 301F
	move.b  (A3)+,D0                              ; 00003C66 101B
	tst.w   D0                                    ; 00003C68 4A40
	beq.s   L_003CC8                              ; 00003C6A 675C
	clr.w   ($28,A5)                              ; 00003C6C 426D 0028
	clr.b   ($2a,A5)                              ; 00003C70 422D 002A
	lea     (-$3a2,A6),A0                         ; 00003C74 41EE FC5E
	moveq   #$0,D1                                ; 00003C78 7200
	move.b  ($ff,A5),D1                           ; 00003C7A 122D 00FF
	moveq   #$7,D2                                ; 00003C7E 7407
	and.w   D1,D2                                 ; 00003C80 C441
	eor.w   D2,D1                                 ; 00003C82 B541
	eori.w  #$18,D1                               ; 00003C84 0A41 0018
	lsr.w   #3,D1                                 ; 00003C88 E649
	bclr    D2,(A0,D1.w)                          ; 00003C8A 05B0 1000
	move.l  (A0)+,D1                              ; 00003C8E 2218
	or.l    (A0)+,D1                              ; 00003C90 8298
	or.l    (A0)+,D1                              ; 00003C92 8298
	or.l    (A0)+,D1                              ; 00003C94 8298
	bne.s   L_003CC0                              ; 00003C96 6628
	move.w  D0,-(A7)                              ; 00003C98 3F00
	addq.w  #1,(-$6c,A6)                          ; 00003C9A 526E FF94
	movem.l (-$40,A6),D0-D3                       ; 00003C9E 4CEE 000F FFC0
	movem.l D0-D3,(-$3a2,A6)                      ; 00003CA4 48EE 000F FC5E
	move.l  (-$60,A6),(-$336,A6)                  ; 00003CAA 2D6E FFA0 FCCA
	move.w  (-$6c,A6),D1                          ; 00003CB0 322E FF94
	moveq   #$1,D0                                ; 00003CB4 7001
	bsr.w   L_00083A                              ; 00003CB6 6100 CB82
	move.w  (A7)+,D0                              ; 00003CBA 301F
	clr.l   (-$33c,A6)                            ; 00003CBC 42AE FCC4

L_003CC0:
	lea     (A3,D0.w),A3                          ; 00003CC0 47F3 0000
	bra.w   L_002F92                              ; 00003CC4 6000 F2CC

L_003CC8:
	bsr.w   L_001A42                              ; 00003CC8 6100 DD78
	lea     ($16,A5),A3                           ; 00003CCC 47ED 0016
	bra.w   L_0014EC                              ; 00003CD0 6000 D81A

L_003CD4:
	move.b  (A3)+,-(A7)                           ; 00003CD4 1F1B
	move.w  (A7)+,D0                              ; 00003CD6 301F
	move.b  (A3)+,D0                              ; 00003CD8 101B
	add.w   (-$3b4,A6),D0                         ; 00003CDA D06E FC4C
	bgt.s   L_003CE4                              ; 00003CDE 6E04
	moveq   #$1,D0                                ; 00003CE0 7001
	bra.s   L_003CFC                              ; 00003CE2 6018

L_003CE4:
	cmpi.w  #$1f4,D0                              ; 00003CE4 0C40 01F4
	bls.s   L_003CFC                              ; 00003CE8 6312
	move.w  #$1f4,D0                              ; 00003CEA 303C 01F4
	bra.s   L_003CFC                              ; 00003CEE 600C

L_003CF0:
	move.b  (A3)+,-(A7)                           ; 00003CF0 1F1B
	move.w  (A7)+,D0                              ; 00003CF2 301F
	move.b  (A3)+,D0                              ; 00003CF4 101B
	tst.w   D0                                    ; 00003CF6 4A40
	bne.s   L_003CFC                              ; 00003CF8 6602
	moveq   #$1,D0                                ; 00003CFA 7001

L_003CFC:
	move.w  D0,D3                                 ; 00003CFC 3600
	mulu.w  (-$68,A6),D0                          ; 00003CFE C0EE FF98
	tst.b   ($fe,A5)                              ; 00003D02 4A2D 00FE
	bmi.s   L_003D30                              ; 00003D06 6B28
	bsr.w   L_001B94                              ; 00003D08 6100 DE8A
	move.w  D3,(-$66,A6)                          ; 00003D0C 3D43 FF9A
	move.w  D3,(-$3b6,A6)                         ; 00003D10 3D43 FC4A
	move.w  D3,(-$3b4,A6)                         ; 00003D14 3D43 FC4C
	cmpi.w  #$100,(-$6a,A6)                       ; 00003D18 0C6E 0100 FF96
	beq.s   L_003D24                              ; 00003D1E 6704
	clr.w   (-$3b4,A6)                            ; 00003D20 426E FC4C

L_003D24:
	move.l  D0,(-$5c,A6)                          ; 00003D24 2D40 FFA4
	bsr.w   L_001B8C                              ; 00003D28 6100 DE62
	bra.w   L_002F92                              ; 00003D2C 6000 F264

L_003D30:
	bsr.w   L_001B94                              ; 00003D30 6100 DE62
	bsr.w   L_001BF2                              ; 00003D34 6100 DEBC
	bra.w   L_002F92                              ; 00003D38 6000 F258

L_003D3C:
	moveq   #$0,D0                                ; 00003D3C 7000
	move.b  (A3)+,D0                              ; 00003D3E 101B
	add.w   D0,D0                                 ; 00003D40 D040
	move.w  L_003D4A(pc,D0.w),D0                  ; 00003D42 303B 0006
	jmp     L_003D4A(pc,D0.w)                     ; 00003D46 4EFB 0002

L_003D4A:
	dc.w    L_003D56-L_003D4A                     ; 00003D4A
	dc.w    L_003D76-L_003D4A                     ; 00003D4C
	dc.w    L_003D96-L_003D4A                     ; 00003D4E
	dc.w    L_003D6C-L_003D4A                     ; 00003D50
	dc.w    L_003DAC-L_003D4A                     ; 00003D52
	dc.w    L_003DB0-L_003D4A                     ; 00003D54

L_003D56:
	move.b  (A3)+,-(A7)                           ; 00003D56 1F1B
	move.w  (A7)+,D0                              ; 00003D58 301F
	move.b  (A3)+,D0                              ; 00003D5A 101B
	bset    #$0,($60,A5)                          ; 00003D5C 08ED 0000 0060
	bne.w   L_002F92                              ; 00003D62 6600 F22E
	adda.w  D0,A3                                 ; 00003D66 D6C0
	bra.w   L_002F92                              ; 00003D68 6000 F228

L_003D6C:
	bset    #$2,($60,A5)                          ; 00003D6C 08ED 0002 0060
	bra.w   L_002F92                              ; 00003D72 6000 F21E

L_003D76:
	move.b  (A3)+,-(A7)                           ; 00003D76 1F1B
	move.w  (A7)+,D0                              ; 00003D78 301F
	move.b  (A3)+,D0                              ; 00003D7A 101B
	btst    #$2,($60,A5)                          ; 00003D7C 082D 0002 0060
	beq.w   L_002F92                              ; 00003D82 6700 F20E
	bset    #$1,($60,A5)                          ; 00003D86 08ED 0001 0060
	bne.w   L_002F92                              ; 00003D8C 6600 F204
	adda.w  D0,A3                                 ; 00003D90 D6C0
	bra.w   L_002F92                              ; 00003D92 6000 F1FE

L_003D96:
	move.b  (A3)+,-(A7)                           ; 00003D96 1F1B
	move.w  (A7)+,D0                              ; 00003D98 301F
	move.b  (A3)+,D0                              ; 00003D9A 101B
	bset    #$3,($60,A5)                          ; 00003D9C 08ED 0003 0060
	beq.w   L_002F92                              ; 00003DA2 6700 F1EE
	adda.w  D0,A3                                 ; 00003DA6 D6C0
	bra.w   L_002F92                              ; 00003DA8 6000 F1E8

L_003DAC:
	bra.w   L_002F92                              ; 00003DAC 6000 F1E4

L_003DB0:
	moveq   #$3,D0                                ; 00003DB0 7003
	and.b   ($60,A5),D0                           ; 00003DB2 C02D 0060
	beq.w   L_002F92                              ; 00003DB6 6700 F1DA
	bsr.w   L_001A42                              ; 00003DBA 6100 DC86
	bra.w   L_002F92                              ; 00003DBE 6000 F1D2

L_003DC2:
	moveq   #$0,D0                                ; 00003DC2 7000
	move.b  (A3)+,D0                              ; 00003DC4 101B
	move.l  A3,(-$38a,A6)                         ; 00003DC6 2D4B FC76
	adda.l  D0,A3                                 ; 00003DCA D7C0
	bra.w   L_002F92                              ; 00003DCC 6000 F1C4

L_003DD0:
	bsr.w   L_00257C                              ; 00003DD0 6100 E7AA
	move.b  (A3)+,D6                              ; 00003DD4 1C1B
	move.b  D6,($3,A5)                            ; 00003DD6 1B46 0003
	bsr.w   L_0024F6                              ; 00003DDA 6100 E71A
	bra.w   L_002F92                              ; 00003DDE 6000 F1B2

L_003DE2:
	move.b  (A3)+,D0                              ; 00003DE2 101B
	bne.s   L_003DF2                              ; 00003DE4 660C
	move.b  (A3),($20,A5)                         ; 00003DE6 1B53 0020
	moveq   #$20,D0                               ; 00003DEA 7020
	bsr.w   L_001534                              ; 00003DEC 6100 D746
	bra.s   L_003E30                              ; 00003DF0 603E

L_003DF2:
	cmpi.b  #$1,D0                                ; 00003DF2 0C00 0001
	bne.s   L_003DFC                              ; 00003DF6 6604
	bra.w   L_003A32                              ; 00003DF8 6000 FC38

L_003DFC:
	cmpi.b  #$20,D0                               ; 00003DFC 0C00 0020
	bne.s   L_003E0E                              ; 00003E00 660C
	move.b  (A3),($2c,A5)                         ; 00003E02 1B53 002C
	moveq   #$2c,D0                               ; 00003E06 702C
	bsr.w   L_001534                              ; 00003E08 6100 D72A
	bra.s   L_003E30                              ; 00003E0C 6022

L_003E0E:
	cmpi.b  #$5b,D0                               ; 00003E0E 0C00 005B
	bne.s   L_003E20                              ; 00003E12 660C
	move.b  (A3),($26,A5)                         ; 00003E14 1B53 0026
	moveq   #$26,D0                               ; 00003E18 7026
	bsr.w   L_001534                              ; 00003E1A 6100 D718
	bra.s   L_003E30                              ; 00003E1E 6010

L_003E20:
	cmpi.b  #$5d,D0                               ; 00003E20 0C00 005D
	bne.s   L_003E30                              ; 00003E24 660A
	move.b  (A3),($27,A5)                         ; 00003E26 1B53 0027
	moveq   #$27,D0                               ; 00003E2A 7027
	bsr.w   L_001534                              ; 00003E2C 6100 D706

L_003E30:
	move.b  (-$1,A3),D1                           ; 00003E30 122B FFFF
	move.b  (A3)+,D2                              ; 00003E34 141B
	bsr.w   L_0013E2                              ; 00003E36 6100 D5AA
	bra.w   L_002F92                              ; 00003E3A 6000 F156

L_003E3E:
	bsr.s   L_003E50                              ; 00003E3E 6110
	movea.l A3,A0                                 ; 00003E40 204B
	adda.l  D0,A3                                 ; 00003E42 D7C0
	subq.w  #1,D0                                 ; 00003E44 5340
	bcs.s   L_003E4C                              ; 00003E46 6504
	bsr.w   L_0005A6                              ; 00003E48 6100 C75C

L_003E4C:
	bra.w   L_002F92                              ; 00003E4C 6000 F144

L_003E50:
	move.w  D1,-(A7)                              ; 00003E50 3F01
	moveq   #$0,D0                                ; 00003E52 7000

L_003E54:
	move.b  (A3)+,D1                              ; 00003E54 121B
	bpl.s   L_003E62                              ; 00003E56 6A0A
	and.b   #$7f,D1                               ; 00003E58 C23C 007F
	or.b    D1,D0                                 ; 00003E5C 8001
	lsl.l   #7,D0                                 ; 00003E5E EF88
	bra.s   L_003E54                              ; 00003E60 60F2

L_003E62:
	or.b    D1,D0                                 ; 00003E62 8001
	move.w  (A7)+,D1                              ; 00003E64 321F
	rts                                           ; 00003E66 4E75

L_003E68:
	movem.l D1/A0-A1/A6,-(A7)                     ; 00003E68 48E7 40C2
	lea     L_005E88(pc),A6                       ; 00003E6C 4DFA 201A
	movea.l (-$32e,A6),A0                         ; 00003E70 206E FCD2
	btst    #$0,D1                                ; 00003E74 0801 0000
	beq.s   L_003E7C                              ; 00003E78 6702
	addq.l  #1,D1                                 ; 00003E7A 5281

L_003E7C:
	tst.b   ($d,A0)                               ; 00003E7C 4A28 000D
	bne.s   L_003E88                              ; 00003E80 6606
	cmp.l   ($8,A0),D1                            ; 00003E82 B2A8 0008
	bls.s   L_003E92                              ; 00003E86 630A

L_003E88:
	move.l  ($4,A0),D0                            ; 00003E88 2028 0004
	beq.s   L_003ECE                              ; 00003E8C 6740
	movea.l D0,A0                                 ; 00003E8E 2040
	bra.s   L_003E7C                              ; 00003E90 60EA

L_003E92:
	lea     ($10,A0,D1.l),A1                      ; 00003E92 43F0 1810
	moveq   #-$10,D0                              ; 00003E96 70F0
	add.l   ($8,A0),D0                            ; 00003E98 D0A8 0008
	sub.l   D1,D0                                 ; 00003E9C 9081
	bcs.s   L_003EC4                              ; 00003E9E 6524
	move.l  D0,($8,A1)                            ; 00003EA0 2340 0008
	move.l  D1,($8,A0)                            ; 00003EA4 2141 0008
	moveq   #$0,D0                                ; 00003EA8 7000
	move.l  D0,($c,A1)                            ; 00003EAA 2340 000C
	move.l  ($4,A0),D0                            ; 00003EAE 2028 0004
	move.l  A1,($4,A0)                            ; 00003EB2 2149 0004
	move.l  A0,(A1)                               ; 00003EB6 2288
	move.l  D0,($4,A1)                            ; 00003EB8 2340 0004
	beq.s   L_003EC4                              ; 00003EBC 6706
	exg     D0,A0                                 ; 00003EBE C188
	move.l  A1,(A0)                               ; 00003EC0 2089
	movea.l D0,A0                                 ; 00003EC2 2040

L_003EC4:
	clr.l   ($c,A0)                               ; 00003EC4 42A8 000C
	moveq   #$10,D0                               ; 00003EC8 7010
	add.l   A0,D0                                 ; 00003ECA D088
	bra.s   L_003ED4                              ; 00003ECC 6006

L_003ECE:
	bsr.s   L_003EDA                              ; 00003ECE 610A
	bpl.s   L_003ED4                              ; 00003ED0 6A02
	moveq   #-$1,D0                               ; 00003ED2 70FF

L_003ED4:
	movem.l (A7)+,D1/A0-A1/A6                     ; 00003ED4 4CDF 4302
	rts                                           ; 00003ED8 4E75

L_003EDA:
	movem.l D1-D2/A0-A1,-(A7)                     ; 00003EDA 48E7 60C0
	pea     L_000000-$F0(pc)                      ; 00003EDE 487A C030
	bsr.s   L_003F10                              ; 00003EE2 612C
	move.l  D0,(A7)                               ; 00003EE4 2E80
	moveq   #$10,D0                               ; 00003EE6 7010
	add.l   D0,D1                                 ; 00003EE8 D280
	move.l  D1,-(A7)                              ; 00003EEA 2F01
	dc.w    $ff48                                 ; 00003EEC FF48
	addq.l  #4,A7                                 ; 00003EEE 588F
	movea.l D0,A0                                 ; 00003EF0 2040
	tst.l   D0                                    ; 00003EF2 4A80
	bmi.s   L_003F04                              ; 00003EF4 6B0E
	bsr.w   L_00405C                              ; 00003EF6 6100 0164
	move.w  #$10,($c,A0)                          ; 00003EFA 317C 0010 000C
	lea     ($10,A0),A0                           ; 00003F00 41E8 0010

L_003F04:
	bsr.s   L_003F10                              ; 00003F04 610A
	addq.l  #4,A7                                 ; 00003F06 588F
	move.l  A0,D0                                 ; 00003F08 2008
	movem.l (A7)+,D1-D2/A0-A1                     ; 00003F0A 4CDF 0306
	rts                                           ; 00003F0E 4E75

L_003F10:
	move.l  ($4,A7),-(A7)                         ; 00003F10 2F2F 0004
	dc.w    $ff30                                 ; 00003F14 FF30
	cmp.w   #$300,D0                              ; 00003F16 B07C 0300
	bcc.s   L_003F22                              ; 00003F1A 6406
	dc.w    $ff50                                 ; 00003F1C FF50
	addq.l  #4,A7                                 ; 00003F1E 588F
	rts                                           ; 00003F20 4E75

L_003F22:
	dc.w    $ff80                                 ; 00003F22 FF80
	addq.l  #4,A7                                 ; 00003F24 588F
	rts                                           ; 00003F26 4E75

L_003F28:
	movem.l D1/A0-A1/A6,-(A7)                     ; 00003F28 48E7 40C2
	lea     L_005E88(pc),A6                       ; 00003F2C 4DFA 1F5A
	movea.l (-$32e,A6),A0                         ; 00003F30 206E FCD2

L_003F34:
	move.l  ($4,A0),D0                            ; 00003F34 2028 0004
	beq.s   L_003F3E                              ; 00003F38 6704
	movea.l D0,A0                                 ; 00003F3A 2040
	bra.s   L_003F34                              ; 00003F3C 60F6

L_003F3E:
	btst    #$0,D1                                ; 00003F3E 0801 0000
	beq.s   L_003F46                              ; 00003F42 6702
	addq.l  #1,D1                                 ; 00003F44 5281

L_003F46:
	tst.b   ($d,A0)                               ; 00003F46 4A28 000D
	bne.s   L_003F52                              ; 00003F4A 6606
	cmp.l   ($8,A0),D1                            ; 00003F4C B2A8 0008
	bls.s   L_003F5A                              ; 00003F50 6308

L_003F52:
	move.l  (A0),D0                               ; 00003F52 2010
	beq.s   L_003F92                              ; 00003F54 673C
	movea.l D0,A0                                 ; 00003F56 2040
	bra.s   L_003F46                              ; 00003F58 60EC

L_003F5A:
	movea.l A0,A1                                 ; 00003F5A 2248
	adda.l  ($8,A0),A1                            ; 00003F5C D3E8 0008
	suba.l  D1,A1                                 ; 00003F60 93C1
	moveq   #-$10,D0                              ; 00003F62 70F0
	add.l   A1,D0                                 ; 00003F64 D089
	sub.l   A0,D0                                 ; 00003F66 9088
	bcs.s   L_003F88                              ; 00003F68 651E
	move.l  D0,($8,A0)                            ; 00003F6A 2140 0008
	move.l  D1,($8,A1)                            ; 00003F6E 2341 0008
	move.l  ($4,A0),D0                            ; 00003F72 2028 0004
	move.l  A1,($4,A0)                            ; 00003F76 2149 0004
	move.l  A0,(A1)                               ; 00003F7A 2288
	move.l  D0,($4,A1)                            ; 00003F7C 2340 0004
	beq.s   L_003F86                              ; 00003F80 6704
	movea.l D0,A0                                 ; 00003F82 2040
	move.l  A1,(A0)                               ; 00003F84 2089

L_003F86:
	movea.l A1,A0                                 ; 00003F86 2049

L_003F88:
	clr.l   ($c,A0)                               ; 00003F88 42A8 000C
	moveq   #$10,D0                               ; 00003F8C 7010
	add.l   A0,D0                                 ; 00003F8E D088
	bra.s   L_003F9A                              ; 00003F90 6008

L_003F92:
	bsr.w   L_003EDA                              ; 00003F92 6100 FF46
	bpl.s   L_003F9A                              ; 00003F96 6A02
	moveq   #-$1,D0                               ; 00003F98 70FF

L_003F9A:
	movem.l (A7)+,D1/A0-A1/A6                     ; 00003F9A 4CDF 4302
	rts                                           ; 00003F9E 4E75

L_003FA0:
	movem.l D1/A0-A1/A6,-(A7)                     ; 00003FA0 48E7 40C2
	lea     L_005E88(pc),A6                       ; 00003FA4 4DFA 1EE2
	movea.w #$fff0,A0                             ; 00003FA8 307C FFF0
	adda.l  D1,A0                                 ; 00003FAC D1C1
	tst.b   ($c,A0)                               ; 00003FAE 4A28 000C
	bne.w   L_004054                              ; 00003FB2 6600 00A0
	moveq   #$0,D1                                ; 00003FB6 7200
	move.l  (A0),D0                               ; 00003FB8 2010
	beq.s   L_003FC6                              ; 00003FBA 670A
	movea.l D0,A1                                 ; 00003FBC 2240
	cmpa.l  ($4,A1),A0                            ; 00003FBE B1E9 0004
	bne.w   L_004054                              ; 00003FC2 6600 0090

L_003FC6:
	move.l  ($4,A0),D0                            ; 00003FC6 2028 0004
	beq.s   L_003FD4                              ; 00003FCA 6708
	movea.l D0,A1                                 ; 00003FCC 2240
	cmpa.l  (A1),A0                               ; 00003FCE B1D1
	bne.w   L_004054                              ; 00003FD0 6600 0082

L_003FD4:
	btst    #$4,($d,A0)                           ; 00003FD4 0828 0004 000D
	beq.s   L_003FE8                              ; 00003FDA 670C
	bsr.w   L_0040B8                              ; 00003FDC 6100 00DA
	pea     (A0)                                  ; 00003FE0 4850
	dc.w    $ff49                                 ; 00003FE2 FF49
	addq.l  #4,A7                                 ; 00003FE4 588F
	bra.s   L_004050                              ; 00003FE6 6068

L_003FE8:
	clr.b   ($d,A0)                               ; 00003FE8 4228 000D
	move.l  (A0),D0                               ; 00003FEC 2010
	beq.s   L_00401E                              ; 00003FEE 672E
	movea.l D0,A1                                 ; 00003FF0 2240
	tst.b   ($d,A1)                               ; 00003FF2 4A29 000D
	bne.s   L_00401E                              ; 00003FF6 6626
	moveq   #$10,D0                               ; 00003FF8 7010
	add.l   ($8,A1),D0                            ; 00003FFA D0A9 0008
	add.l   A1,D0                                 ; 00003FFE D089
	cmpa.l  D0,A0                                 ; 00004000 B1C0
	bne.s   L_00401E                              ; 00004002 661A
	moveq   #$10,D0                               ; 00004004 7010
	add.l   ($8,A0),D0                            ; 00004006 D0A8 0008
	add.l   D0,($8,A1)                            ; 0000400A D1A9 0008
	movea.l ($4,A0),A0                            ; 0000400E 2068 0004
	move.l  A0,($4,A1)                            ; 00004012 2348 0004
	move.l  A0,D0                                 ; 00004016 2008
	beq.s   L_00401C                              ; 00004018 6702
	move.l  A1,(A0)                               ; 0000401A 2089

L_00401C:
	movea.l A1,A0                                 ; 0000401C 2049

L_00401E:
	move.l  ($4,A0),D0                            ; 0000401E 2028 0004
	beq.s   L_004050                              ; 00004022 672C
	movea.l D0,A1                                 ; 00004024 2240
	tst.b   ($d,A1)                               ; 00004026 4A29 000D
	bne.s   L_004050                              ; 0000402A 6624
	moveq   #$10,D0                               ; 0000402C 7010
	add.l   ($8,A0),D0                            ; 0000402E D0A8 0008
	add.l   A0,D0                                 ; 00004032 D088
	cmpa.l  D0,A1                                 ; 00004034 B3C0
	bne.s   L_004050                              ; 00004036 6618
	moveq   #$10,D0                               ; 00004038 7010
	add.l   ($8,A1),D0                            ; 0000403A D0A9 0008
	add.l   D0,($8,A0)                            ; 0000403E D1A8 0008
	movea.l ($4,A1),A1                            ; 00004042 2269 0004
	move.l  A1,($4,A0)                            ; 00004046 2149 0004
	move.l  A1,D0                                 ; 0000404A 2009
	beq.s   L_004050                              ; 0000404C 6702
	move.l  A0,(A1)                               ; 0000404E 2288

L_004050:
	moveq   #$0,D0                                ; 00004050 7000
	bra.s   L_004056                              ; 00004052 6002

L_004054:
	moveq   #-$1,D0                               ; 00004054 70FF

L_004056:
	movem.l (A7)+,D1/A0-A1/A6                     ; 00004056 4CDF 4302
	rts                                           ; 0000405A 4E75

L_00405C:
	movem.l D1-D7/A0-A6,-(A7)                     ; 0000405C 48E7 7FFE
	lea     L_005E88(pc),A6                       ; 00004060 4DFA 1E26
	moveq   #$10,D0                               ; 00004064 7010
	sub.l   D0,D1                                 ; 00004066 9280
	bls.s   L_0040B0                              ; 00004068 6346
	clr.l   (A0)+                                 ; 0000406A 4298
	clr.l   (A0)+                                 ; 0000406C 4298
	move.l  D1,(A0)+                              ; 0000406E 20C1
	clr.l   (A0)+                                 ; 00004070 4298
	suba.l  D0,A0                                 ; 00004072 91C0
	movea.l (-$32e,A6),A1                         ; 00004074 226E FCD2
	cmpa.l  A1,A0                                 ; 00004078 B1C9
	bhi.s   L_004088                              ; 0000407A 620C
	move.l  A0,(-$32e,A6)                         ; 0000407C 2D48 FCD2
	move.l  A1,($4,A0)                            ; 00004080 2149 0004
	move.l  A0,(A1)                               ; 00004084 2288
	bra.s   L_0040AC                              ; 00004086 6024

L_004088:
	move.l  ($4,A1),D0                            ; 00004088 2029 0004
	beq.s   L_004096                              ; 0000408C 6708
	cmpa.l  D0,A0                                 ; 0000408E B1C0
	bls.s   L_00409E                              ; 00004090 630C
	movea.l D0,A1                                 ; 00004092 2240
	bra.s   L_004088                              ; 00004094 60F2

L_004096:
	move.l  A0,($4,A1)                            ; 00004096 2348 0004
	move.l  A1,(A0)                               ; 0000409A 2089
	bra.s   L_0040AC                              ; 0000409C 600E

L_00409E:
	move.l  D0,($4,A0)                            ; 0000409E 2140 0004
	move.l  A1,(A0)                               ; 000040A2 2089
	move.l  A0,($4,A1)                            ; 000040A4 2348 0004
	movea.l D0,A1                                 ; 000040A8 2240
	move.l  A0,(A1)                               ; 000040AA 2288

L_0040AC:
	moveq   #$0,D0                                ; 000040AC 7000
	bra.s   L_0040B2                              ; 000040AE 6002

L_0040B0:
	moveq   #-$1,D0                               ; 000040B0 70FF

L_0040B2:
	movem.l (A7)+,D1-D7/A0-A6                     ; 000040B2 4CDF 7FFE
	rts                                           ; 000040B6 4E75

L_0040B8:
	movem.l D1-D7/A0-A6,-(A7)                     ; 000040B8 48E7 7FFE
	lea     L_005E88(pc),A6                       ; 000040BC 4DFA 1DCA
	movea.l (-$32e,A6),A1                         ; 000040C0 226E FCD2
	cmpa.l  A1,A0                                 ; 000040C4 B1C9
	bne.s   L_0040D8                              ; 000040C6 6610
	move.l  ($4,A0),D0                            ; 000040C8 2028 0004
	beq.s   L_0040FE                              ; 000040CC 6730
	movea.l D0,A1                                 ; 000040CE 2240
	move.l  A1,(-$32e,A6)                         ; 000040D0 2D49 FCD2
	clr.l   (A1)                                  ; 000040D4 4291
	bra.s   L_0040FA                              ; 000040D6 6022

L_0040D8:
	move.l  ($4,A1),D0                            ; 000040D8 2029 0004
	beq.s   L_0040FE                              ; 000040DC 6720
	movea.l D0,A1                                 ; 000040DE 2240
	cmpa.l  A1,A0                                 ; 000040E0 B1C9
	bne.s   L_0040D8                              ; 000040E2 66F4
	move.l  (A0),D0                               ; 000040E4 2010
	beq.s   L_0040F0                              ; 000040E6 6708
	movea.l D0,A1                                 ; 000040E8 2240
	move.l  ($4,A0),($4,A1)                       ; 000040EA 2368 0004 0004

L_0040F0:
	move.l  ($4,A0),D0                            ; 000040F0 2028 0004
	beq.s   L_0040FA                              ; 000040F4 6704
	movea.l D0,A1                                 ; 000040F6 2240
	move.l  (A0),(A1)                             ; 000040F8 2290

L_0040FA:
	moveq   #$0,D0                                ; 000040FA 7000
	bra.s   L_004100                              ; 000040FC 6002

L_0040FE:
	moveq   #-$1,D0                               ; 000040FE 70FF

L_004100:
	movem.l (A7)+,D1-D7/A0-A6                     ; 00004100 4CDF 7FFE
	rts                                           ; 00004104 4E75

L_004106:
	movem.l D0/A0-A2/A6,-(A7)                     ; 00004106 48E7 80E2
	lea     L_005E88(pc),A6                       ; 0000410A 4DFA 1D7C
	move.l  ($1a8).w,(-$180,A6)                   ; 0000410E 2D78 01A8 FE80
	move.l  ($1ac).w,(-$178,A6)                   ; 00004114 2D78 01AC FE88
	lea     L_004488(pc),A0                       ; 0000411A 41FA 036C
	move.l  A0,($1a8).w                           ; 0000411E 21C8 01A8
	move.l  A0,(-$17c,A6)                         ; 00004122 2D48 FE84
	lea     L_004480(pc),A0                       ; 00004126 41FA 0358
	move.l  A0,($1ac).w                           ; 0000412A 21C8 01AC
	move.l  A0,(-$174,A6)                         ; 0000412E 2D48 FE8C
	movea.l #$e840c0,A0                           ; 00004132 207C 00E8 40C0
	move.b  ($25,A0),(-$170,A6)                   ; 00004138 1D68 0025 FE90
	move.b  ($27,A0),(-$16f,A6)                   ; 0000413E 1D68 0027 FE91
	move.b  #$6a,($25,A0)                         ; 00004144 117C 006A 0025
	move.b  #$6b,($27,A0)                         ; 0000414A 117C 006B 0027
	move.b  #$80,($4,A0)                          ; 00004150 117C 0080 0004
	move.b  #$4,($6,A0)                           ; 00004156 117C 0004 0006
	move.b  #$5,($29,A0)                          ; 0000415C 117C 0005 0029
	move.b  #$1,($2d,A0)                          ; 00004162 117C 0001 002D
	move.b  #$5,($31,A0)                          ; 00004168 117C 0005 0031
	move.b  #$5,($39,A0)                          ; 0000416E 117C 0005 0039
	bsr.w   L_00440E                              ; 00004174 6100 0298
	lea     L_004192(pc),A2                       ; 00004178 45FA 0018
	moveq   #$3,D0                                ; 0000417C 7003

L_00417E:
	movea.w (A2)+,A0                              ; 0000417E 305A
	movea.l (A2),A1                               ; 00004180 2252
	move.l  (A0),(A2)+                            ; 00004182 24D0
	adda.l  A2,A1                                 ; 00004184 D3CA
	move.l  A1,(A0)                               ; 00004186 2089
	dbra    D0,L_00417E                           ; 00004188 51C8 FFF4
	movem.l (A7)+,D0/A0-A2/A6                     ; 0000418C 4CDF 4701
	rts                                           ; 00004190 4E75

L_004192:
	dc.w    $0580                                 ; 00004192
	dc.l    L_00420E-*-4                          ; 00004194
	dc.w    $0588                                 ; 00004198
	dc.l    L_0042D6-*-4                          ; 0000419A
	dc.w    $0590                                 ; 0000419E
	dc.l    L_004352-*-4                          ; 000041A0
	dc.w    $059C                                 ; 000041A4
	dc.l    L_0043CA-*-4                          ; 000041A6

L_0041AA:
	movem.l A0/A6,-(A7)                           ; 000041AA 48E7 0082
	lea     L_005E88(pc),A6                       ; 000041AE 4DFA 1CD8
	move.l  ($1a8).w,D0                           ; 000041B2 2038 01A8
	cmp.l   (-$17c,A6),D0                         ; 000041B6 B0AE FE84
	bne.s   L_00420A                              ; 000041BA 664E
	move.l  ($1ac).w,D0                           ; 000041BC 2038 01AC
	cmp.l   (-$174,A6),D0                         ; 000041C0 B0AE FE8C
	bne.s   L_00420A                              ; 000041C4 6644
	movea.l #$e840c0,A0                           ; 000041C6 207C 00E8 40C0
	cmpi.b  #$6a,($25,A0)                         ; 000041CC 0C28 006A 0025
	bne.s   L_00420A                              ; 000041D2 6636
	cmpi.b  #$6b,($27,A0)                         ; 000041D4 0C28 006B 0027
	bne.s   L_00420A                              ; 000041DA 662E
	move.b  (-$170,A6),($25,A0)                   ; 000041DC 116E FE90 0025
	move.b  (-$16f,A6),($27,A0)                   ; 000041E2 116E FE91 0027
	move.l  (-$180,A6),($1a8).w                   ; 000041E8 21EE FE80 01A8
	move.l  (-$178,A6),($1ac).w                   ; 000041EE 21EE FE88 01AC
	lea     L_004192(pc),A0                       ; 000041F4 41FA FF9C
	moveq   #$3,D0                                ; 000041F8 7003

L_0041FA:
	movea.w (A0)+,A6                              ; 000041FA 3C58
	move.l  (A0)+,(A6)                            ; 000041FC 2C98
	dbra    D0,L_0041FA                           ; 000041FE 51C8 FFFA
	moveq   #$0,D0                                ; 00004202 7000

L_004204:
	movem.l (A7)+,A0/A6                           ; 00004204 4CDF 4100
	rts                                           ; 00004208 4E75

L_00420A:
	moveq   #-$1,D0                               ; 0000420A 70FF
	bra.s   L_004204                              ; 0000420C 60F6

L_00420E:
	move.b  #$7f,L_005D36                         ; 0000420E 13FC 007F 0000 5D36

L_004216:
	movem.l D1-D2/A0-A1/A6,-(A7)                  ; 00004216 48E7 60C2
	lea     L_005E88(pc),A6                       ; 0000421A 4DFA 1C6C
	tst.b   (-$155,A6)                            ; 0000421E 4A2E FEAB
	beq.s   L_004248                              ; 00004222 6724
	bmi.s   L_00422A                              ; 00004224 6B04
	bsr.w   L_00440E                              ; 00004226 6100 01E6

L_00422A:
	sf      (-$156,A6)                            ; 0000422A 51EE FEAA
	clr.w   (-$16c,A6)                            ; 0000422E 426E FE94
	movem.l D1-D2/A1,(-$16a,A6)                   ; 00004232 48EE 0206 FE96
	st      (-$156,A6)                            ; 00004238 50EE FEAA
	tst.b   (-$155,A6)                            ; 0000423C 4A2E FEAB
	bne.w   L_0042CA                              ; 00004240 6600 0088
	sf      (-$156,A6)                            ; 00004244 51EE FEAA

L_004248:
	movea.l #$e840c0,A0                           ; 00004248 207C 00E8 40C0
	st      (A0)                                  ; 0000424E 50D0
	move.b  #$32,($5,A0)                          ; 00004250 117C 0032 0005
	move.l  #$e92003,($14,A0)                     ; 00004256 217C 00E9 2003 0014
	move.l  A1,($c,A0)                            ; 0000425E 2149 000C
	move.w  D2,($a,A0)                            ; 00004262 3142 000A
	bsr.w   L_004538                              ; 00004266 6100 02D0
	move.b  #$1,(-$155,A6)                        ; 0000426A 1D7C 0001 FEAB
	move.l  #$ff00,D0                             ; 00004270 203C 0000 FF00
	cmp.l   D0,D2                                 ; 00004276 B480
	bhi.s   L_00428A                              ; 00004278 6210
	move.b  #$88,($7,A0)                          ; 0000427A 117C 0088 0007
	move.b  #$2,($e92001).l                       ; 00004280 13FC 0002 00E9 2001
	bra.s   L_0042CA                              ; 00004288 6040

L_00428A:
	move.w  D0,($a,A0)                            ; 0000428A 3140 000A
	sub.l   D0,D2                                 ; 0000428E 9480
	adda.l  D0,A1                                 ; 00004290 D3C0
	move.l  A1,($1c,A0)                           ; 00004292 2149 001C
	cmp.l   D0,D2                                 ; 00004296 B480
	bls.s   L_0042AA                              ; 00004298 6310
	move.w  D0,($1a,A0)                           ; 0000429A 3140 001A
	sub.l   D0,D2                                 ; 0000429E 9480
	adda.l  D0,A1                                 ; 000042A0 D3C0
	movem.l D2/A1,(-$15e,A6)                      ; 000042A2 48EE 0204 FEA2
	bra.s   L_0042B6                              ; 000042A8 600C

L_0042AA:
	move.w  D2,($1a,A0)                           ; 000042AA 3142 001A
	clr.l   (-$15e,A6)                            ; 000042AE 42AE FEA2
	move.l  A1,(-$15a,A6)                         ; 000042B2 2D49 FEA6

L_0042B6:
	move.b  #$1,(-$156,A6)                        ; 000042B6 1D7C 0001 FEAA
	move.b  #$c8,($7,A0)                          ; 000042BC 117C 00C8 0007
	move.b  #$2,($e92001).l                       ; 000042C2 13FC 0002 00E9 2001

L_0042CA:
	move.b  #$2,($c32).w                          ; 000042CA 11FC 0002 0C32
	movem.l (A7)+,D1-D2/A0-A1/A6                  ; 000042D0 4CDF 4306
	rts                                           ; 000042D4 4E75

L_0042D6:
	move.b  #$7f,L_005D36                         ; 000042D6 13FC 007F 0000 5D36

L_0042DE:
	movem.l D1-D2/A0-A1/A6,-(A7)                  ; 000042DE 48E7 60C2
	lea     L_005E88(pc),A6                       ; 000042E2 4DFA 1BA4
	tst.b   (-$155,A6)                            ; 000042E6 4A2E FEAB
	beq.s   L_004310                              ; 000042EA 6724
	bmi.s   L_0042F2                              ; 000042EC 6B04
	bsr.w   L_00440E                              ; 000042EE 6100 011E

L_0042F2:
	sf      (-$156,A6)                            ; 000042F2 51EE FEAA
	move.w  #$4,(-$16c,A6)                        ; 000042F6 3D7C 0004 FE94
	movem.l D1-D2/A1,(-$16a,A6)                   ; 000042FC 48EE 0206 FE96
	st      (-$156,A6)                            ; 00004302 50EE FEAA
	tst.b   (-$155,A6)                            ; 00004306 4A2E FEAB
	bne.s   L_004346                              ; 0000430A 663A
	sf      (-$156,A6)                            ; 0000430C 51EE FEAA

L_004310:
	movea.l #$e840c0,A0                           ; 00004310 207C 00E8 40C0
	st      (A0)                                  ; 00004316 50D0
	move.b  #$3a,($5,A0)                          ; 00004318 117C 003A 0005
	move.l  #$e92003,($14,A0)                     ; 0000431E 217C 00E9 2003 0014
	move.w  D2,($1a,A0)                           ; 00004326 3142 001A
	move.l  A1,($1c,A0)                           ; 0000432A 2149 001C
	bsr.w   L_004538                              ; 0000432E 6100 0208
	move.b  #$2,(-$155,A6)                        ; 00004332 1D7C 0002 FEAB
	move.b  #$88,($7,A0)                          ; 00004338 117C 0088 0007
	move.b  #$2,($e92001).l                       ; 0000433E 13FC 0002 00E9 2001

L_004346:
	move.b  #$12,($c32).w                         ; 00004346 11FC 0012 0C32
	movem.l (A7)+,D1-D2/A0-A1/A6                  ; 0000434C 4CDF 4306
	rts                                           ; 00004350 4E75

L_004352:
	move.b  #$7f,L_005D36                         ; 00004352 13FC 007F 0000 5D36

L_00435A:
	movem.l D1/A0-A1/A6,-(A7)                     ; 0000435A 48E7 40C2
	lea     L_005E88(pc),A6                       ; 0000435E 4DFA 1B28
	tst.b   (-$155,A6)                            ; 00004362 4A2E FEAB
	beq.s   L_00438C                              ; 00004366 6724
	bmi.s   L_00436E                              ; 00004368 6B04
	bsr.w   L_00440E                              ; 0000436A 6100 00A2

L_00436E:
	sf      (-$156,A6)                            ; 0000436E 51EE FEAA
	move.w  #$8,(-$16c,A6)                        ; 00004372 3D7C 0008 FE94
	movem.l D1-D2/A1,(-$16a,A6)                   ; 00004378 48EE 0206 FE96
	st      (-$156,A6)                            ; 0000437E 50EE FEAA
	tst.b   (-$155,A6)                            ; 00004382 4A2E FEAB
	bne.s   L_0043BE                              ; 00004386 6636
	sf      (-$156,A6)                            ; 00004388 51EE FEAA

L_00438C:
	movea.l #$e840c0,A0                           ; 0000438C 207C 00E8 40C0
	st      (A0)                                  ; 00004392 50D0
	move.b  #$3e,($5,A0)                          ; 00004394 117C 003E 0005
	move.l  #$e92003,($14,A0)                     ; 0000439A 217C 00E9 2003 0014
	move.l  A1,($1c,A0)                           ; 000043A2 2149 001C
	bsr.w   L_004538                              ; 000043A6 6100 0190
	move.b  #$3,(-$155,A6)                        ; 000043AA 1D7C 0003 FEAB
	move.b  #$88,($7,A0)                          ; 000043B0 117C 0088 0007
	move.b  #$2,($e92001).l                       ; 000043B6 13FC 0002 00E9 2001

L_0043BE:
	move.b  #$22,($c32).w                         ; 000043BE 11FC 0022 0C32
	movem.l (A7)+,D1/A0-A1/A6                     ; 000043C4 4CDF 4302
	rts                                           ; 000043C8 4E75

L_0043CA:
	move.l  A6,-(A7)                              ; 000043CA 2F0E
	lea     L_005E88(pc),A6                       ; 000043CC 4DFA 1ABA
	tst.b   (-$155,A6)                            ; 000043D0 4A2E FEAB
	ble.s   L_004404                              ; 000043D4 6F2E
	move.w  D1,D0                                 ; 000043D6 3001
	beq.s   L_0043FE                              ; 000043D8 6724
	subq.w  #2,D0                                 ; 000043DA 5540
	bcs.s   L_0043F2                              ; 000043DC 6514
	bne.s   L_004404                              ; 000043DE 6624
	tst.b   (-$154,A6)                            ; 000043E0 4A2E FEAC
	beq.s   L_004404                              ; 000043E4 671E
	clr.b   (-$154,A6)                            ; 000043E6 422E FEAC
	move.b  D1,($e92001).l                        ; 000043EA 13C1 00E9 2001
	bra.s   L_004404                              ; 000043F0 6012

L_0043F2:
	st      (-$154,A6)                            ; 000043F2 50EE FEAC
	move.b  D1,($e92001).l                        ; 000043F6 13C1 00E9 2001
	bra.s   L_004404                              ; 000043FC 6006

L_0043FE:
	clr.b   (-$156,A6)                            ; 000043FE 422E FEAA
	bsr.s   L_00440E                              ; 00004402 610A

L_004404:
	movea.l (A7)+,A6                              ; 00004404 2C5F
	rts                                           ; 00004406 4E75

L_004408:
	tst.b   (-$152,A6)                            ; 00004408 4A2E FEAE
	bne.s   L_004464                              ; 0000440C 6656

L_00440E:
	movem.l D1/A0/A6,-(A7)                        ; 0000440E 48E7 4082
	movea.l #$e840c0,A0                           ; 00004412 207C 00E8 40C0
	st      (A0)                                  ; 00004418 50D0
	move.b  #$10,($7,A0)                          ; 0000441A 117C 0010 0007
	move.b  #$88,($e92003).l                      ; 00004420 13FC 0088 00E9 2003
	st      (A0)                                  ; 00004428 50D0
	move.b  #$32,($5,A0)                          ; 0000442A 117C 0032 0005
	move.l  #$e92003,($14,A0)                     ; 00004430 217C 00E9 2003 0014
	move.w  #$1a,($a,A0)                          ; 00004438 317C 001A 000A
	lea     L_004466(pc),A6                       ; 0000443E 4DFA 0026
	move.l  A6,($c,A0)                            ; 00004442 214E 000C
	lea     L_005E88(pc),A6                       ; 00004446 4DFA 1A40
	st      (-$155,A6)                            ; 0000444A 50EE FEAB
	clr.b   (-$154,A6)                            ; 0000444E 422E FEAC
	move.b  #$88,($7,A0)                          ; 00004452 117C 0088 0007
	move.b  #$2,($e92001).l                       ; 00004458 13FC 0002 00E9 2001
	movem.l (A7)+,D1/A0/A6                        ; 00004460 4CDF 4102

L_004464:
	rts                                           ; 00004464 4E75

L_004466:
	dc.b    $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88; 00004466
	dc.b    $88,$88,$88,$88,$88,$88,$88,$88,$88,$88; 00004476

L_004480:
	move.b  ($e840c1).l,($c33).w                  ; 00004480 11F9 00E8 40C1 0C33

L_004488:
	clr.b   ($c32).w                              ; 00004488 4238 0C32
	movem.l D0/A6,-(A7)                           ; 0000448C 48E7 8002
	st      ($e840c0).l                           ; 00004490 50F9 00E8 40C0
	lea     L_005E88(pc),A6                       ; 00004496 4DFA 19F0
	tst.b   (-$156,A6)                            ; 0000449A 4A2E FEAA
	bne.s   L_0044BC                              ; 0000449E 661C
	tst.b   (-$155,A6)                            ; 000044A0 4A2E FEAB
	bpl.s   L_0044B6                              ; 000044A4 6A10
	clr.b   (-$155,A6)                            ; 000044A6 422E FEAB
	dc.w    $1D7C,$FF80,$FEAE  ; move.b #$80,(-$152,A6); 000044AA 1D7C FF80 FEAE

L_0044B0:
	movem.l (A7)+,D0/A6                           ; 000044B0 4CDF 4001
	rte                                           ; 000044B4 4E73

L_0044B6:
	bsr.w   L_00440E                              ; 000044B6 6100 FF56
	bra.s   L_0044B0                              ; 000044BA 60F4

L_0044BC:
	bpl.s   L_0044EC                              ; 000044BC 6A2E
	tst.b   (-$155,A6)                            ; 000044BE 4A2E FEAB
	bpl.s   L_0044B6                              ; 000044C2 6AF2
	clr.b   (-$155,A6)                            ; 000044C4 422E FEAB
	clr.b   (-$156,A6)                            ; 000044C8 422E FEAA
	movem.l D1-D2/A1,-(A7)                        ; 000044CC 48E7 6040
	movem.l (-$16e,A6),D0-D2/A1                   ; 000044D0 4CEE 0207 FE92
	jsr     L_0044E0(pc,D0.w)                     ; 000044D6 4EBB 0008
	movem.l (A7)+,D1-D2/A1                        ; 000044DA 4CDF 0206
	bra.s   L_0044B0                              ; 000044DE 60D0

L_0044E0:
	bra.w   L_004216                              ; 000044E0 6000 FD34

L_0044E4:
	bra.w   L_0042DE                              ; 000044E4 6000 FDF8

L_0044E8:
	bra.w   L_00435A                              ; 000044E8 6000 FE70

L_0044EC:
	move.l  A0,-(A7)                              ; 000044EC 2F08
	movea.l #$e840c0,A0                           ; 000044EE 207C 00E8 40C0
	st      (A0)                                  ; 000044F4 50D0
	move.l  (-$15a,A6),($1c,A0)                   ; 000044F6 216E FEA6 001C
	move.l  (-$15e,A6),D0                         ; 000044FC 202E FEA2
	cmpi.l  #$ff00,D0                             ; 00004500 0C80 0000 FF00
	bhi.s   L_004514                              ; 00004506 620C
	clr.b   (-$156,A6)                            ; 00004508 422E FEAA
	move.w  D0,($1a,A0)                           ; 0000450C 3140 001A
	beq.s   L_004532                              ; 00004510 6720
	bra.s   L_00452C                              ; 00004512 6018

L_004514:
	move.w  #$ff00,($1a,A0)                       ; 00004514 317C FF00 001A
	subi.l  #$ff00,D0                             ; 0000451A 0480 0000 FF00
	move.l  D0,(-$15e,A6)                         ; 00004520 2D40 FEA2
	addi.l  #$ff00,(-$15a,A6)                     ; 00004524 06AE 0000 FF00 FEA6

L_00452C:
	move.b  #$48,($7,A0)                          ; 0000452C 117C 0048 0007

L_004532:
	movea.l (A7)+,A0                              ; 00004532 205F
	bra.w   L_0044B0                              ; 00004534 6000 FF7A

L_004538:
	move.w  D0,-(A7)                              ; 00004538 3F00
	move.w  D1,-(A7)                              ; 0000453A 3F01
	move    SR,-(A7)                              ; 0000453C 40E7
	sub.w   #$200,D1                              ; 0000453E 927C 0200
	bcc.s   L_004550                              ; 00004542 640C
	add.w   #$200,D1                              ; 00004544 D27C 0200
	ori.b   #$80,($9da).w                         ; 00004548 0038 0080 09DA
	bra.s   L_004556                              ; 0000454E 6006

L_004550:
	andi.b  #$7f,($9da).w                         ; 00004550 0238 007F 09DA

L_004556:
	ori     #$700,SR                              ; 00004556 007C 0700
	moveq   #$1b,D0                               ; 0000455A 701B
	bsr.w   L_002BAC                              ; 0000455C 6100 E64E
	moveq   #$3,D0                                ; 00004560 7003
	and.w   D1,D0                                 ; 00004562 C041
	clr.b   D1                                    ; 00004564 4201
	lsr.w   #6,D1                                 ; 00004566 EC49
	or.b    L_004592(pc,D0.w),D1                  ; 00004568 823B 0028
	andi.b  #$f,D1                                ; 0000456C 0201 000F
	move.b  ($e9a005).l,D0                        ; 00004570 1039 00E9 A005
	andi.b  #$f0,D0                               ; 00004576 0200 00F0
	or.b    D1,D0                                 ; 0000457A 8001
	move.b  D0,($e9a005).l                        ; 0000457C 13C0 00E9 A005
	move.b  ($9da).w,D0                           ; 00004582 1038 09DA
	bsr.w   L_002BB6                              ; 00004586 6100 E62E
	move    (A7)+,SR                              ; 0000458A 46DF
	move.w  (A7)+,D1                              ; 0000458C 321F
	move.w  (A7)+,D0                              ; 0000458E 301F
	rts                                           ; 00004590 4E75

L_004592:
	dc.b    $03,$01,$02,$00                       ; 00004592

L_004596:
	move    SR,-(A7)                              ; 00004596 40E7
	ori     #$700,SR                              ; 00004598 007C 0700
	movem.l D0-D1/A0-A2,-(A7)                     ; 0000459C 48E7 C0E0
	lea     ($160).w,A0                           ; 000045A0 41F8 0160
	lea     (-$2c6,A6),A1                         ; 000045A4 43EE FD3A
	moveq   #-$8,D0                               ; 000045A8 70F8

L_0045AA:
	move.w  L_0045D4(pc,D0.w),D1                  ; 000045AA 323B 0028
	lea     L_0045D4(pc,D1.w),A2                  ; 000045AE 45FB 1024
	move.l  (A0),(A1)+                            ; 000045B2 22D0
	move.l  A2,(A0)+                              ; 000045B4 20CA
	move.l  (A0),(A1)+                            ; 000045B6 22D0
	move.l  A2,(A0)+                              ; 000045B8 20CA
	addq.w  #2,D0                                 ; 000045BA 5440
	bcc.s   L_0045AA                              ; 000045BC 64EC
	bsr.w   L_004692                              ; 000045BE 6100 00D2
	moveq   #$0,D0                                ; 000045C2 7000
	movem.l (A7)+,D0-D1/A0-A2                     ; 000045C4 4CDF 0703
	move    (A7)+,SR                              ; 000045C8 46DF
	rts                                           ; 000045CA 4E75
	dc.w    L_004742-L_0045D4                     ; 000045CC
	dc.w    L_0045F0-L_0045D4                     ; 000045CE
	dc.w    L_004606-L_0045D4                     ; 000045D0
	dc.w    L_0045D4-L_0045D4                     ; 000045D2

L_0045D4:
	ori     #$700,SR                              ; 000045D4 007C 0700
	tst.b   ($e98007).l                           ; 000045D8 4A39 00E9 8007
	move.b  #$30,($e98005).l                      ; 000045DE 13FC 0030 00E9 8005
	move.b  #$38,($e98005).l                      ; 000045E6 13FC 0038 00E9 8005
	rte                                           ; 000045EE 4E73

L_0045F0:
	ori     #$700,SR                              ; 000045F0 007C 0700
	move.b  #$20,($e98005).l                      ; 000045F4 13FC 0020 00E9 8005
	move.b  #$38,($e98005).l                      ; 000045FC 13FC 0038 00E9 8005
	rte                                           ; 00004604 4E73

L_004606:
	ori     #$700,SR                              ; 00004606 007C 0700
	tst.b   ($e98007).l                           ; 0000460A 4A39 00E9 8007
	move.b  #$38,($e98005).l                      ; 00004610 13FC 0038 00E9 8005
	rte                                           ; 00004618 4E73

L_00461A:
	move    SR,-(A7)                              ; 0000461A 40E7
	ori     #$700,SR                              ; 0000461C 007C 0700
	movem.l D0-D1/A0-A1,-(A7)                     ; 00004620 48E7 C0C0
	move.b  #$9,($e98005).l                       ; 00004624 13FC 0009 00E9 8005
	move.b  #$89,($e98005).l                      ; 0000462C 13FC 0089 00E9 8005
	lea     (-$2c6,A6),A0                         ; 00004634 41EE FD3A
	lea     ($160).w,A1                           ; 00004638 43F8 0160
	moveq   #$7,D0                                ; 0000463C 7007

L_00463E:
	move.l  (A0)+,(A1)+                           ; 0000463E 22D8
	dbra    D0,L_00463E                           ; 00004640 51C8 FFFC
	tst.b   ($e98005).l                           ; 00004644 4A39 00E9 8005
	lea     L_00466C(pc),A0                       ; 0000464A 41FA 0020
	moveq   #$25,D0                               ; 0000464E 7025

L_004650:
	move.b  (A0)+,($e98005).l                     ; 00004650 13D8 00E9 8005
	dbra    D0,L_004650                           ; 00004656 51C8 FFF8
	move.w  ($ed001a).l,D1                        ; 0000465A 3239 00ED 001A
	moveq   #$30,D0                               ; 00004660 7030
	trap    #$f                                   ; 00004662 4E4F
	movem.l (A7)+,D0-D1/A0-A1                     ; 00004664 4CDF 0303
	move    (A7)+,SR                              ; 00004668 46DF
	rts                                           ; 0000466A 4E75

L_00466C:
	dc.b    $09,$80,$04,$45,$01,$00,$02,$50,$03,$C0,$05,$E2,$09,$01,$0B,$56; 0000466C
	dc.b    $0C,$0E,$0D,$00,$0E,$02,$03,$C1,$05,$EA,$00,$80,$0E,$03,$0F,$00; 0000467C
	dc.b    $00,$10,$01,$10,$09,$09               ; 0000468C

L_004692:
	move    SR,-(A7)                              ; 00004692 40E7
	ori     #$700,SR                              ; 00004694 007C 0700
	movem.l D0-D1/A0/A5,-(A7)                     ; 00004698 48E7 C084
	move.b  ($e98005).l,D0                        ; 0000469C 1039 00E9 8005
	lea     L_0046BA(pc),A0                       ; 000046A2 41FA 0016
	moveq   #$1f,D0                               ; 000046A6 701F

L_0046A8:
	move.b  (A0)+,($e98005).l                     ; 000046A8 13D8 00E9 8005
	dbra    D0,L_0046A8                           ; 000046AE 51C8 FFF8
	movem.l (A7)+,D0-D1/A0/A5                     ; 000046B2 4CDF 2103
	move    (A7)+,SR                              ; 000046B6 46DF
	rts                                           ; 000046B8 4E75

L_0046BA:
	dc.b    $09,$80,$04,$44,$01,$00,$03,$C0,$05,$E2,$09,$01,$0B,$50,$0E,$02; 000046BA

L_0046CA:
	dc.b    $0C,$03,$0D,$00,$03,$C1,$05,$EA,$0E,$03,$10,$10,$01,$12,$09,$09; 000046CA

L_0046DA:
	movem.l D1/A5,-(A7)                           ; 000046DA 48E7 4004
	movea.l L_005CA6(pc),A5                       ; 000046DE 2A7A 15C6

L_0046E2:
	cmpi.w  #$3ff,($4,A5)                         ; 000046E2 0C6D 03FF 0004
	bls.s   L_004700                              ; 000046E8 6316
	move    SR,D1                                 ; 000046EA 40C1
	ori     #$700,SR                              ; 000046EC 007C 0700

L_0046F0:
	btst    #$2,($e98005).l                       ; 000046F0 0839 0002 00E9 8005
	beq.s   L_0046F0                              ; 000046F8 67F6
	bsr.s   L_004746                              ; 000046FA 614A
	move    D1,SR                                 ; 000046FC 46C1
	bra.s   L_0046E2                              ; 000046FE 60E2

L_004700:
	move.w  (A5),D1                               ; 00004700 3215
	move.b  (A0)+,($10,A5,D1.w)                   ; 00004702 1B98 1010
	bpl.s   L_004724                              ; 00004706 6A1C
	cmpi.b  #-$10,-(A0)                           ; 00004708 0C20 00F0
	bcc.s   L_00471C                              ; 0000470C 640E
	move.b  ($f,A5),-(A7)                         ; 0000470E 1F2D 000F
	cmpm.b  (A7)+,(A0)+                           ; 00004712 B10F
	bne.s   L_00471E                              ; 00004714 6608
	dbra    D0,L_0046E2                           ; 00004716 51C8 FFCA
	bra.s   L_004734                              ; 0000471A 6018

L_00471C:
	addq.l  #1,A0                                 ; 0000471C 5288

L_00471E:
	move.b  (-$1,A0),($f,A5)                      ; 0000471E 1B68 FFFF 000F

L_004724:
	addq.w  #1,D1                                 ; 00004724 5241
	andi.w  #$3ff,D1                              ; 00004726 0241 03FF
	move.w  D1,(A5)                               ; 0000472A 3A81
	addq.w  #1,($4,A5)                            ; 0000472C 526D 0004
	dbra    D0,L_0046E2                           ; 00004730 51C8 FFB0

L_004734:
	tst.b   ($e,A5)                               ; 00004734 4A2D 000E
	bne.s   L_00473C                              ; 00004738 6602
	bsr.s   L_004746                              ; 0000473A 610A

L_00473C:
	movem.l (A7)+,D1/A5                           ; 0000473C 4CDF 2002
	rts                                           ; 00004740 4E75

L_004742:
	bsr.s   L_004746                              ; 00004742 6102
	rte                                           ; 00004744 4E73

L_004746:
	move    SR,-(A7)                              ; 00004746 40E7
	ori     #$700,SR                              ; 00004748 007C 0700
	move.l  A5,-(A7)                              ; 0000474C 2F0D
	move.w  D0,-(A7)                              ; 0000474E 3F00
	movea.l L_005CA6(pc),A5                       ; 00004750 2A7A 1554
	tst.w   ($4,A5)                               ; 00004754 4A6D 0004
	bne.s   L_004768                              ; 00004758 660E
	sf      ($e,A5)                               ; 0000475A 51ED 000E
	move.b  #$28,($e98005).l                      ; 0000475E 13FC 0028 00E9 8005
	bra.s   L_0047A4                              ; 00004766 603C

L_004768:
	move.w  ($2,A5),D0                            ; 00004768 302D 0002
	move.b  ($10,A5,D0.w),($e98007).l             ; 0000476C 13F5 0010 00E9 8007
	addq.w  #1,D0                                 ; 00004774 5240
	subq.w  #1,($4,A5)                            ; 00004776 536D 0004
	beq.s   L_004798                              ; 0000477A 671C
	btst    #$2,($e98005).l                       ; 0000477C 0839 0002 00E9 8005
	beq.s   L_004798                              ; 00004784 6712
	and.w   #$3ff,D0                              ; 00004786 C07C 03FF
	move.b  ($10,A5,D0.w),($e98007).l             ; 0000478A 13F5 0010 00E9 8007
	subq.w  #1,($4,A5)                            ; 00004792 536D 0004
	addq.w  #1,D0                                 ; 00004796 5240

L_004798:
	and.w   #$3ff,D0                              ; 00004798 C07C 03FF
	move.w  D0,($2,A5)                            ; 0000479C 3B40 0002
	st      ($e,A5)                               ; 000047A0 50ED 000E

L_0047A4:
	move.b  #$38,($e98005).l                      ; 000047A4 13FC 0038 00E9 8005
	move.w  (A7)+,D0                              ; 000047AC 301F
	movea.l (A7)+,A5                              ; 000047AE 2A5F
	move    (A7)+,SR                              ; 000047B0 46DF
	rts                                           ; 000047B2 4E75

L_0047B4:
	movem.l D0-D1/A0,-(A7)                        ; 000047B4 48E7 C080
	move.w  #$4c09,D1                             ; 000047B8 323C 4C09
	moveq   #$30,D0                               ; 000047BC 7030
	trap    #$f                                   ; 000047BE 4E4F
	movem.l (A7)+,D0-D1/A0                        ; 000047C0 4CDF 0103
	rts                                           ; 000047C4 4E75

L_0047C6:
	dc.b    $00,$00                               ; 000047C6

L_0047C8:
	eori.w  #$f,($e82200).l                       ; 000047C8 0A79 000F 00E8 2200
	movem.l D1/D7/A1,-(A7)                        ; 000047D0 48E7 4140
	move.w  D0,D7                                 ; 000047D4 3E00
	moveq   #$0,D1                                ; 000047D6 7200
	movea.l #$e98005,A1                           ; 000047D8 227C 00E9 8005
	move.b  (A1),D0                               ; 000047DE 1011
	move.b  #$c,(A1)                              ; 000047E0 12BC 000C
	move.b  #$3,(A1)                              ; 000047E4 12BC 0003
	lea     L_0047C6(pc),A1                       ; 000047E8 43FA FFDC

L_0047EC:
	moveq   #$34,D0                               ; 000047EC 7034
	trap    #$f                                   ; 000047EE 4E4F
	tst.l   D0                                    ; 000047F0 4A80
	beq.s   L_0047EC                              ; 000047F2 67F8
	move.b  (A0)+,D1                              ; 000047F4 1218
	bpl.s   L_004804                              ; 000047F6 6A0C
	cmpi.b  #-$10,D1                              ; 000047F8 0C01 00F0
	bcc.s   L_004802                              ; 000047FC 6404
	cmp.b   (A1),D1                               ; 000047FE B211
	beq.s   L_004808                              ; 00004800 6706

L_004802:
	move.b  D1,(A1)                               ; 00004802 1281

L_004804:
	moveq   #$35,D0                               ; 00004804 7035
	trap    #$f                                   ; 00004806 4E4F

L_004808:
	dbra    D7,L_0047EC                           ; 00004808 51CF FFE2
	movem.l (A7)+,D1/D7/A1                        ; 0000480C 4CDF 0282
	rts                                           ; 00004810 4E75

L_004812:
	movem.l D0-D1/A0-A3,-(A7)                     ; 00004812 48E7 C0F0
	move.l  A0,D1                                 ; 00004816 2208
	and.w   #$10,D1                               ; 00004818 C27C 0010
	beq.s   L_00482C                              ; 0000481C 670E
	lea     ($280).w,A0                           ; 0000481E 41F8 0280
	lea     (-$286,A6),A1                         ; 00004822 43EE FD7A
	lea     L_004876(pc),A3                       ; 00004826 47FA 004E
	bra.s   L_004838                              ; 0000482A 600C

L_00482C:
	lea     ($200).w,A0                           ; 0000482C 41F8 0200
	lea     (-$2a6,A6),A1                         ; 00004830 43EE FD5A
	lea     L_004866(pc),A3                       ; 00004834 47FA 0030

L_004838:
	moveq   #-$8,D0                               ; 00004838 70F8

L_00483A:
	move.l  (A0),(A1)+                            ; 0000483A 22D0
	move.w  D0,D1                                 ; 0000483C 3200
	add.w   D1,D1                                 ; 0000483E D241
	move.w  (A3,D1.w),D1                          ; 00004840 3233 1000
	lea     (A3,D1.w),A2                          ; 00004844 45F3 1000
	move.l  A2,(A0)                               ; 00004848 208A
	addq.l  #8,A0                                 ; 0000484A 5088
	addq.w  #1,D0                                 ; 0000484C 5240
	bcc.s   L_00483A                              ; 0000484E 64EA
	movem.l (A7)+,D0-D1/A0-A3                     ; 00004850 4CDF 0F03
	rts                                           ; 00004854 4E75
	dc.w    L_00492C-L_004866                     ; 00004856
	dc.w    L_004936-L_004866                     ; 00004858
	dc.w    L_004940-L_004866                     ; 0000485A
	dc.w    L_00494A-L_004866                     ; 0000485C
	dc.w    L_004954-L_004866                     ; 0000485E
	dc.w    L_00495E-L_004866                     ; 00004860
	dc.w    L_00496C-L_004866                     ; 00004862
	dc.w    L_00497A-L_004866                     ; 00004864

L_004866:
	dc.w    L_004986-L_004876                     ; 00004866
	dc.w    L_004990-L_004876                     ; 00004868
	dc.w    L_00499A-L_004876                     ; 0000486A
	dc.w    L_0049A4-L_004876                     ; 0000486C
	dc.w    L_0049AE-L_004876                     ; 0000486E
	dc.w    L_0049B8-L_004876                     ; 00004870
	dc.w    L_0049C2-L_004876                     ; 00004872
	dc.w    L_0049CE-L_004876                     ; 00004874

L_004876:
	movem.l D0/A0-A1,-(A7)                        ; 00004876 48E7 80C0
	move.b  #$80,($2,A0)                          ; 0000487A 117C 0080 0002
	move.l  A0,D0                                 ; 00004880 2008
	and.w   #$10,D0                               ; 00004882 C07C 0010
	add.w   D0,D0                                 ; 00004886 D040
	add.w   D0,D0                                 ; 00004888 D040
	lea     (-$2a6,A6),A0                         ; 0000488A 41EE FD5A
	lea     ($200).w,A1                           ; 0000488E 43F8 0200
	adda.w  D0,A0                                 ; 00004892 D0C0
	adda.w  D0,A1                                 ; 00004894 D2C0
	adda.w  D0,A1                                 ; 00004896 D2C0
	moveq   #$7,D0                                ; 00004898 7007

L_00489A:
	move.l  (A0)+,(A1)                            ; 0000489A 2298
	addq.l  #8,A1                                 ; 0000489C 5089
	dbra    D0,L_00489A                           ; 0000489E 51C8 FFFA
	movem.l (A7)+,D0/A0-A1                        ; 000048A2 4CDF 0301
	rts                                           ; 000048A6 4E75

L_0048A8:
	movem.l D0-D1/A1,-(A7)                        ; 000048A8 48E7 C040
	move.b  #$80,($2,A0)                          ; 000048AC 117C 0080 0002
	moveq   #$0,D0                                ; 000048B2 7000
	bsr.w   L_000BF4                              ; 000048B4 6100 C33E
	clr.b   ($2,A0)                               ; 000048B8 4228 0002
	lea     L_0048F8(pc),A1                       ; 000048BC 43FA 003A
	move.l  A0,D0                                 ; 000048C0 2008
	and.b   #$10,D0                               ; 000048C2 C03C 0010
	add.b   D0,D0                                 ; 000048C6 D000
	tas     D0                                    ; 000048C8 4AC0
	move.b  D0,($3,A1)                            ; 000048CA 1340 0003

L_0048CE:
	moveq   #$0,D0                                ; 000048CE 7000
	move.b  (A1)+,D0                              ; 000048D0 1019
	cmpi.b  #-$2,D0                               ; 000048D2 0C00 00FE
	beq.s   L_004926                              ; 000048D6 674E
	moveq   #$f,D1                                ; 000048D8 720F
	and.b   D0,D1                                 ; 000048DA C200
	eor.b   D1,D0                                 ; 000048DC B300
	ror.b   #4,D0                                 ; 000048DE E818
	move.b  D0,($2,A0)                            ; 000048E0 1140 0002
	add.w   D1,D1                                 ; 000048E4 D241
	tst.b   ($e9a001).l                           ; 000048E6 4A39 00E9 A001
	move.b  (A1)+,(A0,D1.w)                       ; 000048EC 1199 1000
	tst.b   ($e9a001).l                           ; 000048F0 4A39 00E9 A001
	bra.s   L_0048CE                              ; 000048F6 60D6

L_0048F8:
	dc.b    $06,$00,$04,$80,$66,$02,$84,$FF,$85,$BF,$86,$FF,$87,$BF,$67,$18; 000048F8
	dc.b    $65,$94,$55,$85,$44,$08,$45,$00,$35,$90,$24,$08,$25,$00,$05,$02; 00004908
	dc.b    $03,$FF,$14,$2B,$94,$00,$35,$81,$55,$81,$06,$20,$FE,$00; 00004918

L_004926:
	movem.l (A7)+,D0-D1/A1                        ; 00004926 4CDF 0203
	rts                                           ; 0000492A 4E75

L_00492C:
	move.b  #$1,($eafa07).l                       ; 0000492C 13FC 0001 00EA FA07
	rte                                           ; 00004934 4E73

L_004936:
	move.b  #$2,($eafa07).l                       ; 00004936 13FC 0002 00EA FA07
	rte                                           ; 0000493E 4E73

L_004940:
	move.b  #$4,($eafa07).l                       ; 00004940 13FC 0004 00EA FA07
	rte                                           ; 00004948 4E73

L_00494A:
	move.b  #$8,($eafa07).l                       ; 0000494A 13FC 0008 00EA FA07
	rte                                           ; 00004952 4E73

L_004954:
	move.b  #$10,($eafa07).l                      ; 00004954 13FC 0010 00EA FA07
	rte                                           ; 0000495C 4E73

L_00495E:
	ori     #$700,SR                              ; 0000495E 007C 0700
	move.b  #$20,($eafa07).l                      ; 00004962 13FC 0020 00EA FA07
	rte                                           ; 0000496A 4E73

L_00496C:
	move.l  A6,-(A7)                              ; 0000496C 2F0E
	movea.l L_005C9E(pc),A6                       ; 0000496E 2C7A 132E
	bsr.w   L_004A36                              ; 00004972 6100 00C2
	movea.l (A7)+,A6                              ; 00004976 2C5F
	rte                                           ; 00004978 4E73

L_00497A:
	move.b  #$80,($eafa07).l                      ; 0000497A 13FC 0080 00EA FA07
	bra.w   L_0029DE                              ; 00004982 6000 E05A

L_004986:
	move.b  #$1,($eafa17).l                       ; 00004986 13FC 0001 00EA FA17
	rte                                           ; 0000498E 4E73

L_004990:
	move.b  #$2,($eafa17).l                       ; 00004990 13FC 0002 00EA FA17
	rte                                           ; 00004998 4E73

L_00499A:
	move.b  #$4,($eafa17).l                       ; 0000499A 13FC 0004 00EA FA17
	rte                                           ; 000049A2 4E73

L_0049A4:
	move.b  #$8,($eafa17).l                       ; 000049A4 13FC 0008 00EA FA17
	rte                                           ; 000049AC 4E73

L_0049AE:
	move.b  #$10,($eafa17).l                      ; 000049AE 13FC 0010 00EA FA17
	rte                                           ; 000049B6 4E73

L_0049B8:
	move.b  #$20,($eafa17).l                      ; 000049B8 13FC 0020 00EA FA17
	rte                                           ; 000049C0 4E73

L_0049C2:
	move.l  A6,-(A7)                              ; 000049C2 2F0E
	movea.l L_005CA2(pc),A6                       ; 000049C4 2C7A 12DC
	bsr.s   L_004A36                              ; 000049C8 616C
	movea.l (A7)+,A6                              ; 000049CA 2C5F
	rte                                           ; 000049CC 4E73

L_0049CE:
	move.b  #$80,($eafa17).l                      ; 000049CE 13FC 0080 00EA FA17
	rte                                           ; 000049D6 4E73

L_0049D8:
	move.l  A6,-(A7)                              ; 000049D8 2F0E
	movea.l L_005CA2(pc),A6                       ; 000049DA 2C7A 12C6
	bra.s   L_0049E6                              ; 000049DE 6006

L_0049E0:
	move.l  A6,-(A7)                              ; 000049E0 2F0E
	movea.l L_005C9E(pc),A6                       ; 000049E2 2C7A 12BA

L_0049E6:
	move.w  D1,-(A7)                              ; 000049E6 3F01

L_0049E8:
	cmpi.w  #$3ff,($4,A6)                         ; 000049E8 0C6E 03FF 0004
	bls.s   L_0049F4                              ; 000049EE 6304
	bsr.s   L_004A36                              ; 000049F0 6144
	bra.s   L_0049E8                              ; 000049F2 60F4

L_0049F4:
	move.w  (A6),D1                               ; 000049F4 3216
	move.b  (A0)+,($10,A6,D1.w)                   ; 000049F6 1D98 1010
	bpl.s   L_004A18                              ; 000049FA 6A1C
	cmpi.b  #-$10,-(A0)                           ; 000049FC 0C20 00F0
	bcc.s   L_004A10                              ; 00004A00 640E
	move.b  ($f,A6),-(A7)                         ; 00004A02 1F2E 000F
	cmpm.b  (A7)+,(A0)+                           ; 00004A06 B10F
	bne.s   L_004A12                              ; 00004A08 6608
	dbra    D0,L_0049E8                           ; 00004A0A 51C8 FFDC
	bra.s   L_004A28                              ; 00004A0E 6018

L_004A10:
	addq.l  #1,A0                                 ; 00004A10 5288

L_004A12:
	move.b  (-$1,A0),($f,A6)                      ; 00004A12 1D68 FFFF 000F

L_004A18:
	addq.w  #1,D1                                 ; 00004A18 5241
	andi.w  #$3ff,D1                              ; 00004A1A 0241 03FF
	move.w  D1,(A6)                               ; 00004A1E 3C81
	addq.w  #1,($4,A6)                            ; 00004A20 526E 0004
	dbra    D0,L_0049E8                           ; 00004A24 51C8 FFC2

L_004A28:
	tst.b   ($e,A6)                               ; 00004A28 4A2E 000E
	bne.s   L_004A30                              ; 00004A2C 6602
	bsr.s   L_004A36                              ; 00004A2E 6106

L_004A30:
	move.w  (A7)+,D1                              ; 00004A30 321F
	movea.l (A7)+,A6                              ; 00004A32 2C5F
	rts                                           ; 00004A34 4E75

L_004A36:
	movem.l D0-D1/A1-A2,-(A7)                     ; 00004A36 48E7 C060
	move    SR,-(A7)                              ; 00004A3A 40E7
	ori     #$700,SR                              ; 00004A3C 007C 0700
	movea.l ($8,A6),A1                            ; 00004A40 226E 0008
	movea.l #$e9a001,A2                           ; 00004A44 247C 00E9 A001
	move.b  #$5,($2,A1)                           ; 00004A4A 137C 0005 0002
	move.w  ($4,A6),D0                            ; 00004A50 302E 0004
	beq.s   L_004AAC                              ; 00004A54 6756
	tst.b   (A2)                                  ; 00004A56 4A12
	btst    #$6,($8,A1)                           ; 00004A58 0829 0006 0008
	beq.s   L_004A8C                              ; 00004A5E 672C
	move.w  ($2,A6),D1                            ; 00004A60 322E 0002
	subq.w  #1,D0                                 ; 00004A64 5340

L_004A66:
	tst.b   (A2)                                  ; 00004A66 4A12
	move.b  ($10,A6,D1.w),($c,A1)                 ; 00004A68 1376 1010 000C
	addq.w  #1,D1                                 ; 00004A6E 5241
	andi.w  #$3ff,D1                              ; 00004A70 0241 03FF
	tst.b   (A2)                                  ; 00004A74 4A12
	btst    #$6,($8,A1)                           ; 00004A76 0829 0006 0008
	dbeq    D0,L_004A66                           ; 00004A7C 57C8 FFE8
	beq.s   L_004A84                              ; 00004A80 6702
	moveq   #$0,D0                                ; 00004A82 7000

L_004A84:
	move.w  D1,($2,A6)                            ; 00004A84 3D41 0002
	move.w  D0,($4,A6)                            ; 00004A88 3D40 0004

L_004A8C:
	st      ($e,A6)                               ; 00004A8C 50EE 000E
	tst.b   (A2)                                  ; 00004A90 4A12
	sf      ($2,A1)                               ; 00004A92 51E9 0002
	ori.b   #$40,($6,A6)                          ; 00004A96 002E 0040 0006
	tst.b   (A2)                                  ; 00004A9C 4A12
	move.b  ($6,A6),($c,A1)                       ; 00004A9E 136E 0006 000C
	move    (A7)+,SR                              ; 00004AA4 46DF
	movem.l (A7)+,D0-D1/A1-A2                     ; 00004AA6 4CDF 0603
	rts                                           ; 00004AAA 4E75

L_004AAC:
	sf      ($e,A6)                               ; 00004AAC 51EE 000E
	tst.b   (A2)                                  ; 00004AB0 4A12
	move.b  #$40,($6,A1)                          ; 00004AB2 137C 0040 0006
	move    (A7)+,SR                              ; 00004AB8 46DF
	movem.l (A7)+,D0-D1/A1-A2                     ; 00004ABA 4CDF 0603
	rts                                           ; 00004ABE 4E75

L_004AC0:
	movem.l A0-A1,-(A7)                           ; 00004AC0 48E7 00C0
	lea     L_005C3E(pc),A1                       ; 00004AC4 43FA 1178
	moveq   #$5f,D0                               ; 00004AC8 705F

L_004ACA:
	move.b  (A0)+,(A1)+                           ; 00004ACA 12D8
	dbeq    D0,L_004ACA                           ; 00004ACC 57C8 FFFC
	beq.s   L_004AD4                              ; 00004AD0 6702
	clr.b   -(A1)                                 ; 00004AD2 4221

L_004AD4:
	movem.l (A7)+,A0-A1                           ; 00004AD4 4CDF 0300
	rts                                           ; 00004AD8 4E75

L_004ADA:
	move.l  A0,-(A7)                              ; 00004ADA 2F08
	lea     L_005C3E(pc),A0                       ; 00004ADC 41FA 1160
	move.l  A0,D0                                 ; 00004AE0 2008
	movea.l (A7)+,A0                              ; 00004AE2 205F
	rts                                           ; 00004AE4 4E75

L_004AE6:
	movem.l D1-D7/A0-A1,-(A7)                     ; 00004AE6 48E7 7FC0
	lea     L_005C3E(pc),A1                       ; 00004AEA 43FA 1152
	moveq   #-$21,D7                              ; 00004AEE 7EDF
	moveq   #$5f,D0                               ; 00004AF0 705F

L_004AF2:
	move.b  (A0)+,D1                              ; 00004AF2 1218
	beq.s   L_004B1E                              ; 00004AF4 6728
	smi     D3                                    ; 00004AF6 5BC3
	move.b  (A1)+,D2                              ; 00004AF8 1419
	smi     D4                                    ; 00004AFA 5BC4
	eor.b   D4,D3                                 ; 00004AFC B903
	bne.s   L_004B26                              ; 00004AFE 6626
	tst.b   D4                                    ; 00004B00 4A04
	bmi.s   L_004B14                              ; 00004B02 6B10
	cmp.b   #$61,D1                               ; 00004B04 B23C 0061
	bcs.s   L_004B14                              ; 00004B08 650A
	cmp.b   #$7a,D1                               ; 00004B0A B23C 007A
	bhi.s   L_004B14                              ; 00004B0E 6204
	and.b   D7,D1                                 ; 00004B10 C207
	and.b   D7,D2                                 ; 00004B12 C407

L_004B14:
	cmp.b   D1,D2                                 ; 00004B14 B401
	dbne    D0,L_004AF2                           ; 00004B16 56C8 FFDA
	bne.s   L_004B26                              ; 00004B1A 660A
	bra.s   L_004B22                              ; 00004B1C 6004

L_004B1E:
	tst.b   (A1)                                  ; 00004B1E 4A11
	bne.s   L_004B26                              ; 00004B20 6604

L_004B22:
	moveq   #$0,D0                                ; 00004B22 7000
	bra.s   L_004B28                              ; 00004B24 6002

L_004B26:
	moveq   #-$1,D0                               ; 00004B26 70FF

L_004B28:
	movem.l (A7)+,D1-D7/A0-A1                     ; 00004B28 4CDF 03FE
	rts                                           ; 00004B2C 4E75

L_004B2E:
	move.l  A6,-(A7)                              ; 00004B2E 2F0E
	lea     L_005E88(pc),A6                       ; 00004B30 4DFA 1356
	move.w  D1,D0                                 ; 00004B34 3001
	bmi.s   L_004B50                              ; 00004B36 6B18
	cmpi.w  #$80,D0                               ; 00004B38 0C40 0080
	bls.s   L_004B42                              ; 00004B3C 6304
	move.w  #$80,D0                               ; 00004B3E 303C 0080

L_004B42:
	cmp.w   (-$348,A6),D0                         ; 00004B42 B06E FCB8
	beq.s   L_004B50                              ; 00004B46 6708
	move.w  D0,(-$348,A6)                         ; 00004B48 3D40 FCB8
	move.w  D0,(-$346,A6)                         ; 00004B4C 3D40 FCBA

L_004B50:
	move.w  (-$348,A6),D0                         ; 00004B50 302E FCB8
	movea.l (A7)+,A6                              ; 00004B54 2C5F
	rts                                           ; 00004B56 4E75

L_004B58:
	move.l  A6,-(A7)                              ; 00004B58 2F0E
	lea     L_005E88(pc),A6                       ; 00004B5A 4DFA 132C
	move.w  D1,D0                                 ; 00004B5E 3001
	bmi.s   L_004B7A                              ; 00004B60 6B18
	cmpi.w  #$80,D0                               ; 00004B62 0C40 0080
	bls.s   L_004B6C                              ; 00004B66 6304
	move.w  #$80,D0                               ; 00004B68 303C 0080

L_004B6C:
	cmp.w   (-$354,A6),D0                         ; 00004B6C B06E FCAC
	beq.s   L_004B7A                              ; 00004B70 6708
	move.w  D0,(-$354,A6)                         ; 00004B72 3D40 FCAC
	st      (-$344,A6)                            ; 00004B76 50EE FCBC

L_004B7A:
	move.w  (-$354,A6),D0                         ; 00004B7A 302E FCAC
	movea.l (A7)+,A6                              ; 00004B7E 2C5F
	rts                                           ; 00004B80 4E75

L_004B82:
	move.l  A6,-(A7)                              ; 00004B82 2F0E
	lea     L_005E88(pc),A6                       ; 00004B84 4DFA 1302
	tst.w   D1                                    ; 00004B88 4A41
	beq.s   L_004B94                              ; 00004B8A 6708
	move.w  D1,(-$6a,A6)                          ; 00004B8C 3D41 FF96
	clr.w   (-$3b4,A6)                            ; 00004B90 426E FC4C

L_004B94:
	move.w  (-$6a,A6),D0                          ; 00004B94 302E FF96
	movea.l (A7)+,A6                              ; 00004B98 2C5F
	rts                                           ; 00004B9A 4E75

L_004B9C:
	move.l  A0,D0                                 ; 00004B9C 2008
	lea     L_005E88(pc),A0                       ; 00004B9E 41FA 12E8
	exg     D0,A0                                 ; 00004BA2 C188
	rts                                           ; 00004BA4 4E75

L_004BA6:
	move.l  A0,D0                                 ; 00004BA6 2008
	lea     L_00001C(pc),A0                       ; 00004BA8 41FA B472
	exg     D0,A0                                 ; 00004BAC C188
	rts                                           ; 00004BAE 4E75

L_004BB0:
	move.l  A0,D0                                 ; 00004BB0 2008
	lea     L_0056A6(pc),A0                       ; 00004BB2 41FA 0AF2
	exg     D0,A0                                 ; 00004BB6 C188
	rts                                           ; 00004BB8 4E75

L_004BBA:
	move.l  L_005B06(pc),D0                       ; 00004BBA 203A 0F4A
	rts                                           ; 00004BBE 4E75

L_004BC0:
	move.w  L_005E1C(pc),D0                       ; 00004BC0 303A 125A
	rts                                           ; 00004BC4 4E75

L_004BC6:
	movem.l L_005E48(pc),D0-D1                    ; 00004BC6 4CFA 0003 127E
	rts                                           ; 00004BCC 4E75

L_004BCE:
	move.l  A0,-(A7)                              ; 00004BCE 2F08
	lea     L_005E88(pc),A0                       ; 00004BD0 41FA 12B6
	move.l  (-$382,A0),D0                         ; 00004BD4 2028 FC7E
	beq.s   L_004BE6                              ; 00004BD8 670C
	movea.l D0,A0                                 ; 00004BDA 2040
	move.l  ($14,A0),D0                           ; 00004BDC 2028 0014
	beq.s   L_004BE6                              ; 00004BE0 6704
	adda.l  D0,A0                                 ; 00004BE2 D1C0
	bra.s   L_004BEA                              ; 00004BE4 6004

L_004BE6:
	lea     L_005C34(pc),A0                       ; 00004BE6 41FA 104C

L_004BEA:
	move.l  A0,D0                                 ; 00004BEA 2008
	movea.l (A7)+,A0                              ; 00004BEC 205F
	rts                                           ; 00004BEE 4E75

L_004BF0:
	move.l  L_005AFE(pc),D0                       ; 00004BF0 203A 0F0C
	bne.s   L_004BFC                              ; 00004BF4 6606
	pea     L_005C34(pc)                          ; 00004BF6 487A 103C
	move.l  (A7)+,D0                              ; 00004BFA 201F

L_004BFC:
	rts                                           ; 00004BFC 4E75

L_004BFE:
	move.l  A6,-(A7)                              ; 00004BFE 2F0E
	lea     L_005E88(pc),A6                       ; 00004C00 4DFA 1286
	add.w   D1,(-$256,A6)                         ; 00004C04 D36E FDAA
	move.w  (-$256,A6),D0                         ; 00004C08 302E FDAA
	movea.l (A7)+,A6                              ; 00004C0C 2C5F
	rts                                           ; 00004C0E 4E75

L_004C10:
	move.l  A6,-(A7)                              ; 00004C10 2F0E
	lea     L_005E88(pc),A6                       ; 00004C12 4DFA 1274
	move.l  D1,(-$33c,A6)                         ; 00004C16 2D41 FCC4
	movea.l (A7)+,A6                              ; 00004C1A 2C5F
	rts                                           ; 00004C1C 4E75

L_004C1E:
	move.w  #$100,D0                              ; 00004C1E 303C 0100
	rts                                           ; 00004C22 4E75

L_004C24:
	rts                                           ; 00004C24 4E75

L_004C26:
	movem.l D1/A0,-(A7)                           ; 00004C26 48E7 4080
	lea     L_005E88(pc),A0                       ; 00004C2A 41FA 125C
	lsl.w   #8,D1                                 ; 00004C2E E149
	adda.w  D1,A0                                 ; 00004C30 D0C1
	ori.b   #$a0,($2,A0)                          ; 00004C32 0028 00A0 0002
	movem.l (A7)+,D1/A0                           ; 00004C38 4CDF 0102
	rts                                           ; 00004C3C 4E75

L_004C3E:
	movem.l D1/A6,-(A7)                           ; 00004C3E 48E7 4002
	lea     L_005E88(pc),A6                       ; 00004C42 4DFA 1244
	move.w  D1,D0                                 ; 00004C46 3001
	ext.w   D0                                    ; 00004C48 4880
	tst.w   D1                                    ; 00004C4A 4A41
	bpl.s   L_004C5A                              ; 00004C4C 6A0C
	add.w   (-$7a,A6),D0                          ; 00004C4E D06E FF86
	cmpi.w  #$7f,D0                               ; 00004C52 0C40 007F
	ble.s   L_004C5A                              ; 00004C56 6F02
	moveq   #$7f,D0                               ; 00004C58 707F

L_004C5A:
	cmpi.w  #-$7f,D0                              ; 00004C5A 0C40 FF81
	bge.s   L_004C62                              ; 00004C5E 6C02
	moveq   #-$7f,D0                              ; 00004C60 7081

L_004C62:
	ext.w   D0                                    ; 00004C62 4880
	move.w  D0,(-$7a,A6)                          ; 00004C64 3D40 FF86
	bsr.w   L_00343A                              ; 00004C68 6100 E7D0
	movem.l (A7)+,D1/A6                           ; 00004C6C 4CDF 4002
	rts                                           ; 00004C70 4E75

L_004C72:
	move.l  L_005E28(pc),D0                       ; 00004C72 203A 11B4
	move.l  L_005E24(pc),D1                       ; 00004C76 223A 11AC
	rts                                           ; 00004C7A 4E75

L_004C7C:
	move.l  L_005E20(pc),D0                       ; 00004C7C 203A 11A2
	rts                                           ; 00004C80 4E75

L_004C82:
	move.l  L_005E34(pc),D0                       ; 00004C82 203A 11B0
	rts                                           ; 00004C86 4E75

L_004C88:
	movem.l D1-D7/A0-A5,-(A7)                     ; 00004C88 48E7 7FFC
	moveq   #$0,D1                                ; 00004C8C 7200
	move.w  ($4,A6),D1                            ; 00004C8E 322E 0004
	lsl.w   #8,D1                                 ; 00004C92 E149
	add.l   (A6),D1                               ; 00004C94 D296
	add.l   #$5f78,D1                             ; 00004C96 D2BC 0000 5F78
	moveq   #$7,D2                                ; 00004C9C 7407

L_004C9E:
	moveq   #$f,D0                                ; 00004C9E 700F
	and.b   D6,D0                                 ; 00004CA0 C006
	beq.s   L_004CAA                              ; 00004CA2 6706
	add.l   #$410,D1                              ; 00004CA4 D2BC 0000 0410

L_004CAA:
	ror.l   #4,D6                                 ; 00004CAA E89E
	dbra    D2,L_004C9E                           ; 00004CAC 51CA FFF0
	move.l  D1,-(A7)                              ; 00004CB0 2F01
	pea     L_000000-$F0(pc)                      ; 00004CB2 487A B25C
	dc.w    $ff4a                                 ; 00004CB6 FF4A
	addq.l  #8,A7                                 ; 00004CB8 508F
	tst.l   D0                                    ; 00004CBA 4A80
	bmi.s   L_004CEC                              ; 00004CBC 6B2E
	move.l  D1,D0                                 ; 00004CBE 2001
	movea.l A7,A5                                 ; 00004CC0 2A4F
	pea     L_005066(pc)                          ; 00004CC2 487A 03A2
	moveq   #-$10,D0                              ; 00004CC6 70F0
	add.l   (A6),D0                               ; 00004CC8 D096
	beq.s   L_004CE2                              ; 00004CCA 6716
	subq.l  #4,A7                                 ; 00004CCC 598F
	movea.l A7,A0                                 ; 00004CCE 204F
	moveq   #$0,D2                                ; 00004CD0 7400
	divu.w  #$400,D0                              ; 00004CD2 80FC 0400
	bsr.s   L_004CF4                              ; 00004CD6 611C
	clr.b   (A0)                                  ; 00004CD8 4210
	pea     (A7)                                  ; 00004CDA 4857
	dc.w    $ff09                                 ; 00004CDC FF09
	pea     L_005046(pc)                          ; 00004CDE 487A 0366

L_004CE2:
	dc.w    $ff09                                 ; 00004CE2 FF09
	movea.l A5,A7                                 ; 00004CE4 2E4D
	movem.l (A7)+,D1-D7/A0-A5                     ; 00004CE6 4CDF 3FFE
	rts                                           ; 00004CEA 4E75

L_004CEC:
	pea     L_000D93(pc)                          ; 00004CEC 487A C0A5
	bra.w   L_00051A                              ; 00004CF0 6000 B828

L_004CF4:
	andi.l  #$ffff,D0                             ; 00004CF4 0280 0000 FFFF
	divu.w  #$a,D0                                ; 00004CFA 80FC 000A
	tst.w   D0                                    ; 00004CFE 4A40
	beq.s   L_004D08                              ; 00004D00 6706
	move.l  D0,-(A7)                              ; 00004D02 2F00
	bsr.s   L_004CF4                              ; 00004D04 61EE
	move.l  (A7)+,D0                              ; 00004D06 201F

L_004D08:
	swap    D0                                    ; 00004D08 4840
	addi.b  #$30,D0                               ; 00004D0A 0600 0030
	move.b  D0,(A0)+                              ; 00004D0E 10C0
	rts                                           ; 00004D10 4E75

L_004D12:
	movem.l D1/A0-A1,-(A7)                        ; 00004D12 48E7 40C0
	moveq   #$28,D7                               ; 00004D16 7E28
	movea.l #$eafa01,A0                           ; 00004D18 207C 00EA FA01
	bsr.s   L_004D74                              ; 00004D1E 6154
	andi.b  #$2,D0                                ; 00004D20 0200 0002
	or.b    D0,D7                                 ; 00004D24 8E00
	lea     ($10,A0),A0                           ; 00004D26 41E8 0010
	bsr.s   L_004D74                              ; 00004D2A 6148
	andi.b  #$4,D0                                ; 00004D2C 0200 0004
	or.b    D0,D7                                 ; 00004D30 8E00
	lea     ($88).w,A1                            ; 00004D32 43F8 0088
	cmpi.w  #$22ff,(A1)                           ; 00004D36 0C51 22FF
	beq.s   L_004D6E                              ; 00004D3A 6732
	movea.l (A1),A0                               ; 00004D3C 2051
	subq.l  #8,A0                                 ; 00004D3E 5188
	cmpi.l  #$50434d38,(A0)                       ; 00004D40 0C90 5043 4D38
	bne.s   L_004D6E                              ; 00004D46 6626
	bset    #$10,D7                               ; 00004D48 08C7 0010
	move.w  #$300,D0                              ; 00004D4C 303C 0300
	trap    #$2                                   ; 00004D50 4E42
	tst.l   D0                                    ; 00004D52 4A80
	ble.s   L_004D5A                              ; 00004D54 6F04
	bset    #$4,D7                                ; 00004D56 08C7 0004

L_004D5A:
	cmpi.l  #$31303040,-(A0)                      ; 00004D5A 0CA0 3130 3040
	bcs.s   L_004D6E                              ; 00004D60 650C
	cmpi.l  #$52444e5f,-(A0)                      ; 00004D62 0CA0 5244 4E5F
	bne.s   L_004D6E                              ; 00004D68 6604
	bset    #$17,D7                               ; 00004D6A 08C7 0017

L_004D6E:
	movem.l (A7)+,D1/A0-A1                        ; 00004D6E 4CDF 0302
	rts                                           ; 00004D72 4E75

L_004D74:
	link    A5,#-$2                               ; 00004D74 4E55 FFFE
	move.w  #$1,-(A7)                             ; 00004D78 3F3C 0001
	pea     (-$2,A5)                              ; 00004D7C 486D FFFE
	pea     (A0)                                  ; 00004D80 4850
	dc.w    $fff7                                 ; 00004D82 FFF7
	tst.l   D0                                    ; 00004D84 4A80
	seq     D0                                    ; 00004D86 57C0
	unlk    A5                                    ; 00004D88 4E5D
	rts                                           ; 00004D8A 4E75

L_004D8C:
	move.l  A0,-(A7)                              ; 00004D8C 2F08
	movea.l ($90).w,A0                            ; 00004D8E 2078 0090
	cmpi.l  #$2d4d4344,(-$c,A0)                   ; 00004D92 0CA8 2D4D 4344 FFF4
	bne.s   L_004DB2                              ; 00004D9A 6616
	cmpi.l  #$5256302d,(-$8,A0)                   ; 00004D9C 0CA8 5256 302D FFF8
	bne.s   L_004DB2                              ; 00004DA4 660C
	cmpi.l  #$680001,-(A0)                        ; 00004DA6 0CA0 0068 0001
	bne.s   L_004DB2                              ; 00004DAC 6604
	moveq   #$0,D0                                ; 00004DAE 7000
	bra.s   L_004DB4                              ; 00004DB0 6002

L_004DB2:
	moveq   #-$1,D0                               ; 00004DB2 70FF

L_004DB4:
	movea.l (A7)+,A0                              ; 00004DB4 205F
	rts                                           ; 00004DB6 4E75

L_004DB8:
	rts                                           ; 00004DB8 4E75

L_004DBA:
	move.l  #$50010,(A6)                          ; 00004DBA 2CBC 0005 0010
	move.w  #$40,($4,A6)                          ; 00004DC0 3D7C 0040 0004
	move.w  #$14,($6,A6)                          ; 00004DC6 3D7C 0014 0006
	clr.l   ($8,A6)                               ; 00004DCC 42AE 0008
	clr.l   ($c,A6)                               ; 00004DD0 42AE 000C
	clr.l   ($10,A6)                              ; 00004DD4 42AE 0010
	btst    #$1,D7                                ; 00004DD8 0807 0001
	beq.s   L_004DE2                              ; 00004DDC 6704
	addq.b  #1,($f,A6)                            ; 00004DDE 522E 000F

L_004DE2:
	tst.b   (A2)+                                 ; 00004DE2 4A1A
	beq.s   L_004DB8                              ; 00004DE4 67D2

L_004DE6:
	move.b  (A2)+,D0                              ; 00004DE6 101A
	beq.s   L_004DB8                              ; 00004DE8 67CE
	cmpi.b  #$20,D0                               ; 00004DEA 0C00 0020
	bls.s   L_004DE6                              ; 00004DEE 63F6
	cmpi.b  #$2d,D0                               ; 00004DF0 0C00 002D
	beq.s   L_004E0E                              ; 00004DF4 6718
	cmpi.b  #$2f,D0                               ; 00004DF6 0C00 002F
	beq.s   L_004E0E                              ; 00004DFA 6712
	lea     (-$1,A2),A0                           ; 00004DFC 41EA FFFF
	move.l  A0,($10,A6)                           ; 00004E00 2D48 0010

L_004E04:
	cmpi.b  #$20,(A2)+                            ; 00004E04 0C1A 0020
	bhi.s   L_004E04                              ; 00004E08 62FA
	subq.l  #1,A2                                 ; 00004E0A 538A
	bra.s   L_004DE6                              ; 00004E0C 60D8

L_004E0E:
	lea     L_004E4A(pc),A0                       ; 00004E0E 41FA 003A
	movea.l A0,A1                                 ; 00004E12 2248
	move.b  (A2)+,D0                              ; 00004E14 101A
	beq.s   L_004DB8                              ; 00004E16 67A0

L_004E18:
	move.b  (A0)+,D1                              ; 00004E18 1218
	beq.s   L_004E42                              ; 00004E1A 6726
	bmi.s   L_004E42                              ; 00004E1C 6B24
	cmpi.b  #$61,D0                               ; 00004E1E 0C00 0061
	bls.s   L_004E2E                              ; 00004E22 630A
	cmpi.b  #$7a,D0                               ; 00004E24 0C00 007A
	bhi.s   L_004E2E                              ; 00004E28 6204
	andi.b  #$df,D0                               ; 00004E2A 0200 00DF

L_004E2E:
	cmp.b   D1,D0                                 ; 00004E2E B001
	bne.s   L_004E18                              ; 00004E30 66E6
	move.l  A0,D0                                 ; 00004E32 2008
	sub.l   A1,D0                                 ; 00004E34 9089
	add.w   D0,D0                                 ; 00004E36 D040
	move.w  L_004E52(pc,D0.w),D0                  ; 00004E38 303B 0018
	jsr     L_004E54(pc,D0.w)                     ; 00004E3C 4EBB 0016
	bra.s   L_004DE6                              ; 00004E40 60A4

L_004E42:
	pea     L_0052C4(pc)                          ; 00004E42 487A 0480
	bra.w   L_00051A                              ; 00004E46 6000 B6D2

L_004E4A:
	dc.b    'RBKTUWIH'                            ; 00004E4A

L_004E52:
	dc.b    $3F,$00                               ; 00004E52

L_004E54:
	dc.w    L_004E66-L_004E54                     ; 00004E54
	dc.w    L_004E82-L_004E54                     ; 00004E56
	dc.w    L_004E92-L_004E54                     ; 00004E58
	dc.w    L_004EA8-L_004E54                     ; 00004E5A
	dc.w    L_004EA2-L_004E54                     ; 00004E5C
	dc.w    L_004E98-L_004E54                     ; 00004E5E
	dc.w    L_004EC2-L_004E54                     ; 00004E60
	dc.w    L_004F5C-L_004E54                     ; 00004E62
	dc.w    L_004F5C-L_004E54                     ; 00004E64

L_004E66:
	addq.l  #4,A7                                 ; 00004E66 588F
	bsr.w   L_004D8C                              ; 00004E68 6100 FF22
	bmi.w   L_004F6C                              ; 00004E6C 6B00 00FE
	moveq   #$0,D0                                ; 00004E70 7000
	trap    #$4                                   ; 00004E72 4E44
	tst.l   D0                                    ; 00004E74 4A80
	bmi.w   L_004F74                              ; 00004E76 6B00 00FC
	pea     L_005256(pc)                          ; 00004E7A 487A 03DA
	dc.w    $ff09                                 ; 00004E7E FF09
	dc.w    $ff00                                 ; 00004E80 FF00

L_004E82:
	bsr.w   L_004F9C                              ; 00004E82 6100 0118
	mulu.w  #$400,D1                              ; 00004E86 C2FC 0400
	moveq   #$10,D0                               ; 00004E8A 7010
	add.l   D0,D1                                 ; 00004E8C D280
	move.l  D1,(A6)                               ; 00004E8E 2C81
	rts                                           ; 00004E90 4E75

L_004E92:
	st      ($9,A6)                               ; 00004E92 50EE 0009
	rts                                           ; 00004E96 4E75

L_004E98:
	bsr.w   L_004F9C                              ; 00004E98 6100 0102
	move.w  D1,($6,A6)                            ; 00004E9C 3D41 0006
	rts                                           ; 00004EA0 4E75

L_004EA2:
	st      ($8,A6)                               ; 00004EA2 50EE 0008
	rts                                           ; 00004EA6 4E75

L_004EA8:
	bsr.w   L_004F9C                              ; 00004EA8 6100 00F2
	cmpi.w  #$20,D1                               ; 00004EAC 0C41 0020
	bcs.w   L_004F8C                              ; 00004EB0 6500 00DA
	cmpi.w  #$80,D1                               ; 00004EB4 0C41 0080
	bhi.w   L_004F8C                              ; 00004EB8 6200 00D2
	move.w  D1,($4,A6)                            ; 00004EBC 3D41 0004
	rts                                           ; 00004EC0 4E75

L_004EC2:
	moveq   #$0,D4                                ; 00004EC2 7800
	moveq   #$0,D3                                ; 00004EC4 7600
	moveq   #$0,D2                                ; 00004EC6 7400

L_004EC8:
	move.b  (A2)+,D0                              ; 00004EC8 101A
	bmi.w   L_004F84                              ; 00004ECA 6B00 00B8
	beq.s   L_004F16                              ; 00004ECE 6746
	cmpi.b  #$61,D0                               ; 00004ED0 0C00 0061
	bcs.s   L_004EE0                              ; 00004ED4 650A
	cmpi.b  #$7a,D0                               ; 00004ED6 0C00 007A
	bhi.s   L_004EE0                              ; 00004EDA 6204
	andi.b  #$df,D0                               ; 00004EDC 0200 00DF

L_004EE0:
	lea     L_004F1E(pc),A0                       ; 00004EE0 41FA 003C

L_004EE4:
	move.b  (A0)+,D1                              ; 00004EE4 1218
	beq.w   L_004F84                              ; 00004EE6 6700 009C
	cmp.b   D0,D1                                 ; 00004EEA B200
	bne.s   L_004EE4                              ; 00004EEC 66F6
	moveq   #$0,D0                                ; 00004EEE 7000
	move.b  ($b,A0),D0                            ; 00004EF0 1028 000B
	beq.s   L_004F16                              ; 00004EF4 6720
	bmi.s   L_004F36                              ; 00004EF6 6B3E
	bset    D0,D4                                 ; 00004EF8 01C4
	bne.w   L_004F94                              ; 00004EFA 6600 0098
	cmpi.b  #$40,D0                               ; 00004EFE 0C00 0040
	bcs.s   L_004F10                              ; 00004F02 650C
	lea     L_0046CA(pc),A3                       ; 00004F04 47FA F7C4
	move.w  #$c04,(A3)                            ; 00004F08 36BC 0C04
	and.b   #$f,D0                                ; 00004F0C C03C 000F

L_004F10:
	bsr.s   L_004F50                              ; 00004F10 613E
	bne.s   L_004EC8                              ; 00004F12 66B4
	bra.s   L_004F7C                              ; 00004F14 6066

L_004F16:
	move.l  D3,($c,A6)                            ; 00004F16 2D43 000C
	subq.l  #1,A2                                 ; 00004F1A 538A
	rts                                           ; 00004F1C 4E75

L_004F1E:
	dc.b    $09,$20,$2D,$2F,$31,$32,$52,$50,$49,$48,$41,$00,$00,$00,$00,$00; 00004F1E
	dc.b    $01,$02,$03,$04,$05,$43,$FF,$00       ; 00004F2E

L_004F36:
	moveq   #$0,D3                                ; 00004F36 7600
	moveq   #$0,D2                                ; 00004F38 7400
	moveq   #$1,D0                                ; 00004F3A 7001
	bsr.s   L_004F50                              ; 00004F3C 6112
	moveq   #$2,D0                                ; 00004F3E 7002
	bsr.s   L_004F50                              ; 00004F40 610E
	moveq   #$4,D0                                ; 00004F42 7004
	bsr.s   L_004F50                              ; 00004F44 610A
	moveq   #$3,D0                                ; 00004F46 7003
	bsr.s   L_004F50                              ; 00004F48 6106
	move.l  D3,($c,A6)                            ; 00004F4A 2D43 000C
	rts                                           ; 00004F4E 4E75

L_004F50:
	btst    D0,D7                                 ; 00004F50 0107
	beq.s   L_004F5A                              ; 00004F52 6706
	lsl.l   D2,D0                                 ; 00004F54 E5A8
	or.l    D0,D3                                 ; 00004F56 8680
	addq.w  #4,D2                                 ; 00004F58 5842

L_004F5A:
	rts                                           ; 00004F5A 4E75

L_004F5C:
	pea     L_005084(pc)                          ; 00004F5C 487A 0126
	dc.w    $ff09                                 ; 00004F60 FF09
	dc.w    $ff00                                 ; 00004F62 FF00

L_004F64:
	pea     L_005004(pc)                          ; 00004F64 487A 009E
	bra.w   L_00051A                              ; 00004F68 6000 B5B0

L_004F6C:
	pea     L_0051E4(pc)                          ; 00004F6C 487A 0276
	bra.w   L_00051A                              ; 00004F70 6000 B5A8

L_004F74:
	pea     L_005239(pc)                          ; 00004F74 487A 02C3
	bra.w   L_00051A                              ; 00004F78 6000 B5A0

L_004F7C:
	pea     L_005297(pc)                          ; 00004F7C 487A 0319
	bra.w   L_00051A                              ; 00004F80 6000 B598

L_004F84:
	pea     L_005272(pc)                          ; 00004F84 487A 02EC
	bra.w   L_00051A                              ; 00004F88 6000 B590

L_004F8C:
	pea     L_005218(pc)                          ; 00004F8C 487A 028A
	bra.w   L_00051A                              ; 00004F90 6000 B588

L_004F94:
	pea     L_0052EB(pc)                          ; 00004F94 487A 0355
	bra.w   L_00051A                              ; 00004F98 6000 B580

L_004F9C:
	moveq   #$0,D1                                ; 00004F9C 7200
	moveq   #$0,D0                                ; 00004F9E 7000

L_004FA0:
	move.b  (A2)+,D0                              ; 00004FA0 101A
	beq.s   L_004FC6                              ; 00004FA2 6722
	cmpi.b  #$3a,D0                               ; 00004FA4 0C00 003A
	beq.s   L_004FA0                              ; 00004FA8 67F6
	subi.b  #$30,D0                               ; 00004FAA 0400 0030
	bcs.s   L_004FC6                              ; 00004FAE 6516
	cmpi.b  #$a,D0                                ; 00004FB0 0C00 000A
	bcc.s   L_004FC6                              ; 00004FB4 6410
	mulu.w  #$a,D1                                ; 00004FB6 C2FC 000A
	add.l   D0,D1                                 ; 00004FBA D280
	cmpi.l  #$ffff,D1                             ; 00004FBC 0C81 0000 FFFF
	bcs.s   L_004FA0                              ; 00004FC2 65DC
	bra.s   L_004F8C                              ; 00004FC4 60C6

L_004FC6:
	subq.l  #1,A2                                 ; 00004FC6 538A
	rts                                           ; 00004FC8 4E75

L_004FCA:
	dc.b    'X68k music creat'                    ; 00004FCA
	dc.b    'ive driver versi'                    ; 00004FDA
	dc.b    'on 0.68 (c)1993-'                    ; 00004FEA
	dc.b    $39,$37,$20,$43,$55,$4C,$2E,$0D,$0A,$00; 00004FFA

L_005004:
	dc.b    $54,$52,$41,$50,$20,$23,$34,$20,$82,$AA,$8A,$F9,$82,$C9,$8E,$67; 00005004
	dc.b    $97,$70,$82,$B3,$82,$EA,$82,$C4,$82,$A2,$82,$DC,$82,$B7,$0D,$0A; 00005014
	dc.b    $0D,$0A,$00                           ; 00005024

L_005027:
	dc.b    $4D,$43,$44,$52,$56,$82,$CD,$8A,$F9,$82,$C9,$8F,$ED,$92,$93,$82; 00005027
	dc.b    $B5,$82,$C4,$82,$A2,$82,$DC,$82,$B7,$0D,$0A,$0D,$0A,$00,$00; 00005037

L_005046:
	dc.b    $4B,$42,$20,$82,$CC,$8C,$C5,$92,$E8,$83,$6F,$83,$62,$83,$74,$83; 00005046
	dc.b    $40,$82,$F0,$8A,$6D,$95,$DB,$82,$B5,$82,$DC,$82,$B7,$0D,$0A,$00; 00005056

L_005066:
	dc.b    $8C,$C5,$92,$E8,$83,$6F,$83,$62,$83,$74,$83,$40,$82,$CD,$8A,$6D; 00005066
	dc.b    $95,$DB,$82,$B5,$82,$DC,$82,$B9,$82,$F1,$0D,$0A,$00,$00; 00005076

L_005084:
	dc.b    $8E,$67,$97,$70,$96,$40,$3A,$20,$4D,$43,$44,$52,$56,$20,$5B,$83; 00005084
	dc.b    $49,$83,$76,$83,$56,$83,$87,$83,$93,$5D,$0D,$0A,$09,$2D,$52,$09; 00005094
	dc.b    $09,$8F,$ED,$92,$93,$82,$F0,$89,$F0,$8F,$9C,$82,$B5,$82,$DC,$82; 000050A4
	dc.b    $B7,$0D,$0A,$09,$2D,$4B,$09,$09,$83,$4C,$81,$5B,$83,$7B,$81,$5B; 000050B4
	dc.b    $83,$68,$83,$52,$83,$93,$83,$67,$83,$8D,$81,$5B,$83,$8B,$82,$F0; 000050C4
	dc.b    $8B,$D6,$8E,$7E,$82,$B5,$82,$DC,$82,$B7,$0D,$0A,$09,$2D,$42,$6E; 000050D4
	dc.b    $09,$09,$83,$6F,$83,$62,$83,$74,$83,$40,$83,$54,$83,$43,$83,$59; 000050E4
	dc.b    $82,$F0,$8E,$77,$92,$E8,$82,$B5,$82,$DC,$82,$B7,$09,$28,$64,$65; 000050F4
	dc.b    $66,$2E,$33,$32,$30,$29,$0D,$0A,$09,$2D,$54,$6E,$09,$09,$83,$67; 00005104
	dc.b    $83,$89,$83,$62,$83,$4E,$90,$94,$82,$F0,$8E,$77,$92,$E8,$82,$B5; 00005114
	dc.b    $82,$DC,$82,$B7,$09,$28,$64,$65,$66,$2E,$36,$34,$29,$0D,$0A,$09; 00005124
	dc.b    $2D,$57,$6E,$09,$09,$83,$47,$83,$4E,$83,$58,$83,$4E,$83,$8B,$81; 00005134
	dc.b    $5B,$83,$56,$83,$75,$91,$97,$90,$4D,$83,$45,$83,$46,$83,$43,$83; 00005144
	dc.b    $67,$82,$F0,$8E,$77,$92,$E8,$82,$B5,$82,$DC,$82,$B7,$09,$28,$64; 00005154
	dc.b    $65,$66,$2E,$32,$30,$29,$0D,$0A,$09,$2D,$49,$3C,$31,$32,$52,$50; 00005164
	dc.b    $49,$3E,$09,$4D,$49,$44,$49,$83,$43,$83,$93,$83,$5E,$81,$5B,$83; 00005174
	dc.b    $74,$83,$46,$81,$5B,$83,$58,$82,$CC,$8F,$87,$8F,$98,$82,$F0,$8E; 00005184
	dc.b    $77,$92,$E8,$82,$B5,$82,$DC,$82,$B7,$09,$28,$64,$65,$66,$2E,$42; 00005194
	dc.b    $4F,$41,$52,$44,$23,$31,$82,$CC,$82,$DD,$29,$0D,$0A,$09,$2D,$49; 000051A4
	dc.b    $41,$09,$09,$4D,$49,$44,$49,$83,$43,$83,$93,$83,$5E,$81,$5B,$83; 000051B4
	dc.b    $74,$83,$46,$81,$5B,$83,$58,$82,$F0,$8E,$A9,$93,$AE,$82,$C9,$8A; 000051C4
	dc.b    $84,$82,$E8,$93,$96,$82,$C4,$82,$DC,$82,$B7,$0D,$0A,$0D,$0A,$00; 000051D4

L_0051E4:
	dc.b    $4D,$43,$44,$52,$56,$82,$AA,$8F,$ED,$92,$93,$82,$B5,$82,$C4,$82; 000051E4
	dc.b    $A2,$82,$C8,$82,$A2,$82,$A9,$81,$41,$96,$A2,$91,$CE,$89,$9E,$82; 000051F4
	dc.b    $CC,$83,$6F,$81,$5B,$83,$57,$83,$87,$83,$93,$82,$C5,$82,$B7,$0D; 00005204
	dc.b    $0A,$0D,$0A,$00                       ; 00005214

L_005218:
	dc.b    $8B,$4B,$92,$E8,$8A,$4F,$82,$CC,$90,$94,$92,$6C,$82,$AA,$8E,$77; 00005218
	dc.b    $92,$E8,$82,$B3,$82,$EA,$82,$DC,$82,$B5,$82,$BD,$0D,$0A,$0D,$0A; 00005228
	dc.b    $00                                   ; 00005238

L_005239:
	dc.b    $8F,$ED,$92,$93,$89,$F0,$8F,$9C,$82,$C5,$82,$AB,$82,$DC,$82,$B9; 00005239
	dc.b    $82,$F1,$82,$C5,$82,$B5,$82,$BD,$0D,$0A,$0D,$0A,$00; 00005249

L_005256:
	dc.b    $4D,$43,$44,$52,$56,$82,$F0,$8F,$ED,$92,$93,$89,$F0,$8F,$9C,$82; 00005256
	dc.b    $B5,$82,$DC,$82,$B5,$82,$BD,$0D,$0A,$0D,$0A,$00; 00005266

L_005272:
	dc.b    $96,$A2,$92,$E8,$8B,$60,$82,$CC,$83,$56,$83,$93,$83,$7B,$83,$8B; 00005272
	dc.b    $82,$AA,$8E,$77,$92,$E8,$82,$B3,$82,$EA,$82,$DC,$82,$B5,$82,$BD; 00005282
	dc.b    $0D,$0A,$0D,$0A,$00                   ; 00005292

L_005297:
	dc.b    $96,$A2,$8E,$C0,$91,$95,$82,$CC,$83,$43,$83,$93,$83,$5E,$81,$5B; 00005297
	dc.b    $83,$74,$83,$46,$81,$5B,$83,$58,$82,$AA,$8E,$77,$92,$E8,$82,$B3; 000052A7
	dc.b    $82,$EA,$82,$DC,$82,$B5,$82,$BD,$0D,$0A,$0D,$0A,$00; 000052B7

L_0052C4:
	dc.b    $96,$A2,$91,$CE,$89,$9E,$82,$CC,$83,$49,$83,$76,$83,$56,$83,$87; 000052C4
	dc.b    $83,$93,$82,$AA,$8E,$67,$97,$70,$82,$B3,$82,$EA,$82,$DC,$82,$B5; 000052D4
	dc.b    $82,$BD,$0D,$0A,$0D,$0A,$00           ; 000052E4

L_0052EB:
	dc.b    $83,$43,$83,$93,$83,$5E,$81,$5B,$83,$74,$83,$46,$81,$5B,$83,$58; 000052EB
	dc.b    $8E,$77,$92,$E8,$82,$AA,$8F,$64,$95,$A1,$82,$B5,$82,$C4,$82,$A2; 000052FB
	dc.b    $82,$DC,$82,$B7,$0D,$0A,$0D,$0A,$00   ; 0000530B

	ifnd __ATARI__
	bss
	else
; Work area, song buffer and all in one piece after the code, as the
; original has them after its BSS.
	endif

	ds.b    914
L_0056A6:
	ds.b    1112
L_005AFE:
	ds.b    8
L_005B06:
	ds.b    8
L_005B0E:
	ds.b    294
L_005C34:
	ds.b    10
L_005C3E:
	ds.b    96
L_005C9E:
	ds.b    4
L_005CA2:
	ds.b    4
L_005CA6:
	ds.b    144
L_005D36:
	ds.b    230
L_005E1C:
	ds.b    4
L_005E20:
	ds.b    4
L_005E24:
	ds.b    4
L_005E28:
	ds.b    12
L_005E34:
	ds.b    20
L_005E48:
	ds.b    64
L_005E88:
	ds.b    2312

	ifd __ATARI__
	ds.b    $4010+MCDRV_BUFFER-2312 ; The rest of the work area (64 tracks), then the song buffer.

mcdrv_opm_address:
	ds.b    1 ; The OPM register last selected.

mcdrv_opm_1b:
	ds.b    1 ; Register $1B as written (the X68000 keeps it at $9DA).

	even
	endif
