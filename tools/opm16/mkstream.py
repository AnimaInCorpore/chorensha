# Converts an OPM write log ("cycles reg value", 10 MHz) into the word
# stream the opm16 DSP prototype plays: big-endian 24-bit words padded to
# 32 bits (the 68030 writes longs to the host port).
#   $00rrdd       write register rr = dd
#   $80nnnn       wait nnnn blocks before the next words
# Timer registers ($10-$14) are dropped; the 68030 owns the timers.
#   mkstream.py in.log out.bin [seconds] [divider] [block]
import struct, sys
rate = 25175000.0 / 256.0 / (float(sys.argv[4]) if len(sys.argv) > 4 else 6.0)
seconds = float(sys.argv[3]) if len(sys.argv) > 3 else 60.0
npf = 62500.0 / rate
BLOCK = int(sys.argv[5]) if len(sys.argv) > 5 else 32
words, block = [], 0
for line in open(sys.argv[1]):
    c, r, v = line.split()
    c = max(0, int(c)); r = int(r, 16); v = int(v, 16)
    if 0x10 <= r <= 0x14:
        continue
    frame = c / 160.0 / npf
    if frame >= seconds * rate:
        break
    b = int(frame / BLOCK + 0.5)
    if b > block:
        words.append(0x800000 | (b - block)); block = b
    words.append((r << 8) | v)
end = int(seconds * rate / BLOCK)
if end > block:
    words.append(0x800000 | (end - block))
open(sys.argv[2], "wb").write(b"".join(struct.pack(">I", w) for w in words))
print("%d words, %d blocks, %.1f words per block" % (len(words), end, len(words) / max(1, end)))
