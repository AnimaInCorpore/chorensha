Cho Ren Sha 68k for the Atari Falcon030
=======================================
Release @VERSION@

Cho Ren Sha 68k, the X68000 vertical shooter (c) 1995 by Famibe No Yosshin, on the Atari Falcon030.  The game's
own 68000 program runs on the Falcon as it is; a small layer stands in for the X68000's hardware, and the
Falcon's DSP helps with the drawing and makes the sound.

Source, screenshots and a video of it running:
https://github.com/AnimaInCorpore/chorensha  (commit @COMMIT@)


What you need
-------------

A Falcon030 with 14 MB of RAM, and an RGB monitor or a TV (50 Hz) or a VGA monitor (60 Hz).  The picture is
256 x 240 either way.  4 MB is not enough: of the memory the game needs, about 4.6 MB has to be the Falcon's
own ST-RAM, because the screen and the sound samples can only live there.  Fast RAM is used for the rest if
the machine has any, though that has not been tried yet.

A 68030 is required.  The game will not run on a 68040 or on a CT60's 68060: it uses an addressing mode and an
instruction those chips dropped, and it writes its own drawing code as it loads without clearing the caches
afterwards, which only the 68030's simpler caches make safe.


Starting it
-----------

Put SZ2.TOS, DSPRITE.LOD and the four ..._DAT folders together in one folder on a hard disk or a GEMDOS drive,
and start SZ2.TOS from the desktop.  The info screen waits for a key.  The title menu's EXIT returns to the
desktop.

Keyboard:   cursor keys  move           Left Shift  button 1           Control  button 2
Joystick:   joystick port 1 moves; the right mouse button is button 2
Jaguar pad: in the Falcon's enhanced joystick port A: D-pad move, B button 1, A button 2


What is new
-----------

- Music and sound effects.  The game's own music driver still runs on the processor, and what it would have
  written to the X68000's YM2151 sound chip is passed to the DSP, which imitates that chip and mixes the music
  with the game's sound effects.
- The background scrolls, in one layer.
- A faster renderer: the processor and the DSP now work side by side wherever they can instead of waiting for
  each other, and sprites that share a palette are drawn one after another without setting their colours up
  again.


How far along it is
-------------------

This is a beta.  The game runs, with music and sound, but it has not been played through, and none of this
year's work has been tried on a real Falcon.  It was checked for this release in the Hatari emulator
(Falcon030, TOS 4.04, 14 MB, emulated DSP) on both kinds of monitor: the info screen, the title menu and the
attract mode.  In the attract demo the game itself keeps full speed, and the screen is redrawn for about 19
frames out of 20 over the stretch that was measured; an earlier and longer measurement gave about 4 out of 5.
Both are emulator figures, not measurements on real hardware.

Still missing or unproven:
- The music and the sound effects are new in this release and have only been heard in the emulator.
- The background scrolls in one layer only, and not sideways.
- The bottom 16 lines of the X68000's picture are not shown.
- A 68030 is needed (see above).


What is in here
---------------

SZ2.TOS       the program
DSPRITE.LOD   the DSP program, loaded by SZ2.TOS
BGM_DAT, ETC_DAT, PCM_DAT, XSP_DAT   the game's data
