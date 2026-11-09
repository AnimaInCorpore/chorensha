# Runs the LZX 1.04 self-extracting stub of an X68000 .X file in Musashi and
# dumps the unpacked program once the stub jumps into it.
import sys, struct
import machine68k as m
src, out = sys.argv[1], sys.argv[2]
B = int(sys.argv[3], 16) if len(sys.argv) > 3 else 0x10000
data = open(src, "rb").read()
assert data[:2] == b"HU"
text_size, data_size, bss_size = struct.unpack(">III", data[12:24])
text = bytearray(data[64:64 + text_size + data_size])
# The stub asks IOCS (trap #15) for the MPU type; answer "68000" by patching.
for off in (0x7c, 0x88):
    assert text[off:off+2] == b"\x4e\x4f"
text[0x7c:0x7e] = b"\x70\x00"   # moveq #0,d0 -> 68000, no cache flush
mc = m.Machine(m.CPUType.M68000, 2048)
mem, cpu = mc.mem, mc.cpu
mem.w_block(B, bytes(text))
end = B + text_size + data_size + bss_size
R = m.Register
cpu.w_reg(R.A0, B - 256); cpu.w_reg(R.A1, end); cpu.w_reg(R.A4, B)
cpu.w_reg(R.A7, 0x1f0000); cpu.w_sr(0x0000); cpu.w_usp(0x1f0000); cpu.w_isp(0x1f8000)
cpu.w_pc(B)
seen_high = False; hits = []
def hook(pc=None):
    global seen_high
    pc = cpu.r_pc() if pc is None else pc
    if pc >= B + 0x200: seen_high = True
    if seen_high and B <= pc < B + 0x200:
        hits.append(pc); mc.abort_execute()
cpu.set_instr_hook_callback(hook)
for _ in range(2000):
    mc.execute(100000)
    if hits: break
print("entry $%x (offset $%x)" % (hits[0], hits[0] - B) if hits else "no entry")
print("stopped at pc $%x after the stub, a0 $%x a1 $%x a4 $%x" % (cpu.r_pc(), cpu.r_reg(R.A0), cpu.r_reg(R.A1), cpu.r_reg(R.A4)))
size = 0x5314 + 0x200
open(out, "wb").write(bytes(mem.r_block(B, size)))
print("wrote", size, "bytes from $%x" % B)
