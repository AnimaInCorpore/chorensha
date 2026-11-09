; opm16 kernel: operator numbering, record layouts and variables.
; Shared by the game's DSP program (sources/atari/dsprite.asm) and the
; standalone test program (tools/opm16/opmtest.asm), which define the memory
; map (see opmtest.asm) before including it.

LFSR_TAPS	equ	$e10000
ATT_ONE		equ	8192		; envelope attenuation is 10.13 fixed point
ATT_MAX		equ	1023*ATT_ONE

; Operators are numbered q = 4 * channel + n, n = 0..3 for O1..O4, which
; are the slots channel + 0, 16, 8, 24.
;
; Channel record, OPR + CHR * channel: 0 routine, 1 mix base, 2/3 O1
; increment and gain, 4 history gain, 5 newest history, 6 older history,
; 7/8 O2 increment and gain, 9/10 O3, 11/12 O4.
CHR		equ	13

; Envelope record, ENV + 16 * q.
E_HND		equ	0		; state handler: h_att, h_dec, h_sus, h_rel, h_off
E_ATT		equ	1		; attenuation
E_CUR		equ	2		; step of the state (attack multiplier or add)
E_SL		equ	3		; sustain level
E_TL		equ	4		; TL * 8 + TAB_GAIN
E_AM		equ	5		; AM offset word (the channel's or ZERO)
E_SCALE		equ	6		; gain scale
E_GAINW		equ	7		; gain word in the channel record
E_AUD		equ	8		; audible flag word (CH_AUD + channel or SINK)
E_OPGW		equ	9		; 2^(-t/64) word (CH_OPG + channel or SINK)
E_MUL		equ	10		; attack multiplier, 0 = held
E_DADD		equ	11
E_SADD		equ	12
E_RADD		equ	13
E_AR		equ	14		; effective attack rate
E_KSR		equ	15		; key scaling the rates were made with

; Pitch record, PITCH + 8 * q: 0 DT2 value, 1 DT1 code, 2 frequency code
; + DT2, 3 block, 4 signed DT1 step, 5 MUL * 2 (or 1), 6 increment word.

wait_count	equ	VARS+0
fifo_rd		equ	VARS+1
fifo_wr		equ	VARS+2
seg		equ	VARS+3
lfo_hi		equ	VARS+4
lfo_lo		equ	VARS+5
native_frac	equ	VARS+6
lfsr		equ	VARS+7
noise_acc	equ	VARS+8
lfo_am		equ	VARS+9
lfo_pm		equ	VARS+10
lfo_last	equ	VARS+11
blocks		equ	VARS+12
cur_ch		equ	VARS+13
noise_amp	equ	VARS+14
capture_ptr	equ	VARS+15
noise_step	equ	VARS+16
noise_rec	equ	VARS+17		; ch 7 O4 record when the noise replaces it
noise_bit	equ	VARS+18
lfo_noise	equ	VARS+19
ssi_errors	equ	VARS+20
noise_val	equ	VARS+21
ev_word		equ	VARS+22
ev_reg		equ	VARS+23
ev_data		equ	VARS+24
slot		equ	VARS+25
native		equ	VARS+26
cur_pms		equ	VARS+27
cur_pm		equ	VARS+28
pmd		equ	VARS+29
bfreq		equ	VARS+30
oblock		equ	VARS+31
adj		equ	VARS+32
kcx		equ	VARS+33
ksr		equ	VARS+34
kmask		equ	VARS+35
cur_o		equ	VARS+36
cur_q		equ	VARS+37
cur_n		equ	VARS+38
csum		equ	VARS+40		; a2 a1 a0 b2 b1 b0
csum_prev	equ	VARS+46
rc_r4		equ	VARS+48		; render_channel: next channel record
rc_r7		equ	VARS+49		; and phase
starved		equ	VARS+50		; blocks that found the stream empty
fifo_blocks	equ	VARS+51		; blocks the waits in the FIFO add up to
