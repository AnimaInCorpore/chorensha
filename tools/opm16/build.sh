#!/bin/sh
# Usage: build.sh [divider] [block] [check_blocks]
# Tables, DSP program, model and player for 25.175 MHz / 256 / divider.
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"; cd "$HERE"
ROOT="$(cd "$HERE/../.." && pwd)"
DIV="${1:-6}"; BLOCK="${2:-32}"; CHECK="${3:-0}"
YMFM="${YMFM:-$ROOT/../F030MXDRV/third_party/mame/3rdparty/ymfm/src/ymfm_fm.ipp}"
DSP_TOOLS="${DSP_TOOLS:-$ROOT/../ASM56000/build}"
T="${M68K_TOOLS:-$ROOT/tools}"
INC="$ROOT/sources/atari"
python3 gentab.py "$YMFM" yrom.txt "$DIV" "$BLOCK"
printf 'CHECK_BLOCKS\tequ\t%d\n' "$CHECK" > opm16_cfg.asm
"$DSP_TOOLS/asm56000" -q -a -i"$INC" -bopm16.cld -z -lopm16.lst opmtest.asm
python3 "$ROOT/tools/check_dsp_listing.py" opm16.lst
"$DSP_TOOLS/cldlod" opm16.cld | awk '{ sub(/\r$/, ""); printf "%s\r\n", $0 }' > OPM16.LOD
"$T/vasmm68k_mot_mac" opmplay.s -quiet -Faout -m68030 -DPRESCALE=$((DIV - 1)) -o opmplay.o
"$T/vlink_mac" opmplay.o -tos-flags 7 -bataritos -estart -o OPMPLAY.PRG
clang++ -std=c++17 -O2 -o model2 model2.cpp
grep -E "Errors|Warnings" opm16.lst | tail -2
