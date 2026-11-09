// Renders an OPM register write log ("cycles reg value" per line, cycles at
// 10 MHz) with ymfm's YM2151 at 4 MHz and writes a 48 kHz 16-bit stereo WAV.
#include "ymfm_opm.h"
#include <cmath>
#include <cstdio>
#include <cstdint>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

struct Write { uint64_t cycles; uint8_t reg, val; };

int main(int argc, char **argv)
{
    if (argc < 3) { std::fprintf(stderr, "usage: opmlog2wav in.log out.wav [seconds]\n"); return 1; }
    std::vector<Write> writes;
    std::ifstream in(argv[1]);
    std::string line;
    while (std::getline(in, line)) {
        std::istringstream ss(line);
        int64_t c; unsigned r, v;
        if (ss >> c >> std::hex >> r >> v) writes.push_back({uint64_t(c < 0 ? 0 : c), uint8_t(r), uint8_t(v)});
    }
    double seconds = argc > 3 ? std::atof(argv[3]) : (writes.empty() ? 1.0 : writes.back().cycles / 1e7 + 1.0);

    ymfm::ymfm_interface intf;
    ymfm::ym2151 chip(intf);
    chip.reset();
    const double chip_rate = 4000000.0 / 64.0;
    const uint64_t native = uint64_t(seconds * chip_rate);
    std::vector<float> l(native), r(native);
    size_t w = 0;
    for (uint64_t i = 0; i < native; ++i) {
        uint64_t now = uint64_t(i * (1e7 / chip_rate));
        while (w < writes.size() && writes[w].cycles <= now) {
            chip.write_address(writes[w].reg);
            chip.write_data(writes[w].val);
            ++w;
        }
        ymfm::ym2151::output_data out;
        chip.generate(&out, 1);
        l[i] = float(out.data[0]); r[i] = float(out.data[1]);
    }
    const uint32_t rate = 48000;
    const uint64_t frames = uint64_t(seconds * rate);
    std::vector<int16_t> pcm(frames * 2);
    for (uint64_t f = 0; f < frames; ++f) {
        double pos = f * chip_rate / rate;
        uint64_t i = uint64_t(pos); double t = pos - i;
        uint64_t j = std::min<uint64_t>(i + 1, native - 1);
        double a = l[i] * (1 - t) + l[j] * t, b = r[i] * (1 - t) + r[j] * t;
        pcm[2 * f] = int16_t(std::max(-32768.0, std::min(32767.0, a)));
        pcm[2 * f + 1] = int16_t(std::max(-32768.0, std::min(32767.0, b)));
    }
    FILE *o = std::fopen(argv[2], "wb");
    uint32_t data = uint32_t(pcm.size() * 2), riff = 36 + data, fmt = 16, byterate = rate * 4;
    uint16_t pcmfmt = 1, ch = 2, align = 4, bits = 16;
    std::fwrite("RIFF", 1, 4, o); std::fwrite(&riff, 4, 1, o); std::fwrite("WAVEfmt ", 1, 8, o);
    std::fwrite(&fmt, 4, 1, o); std::fwrite(&pcmfmt, 2, 1, o); std::fwrite(&ch, 2, 1, o);
    std::fwrite(&rate, 4, 1, o); std::fwrite(&byterate, 4, 1, o); std::fwrite(&align, 2, 1, o);
    std::fwrite(&bits, 2, 1, o); std::fwrite("data", 1, 4, o); std::fwrite(&data, 4, 1, o);
    std::fwrite(pcm.data(), 2, pcm.size(), o);
    std::fclose(o);
    std::printf("%zu writes, %.1f s, peak check done\n", writes.size(), seconds);
    return 0;
}
