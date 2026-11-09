import re, sys
prof, lst, lbl_a, lbl_b = sys.argv[1:5]
L=open(lst).read().splitlines()
def addr(lbl):
    for i,l in enumerate(L):
        if re.match(r"^\s*\d+\s+%s:?\s*$"%lbl,l):
            for k in range(i,i+6):
                m=re.search(r"P:([0-9A-F]{4})",L[k])
                if m: return int(m.group(1),16)
a0,a1=addr(lbl_a),addr(lbl_b)
rows=[]; tot_all=0
for line in open(prof, errors="replace"):
    m=re.match(r"^p:([0-9a-f]+)\s.*?\(\s*\d+ cyc\)\s+(.*?)\s+[\d.,]+% \((\d+), (\d+), (\d+)\)\s*$", line)
    if m:
        tot_all+=int(m.group(4))
        if a0<=int(m.group(1),16)<a1: rows.append((int(m.group(1),16), m.group(2).strip(), int(m.group(3)), int(m.group(4))))
tot=sum(r[3] for r in rows)
print("%s..%s: %.1f%% of all"%(lbl_a,lbl_b,100*tot/tot_all))
# group by execution count to see loops
import collections
g=collections.defaultdict(int)
for pc,t,i,c in rows: g[i]+=c
for i,c in sorted(g.items(), key=lambda x:-x[1])[:8]: print("  executed %8d times: %5.1f%% of the range"%(i,100*c/tot))
for pc,t,i,c in sorted(rows,key=lambda r:-r[3])[:10]: print("  p:%04x %8d x %s"%(pc,i,t))
