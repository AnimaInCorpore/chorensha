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
