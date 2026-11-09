#!/bin/sh
# Usage: run.sh <stream.bin> <outdir> <blocks> [record]
# Boots OPMPLAY.PRG from an AUTO folder in Hatari (fast forward unless
# recording), waits until the DSP has rendered <blocks> blocks, then dumps
# its variables (vars.txt: x:$0300-$033f, checksum at $0328) and the
# capture buffer (cap.txt). With "record", sound goes to <outdir>/sound.wav.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
STREAM="$1"; OUT="$2"; BLOCKS="$3"; REC="${4:-}"
H="${HATARI:-$ROOT/../F030Arcade/third_party/hatari/build/src/hatari}"
TOS="${TOS_IMG:-$ROOT/../F030Arcade/third_party/tos/tos404.img}"
FF=on; [ -n "$REC" ] && FF=off
rm -rf "$OUT"; mkdir -p "$OUT/drive/AUTO"
cp "$HERE/OPMPLAY.PRG" "$OUT/drive/AUTO/OPMPLAY.PRG"
cp "$HERE/OPM16.LOD" "$OUT/drive/"
cp "$HERE/opm16_tab.bin" "$OUT/drive/OPM16TAB.BIN"
cp "$STREAM" "$OUT/drive/STREAM.BIN"
FIFO="$OUT/cmd.fifo"
"$H" --memsize 14 --tos "$TOS" \
  --machine falcon --cpulevel 3 --cpuclock 16 \
  --cpu-exact true --compatible true --patch-tos true --dsp emu \
  --monitor rgb --frameskips 0 --confirm-quit off --sound 50066 \
  --fast-forward boot:on --fast-forward prg:$FF --run-vbls prg:200000 \
  --cmd-fifo "$FIFO" --log-file "$OUT/hatari.log" \
  --trace event --trace-file "$OUT/trace.txt" \
  --harddrive "$OUT/drive" > "$OUT/stdout.txt" 2>&1 &
PID=$!
while [ ! -p "$FIFO" ]; do sleep 0.1; done
cmd() { printf '%s\n' "$1" > "$FIFO"; sleep 0.3; }
i=0
until grep -q "Program exec" "$OUT/trace.txt" 2>/dev/null; do sleep 0.2; i=$((i+1)); [ $i -gt 300 ] && break; done
if [ -n "$REC" ]; then cmd "hatari-path soundout $OUT/sound.wav"; cmd "hatari-shortcut recsound"; fi
n=0; t=0
while [ "$n" -lt "$BLOCKS" ] && [ $t -lt 600 ]; do
  sleep 1; t=$((t+1))
  cmd "hatari-debug dm x \$030c-\$030c"
  v=$(grep -E "^X:030c" "$OUT/stdout.txt" | tail -1 | awk '{print $NF}')
  [ -n "$v" ] && n=$((0x$v))
done
if [ -n "$REC" ]; then cmd "hatari-shortcut recsound"; sleep 1; fi
cmd "hatari-debug dm x \$0300-\$033f"
cmd "hatari-debug dm x \$2000-\$3fff"
sleep 1
kill $PID 2>/dev/null; wait $PID 2>/dev/null
grep -E "^X:03[0-3]" "$OUT/stdout.txt" | tail -64 > "$OUT/vars.txt"
grep -E "^X:[23][0-9a-f]{3} " "$OUT/stdout.txt" | awk '{print $NF}' > "$OUT/cap.txt"
echo "blocks $n"
