# Which YM2151 features do the logged songs use? Reads "cycles reg val" logs
# (10 MHz cycles) and reports per song and in total.
import collections, glob, os, sys
CON_CARRIERS = {0: [3], 1: [3], 2: [3], 3: [3], 4: [1, 3], 5: [1, 2, 3], 6: [1, 2, 3], 7: [0, 1, 2, 3]}
total = collections.defaultdict(collections.Counter)
def ops(ch):            # register offsets of M1, M2, C1, C2 (slots ch, ch+16, ch+8, ch+24)
    return [ch, ch + 16, ch + 8, ch + 24]
for p in sorted(glob.glob(sys.argv[1] + "/*.log")):
    name = os.path.basename(p)[:-4]
    regs = [0] * 256
    st = collections.defaultdict(collections.Counter)
    keyed = [0] * 8
    poly = collections.Counter()
    last_t = 0
    tick = 0
    for line in open(p):
        c, r, v = line.split(); c = max(0, int(c)); r = int(r, 16); v = int(v, 16)
        # sample polyphony every 10 ms
        while last_t + 100000 <= c:
            last_t += 100000
            poly[sum(1 for k in keyed if k)] += 1
        regs[r] = v
        if r == 0x08:
            ch = v & 7; keyed[ch] = (v >> 3) & 15
            if v & 0x78: st["keyon_mask"][(v >> 3) & 15] += 1; st["channels"][ch] += 1
        elif r == 0x0f: st["noise_en"][v >> 7] += 1
        elif r == 0x01: st["test/lfo reset"][v] += 1
        elif r == 0x18: st["lfrq"][v] += 1
        elif r == 0x19: st["pmd" if v & 0x80 else "amd"][v & 0x7f] += 1
        elif r == 0x1b: st["lfo wave"][v & 3] += 1
        elif 0x20 <= r < 0x28:
            st["algorithm"][v & 7] += 1; st["feedback"][(v >> 3) & 7] += 1; st["pan"][v >> 6] += 1
        elif 0x38 <= r < 0x40: st["pms"][(v >> 4) & 7] += 1; st["ams"][v & 3] += 1
        elif 0x40 <= r < 0x60: st["dt1"][(v >> 4) & 7] += 1; st["mul"][v & 15] += 1
        elif 0x80 <= r < 0xa0: st["ks"][v >> 6] += 1
        elif 0xa0 <= r < 0xc0: st["ams-en"][v >> 7] += 1
        elif 0xc0 <= r < 0xe0: st["dt2"][v >> 6] += 1
        elif r == 0x14: st["csm"][v >> 7] += 1
    st["polyphony (keyed channels per 10 ms)"] = poly
    print("== %s" % name)
    for k in ("algorithm", "feedback", "pan", "channels", "keyon_mask", "noise_en", "lfrq", "pmd", "amd", "lfo wave", "pms", "ams", "ams-en", "dt1", "dt2", "mul", "ks", "csm", "test/lfo reset", "polyphony (keyed channels per 10 ms)"):
        if st[k]:
            print("  %-38s %s" % (k, " ".join("%s:%d" % kv for kv in sorted(st[k].items()))))
        for kk, vv in st[k].items(): total[k][kk] += vv
print("== ALL SONGS")
for k, c in total.items():
    print("  %-38s %s" % (k, " ".join("%s:%d" % kv for kv in sorted(c.items()))))
