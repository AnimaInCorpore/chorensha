#
# X68000
#
./tools/vasmm68k_mot_mac sources/sz2.s -quiet -Felf -nosym -no-opt -m68000 -rangewarnings -o binaries/sz2_x68k.o
./tools/vasmm68k_mot_mac sources/x68000/mem_map.s -quiet -Felf -nosym -no-opt -m68000 -rangewarnings -o binaries/mem_map.o
wine ./tools/human68k-ld.exe -q -o binaries/sz2.o binaries/sz2_x68k.o binaries/mem_map.o
wine ./tools/human68k-objcopy.exe -O xfile binaries/sz2.o binaries/sz2.x
cp binaries/sz2.x binaries/x68000/CH68_101_B/SZ2.X

xxd binaries/sz2.x > binaries/sz2.hex
diff binaries/sz2.hex binaries/x68000/sz2.hex > binaries/sz2.dif
diff binaries/sz2.dif binaries/x68000/sz2.dif

#
# Atari
#
./tools/vasmm68k_mot_mac sources/sz2.s -quiet -no-opt -Faout -m68030 -D__ATARI__ -o binaries/sz2_atari.o
./tools/vasmm68k_mot_mac sources/atari/main.s -quiet -Faout -m68030 -o binaries/main.o
./tools/vasmm68k_mot_mac sources/atari/mem_map.s -quiet -Faout -m68030 -o binaries/mem_map.o
./tools/vasmm68k_mot_mac sources/atari/input.s -quiet -Faout -m68030 -o binaries/input.o
./tools/vasmm68k_mot_mac sources/atari/emulator.s -quiet -Faout -m68030 -o binaries/emulator.o
./tools/vasmm68k_mot_mac sources/atari/machine.s -quiet -Faout -m68030 -o binaries/machine.o
./tools/vasmm68k_mot_mac sources/atari/graphics.s -quiet -Faout -m68030 -o binaries/graphics.o
./tools/vasmm68k_mot_mac sources/atari/audio.s -quiet -Faout -m68030 -o binaries/audio.o
./tools/vasmm68k_mot_mac sources/atari/music.s -quiet -Faout -m68030 -o binaries/music.o
./tools/vasmm68k_mot_mac sources/mcdrv.s -quiet -no-opt -Faout -m68030 -D__ATARI__ -o binaries/mcdrv.o

./tools/vlink_mac binaries/main.o binaries/sz2_atari.o binaries/mem_map.o binaries/input.o binaries/emulator.o binaries/machine.o binaries/graphics.o binaries/audio.o binaries/music.o binaries/mcdrv.o -tos-flags 7 -bataritos -estart -o binaries/atari/sz2_dbg.tos
./tools/vlink_mac binaries/main.o binaries/sz2_atari.o binaries/mem_map.o binaries/input.o binaries/emulator.o binaries/machine.o binaries/graphics.o binaries/audio.o binaries/music.o binaries/mcdrv.o -s -tos-flags 7 -bataritos -estart -o binaries/atari/sz2.tos

# DSP: the native ASM56000 rebuild of Motorola's CLAS56 ("make asm56000 cldlod"
# in its checkout). Set DSP_TOOLS to its build directory if it is not next to
# this one. TOS's Dsp_LoadProg needs CRLF line endings (an LF file crashes it),
# so the native cldlod output is converted to what the DOS original writes.
DSP_TOOLS="${DSP_TOOLS:-../ASM56000/build}"
"$DSP_TOOLS/asm56000" -q -a -isources/atari -bbinaries/dsprite.cld -z -lbinaries/dsprite.lst sources/atari/dsprite.asm
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
"$DSP_TOOLS/cldlod" binaries/dsprite.cld | awk '{ sub(/\r$/, ""); printf "%s\r\n", $0 }' > binaries/atari/dsprite.lod

#
# Amiga
#

