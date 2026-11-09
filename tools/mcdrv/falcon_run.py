# Runs MCDRV the way the Falcon build does (falcon_test.s: sources/mcdrv.s
# with __ATARI__ plus sources/atari/music.s) in Musashi as a 68030, with
# nothing of the X68000 around it: any access to $E00000-$FFFFFF, any change
# to the first 4 KB and any unexpected exception is reported. Plays a song
# like the game (trap #4: stop, set data, stop, play), then calls
# music_generate like the VBL and takes the ring like the DSP would, and
# writes the stream words it got (big-endian longs, like mkstream.py).
#
#   falcon_run.py image.bin map.txt song.mdc seconds out.bin
import re, struct, sys
import machine68k as m

R = m.Register
img_path, map_path, song_path, seconds, out_path = sys.argv[1:6]
seconds = float(seconds)
BASE = 0x10000
RATE = 25175000 / 256 / 4
BLOCK = 48

syms = {}
for line in open(map_path):
    s = re.match(r"\s+(\w+): \w+ \w+, value 0x([0-9a-f]+)", line)
    if s:
        syms[s.group(1)] = int(s.group(2), 16)

mc = m.Machine(m.CPUType.M68030, 8 * 1024)
mem, cpu, traps = mc.mem, mc.cpu, mc.traps
mem.w_block(BASE, open(img_path, "rb").read())

state = {"done": False}
problems = []

def done(*_):
    state["done"] = True
    mc.abort_execute()

def exception(*_):
    ssp = cpu.r_reg(R.A7)
    vec = (mem.r16(ssp + 6) & 0xfff) // 4
    problems.append("exception vector %d at $%x" % (vec, mem.r32(ssp + 2)))
    state["done"] = True
    mc.abort_execute()

t_done, t_exc = traps.alloc(done), traps.alloc(exception)
STUB = 0x2000
mem.w16(STUB, 0xa000 + t_exc)
mem.w16(STUB + 2, 0x4e73)                       # rte
mem.w16(STUB + 4, 0x4e73)                       # rte: trap #2 (PCM8) does nothing
for v in range(2, 256):
    mem.w32(v * 4, STUB)
mem.w32(0x88, STUB + 4)
mem.w32(0x90, syms["trap_4_handler"])
DONE = STUB + 0x10
mem.w16(DONE, 0xa000 + t_done)
CALL4 = STUB + 0x20                             # trap #4, done
mem.w16(CALL4, 0x4e44); mem.w16(CALL4 + 2, 0xa000 + t_done)

io = {}
def io_read(addr, *_):
    io[addr] = io.get(addr, 0) + 1
    return 0
def io_write(addr, *_):
    io[addr] = io.get(addr, 0) + 1
for page in range(0xe0, 0x100):
    for w in (0, 1, 2):
        mem.set_special_range_read_func(page << 16, w, io_read)
        mem.set_special_range_write_func(page << 16, w, io_write)

low = mem.r_block(0, 0x1000)
cycles = [0]

def run(pc, sr, regs={}):
    state["done"] = False
    for reg, v in regs.items():
        cpu.w_reg(reg, v & 0xffffffff)
    cpu.w_sr(sr)
    sp = 0x9000
    sp -= 4; mem.w32(sp, DONE)
    cpu.w_reg(R.A7, sp)
    cpu.w_pc(pc)
    n = 0
    while not state["done"]:
        r = mc.execute(100000)
        cycles[0] += r.cycles
        n += r.cycles
        if n > 50_000_000:
            problems.append("no return from $%x" % pc)
            break
    return n

def trap4(d0, **kw):
    regs = {R.D0: d0}
    regs.update({getattr(R, k.upper()): v for k, v in kw.items()})
    run(CALL4, 0x2000, regs)
    return cpu.r_reg(R.D0)

run(syms["music_init"], 0x2700)
song = open(song_path, "rb").read()
SONG = 0x300000
mem.w_block(SONG, song)
results = [trap4(5), trap4(1, a0=SONG, d1=len(song)), trap4(5), trap4(2)]
print("calls: " + " ".join("$%x" % r for r in results))

ring, ring_end = syms["music_ring"], syms["music_ring_end"]
out, blocks, gen_cycles, vbls = [], 0, 0, 0
total = int(seconds * RATE / BLOCK)
while blocks < total and not problems:
    gen_cycles += run(syms["music_generate"], 0x2400)
    vbls += 1
    rd, wr = mem.r32(syms["music_read"]), mem.r32(syms["music_write"])
    sent = 0
    while rd != wr:
        w = mem.r32(rd)
        out.append(w)
        if w & 0x800000:
            sent += w & 0xffff
        rd += 4
        if rd == ring_end:
            rd = ring
    mem.w32(syms["music_read"], rd)
    mem.w32(syms["music_sent_blocks"], mem.r32(syms["music_sent_blocks"]) + sent)
    blocks += sent
    if vbls > 1_000_000:
        problems.append("the stream does not advance")

open(out_path, "wb").write(b"".join(struct.pack(">I", w) for w in out))
changed = [a for a in range(0x1000) if low[a] != mem.r8(a)]
if changed:
    problems.append("low memory changed at " + " ".join("$%x" % a for a in changed[:16]))
if io:
    problems.append("I/O accesses: " + " ".join("$%x x%d" % kv for kv in sorted(io.items())[:16]))
dropped = mem.r32(syms["music_dropped"])
if dropped:
    problems.append("%d words dropped" % dropped)
music_s = blocks * BLOCK / RATE
print("%d words, %d blocks (%.1f s), MCDRV takes %.0f cycles a second of music (%.1f%% of a 16 MHz 68030)" % (
    len(out), blocks, music_s, gen_cycles / music_s, gen_cycles / music_s / 16e6 * 100))
for p in problems:
    print("PROBLEM:", p)
sys.exit(1 if problems else 0)
