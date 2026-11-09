# Usage: bands.py model.wav reference.wav
# Level difference per frequency band (model minus reference, in dB).
import sys, numpy as np
def rd(p):
    d = open(p, "rb").read(); rate = int.from_bytes(d[24:28], "little")
    a = np.frombuffer(d[44:], dtype="<i2").astype(np.float64).reshape(-1, 2)
    return rate, a
def resample(a, src, dst):
    # windowed-sinc low-pass at 0.45*dst, then linear interpolation
    fc = 0.45 * dst / src; n = 255; k = np.arange(n) - n // 2
    h = np.sinc(2 * fc * k) * 2 * fc * np.hanning(n)
    f = np.stack([np.convolve(a[:, c], h, mode="same") for c in range(2)], 1)
    t = np.arange(int(len(a) * dst / src)) * src / dst
    i = t.astype(int); fr = t - i; i = np.minimum(i, len(a) - 2)
    return f[i] * (1 - fr)[:, None] + f[i + 1] * fr[:, None]
rm, m = rd(sys.argv[1]); rr, r = rd(sys.argv[2])
r = resample(r, rr, rm).mean(1); m = m.mean(1); n = min(len(m), len(r))
W = 4096; win = np.hanning(W)
def ps(x):
    P = np.zeros(W//2)
    for j in range(0, n - W, W//2): P += np.abs(np.fft.rfft(x[j:j+W]*win))[:W//2]**2
    return P
A = ps(m[:n]); B = ps(r[:n]); f = np.arange(W//2) * rm / W
out = []
for lo, hi in ((0,500),(500,1000),(1000,2000),(2000,4000),(4000,6000),(6000,int(rm*0.45))):
    s = (f >= lo) & (f < hi)
    out.append("%d-%dHz %+.1f" % (lo, hi, 10*np.log10((A[s].sum()+1)/(B[s].sum()+1))))
print("%-10s %6.0f Hz: model minus ymfm per band (dB): %s" % (sys.argv[1], rm, "  ".join(out)))
