# Usage: check_dsp_listing.py listing.lst
# Checks an asm56000 listing for code placed twice at the same P address, and
# for jumps, calls and DO loops whose encoded target differs from the final
# address of their label. The assembler can size a forward jump differently
# in its two passes without saying so; the code after it then moves, while
# targets keep their first-pass values.
import re, sys

lines = [l.rstrip("\r") for l in open(sys.argv[1], errors="replace").read().split("\n")]
INSTR = re.compile(r"^\s*\d+\s+P:([0-9A-F]{4}) ([0-9A-F]{6})(?:  ([A-Za-z_][A-Za-z0-9_]*):?)?\s+([a-z]+)\s*(\S*)")
LABEL = re.compile(r"^\s*\d+\s+([A-Za-z_][A-Za-z0-9_]*):?\s*$")
WORD2 = re.compile(r"^\s+([0-9A-F]{6})\s*$")

labels = {}  # (scope, name) -> address
pending = []
scope = ""
refs = []
seen = {}
for i, l in enumerate(lines):
    m = LABEL.match(l)
    if m:
        name = m.group(1)
        if not name.startswith("_"):
            scope = name
        pending.append(name)
        continue
    m = INSTR.match(l)
    if not m:
        continue
    addr = int(m.group(1), 16)
    word = int(m.group(2), 16)
    if m.group(3):
        name = m.group(3)
        if not name.startswith("_"):
            scope = name
        pending.append(name)
    for name in pending:
        labels[(scope if name.startswith("_") else "", name)] = addr
    pending = []
    seen.setdefault(addr, []).append(i + 1)
    mnem, ops = m.group(4), m.group(5)
    second = None
    for j in range(i + 1, min(i + 10, len(lines))):  # past wrapped comments and page headers
        if re.match(r"^\s*\d+\s{3,}", lines[j]):
            break  # the next listing line
        w = WORD2.match(lines[j])
        if w:
            second = int(w.group(1), 16)
            break
    if mnem == "do" or mnem.startswith("j"):
        target = ops.split(",")[-1].lstrip("<>")
        if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", target):
            refs.append((i + 1, addr, mnem, target, scope, word, second))

problems = []
for a, where in seen.items():
    if len(where) > 1:
        problems.append("P:%04x is used by listing lines %s" % (a, ", ".join(map(str, where))))
for line, addr, mnem, target, scope, word, second in refs:
    key = (scope, target) if target.startswith("_") else ("", target)
    if key not in labels:
        continue  # an equate or an external symbol
    want = labels[key]
    if mnem == "do":
        got, want = second, want - 1
    elif second is not None and (mnem in ("jclr", "jset", "jsclr", "jsset") or (word >> 16) in (0x0A, 0x0B)):
        got = second
    else:
        got = word & 0xFFF
    if got != want:
        problems.append("listing line %d, P:%04x %s %s: encoded $%04x, label at $%04x" % (line, addr, mnem, target, got, want))
for p in problems:
    print(p)
sys.exit(1 if problems else 0)
