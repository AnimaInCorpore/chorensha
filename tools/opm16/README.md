# opm16: YM2151 on the Falcon DSP

A DSP56001 kernel that plays Chō Ren Sha's music from a stream of YM2151
register writes, in place of the X68000's OPM. The 68030 sends the writes
over the host port; the DSP renders 8 channels x 4 operators and sends the
result to the DAC through the SSI. The kernel is in `sources/atari/opm16_*.asm`
and the game's DSP program includes it (`dsprite.asm`); this directory has a
standalone test program for it, a C++ model and the tables.

Measured in Hatari (calibrated build, profiling 5 s of each song):

| Rate | Block | Stage 1 | Boss 1 |
|---|---|---|---|
| 16390 Hz (25.175 MHz / 256 / 6) | 32 frames | 36.4% of the DSP | 37.2% |
| 24585 Hz (25.175 MHz / 256 / 4) | 48 frames | 48.5% | 49.2% |

At 24585 Hz the operator loops take about 36% and the per-block work
(events, LFO, envelopes, pitch) about 9%. Not yet checked on a real Falcon.

## Files

- `opmtest.asm`: the standalone DSP program around the kernel (memory map,
  SSI, host port, checksum and capture).
- `opmplay.s`: TOS player for testing. It loads `OPM16.LOD`, uploads
  `OPM16TAB.BIN` to the DSP, routes the DSP to the DAC and feeds
  `STREAM.BIN` to the host port.
- `gentab.py`: tables for a sample rate and block size, written for the DSP
  (`opm16_tab.asm`, `opm16_tab.bin`) and for the model (`opm16_tab.h`).
  It reads the phase step table from ymfm's `ymfm_fm.ipp`.
- `mkstream.py`: turns an OPM write log from `../mcdrv/mcdrv_run.py` into a
  stream (`$00rrdd` = write register, `$80nnnn` = wait n blocks). Timer
  registers are dropped.
- `model2.cpp`: C++ model of the kernel. Same tables, same arithmetic
  (24-bit words, DSP rounding). It writes a WAV and the capture/checksum
  the DSP is compared against.
- `build.sh [divider] [block] [check_blocks]`: builds all of the above.
  It expects ymfm in `../F030MXDRV` and ASM56000 in `../ASM56000/build`
  (next to this repository; `YMFM` and `DSP_TOOLS` override).
- `run.sh`, `verify.sh <blocks> <stream>...`: run a stream in Hatari
  (`../F030Arcade`, or `HATARI`/`TOS_IMG`) and compare the DSP's checksum
  of its first blocks and its capture of the first 8192 words with the
  model. Build with the same `check_blocks` first.
- `prof.sh <stream> <outdir>`, `psum.py`, `hot.py`: DSP profile of blocks
  2000-4560, per routine or per instruction. Build with `check_blocks` 0.
- `bands.py`: level difference per frequency band between two WAVs.
- `yrom.txt`: the DSP's Y ROM sine, as Hatari has it.

Typical use, with the logs in `logs/`:

```sh
python3 mkstream.py logs/SZ2_S1.log S1.BIN 60 4 48
./build.sh 4 48 6000
./verify.sh 6000 S1.BIN
./build.sh 4 48 0
./prof.sh S1.BIN prof_S1 && python3 psum.py prof_S1/dprofile.txt opm16.lst 2560 48 24584.96
```

## How it works

- **Blocks.** Register writes, the LFO, envelopes, gains and pitch are
  computed once per block (about 2 ms). The operators run per frame.
- **Operators.** Each operator is one loop over the block, in internal P.
  It looks up a copy of the Y ROM sine in Y RAM `$00-$ff`. The phase is a
  48-bit accumulator whose low 8 integer bits are the index; `y1 = $ff` is
  both the mask and the multiplier of the increment. Per frame: 7
  instructions for a modulated operator, 10 for operator 1 with feedback,
  4 for an unmodulated one.
- **Records.** The data each channel needs for rendering sits in one
  record: its routine, mix and per-operator increment and gain. A
  dispatcher calls one routine per channel: operator 1 with or without
  feedback, then the algorithm. Silent channels are skipped.
- **Envelopes.** Each operator's envelope record starts with the address of
  the handler for its state (attack, decay, sustain, release, off). Rates,
  levels and key scaling are recomputed when registers are written, not
  every block.
- **Pitch.** Increments are recomputed only for channels whose KC, KF, DT
  or MUL changed, and every block for channels with PM. A KF write updates
  the four operators from cached KC values.
- **Output.** Blocks are rendered into a ring of four SSI segments. The SSI
  fast interrupt sends two 16-bit words per frame.

Memory: X internal holds the modulation rings, Y internal the sine, and
X/Y external the tables, records, mixes and the 512-word host FIFO.

## Not done: a 1024-step sine

F030MXDRV (commit `773294f`) and the F030Arcade games that use its kernel
(`bc35f34`) replaced the DSP's 256-step sine ROM with the chip's own
1024-step waveform. Its largest effect was on patches without feedback. It
was looked at for this kernel on 2026-11-18 and not built; this is what a
later implementation has to solve.

**The loops need no change in cost.** They already run in internal P and use
the phase index as the table address (`move b1,r0`, `y:(r0)`). With
`y1 = $3ff` the table is `Y:$0000-$03ff`: the first 256 words are internal
Y RAM, where the ROM copy is now, and the other 768 are external Y
(`Y:$0100-$03ff`). A read from internal P of external Y costs no extra bus
cycle. An indexed read from a table elsewhere (`y:(r0+n0)`) would cost one
cycle per operator and frame, so the table should stay at address 0.

**What follows the table size:**

- `y1` (and the masks in `opm16_block.asm` and `opm16_warm.asm` that mean the
  sine index): `$ff` becomes `$3ff`.
- `INC_K`: `256/510` becomes `1024/2046` of 2^23, because the mask is also
  the multiplier of the increment.
- The modulator gain `1021` (8168/8 index units) and `FBK` are in index
  units: four times as large.
- The table itself: the chip's waveform at zero envelope attenuation, from
  ymfm's quarter log-sine and power tables (F030MXDRV
  `tools/generate_ym2151_tables.py` has it), scaled so that its peak of 8168
  is full scale, since the gains here already carry the 8168. `gentab.py`
  would write it for the DSP and for `model2.cpp` (`T_YROM`, `idx()`, `adv()`).

**The game's DSP program has no room for it.** `dsprite.asm` as of `134139c`:

| | free words |
|---|---|
| external code, `P:$0200-$0BFF` | 7 |
| internal code, `P:$0040-$01FF` | 6 |
| X, sprite masks up to `X:$7FF8` | 7 |
| Y, 462 masks of room for about 449 | about 143 |

External `Y:$0100-$03ff` is the same memory as `Y:$4100-$43ff` and
`P:$0100-$03ff`. It holds the RLE chunk boundaries and tables and the 32
operator phases (`$4100-$415F`, each an X and a Y word at one address) and
the first 512 words of the external code. `Y:$4160-$41FF` looks unused.

One way to make the room:

1. Replace `TAB_GAIN` (1024 words of 2^(-t/64)) by a 64-entry fraction table
   and a shift by `t >> 6`. That frees about 944 words in X for a few cycles
   per operator and block; the model has to round the same way.
2. Move about 600 words of external code to the freed X memory
   (`P:$47C0` onwards). Jumps to and from it are long ones: the short forms
   reach `$0FFF` only, and `check_dsp_listing.py` has to stay clean.
3. Give the RLE chunk tables and the phases a new address that is free in
   both X and Y, or read their two halves separately. This is the part that
   touches the sprite code, and nothing checks that code but running the
   game.

A 512-step table is not much easier: `Y:$0100-$01ff` still holds the RLE
tables and the phases.

**Order worth keeping:** first the kernel alone (`opmtest.asm` has its own,
roomier memory map), with the table size as a setting so that the game
stays at 256 steps, and `verify.sh` showing the DSP equal to the model; then
the game's memory. The scripts here are written for macOS (Hatari's command
FIFO, `clang++`, the `_mac` tools), and the stream logs in `logs/` are not
in the repository, so on Windows they need porting first.
