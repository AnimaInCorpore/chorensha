#!/bin/sh
# Usage: prof.sh <stream> <outdir> : DSP profile over render_block hits 2000-4560
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="$2"
RB=$(grep -E "^\s*[0-9]+\s+render_block:?.?$" -A3 "$HERE/opm16.lst" | grep -o -m1 "P:0[0-9A-F]*" | cut -d: -f2)
H="${HATARI:-$ROOT/../F030Arcade/third_party/hatari/build/src/hatari}"
TOS="${TOS_IMG:-$ROOT/../F030Arcade/third_party/tos/tos404.img}"
rm -rf "$OUT"; mkdir -p "$OUT/drive/AUTO"
cp "$HERE/OPMPLAY.PRG" "$OUT/drive/AUTO/"; cp "$HERE/OPM16.LOD" "$OUT/drive/"
cp "$HERE/opm16_tab.bin" "$OUT/drive/OPM16TAB.BIN"; cp "$1" "$OUT/drive/STREAM.BIN"
printf 'dp on\n' > "$OUT/on.ini"; printf 'dp save %s/dprofile.txt\ndp off\n' "$OUT" > "$OUT/off.ini"
printf 'db pc = $%s :2000 :once :trace :file %s/on.ini\ndb pc = $%s :4560 :once :trace :file %s/off.ini\n' "$RB" "$OUT" "$RB" "$OUT" > "$OUT/start.ini"
"$H" --memsize 14 --tos "$TOS" --machine falcon --cpulevel 3 --cpuclock 16 \
  --cpu-exact true --compatible true --patch-tos true --dsp emu --monitor rgb --frameskips 0 \
  --confirm-quit off --sound off --fast-forward boot:on --fast-forward prg:off --run-vbls prg:3000 \
  --parse "$OUT/start.ini" --log-file "$OUT/hatari.log" --harddrive "$OUT/drive" > "$OUT/stdout.txt" 2>&1
echo "render_block \$$RB"
