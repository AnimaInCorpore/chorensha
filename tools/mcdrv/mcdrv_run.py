# Runs X68000 MCDRV in Musashi (machine68k) with a minimal X68000 around it:
# Human68k DOS calls (line F) and IOCS (trap #15) answered from Python, the
# MFP and the YM2151 (OPM) registers and timers as I/O. Installs MCDRV, then
# calls trap #4 like Cho Ren Sha 68k does to play a song, and logs every OPM
# register write with its time in 10 MHz CPU cycles.
#
#   mcdrv_run.py image.bin relocs.txt song.mdc seconds out.log [cmdline]
import os, struct, sys
import machine68k as m

R = m.Register
img_path, rel_path, song_path, seconds, log_path = sys.argv[1:6]
cmdline = sys.argv[6] if len(sys.argv) > 6 else "-B256"
seconds = float(seconds)
CPU_HZ = 10_000_000

mc = m.Machine(m.CPUType.M68000, 14 * 1024)
mem, cpu, traps = mc.mem, mc.cpu, mc.traps

# --- load and relocate MCDRV -------------------------------------------------
B = 0x20000
img = bytearray(open(img_path, "rb").read())
for line in open(rel_path):
    if line.strip():
        r = int(line, 16)
        struct.pack_into(">I", img, r, struct.unpack_from(">I", img, r)[0] + B)
mem.w_block(B, bytes(img))
BSS = 0x147c
END = B + len(img) + BSS
PSP = B - 256
mem.w32(PSP + 8, END + 0x10000)          # end of the memory block

# --- stubs: DOS (line F), IOCS (trap #15), call return ----------------------
STUB = 0x3000
out_text = []
heap = [0x400000]
state = {"done": False, "exit": None}

def frame():
    ssp = cpu.r_reg(R.A7)
    return ssp, mem.r16(ssp), mem.r32(ssp + 2)

def dos_call(*_):
    ssp, sr, pc = frame()
    op = mem.r16(pc)
    mem.w32(ssp + 2, pc + 2)
    args = ssp + 6 if sr & 0x2000 else cpu.r_usp()
    d0 = 0
    fn = op & 0xff
    if os.environ.get("DOSLOG"):
        print("DOS $FF%02X from $%x args %s" % (fn, pc - B, " ".join("%08x" % mem.r32(args + 4 * i) for i in range(3))))
    if fn == 0x09:                      # _PRINT
        a = mem.r32(args); s = bytearray()
        while mem.r8(a): s.append(mem.r8(a)); a += 1
        out_text.append(s.decode("shift_jis", "replace"))
    elif fn == 0x20:                    # _SUPER
        arg = mem.r32(args)
        if arg == 0:                    # enter supervisor on the caller's stack
            usp = cpu.r_usp()
            new = usp - 6
            mem.w16(new, sr | 0x2000); mem.w32(new + 2, pc + 2)
            d0 = ssp + 6
            cpu.w_reg(R.A7, new)
        else:                           # back to user mode
            cpu.w_usp(ssp + 6)
            mem.w16(arg - 6, sr & ~0x2000); mem.w32(arg - 4, pc + 2)
            cpu.w_reg(R.A7, arg - 6)
    elif fn == 0x48:                    # _MALLOC
        size = mem.r32(args)
        if size >= 0xffffff:
            d0 = 0x81000000 | 0x800000
        else:
            d0 = heap[0]; heap[0] += (size + 15) & ~15
    elif fn in (0x49, 0x4a):            # _MFREE, _SETBLOCK
        d0 = 0
    elif fn == 0xf7:                    # _BUS_ERR: no MIDI or other boards here
        d0 = 2
    elif fn == 0x31:                    # _KEEPPR: resident, installation done
        state["done"] = True; mc.abort_execute()
    elif fn in (0x00, 0x4c):            # _EXIT, _EXIT2
        state["exit"] = "exit"; mc.abort_execute()
    else:
        out_text.append("[DOS $FF%02X]" % fn)
        d0 = 0xfffffffe if fn in (0x3d, 0x3c, 0x43) else 0
    cpu.w_reg(R.D0, d0 & 0xffffffff)

iocs_calls = {}
def iocs_call(*_):
    fn = cpu.r_reg(R.D0) & 0xff
    iocs_calls[fn] = iocs_calls.get(fn, 0) + 1
    d0 = 0
    if fn == 0x82:                      # _B_BPEEK
        d0 = mem.r8(cpu.r_reg(R.A1)) if cpu.r_reg(R.A1) < 0xe00000 else 0xffffffff
    cpu.w_reg(R.D0, d0)

def call_done(*_):
    state["done"] = True; mc.abort_execute()

t_dos, t_iocs, t_done = traps.alloc(dos_call), traps.alloc(iocs_call), traps.alloc(call_done)
mem.w16(STUB, 0xa000 + t_dos); mem.w16(STUB + 2, 0x4e73)          # rte
mem.w16(STUB + 4, 0xa000 + t_iocs); mem.w16(STUB + 6, 0x4e73)
mem.w32(0x2c, STUB); mem.w32(0xbc, STUB + 4)
for v in range(0x20, 0x30):             # unused traps: ROM default $vvFFxxxx
    if v not in (0x2f,):
        mem.w32(v * 4, (v << 24) | 0xff0000 | 0x1000)
mem.w32(0x10c, (0x43 << 24) | 0xff1000)
CALL = STUB + 0x10                                                  # trap #4; done; bra *
mem.w16(CALL, 0x4e44); mem.w16(CALL + 2, 0xa000 + t_done); mem.w16(CALL + 4, 0x60fe)
IDLE = STUB + 0x20
mem.w16(IDLE, 0x4e71); mem.w16(IDLE + 2, 0x60fc)                    # nop; bra.s -4

# --- I/O: MFP, OPM, PPI, ADPCM; everything else reads 0 ---------------------
cycles = [0]
mfp = {}
opm = {"addr": 0, "regs": [0] * 256, "flags": 0, "a": None, "b": None, "irq": False}
log = []
io_unknown = {}

def opm_period(t):
    r = opm["regs"]
    if t == "a":
        na = (r[0x10] << 2) | (r[0x11] & 3)
        return (1024 - na) * 64 * CPU_HZ // 4_000_000
    return (256 - r[0x12]) * 1024 * CPU_HZ // 4_000_000

def opm_write(reg, val):
    old = opm["regs"][0x14]
    opm["regs"][reg] = val
    if reg == 0x14:
        if val & 0x10: opm["flags"] &= ~1
        if val & 0x20: opm["flags"] &= ~2
        for bit, t in ((1, "a"), (2, "b")):
            if val & bit and not old & bit:
                opm[t] = cycles[0] + opm_period(t)
            if not val & bit:
                opm[t] = None
    log.append((cycles[0], reg, val))

def io_read(addr):
    if addr == 0xe90003:
        return opm["flags"]                         # never busy
    if addr == 0xe88001:                            # GPIP: bit 7 V-DISP
        frame_c = CPU_HZ // 55
        vdisp = (cycles[0] % frame_c) < frame_c * 85 // 100
        return (0x80 if vdisp else 0) | (0 if opm["irq"] else 0x08) | 0x77
    if 0xe88000 <= addr < 0xe88040:
        return mfp.get(addr, 0)
    if addr == 0xe9a001:
        return 0xff
    io_unknown[addr & ~0xff] = io_unknown.get(addr & ~0xff, 0) + 1
    return 0

def io_write(addr, val):
    if addr == 0xe90001:
        opm["addr"] = val
    elif addr == 0xe90003:
        opm_write(opm["addr"], val)
    elif 0xe88000 <= addr < 0xe88040:
        mfp[addr] = val
    else:
        io_unknown[addr & ~0xff] = io_unknown.get(addr & ~0xff, 0) + 1

def rd8(a): return io_read(a)
def rd16(a): return (io_read(a) << 8) | io_read(a + 1)
def rd32(a): return (rd16(a) << 16) | rd16(a + 2)
def wr8(a, v): io_write(a, v & 0xff)
def wr16(a, v): io_write(a, (v >> 8) & 0xff); io_write(a + 1, v & 0xff)
def wr32(a, v): wr16(a, v >> 16); wr16(a + 2, v & 0xffff)
for page in range(0xe8, 0xf0):
    base = page << 16
    for w, rf, wf in ((0, rd8, wr8), (1, rd16, wr16), (2, rd32, wr32)):
        mem.set_special_range_read_func(base, w, rf)
        mem.set_special_range_write_func(base, w, wf)

# --- run helpers ------------------------------------------------------------
def tick_timers():
    for bit, t in ((1, "a"), (2, "b")):
        due = opm[t]
        while due is not None and due <= cycles[0]:
            if opm["regs"][0x14] & (bit << 2):
                opm["flags"] |= bit
            due += opm_period(t)
            opm[t] = due
    irq = opm["flags"] != 0
    edge = irq and not opm["irq"]
    opm["irq"] = irq
    return edge

pending = [False]
def maybe_interrupt():
    if not pending[0]:
        return
    sr = cpu.r_sr()
    if (sr >> 8) & 7 >= 6:
        return
    if not (mfp.get(0xe88009, 0) & 8 and mfp.get(0xe88015, 0) & 8):
        pending[0] = False
        return
    pc = cpu.r_pc()
    cpu.w_sr((sr | 0x2000) & ~0x8700 | 0x0600)
    sp = cpu.r_reg(R.A7) - 6
    mem.w16(sp, sr); mem.w32(sp + 2, pc)
    cpu.w_reg(R.A7, sp)
    vec = (mfp.get(0xe88017, 0x40) & 0xf0) + 3
    cpu.w_pc(mem.r32(vec * 4))
    pending[0] = False

def run(max_cycles, slice_c=2000, stop_on_done=True):
    end = cycles[0] + max_cycles
    while cycles[0] < end:
        r = mc.execute(slice_c)
        cycles[0] += r.cycles
        if tick_timers():
            pending[0] = True
        maybe_interrupt()
        if stop_on_done and (state["done"] or state["exit"]):
            return True
    return False

def call(d0, d1=0, a0=0, a1=0, d2=0):
    state["done"] = False
    for reg, v in ((R.D0, d0), (R.D1, d1), (R.D2, d2), (R.A0, a0), (R.A1, a1)):
        cpu.w_reg(reg, v & 0xffffffff)
    cpu.w_sr(0x2000)
    cpu.w_reg(R.A7, 0x9000)
    cpu.w_pc(CALL)
    ok = run(CPU_HZ * 5)
    return ok, cpu.r_reg(R.D0)

# --- install MCDRV ------------------------------------------------------------
CMD = 0x3800
cb = cmdline.encode()
mem.w8(CMD, len(cb)); mem.w_block(CMD + 1, cb + b"\0")
cpu.w_isp(0x9000); cpu.w_usp(0xa000)
cpu.w_sr(0x0000)
for reg, v in ((R.A0, PSP), (R.A1, END), (R.A2, CMD), (R.A3, 0x3900), (R.A4, B)):
    cpu.w_reg(reg, v)
cpu.w_pc(B + 0xe0)
mem.w32(0x3900, 0)
import os
if os.environ.get("TRACE_INSTALL"):
    labels = set(int(l, 16) for l in os.environ["TRACE_INSTALL"].split(","))
    seen = []
    def hook(pc=None):
        pc = cpu.r_pc() if pc is None else pc
        if pc - B in labels and (not seen or seen[-1] != pc - B):
            seen.append(pc - B)
    cpu.set_instr_hook_callback(hook)
run(CPU_HZ * 10)
if os.environ.get("TRACE_INSTALL"):
    cpu.set_instr_hook_callback(None)
    print("install path:", " ".join("%04X" % a for a in seen))
print("install:", "resident" if state["done"] else state["exit"], "|", " ".join(out_text).replace("\r\n", " / ")[:300])
print("trap #4 vector $%x, OPM vector $%x" % (mem.r32(0x90), mem.r32(0x10c)))
out_text.clear()

# --- play like the game: stop (5), set data (1), 5, play (2) ------------------
song = open(song_path, "rb").read()
SONG = 0x300000
mem.w_block(SONG, song)
results = []
for fn, kw in ((5, {}), (1, {"a0": SONG, "d1": len(song)}), (5, {}), (2, {})):
    ok, d0 = call(fn, **kw)
    results.append("fn%d->%s$%x" % (fn, "" if ok else "TIMEOUT ", d0))
print("calls:", " ".join(results))

# --- let it play --------------------------------------------------------------
state["done"] = False
cpu.w_sr(0x2000); cpu.w_reg(R.A7, 0x9000); cpu.w_pc(IDLE)
start = cycles[0]
run(int(CPU_HZ * seconds), stop_on_done=False)
with open(log_path, "w") as f:
    for c, reg, val in log:
        f.write("%d %02x %02x\n" % (c - start, reg, val))
played = [e for e in log if e[0] >= start]
print("OPM writes: %d total, %d while playing; key-ons %d" % (
    len(log), len(played), sum(1 for e in played if e[1] == 0x08 and e[2] & 0x78)))
print("timer regs: A=%d B=%d ctrl=$%02x" % ((opm["regs"][0x10] << 2) | (opm["regs"][0x11] & 3), opm["regs"][0x12], opm["regs"][0x14]))
print("IOCS calls:", {"$%02x" % k: v for k, v in iocs_calls.items()}, "| unknown I/O pages:", {"$%x" % k: v for k, v in io_unknown.items()})
if out_text:
    print("text:", " ".join(out_text)[:200])
