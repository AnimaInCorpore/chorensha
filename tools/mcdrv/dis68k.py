# Tracing 68000 disassembler for a relocatable binary (base 0), built on
# Musashi's disassembler (machine68k). Writes vasm (mot syntax) source in the
# style of sources/sz2.s: labels for every branch, PC-relative and relocated
# reference, code found by following control flow from the entry points, the
# rest as data. Usage:
#   dis68k.py image.bin relocs.txt bss_size out.s entry [entry ...] [@table:count]
import re, struct, sys
import machine68k as m

img_path, rel_path, bss_size, out_path = sys.argv[1:5]
img = open(img_path, "rb").read()
n = len(img)
bss_size = int(bss_size, 16)
relocs = sorted(int(l, 16) for l in open(rel_path) if l.strip())
relset = set(relocs)
reltarget = {r: struct.unpack(">I", img[r:r + 4])[0] for r in relocs}

mc = m.Machine(m.CPUType.M68000, 1024)
mc.mem.w_block(0, img)
cpu = mc.cpu

import json
cfg = json.load(open(sys.argv[5]))
h = lambda v: int(v, 16) if isinstance(v, str) else v
entries = [h(e) for e in cfg.get("entries", [])]
tables = [(h(t), c) for t, c in cfg.get("fntables", [])]
offtables = [(h(b), h(st), c) for b, st, c in cfg.get("offtables", [])]
vectables = [(h(t), c) for t, c in cfg.get("vectables", [])]
dataoff = {}     # address -> text for table entries
for b, st, c in offtables:
    for i in range(c):
        a = st + 2 * i
        v = struct.unpack(">h", img[a:a + 2])[0]
        t = (b + v) & 0xffffff
        entries.append(t)
        dataoff[a] = (2, "dc.w    L_%06X-L_%06X" % (t, b), [t, b])
for t0, c in vectables:
    for i in range(c):
        a = t0 + 6 * i
        vec = struct.unpack(">H", img[a:a + 2])[0]
        off = struct.unpack(">i", img[a + 2:a + 6])[0]
        t = a + 6 + off
        entries.append(t)
        dataoff[a] = (2, "dc.w    $%04X" % vec, [])
        dataoff[a + 2] = (4, "dc.l    L_%06X-*-4" % t, [t])
for t, c in tables:
    for i in range(c):
        r = t + 4 * i
        if r in relset:
            entries.append(reltarget[r])

BRANCH = re.compile(r"^(bra|bsr|b(hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le|hs|lo))$")
code = {}        # pc -> (size, text)
labels = set()
notes = []
work = list(entries)
labels.update(entries)

def s16(v): return v - 0x10000 if v & 0x8000 else v
def s8(v): return v - 0x100 if v & 0x80 else v

while work:
    pc = work.pop()
    while 0 <= pc < n:
        if pc in code:
            break
        size, text = cpu.disassemble(pc)
        if any(p in code for p in range(pc + 1, pc + size)) or any(
                pc < q < pc + code[q][0] for q in code if q < pc + size and q > pc - 10):
            notes.append("overlap at %04x" % pc)
        code[pc] = (size, text)
        mn = text.split()[0] if text.split() else ""
        ops = text[len(mn):].strip()
        nxt = pc + size
        if mn.startswith("dc.w"):
            op = int(ops.split(";")[0].strip()[1:], 16)
            if op & 0xf000 == 0xf000:      # Human68k DOS call
                if op in (0xff00, 0xff31, 0xff4c):
                    break
                pc = nxt
                continue
            notes.append("unknown opcode at %04x: %s" % (pc, text))
            break
        base = mn.split(".")[0]
        tgt = None
        mt = re.search(r"\$([0-9a-f]+)$", ops)
        if BRANCH.match(base) or base.startswith("db"):
            tgt = int(mt.group(1), 16)
            labels.add(tgt)
            work.append(tgt)
            if base == "bra":
                break
            pc = nxt
            continue
        if base in ("jmp", "jsr"):
            mpc = re.search(r";\s*\(\$([0-9a-f]+)\)", ops)
            if mpc:
                tgt = int(mpc.group(1), 16)
            else:
                for r in relset:
                    if pc < r < nxt:
                        tgt = reltarget[r]
            if tgt is not None:
                labels.add(tgt); work.append(tgt)
            else:
                notes.append("computed %s at %04x: %s" % (base, pc, text))
            if base == "jmp":
                break
            pc = nxt
            continue
        if base in ("rts", "rte", "rtr", "illegal"):
            break
        pc = nxt

# Collect references for labels and operand rewriting.
def ext_target(pc, size, disp):
    # PC-indexed: find the brief extension word whose low byte is the
    # displacement; the target is relative to that word's address.
    for e in range(pc + 2, pc + size, 2):
        w = struct.unpack(">H", img[e:e + 2])[0]
        if (w & 0x0700) == 0 and s8(w & 0xff) == disp:
            return e + disp
    return None

rendered = {}
for pc, (size, text) in sorted(code.items()):
    mn = text.split()[0]
    ops = text[len(mn):].strip()
    base = mn.split(".")[0]
    if mn.startswith("dc.w"):
        rendered[pc] = "dc.w    " + ops.split(";")[0].strip()
        continue
    # Branch sizes.
    if BRANCH.match(base):
        op = struct.unpack(">H", img[pc:pc + 2])[0]
        mn = base + (".w" if op & 0xff == 0 else ".s")
        t = int(re.search(r"\$([0-9a-f]+)$", ops).group(1), 16)
        ops = "L_%06X" % t
        rendered[pc] = "%-8s%s" % (mn, ops)
        continue
    if base.startswith("db"):
        t = int(re.search(r"\$([0-9a-f]+)$", ops).group(1), 16)
        ops = re.sub(r"\$[0-9a-f]+$", "L_%06X" % t, ops)
    # (d16,PC) with Musashi's target comment.
    def pcrel(mo):
        t = int(mo.group(2), 16)
        if t >= 0x80000000:
            labels.add(0)
            return "L_000000-$%X(pc)" % (0x100000000 - t)
        labels.add(t)
        return "L_%06X(pc)" % t
    # Musashi appends "; ($target)" after the whole operand list.
    mcom = re.search(r";\s*\(\$([0-9a-f]+)\)\s*$", ops)
    if mcom:
        body = ops[:mcom.start()].rstrip()
        fake = re.sub(r"\((-?\$[0-9a-f]+),PC\)", lambda mo: "(%s,PC); ($%s)" % (mo.group(1), mcom.group(1)), body, count=1)
        ops = re.sub(r"\((-?\$[0-9a-f]+),PC\);\s*\(\$([0-9a-f]+)\)", pcrel, fake)
        if "PC)" in ops:
            notes.append("pc-relative left at %04x: %s" % (pc, text))
    # (d8,PC,Xn)
    def pcidx(mo):
        d = int(mo.group(1).replace("$", ""), 16) if not mo.group(1).startswith("-") else -int(mo.group(1)[2:], 16)
        t = ext_target(pc, size, d)
        if t is None:
            notes.append("pc-index target unknown at %04x" % pc)
            return mo.group(0)
        labels.add(t)
        return "L_%06X(pc,%s)" % (t, mo.group(2))
    ops = re.sub(r"\((-?\$[0-9a-f]+),PC,([AD][0-7]\.[wl])\)", pcidx, ops)
    # Relocated longs inside the instruction: immediates or absolute longs.
    for r in relocs:
        if pc < r < pc + size:
            t = reltarget[r]
            labels.add(t)
            hexv = "$%x" % t
            if "#" + hexv in ops:
                ops = ops.replace("#" + hexv, "#L_%06X" % t, 1)
            elif hexv + ".l" in ops:
                ops = ops.replace(hexv + ".l", "L_%06X" % t, 1)
            else:
                notes.append("relocation at %04x not placed in: %s" % (r, text))
    # Byte immediates stored sign-extended ($FFxx): keep the encoding.
    if mn.endswith(".b") and ops.startswith("#$"):
        ext = struct.unpack(">H", img[pc + 2:pc + 4])[0]
        mi = re.match(r"#\$([0-9a-f]+)", ops)
        if ext & 0xff00 == 0xff00 and int(mi.group(1), 16) == ext & 0xff:
            # vasm writes $00xx; keep the original word with raw dc.w.
            words = ",".join("$%04X" % struct.unpack(">H", img[a:a + 2])[0] for a in range(pc, pc + size, 2))
            rendered[pc] = "%-8s%s" % ("dc.w", words) + "  ; " + mn + " " + re.sub(r",\s+", ",", ops)
            continue
    # Absolute addresses: ($x).w / ($x).l for vasm.
    ops = re.sub(r"(?<![#\w])\$([0-9a-f]+)\.(w|l)\b", r"($\1).\2", ops)
    ops = re.sub(r",\s+", ",", ops)
    rendered[pc] = "%-8s%s" % (mn, ops)

# Data labels from relocated longs outside code and from tables.
for r in relocs:
    labels.add(reltarget[r])
for a, (sz, txt, refs) in dataoff.items():
    labels.update(refs)

# Emit.
out = []
def comment_bytes(pc, size):
    words = " ".join("%04X" % struct.unpack(">H", img[a:a + 2])[0] for a in range(pc, pc + size, 2))
    return "; %08X %s" % (pc, words)

def in_code(a):
    return a in code

data_relpos = set()
for r in relocs:
    if not any(p <= r < p + code[p][0] for p in code if p <= r < p + 10):
        data_relpos.add(r)

pc = 0
lines = []
codestarts = set(code)
while pc < n:
    if pc in labels:
        lines.append("")
        lines.append("L_%06X:" % pc)
    if pc in code:
        size, _ = code[pc]
        lines.append("\t%-46s%s" % (rendered[pc], comment_bytes(pc, size)))
        pc += size
        continue
    # Data run up to the next label, code or relocation.
    if pc in dataoff:
        sz, txt, refs = dataoff[pc]
        lines.append("\t%-46s; %08X" % (txt, pc))
        pc += sz
        continue
    if pc in data_relpos:
        lines.append("\t%-46s; %08X" % ("dc.l    L_%06X" % reltarget[pc], pc))
        pc += 4
        continue
    end = pc + 1
    while end < n and end not in labels and end not in code and end not in data_relpos and end not in dataoff and end - pc < 16:
        end += 1
    chunk = img[pc:end]
    if all(32 <= b < 127 and b not in (39,) for b in chunk) and len(chunk) >= 4:
        lines.append("\t%-46s; %08X" % ("dc.b    '%s'" % chunk.decode(), pc))
    else:
        lines.append("\t%-46s; %08X" % ("dc.b    " + ",".join("$%02X" % b for b in chunk), pc))
    pc = end

# BSS labels.
bss_labels = sorted(l for l in labels if n <= l < 0x80000000)
lines.append("")
lines.append("\tbss")
lines.append("")
pos = n
for l in bss_labels + [n + bss_size]:
    if l > pos:
        lines.append("\tds.b    %d" % (l - pos))
    if l < n + bss_size:
        lines.append("L_%06X:" % l)
    pos = l
for b in labels:
    if not (0 <= b <= n + bss_size) and b < 0x80000000:
        notes.append("label outside image: %x" % b)
    elif b < n and b not in code and any(p < b < p + code[p][0] for p in code if p < b and p > b - 12):
        notes.append("label inside an instruction: %04x" % b)

open(out_path, "w").write("\n".join(lines) + "\n")
print("%d instructions, %d labels, %d code bytes of %d" % (len(code), len(labels), sum(s for s, _ in code.values()), n))
for x in notes[:60]:
    print("note:", x)
