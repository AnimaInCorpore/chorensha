#
# X68000
#
./tools/vasmm68k_mot sources/sz2.s -quiet -Felf -nosym -no-opt -m68000 -rangewarnings -o binaries/sz2_x68k.o
./tools/vasmm68k_mot sources/x68000/mem_map.s -quiet -Felf -nosym -no-opt -m68000 -rangewarnings -o binaries/mem_map.o
human68k-ld -q -o binaries/sz2.o binaries/sz2_x68k.o binaries/mem_map.o
human68k-objcopy -O xfile binaries/sz2.o binaries/sz2.x 
cp binaries/sz2.x binaries/x68000/CH68_101_B/SZ2.X 

xxd binaries/sz2.x > binaries/sz2.hex
diff binaries/sz2.hex binaries/x68000/sz2.hex > binaries/sz2.dif
diff binaries/sz2.dif binaries/x68000/sz2.dif

#
# Atari
#
./tools/vasmm68k_mot sources/sz2.s -quiet -no-opt -Faout -m68030 -D__ATARI__ -o binaries/sz2_atari.o
./tools/vasmm68k_mot sources/atari/main.s -quiet -Faout -m68030 -o binaries/main.o
./tools/vasmm68k_mot sources/atari/mem_map.s -quiet -Faout -m68030 -o binaries/mem_map.o
./tools/vasmm68k_mot sources/atari/input.s -quiet -Faout -m68030 -o binaries/input.o
./tools/vasmm68k_mot sources/atari/emulator.s -quiet -Faout -m68030 -o binaries/emulator.o
./tools/vasmm68k_mot sources/atari/machine.s -quiet -Faout -m68030 -o binaries/machine.o
./tools/vasmm68k_mot sources/atari/graphics.s -quiet -Faout -m68030 -o binaries/graphics.o
./tools/vasmm68k_mot sources/atari/audio.s -quiet -Faout -m68030 -o binaries/audio.o
./tools/vasmm68k_mot sources/atari/music.s -quiet -Faout -m68030 -o binaries/music.o
./tools/vasmm68k_mot sources/mcdrv.s -quiet -no-opt -Faout -m68030 -D__ATARI__ -o binaries/mcdrv.o

./tools/vlink binaries/main.o binaries/sz2_atari.o binaries/mem_map.o binaries/input.o binaries/emulator.o binaries/machine.o binaries/graphics.o binaries/audio.o binaries/music.o binaries/mcdrv.o -tos-flags 7 -bataritos -estart -o binaries/atari/sz2_dbg.tos
./tools/vlink binaries/main.o binaries/sz2_atari.o binaries/mem_map.o binaries/input.o binaries/emulator.o binaries/machine.o binaries/graphics.o binaries/audio.o binaries/music.o binaries/mcdrv.o -s -tos-flags 7 -bataritos -estart -o binaries/atari/sz2.tos

./tools/asm56000.exe -q -a -isources/atari -bbinaries/dsprite.cld -z -lbinaries/dsprite.lst sources/atari/dsprite.asm
# dsprite.asm places its code by hand around fixed data (internal P up to
# $1FF, external from $200), and the assembler can size a forward jump
# differently in its two passes without an error: check the listing for code
# placed twice and for jump targets that missed their labels.
if command -v python3 >/dev/null 2>&1; then
	python3 tools/check_dsp_listing.py binaries/dsprite.lst || exit 1
else
	DSP_OVERLAP=$(grep -E "^ *[0-9]+ +P:[0-9A-F]{4} [0-9A-F]{6}" binaries/dsprite.lst | awk '{print $2}' | sort | uniq -d | head -3)
	if [ -n "$DSP_OVERLAP" ]; then echo "dsprite.asm: code overlaps at $DSP_OVERLAP"; exit 1; fi
fi
./tools/cldlod.exe binaries/dsprite.cld > binaries/atari/dsprite.lod

#
# Amiga
#

