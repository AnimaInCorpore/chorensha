#!/bin/sh
# Usage: verify.sh <check_blocks> <stream.bin>...
# Runs each stream on the DSP in Hatari (built with the same check_blocks)
# and in model2, and compares the checksums and the first captured blocks.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; cd "$HERE"
NB="$1"; shift
for S in "$@"; do
  name=$(basename "$S" .BIN)
  ./run.sh "$S" "$HERE/v_$name" "$NB" > /dev/null
  ./model2 "$S" /dev/null "$NB" "v_$name/cap_m.txt" "$NB"
  dsp=$(awk '{print $NF}' "v_$name/vars.txt" | sed -n '41,46p' | tr '\n' ' ')
  set -- $dsp
  d=$(printf '%02x %s %s %02x %s %s' $((0x$1 & 0xff)) "$2" "$3" $((0x$4 & 0xff)) "$5" "$6")
  m=$(tail -1 "v_$name/cap_m.txt" | cut -d' ' -f3-)
  head -n -1 "v_$name/cap_m.txt" > "v_$name/cap_m2.txt" 2>/dev/null || sed '$d' "v_$name/cap_m.txt" > "v_$name/cap_m2.txt"
  same=$(python3 - "v_$name/cap.txt" "v_$name/cap_m2.txt" <<'PY'
import sys
d=[l.strip() for l in open(sys.argv[1]) if l.strip()]; m=[l.strip() for l in open(sys.argv[2]) if l.strip()]
n=min(len(d),len(m)); bad=[i for i in range(n) if d[i]!=m[i]]
print("capture %d words, %d differ%s" % (n, len(bad), (", first at word %d" % bad[0]) if bad else ""))
PY
)
  if [ "$d" = "$m" ]; then r=SAME; else r=DIFFERENT; fi
  echo "$name: $NB blocks, checksum $r (dsp $d / model $m); $same"
done
