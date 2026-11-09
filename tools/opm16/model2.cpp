// model2: bit-level model of opm16.asm (the DSP kernel prototype).
//   model2 stream.bin out.wav blocks [capture.txt [check_blocks]]
// Plays the same word stream with the same tables and arithmetic; writes a
// WAV (16-bit, top bits of the 24-bit words) and optionally the first 128
// blocks as 24-bit words, one per line, for comparing with the DSP capture,
// followed by the checksum the DSP keeps over its first check_blocks blocks:
// S = sum of w << 24 and P = sum of 2 * w * previous w, both mod 2^56.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include "opm16_tab.h"

static const int32_t ATT_ONE = 8192, ATT_MAX = 1023 * 8192;
static const int OPMAP[4] = {0, 16, 8, 24};
static const int CARRIERS[8] = {8, 8, 8, 8, 10, 14, 14, 15};
static const int DT2[4] = {0, 384, 500, 608};
static const int32_t LFSR_TAPS = 0xe10000;

static int32_t s24(int64_t v) { v &= 0xffffff; return int32_t(v & 0x800000 ? v - 0x1000000 : v); }
static int32_t sat24(int64_t v) { return int32_t(v > 0x7fffff ? 0x7fffff : v < -0x800000 ? -0x800000 : v); }
// DSP mpyr: product 2xy with 24 fraction bits, convergent rounding into a1
static int32_t mpyr(int32_t x, int32_t y)
{
	int64_t p = 2 * int64_t(x) * y;
	int64_t q = p >> 24, r = p & 0xffffff;
	if (r > 0x800000 || (r == 0x800000 && (q & 1))) q++;
	return int32_t(q);
}
// DSP macr: a = acc (24-bit, zero fraction) + 2xy, convergent rounding of the sum
static int32_t macr(int32_t acc, int32_t x, int32_t y)
{
	int64_t v = (int64_t(acc) << 24) + 2 * int64_t(x) * y;
	int64_t q = v >> 24, r = v & 0xffffff;
	if (r > 0x800000 || (r == 0x800000 && (q & 1))) q++;
	return sat24(q);
}
static int32_t mpy_hi(int32_t x, int32_t y) { return int32_t((2 * int64_t(x) * y) >> 24); }

static int32_t R[256];
static int32_t att[32], state[32], inc[32], key[32], gain[32];
static int64_t phase[32];          // b1:b0, 48 bits
static int32_t gainh[8], dirty[8], audible_ch[8], opg[32];
static int32_t hist_x[8], hist_y[8];
static int32_t wait_count = 0, native_frac = 0, lfsr = 1, noise_acc = 0, lfo_am = 0, lfo_pm = 0, lfo_last = 0, lfo_noise = 0;
static int64_t lfo_counter = 0;
static int32_t noise_amp = 0, noise_val = 0, noise_bit = 0, noise_step = 0, noise_on = 0;
static int32_t ring_a[BLOCK + 1], ring_b[BLOCK + 1];
static int32_t mix[3 * BLOCK];
static std::vector<uint32_t> stream;
static size_t rd = 0;

static int lfsr_step()           // returns the shifted-out bit
{
	int bit = lfsr & 1;
	lfsr = (lfsr & 0xffffff) >> 1;
	if (bit) lfsr ^= LFSR_TAPS;
	return bit;
}

static int32_t keycode(int ch) { return (R[0x28 + ch] >> 2) & 31; }
static int32_t ksr_of(int s, int kc) { int sh = ((R[0x80 + s] >> 6) & 3) ^ 3; return kc >> sh; }
static int32_t eff_rate(int raw, int ksr) { if (!raw) return 0; raw += ksr; return raw > 63 ? 63 : raw; }

static void key_write(int data)
{
	int ch = data & 7, mask = (data >> 3) & 15;
	for (int o = 0; o < 4; o++) {
		int s = ch + OPMAP[o], on = (mask >> o) & 1;
		if (on) {
			if (key[s]) continue;
			key[s] = 1; state[s] = 0; phase[s] = 0;
			int r = eff_rate((R[0x80 + s] & 31) * 2, ksr_of(s, keycode(ch)));
			if (r >= 62) att[s] = 0;
		} else if (key[s]) {
			key[s] = 0; state[s] = 3;
		}
	}
}

static void write_reg(int reg, int data)
{
	int r = reg;
	if (reg == 0x19 && (data & 0x80)) r = 0x1a;
	R[r] = data;
	if (reg == 0x08) { key_write(data); return; }
	if ((reg >= 0x28 && reg < 0x60) || (reg >= 0xc0 && reg < 0xe0)) dirty[reg & 7] = 1;
}

static void events()
{
	if (wait_count > 0) { wait_count--; return; }
	while (rd < stream.size()) {
		uint32_t w = stream[rd++];
		if (w & 0x800000) { wait_count = int32_t(w & 0x7fffff) - 1; return; }
		write_reg((w >> 8) & 0xff, w & 0xff);
	}
}

static void lfo_block()
{
	int32_t a = native_frac + NATIVE_BLOCK_FRAC, native = NATIVE_BLOCK_INT;
	if (a & 0x800000) { a &= 0x7fffff; native++; }
	native_frac = a;
	int rate = R[0x18];
	int32_t step = (16 | (rate & 15)) << ((rate >> 4) & 15);
	lfo_counter = (lfo_counter + int64_t(step) * native) & 0xffffffffffffLL;
	if (R[0x01] & 2) lfo_counter = 0;
	int lfo = int((lfo_counter >> 22) & 0xff);
	int am, pm, w = R[0x1b] & 3;
	if (w == 0) { am = lfo ^ 0xff; pm = lfo; }
	else if (w == 1) { am = (lfo & 0x80) ? 0 : 0xff; pm = am ^ 0x80; }
	else if (w == 2) { int b = (lfo & 0x80) ? lfo : lfo ^ 0xff; am = (b << 1) & 0xff; pm = (lfo & 0x40) ? am : am ^ 0xff; }
	else {
		if (lfo != lfo_last) { lfsr_step(); lfo_noise = lfsr & 0xff; }
		am = lfo_noise; pm = lfo_noise;
	}
	lfo_last = lfo;
	lfo_am = (am * (R[0x19] & 0x7f)) >> 7;
	int pms = (pm & 0x80) ? pm - 256 : pm;
	lfo_pm = (pms * (R[0x1a] & 0x7f)) >> 7;
}

static void phase_inc(int ch, int s, int pms)
{
	int32_t bf = ((R[0x28 + ch] & 0x7f) << 6) | ((R[0x30 + ch] >> 2) & 63);
	int32_t delta = DT2[(R[0xc0 + s] >> 6) & 3];
	if (pms) {
		if (pms < 6) delta += lfo_pm >> (6 - pms);
		else delta += s24(int64_t(lfo_pm) << (pms - 5));
	}
	int32_t block = (bf >> 10) & 7;
	int32_t kc4 = (bf >> 6) & 15;
	int32_t eff = (((kc4 - (kc4 >> 2)) << 6) | (bf & 63)) + delta;
	int32_t step;
	bool done = false;
	if (eff < 0) {
		eff += 768;
		if (block == 0) { step = T_PSTEP[0] >> 7; done = true; } else block--;
	} else if (eff >= 768) {
		eff -= 768;
		if (eff >= 768) { eff -= 768; block++; }
		if (block >= 7) { step = T_PSTEP[767]; done = true; } else block++;
	}
	if (!done) step = T_PSTEP[eff] >> (block ^ 7);
	int dt = (R[0x40 + s] >> 4) & 7;
	int32_t adj = T_DT1[((bf >> 8) & 31) * 4 + (dt & 3)];
	step = (dt & 4) ? step - adj : step + adj;
	int32_t mul2 = (R[0x40 + s] & 15) * 2; if (!mul2) mul2 = 1;
	int64_t p = 2 * int64_t(s24(step)) * mul2;        // mpy x0,y0,a
	p >>= 2;                                            // asr a, asr a -> a0
	int32_t st = s24(p);                                // move a0,x0
	int64_t t = 2 * int64_t(st) * NPF_FRAC;            // mpy x0,NPF_FRAC
	t += (int64_t(st) * NPF_INT) << 24;                 // rep #NPF_INT add x0,a
	int32_t f = s24((t << 4) >> 24);                    // rep #4 asl a; a1
	inc[s] = mpyr(f, INC_K);
}

static void controls()
{
	for (int ch = 0; ch < 8; ch++) {
		int alg = R[0x20 + ch] & 7, fb = (R[0x20 + ch] >> 3) & 7;
		int ams = R[0x38 + ch] & 3, pms = (R[0x38 + ch] >> 4) & 7;
		int32_t am = 0;
		if (ams) am = s24(int64_t(lfo_am) << (ams - 1));
		int kc = keycode(ch);
		int audible = 0;
		for (int o = 0; o < 4; o++) {
			int s = ch + OPMAP[o];
			int ksr = ksr_of(s, kc);
			int32_t a = att[s];
			if (state[s] == 3 && a == ATT_MAX) {     // released and silent: nothing changes
				if (dirty[ch] || (pms && (R[0x1a] & 0x7f))) phase_inc(ch, s, pms);
				continue;
			}
			if (state[s] == 0 && a <= 0) { a = 0; state[s] = 1; }
			if (state[s] == 1) {
				int d1l = (R[0xe0 + s] >> 4) & 15;
				d1l |= (d1l + 1) & 16;
				if (a >= s24(int64_t(d1l) << 18)) state[s] = 2;
			}
			int raw;
			switch (state[s]) {
			case 0: raw = (R[0x80 + s] & 31) * 2; break;
			case 1: raw = (R[0xa0 + s] & 31) * 2; break;
			case 2: raw = (R[0xc0 + s] & 31) * 2; break;
			default: raw = (R[0xe0 + s] & 15) * 4 + 2; break;
			}
			int rate = eff_rate(raw, ksr);
			if (state[s] == 0) {
				if (rate < 62 && rate >= 2) {
					a = mpy_hi(a, T_ENV_MUL[rate]);
					if (a < ATT_ONE) a = 0;
				}
			} else {
				a += T_ENV_ADD[rate];
				if (a > ATT_MAX) a = ATT_MAX;
			}
			att[s] = a;
			int32_t t = mpy_hi(a, 0x400) + ((R[0x60 + s] & 0x7f) << 3);
			if (R[0xa0 + s] & 0x80) t += am;
			if (t > 1023) t = 1023;
			int32_t g = T_GAIN[t];
			opg[s] = g;
			if ((CARRIERS[alg] >> o) & 1) {
				gain[s] = mpyr(g, 0x1fe800);
				if (t < 960) audible = 1;
			} else gain[s] = mpyr(g, 1021);
			if (dirty[ch] || (pms && (R[0x1a] & 0x7f))) phase_inc(ch, s, pms);
		}
		gainh[ch] = mpyr(opg[ch], T_FBK[fb]);
		audible_ch[ch] = audible;
		dirty[ch] = 0;
	}
}

// stages ------------------------------------------------------------------------
static inline int idx(int64_t ph, int32_t mod) { return int((uint32_t((ph >> 24) & 0xffffff) + uint32_t(mod)) & 255); }
static inline void adv(int s) { phase[s] = (phase[s] + 510 * int64_t(inc[s])) & 0xffffffffffffLL; }

static void st_ind_w(int s, int32_t *out) { for (int i = 0; i < BLOCK; i++) { out[i] = mpyr(T_YROM[idx(phase[s], 0)], gain[s]); adv(s); } }
static void st_ind_acc(int s, int32_t *ring) { for (int i = 0; i < BLOCK; i++) { ring[i] = macr(ring[i], T_YROM[idx(phase[s], 0)], gain[s]); adv(s); } }
static void st_ser_w(int s, const int32_t *in, int32_t *out)
{
	int32_t tmp[BLOCK];
	for (int i = 0; i < BLOCK; i++) { tmp[i] = mpyr(T_YROM[idx(phase[s], in[i])], gain[s]); adv(s); }
	for (int i = 0; i < BLOCK; i++) out[i] = tmp[i];
}
static void st_ser_mix(int s, const int32_t *in, int32_t *m) { for (int i = 0; i < BLOCK; i++) { m[i] = macr(m[i], T_YROM[idx(phase[s], in[i])], gain[s]); adv(s); } }
static void st_ind_mix(int s, int32_t *m) { st_ind_acc(s, m); }
static void st_ser_acc(int s, const int32_t *in, int32_t *acc) { for (int i = 0; i < BLOCK; i++) { acc[i] = macr(acc[i], T_YROM[idx(phase[s], in[i])], gain[s]); adv(s); } }
static void st_fb_w(int ch, int s, int32_t *out)
{
	for (int i = 0; i < BLOCK; i++) {
		int32_t m = hist_x[ch] + hist_y[ch];
		hist_y[ch] = hist_x[ch];
		int32_t x0 = T_YROM[idx(phase[s], m)];
		adv(s);
		int32_t h = mpyr(x0, gainh[ch]);
		out[i] = mpyr(x0, gain[s]);
		hist_x[ch] = h;
	}
}
static void st_noise_mix(int32_t *m)
{
	for (int i = 0; i < BLOCK; i++) {
		noise_acc += noise_step;
		if (noise_acc & 0x800000) {
			noise_acc &= 0x7fffff;
			int bit = lfsr_step();
			noise_bit = bit;
			noise_val = bit ? -noise_amp : noise_amp;
		}
		m[i] = sat24(int64_t(m[i]) + noise_val);
	}
}

static void noise_setup()
{
	noise_on = 0;
	if (!(R[0x0f] & 0x80)) return;
	noise_step = T_NOISE[(R[0x0f] & 31) ^ 31];
	int32_t t = mpy_hi(att[31], 0x400) + ((R[0x7f] & 0x7f) << 3);
	if (t > 1023) t = 1023;
	noise_amp = (t ^ 1023) << 9;
	noise_val = noise_bit ? -noise_amp : noise_amp;
	noise_on = 1;
}

static void render_channels()
{
	noise_setup();
	for (int ch = 0; ch < 8; ch++) {
		if (!audible_ch[ch]) continue;
		int pan = (R[0x20 + ch] >> 6) & 3;
		if (!pan) continue;
		int32_t *m = mix + (pan == 3 ? 0 : pan == 1 ? BLOCK : 2 * BLOCK);
		int alg = R[0x20 + ch] & 7, fb = (R[0x20 + ch] >> 3) & 7;
		int o1 = ch, o2 = ch + 16, o3 = ch + 8, o4 = ch + 24;
		int32_t *A = ring_a + 1, *B = ring_b + 1;
		if (fb) st_fb_w(ch, o1, A); else st_ind_w(o1, A);
		bool noise = ch == 7 && noise_on;
		switch (alg) {
		case 0: st_ser_w(o2, A, B); st_ser_w(o3, B, A); if (noise) st_noise_mix(m); else st_ser_mix(o4, A, m); break;
		case 1: st_ind_acc(o2, A); st_ser_w(o3, A, B); if (noise) st_noise_mix(m); else st_ser_mix(o4, B, m); break;
		case 2: st_ind_w(o2, B); st_ser_acc(o3, B, A);
			if (noise) st_noise_mix(m); else st_ser_mix(o4, A, m); break;
		case 3: st_ser_w(o2, A, B); st_ind_acc(o3, B); if (noise) st_noise_mix(m); else st_ser_mix(o4, B, m); break;
		case 4: st_ser_mix(o2, A, m); st_ind_w(o3, B); if (noise) st_noise_mix(m); else st_ser_mix(o4, B, m); break;
		case 5: st_ser_mix(o2, A, m); st_ser_mix(o3, A, m); if (noise) st_noise_mix(m); else st_ser_mix(o4, A, m); break;
		case 6: st_ser_mix(o2, A, m); st_ind_mix(o3, m); if (noise) st_noise_mix(m); else st_ind_mix(o4, m); break;
		default: for (int i = 0; i < BLOCK; i++) m[i] = sat24(int64_t(m[i]) + A[i]);
			st_ind_mix(o2, m); st_ind_mix(o3, m); if (noise) st_noise_mix(m); else st_ind_mix(o4, m); break;
		}
	}
}

int main(int argc, char **argv)
{
	if (argc < 4) { std::fprintf(stderr, "usage: model2 stream.bin out.wav blocks [capture.txt]\n"); return 1; }
	FILE *f = std::fopen(argv[1], "rb");
	unsigned char b4[4];
	while (std::fread(b4, 1, 4, f) == 4) stream.push_back((uint32_t(b4[1]) << 16) | (b4[2] << 8) | b4[3]);
	std::fclose(f);
	long blocks = std::atol(argv[3]);
	for (int s = 0; s < 32; s++) { att[s] = ATT_MAX; state[s] = 3; }
	for (int c = 0; c < 8; c++) dirty[c] = 1;
	std::vector<int16_t> pcm;
	FILE *cap = argc > 4 ? std::fopen(argv[4], "w") : nullptr;
	long check_blocks = argc > 5 ? std::atol(argv[5]) : 0;
	uint64_t cs_s = 0, cs_p = 0;
	int32_t cs_prev = 0;
	for (long b = 0; b < blocks; b++) {
		events(); lfo_block(); controls();
		if (getenv("ENVDBG") && b == 7) for (int sl = 0; sl < 32; sl++) std::printf("slot %2d state %d att %06x gain %06x key %d\n", sl, state[sl], att[sl] & 0xffffff, gain[sl] & 0xffffff, key[sl]);
		if (getenv("REGSAT")) { for (int i = 0; i < 256; i++) std::printf("%ld %06x\n", b, R[i] & 0xffffff); }
		if (getenv("REGS") && b == 31) { for (int i = 0; i < 256; i++) std::printf("%06x\n", R[i] & 0xffffff); }
		if (getenv("DBG") && b < 32) { for (int i = 0; i < 32; i++) std::printf("%06x\n", inc[i] & 0xffffff); for (int i = 0; i < 32; i++) std::printf("%06x\n", gain[i] & 0xffffff); }
		for (int i = 0; i < 3 * BLOCK; i++) mix[i] = 0;
		render_channels();
		for (int i = 0; i < BLOCK; i++) {
			int32_t l = sat24(int64_t(mix[i]) + mix[BLOCK + i]), r = sat24(int64_t(mix[i]) + mix[2 * BLOCK + i]);
			pcm.push_back(int16_t(l >> 8)); pcm.push_back(int16_t(r >> 8));
			if (cap && b < 128) std::fprintf(cap, "%06x\n%06x\n", l & 0xffffff, r & 0xffffff);
			if (b < check_blocks) for (int32_t w : {l, r}) {
				cs_s += uint64_t(int64_t(w)) << 24;
				cs_p += uint64_t(2 * int64_t(w) * cs_prev);
				cs_prev = w;
			}
		}
	}
	if (cap) {
		const uint64_t M = (uint64_t(1) << 56) - 1;
		cs_s &= M; cs_p &= M;
		std::fprintf(cap, "check %ld %02x %06x %06x %02x %06x %06x\n", check_blocks,
			unsigned(cs_s >> 48), unsigned(cs_s >> 24) & 0xffffff, unsigned(cs_s) & 0xffffff,
			unsigned(cs_p >> 48), unsigned(cs_p >> 24) & 0xffffff, unsigned(cs_p) & 0xffffff);
		std::fclose(cap);
	}
	FILE *o = std::fopen(argv[2], "wb");
	uint32_t rate = uint32_t(TAB_RATE + 0.5), data = uint32_t(pcm.size() * 2), riff = 36 + data, fmt = 16, br = rate * 4;
	uint16_t pf = 1, chn = 2, al = 4, bits = 16;
	std::fwrite("RIFF", 1, 4, o); std::fwrite(&riff, 4, 1, o); std::fwrite("WAVEfmt ", 1, 8, o);
	std::fwrite(&fmt, 4, 1, o); std::fwrite(&pf, 2, 1, o); std::fwrite(&chn, 2, 1, o); std::fwrite(&rate, 4, 1, o);
	std::fwrite(&br, 4, 1, o); std::fwrite(&al, 2, 1, o); std::fwrite(&bits, 2, 1, o);
	std::fwrite("data", 1, 4, o); std::fwrite(&data, 4, 1, o); std::fwrite(pcm.data(), 2, pcm.size(), o);
	std::fclose(o);
	return 0;
}
