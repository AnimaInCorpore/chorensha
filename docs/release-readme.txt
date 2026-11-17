Cho Ren Sha 68k for the Atari Falcon030, @VERSION@
==================================================

Cho Ren Sha 68k, the X68000 vertical shooter (c) 1995 by Famibe No Yosshin, on the Atari Falcon030. The game's
own 68000 program runs natively; a small layer stands in for the X68000 hardware. Sprites are compiled 68030
code, and the Falcon's DSP works out which background pixels have to be restored each frame, plays the sound
effects and runs a YM2151 of its own for the music.
Source and documentation:
https://github.com/AnimaInCorpore/chorensha  (commit @COMMIT@)

Requirements: an Atari Falcon030 with 14 MB of RAM (4 MB is not enough: the program needs about 11.2 MB, of
which about 4.6 MB must be ST-RAM), an RGB monitor or TV (256 x 240, 50 Hz) or a VGA monitor (256 x 240
line-doubled, 60 Hz).  Start SZ2.TOS from the desktop from a hard disk or a GEMDOS drive.  DSPRITE.LOD and the
four ..._DAT folders must stay in the same folder as SZ2.TOS.  Press SPACE at the info screen to start.

A 68030 is required.  The program does not run on a 68040 or on a CT60's 68060: it uses an addressing mode and
an instruction those CPUs dropped, and it does not flush the caches after compiling its sprite code.  If the
machine has TT-RAM the program is loaded into it, and the screens and the sound samples are kept in ST-RAM;
that path has not been tested on hardware.

New in @VERSION@
----------------

- The music and the sound effects now play through the DSP.  MCDRV, the game's own music driver, runs on the
  68030 as it does on the X68000, and its YM2151 register writes become a stream that the DSP plays with a
  YM2151 of its own, 8 channels of 4 operators, between its sprite work.
- The background scrolls, as one layer (the X68000's slow graphic layer, one line a frame).
- The renderer overlaps its work with the DSP's: it prepares the palettes and the text while the DSP draws the
  sprite masks, and the DSP takes the next sprite list before it draws those masks instead of after.
- The sprite loop tests the display-line throttle once per group of four sprites instead of after every sprite.

Verification status
-------------------

This is a beta.  Checked for this release in Hatari 2.6.1-devel (Falcon030 at 16 MHz, TOS 4.04, 14 MB,
emulated DSP): the info screen, the title menu and the attract mode on an RGB monitor (50 Hz) and on a VGA
monitor (60 Hz).  The game was not played through, and the changes made in 2026 (the DSP restore runs, the
256 x 240 modes, the display-line throttle, the DSP sound and music, the scrolling) have not been run on a
real Falcon.

In the attract mode in Hatari the game logic runs every VBL, and over 1,500 VBLs of the stage 1 demo on RGB
the renderer finishes 1,419 pictures, about 95% of the frames.  VGA has not been measured since the music.
These are Hatari figures, not measurements on real hardware.

Known limitations:
- The music and the sound effects through the DSP are new in this release and have only been checked in Hatari.
- The background scrolls as one layer; the fast layer and the sideways scrolling are not there.
- The bottom 16 lines of the X68000's 256-line picture are not shown.
- A 68030 is required (see above).

Controls
--------

Keyboard:   cursor keys  move           Left Shift  button 1           Control  button 2
Joystick:   joystick port 1 moves; the right mouse button is button 2
Jaguar pad: in the Falcon's enhanced joystick port A: D-pad move, B button 1, A button 2

The title menu's EXIT returns to the desktop.

Files
-----
SZ2.TOS       the program
DSPRITE.LOD   the DSP program (loaded by SZ2.TOS)
BGM_DAT, ETC_DAT, PCM_DAT, XSP_DAT   the game's data
