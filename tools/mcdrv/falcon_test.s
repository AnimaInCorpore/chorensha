; MCDRV as the Falcon build has it (sources/mcdrv.s with __ATARI__) and the
; 68030 side of the music (sources/atari/music.s, without the host port),
; as one image for falcon_run.py.

MCDRV_TEST equ 1

	include	"sources/mcdrv.s"
	include	"sources/atari/music.s"
