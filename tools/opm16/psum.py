# Usage: psum.py dprofile.txt opm16.lst blocks [block] [rate]
# DSP time per routine from a Hatari DSP profile; main_loop and host_service
# count as waiting.
import re, sys, collections
prof, lst, blocks = sys.argv[1], sys.argv[2], int(sys.argv[3])
BLOCK = int(sys.argv[4]) if len(sys.argv) > 4 else 32
RATE = float(sys.argv[5]) if len(sys.argv) > 5 else 16389.97
rows=[]; hz=0
for line in open(prof, errors="replace"):
    if line.startswith("Cycles/second:"): hz=int(line.split(":")[1]); continue
    m=re.match(r"^p:([0-9a-f]+)\s.*?\(\s*\d+ cyc\)\s+(.*?)\s+[\d.,]+% \((\d+), (\d+), (\d+)\)\s*$", line)
    if m: rows.append((int(m.group(1),16), m.group(2).strip(), int(m.group(3)), int(m.group(4))))
labels=[]; pending=None
for line in open(lst, errors="replace"):
    m=re.match(r"^\s*\d+\s+([A-Za-z][A-Za-z0-9_]*):?\s*$", line)
    if m: pending=m.group(1); continue
    m=re.match(r"^\s*\d+\s+([A-Za-z][A-Za-z0-9_]*):?\s+(dc|equ)", line)
    if m: pending=None; continue
    m=re.match(r"^\s*\d+\s+P:([0-9A-F]{4}) [0-9A-F]{6}  ([A-Za-z][A-Za-z0-9_]*):?\s", line)
    if m: labels.append((int(m.group(1),16), m.group(2))); pending=None; continue
    m=re.match(r"^\s*\d+\s+P:([0-9A-F]{4})\s", line)
    if m and pending: labels.append((int(m.group(1),16), pending)); pending=None
labels.sort()
def owner(pc):
    n="?"
    for a,l in labels:
        if a<=pc: n=l
    return n
tot=sum(r[3] for r in rows)
by=collections.Counter()
for pc,t,i,c in rows: by[owner(pc)]+=c
idle=by["main_loop"]+by["host_service"]
frames=blocks*BLOCK
print("window: %d blocks = %.3f s of audio; %.1f M oscillator cycles profiled (%.1f M expected)" % (blocks, frames/RATE, tot/1e6, frames/RATE*hz/1e6))
print("busy %.1f%% of the DSP, waiting %.1f%%; %.0f instruction cycles per frame of work" % (100*(tot-idle)/tot, 100*idle/tot, (tot-idle)/2/frames))
for k,v in by.most_common(40):
    print("  %-22s %5.1f%%  %6.1f per frame" % (k, 100*v/tot, v/2/frames))
