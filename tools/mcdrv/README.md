# MCDRV tools

Tools used to turn `MCDRV.X` (the game's music driver, on the system disk
`binaries/x68000/CH68_101_A`) into `sources/mcdrv.s`, and to run it off the
Falcon for reference output. They need Python 3 with
[machine68k](https://pypi.org/project/machine68k/) (Musashi) on `PYTHONPATH`;
`opmlog2wav` needs a C++17 compiler and the ymfm sources (for example the copy
in F030MXDRV's `third_party/mame/3rdparty/ymfm/src`).

- `unlzx.py MCDRV.X out.bin [base]`: runs the LZX 1.04 unpacking stub and
  dumps the unpacked program, relocated to `base`. Unpacking at two bases and
  comparing gives the relocations; subtracting the base gives the image at 0.
- `dis68k.py image.bin relocs.txt bss_size out.s mcdrv_cfg.json`: tracing
  disassembler; `mcdrv_cfg.json` lists the entry points, jump tables, offset
  tables and the IOCS vector patch table it cannot find on its own.
- `mcdrv_run.py image.bin relocs.txt song.mdc seconds out.log`: installs MCDRV
  in a minimal X68000 (DOS and IOCS calls, MFP, YM2151 timers), plays a song
  through trap #4 like the game and logs every OPM write as
  `cycles register value` (10 MHz cycles from the start of the song).
- `opmlog2wav in.log out.wav [seconds]`: renders such a log with ymfm
  (`c++ -std=c++17 -O2 -I<ymfm/src> opmlog2wav.cpp <ymfm/src>/ymfm_opm.cpp`).
- `opmfeatures.py logdir`: which YM2151 features the logged songs use.
- `falcon_test.s`, `falcon_run.py image.bin map.txt song.mdc seconds out.bin`:
  MCDRV as the Falcon build has it (`sources/mcdrv.s` with `__ATARI__` and
  `sources/atari/music.s`) in Musashi as a bare 68030. It plays a song like
  the game, calls `music_generate` like the VBL, and writes the stream words
  the DSP would get; it reports any access to X68000 hardware, any change to
  low memory and any unexpected exception. Its stream has the same register
  writes as `mkstream.py` makes of the `mcdrv_run.py` log of the original.
  Build the image from the repository root:

  ```sh
  ./tools/vasmm68k_mot_mac tools/mcdrv/falcon_test.s -quiet -no-opt -Fvobj -m68030 -D__ATARI__ -o ft.o
  ./tools/vlink_mac -brawbin1 -Ttext 0x10000 -M -o ft.bin ft.o > ft.map
  ```
