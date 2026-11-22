// Membuat suara latar dan efek suara Guild Petualang dari nol (tanpa sampel orang lain).
// Jalankan dari folder app:  node tool/make_audio.js
// Hasil: assets/audio/ambient_hall.wav (loop 32 dtk), door.wav, bell.wav, tap.wav
const fs = require('fs');
const path = require('path');

const SR = 22050;
const TAU = Math.PI * 2;
const outDir = path.join(__dirname, '..', 'assets', 'audio');
fs.mkdirSync(outDir, { recursive: true });

function rng(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const mtof = (m) => 440 * Math.pow(2, (m - 69) / 12);

function lowpass(x, cutoff) {
  const a = 1 - Math.exp((-TAU * cutoff) / SR);
  const y = new Float32Array(x.length);
  let s = 0;
  for (let i = 0; i < x.length; i++) {
    s += a * (x[i] - s);
    y[i] = s;
  }
  return y;
}
function highpass(x, cutoff) {
  const lp = lowpass(x, cutoff);
  return x.map((v, i) => v - lp[i]);
}

// Pantulan ruangan ala Schroeder. Sinyal diulang tiga kali lalu salinan terakhir diambil,
// sehingga ekor pantulan menyambung mulus saat loop.
function reverb(x, wet, circular) {
  const reps = circular ? 3 : 1;
  const len = x.length;
  const input = new Float32Array(len * reps);
  for (let r = 0; r < reps; r++) input.set(x, r * len);
  const combs = [0.0297, 0.0371, 0.0411, 0.0437].map((d) => ({ d: Math.round(d * SR), buf: null, i: 0 }));
  combs.forEach((c) => (c.buf = new Float32Array(c.d)));
  const fb = 0.8;
  let out = new Float32Array(input.length);
  for (let n = 0; n < input.length; n++) {
    let s = 0;
    for (const c of combs) {
      const y = c.buf[c.i];
      c.buf[c.i] = input[n] + y * fb;
      c.i = (c.i + 1) % c.d;
      s += y;
    }
    out[n] = s / combs.length;
  }
  for (const [d, g] of [[0.005, 0.7], [0.0017, 0.7]]) {
    const n = Math.round(d * SR);
    const buf = new Float32Array(n);
    let i = 0;
    const res = new Float32Array(out.length);
    for (let k = 0; k < out.length; k++) {
      const z = buf[i];
      const v = out[k] + g * z;
      buf[i] = v;
      res[k] = z - g * v;
      i = (i + 1) % n;
    }
    out = res;
  }
  const tail = out.subarray((reps - 1) * len);
  const y = new Float32Array(len);
  for (let i = 0; i < len; i++) y[i] = x[i] * (1 - wet) + tail[i] * wet * 1.6;
  return y;
}

function normalize(x, peak) {
  let m = 0;
  for (const v of x) m = Math.max(m, Math.abs(v));
  const k = m > 0 ? peak / m : 1;
  return x.map((v) => v * k);
}

function writeWav(name, x) {
  const pcm = Buffer.alloc(x.length * 2);
  for (let i = 0; i < x.length; i++) {
    const v = Math.max(-1, Math.min(1, x[i]));
    pcm.writeInt16LE(Math.round(v * 32767), i * 2);
  }
  const h = Buffer.alloc(44);
  h.write('RIFF', 0);
  h.writeUInt32LE(36 + pcm.length, 4);
  h.write('WAVEfmt ', 8);
  h.writeUInt32LE(16, 16);
  h.writeUInt16LE(1, 20);
  h.writeUInt16LE(1, 22);
  h.writeUInt32LE(SR, 24);
  h.writeUInt32LE(SR * 2, 28);
  h.writeUInt16LE(2, 32);
  h.writeUInt16LE(16, 34);
  h.write('data', 36);
  h.writeUInt32LE(pcm.length, 40);
  const file = path.join(outDir, name);
  fs.writeFileSync(file, Buffer.concat([h, pcm]));
  console.log(name, (x.length / SR).toFixed(1) + ' dtk', Math.round((44 + pcm.length) / 1024) + ' KB');
}

// Menulis nada ke buffer. circular = true: ekor yang melewati ujung buffer kembali ke awal.
function bellTone(buf, t0, midi, amp, circular, decay = 1.7) {
  const f = mtof(midi);
  const len = Math.min(Math.round(SR * decay * 4), buf.length);
  const start = Math.round(t0 * SR);
  for (let i = 0; i < len; i++) {
    const t = i / SR;
    const v =
      Math.sin(TAU * f * t) * Math.exp(-t / decay) +
      0.45 * Math.sin(TAU * f * 2.76 * t) * Math.exp(-t / (decay * 0.45)) +
      0.2 * Math.sin(TAU * f * 5.4 * t) * Math.exp(-t / (decay * 0.2));
    const att = Math.min(1, i / (SR * 0.004));
    let idx = start + i;
    if (circular) idx %= buf.length;
    else if (idx >= buf.length) break;
    buf[idx] += v * att * amp;
  }
}

// ---------- Suara latar: aula guild, 32 detik, melingkar ----------
function ambient() {
  const T = 32;
  const N = SR * T;
  const pad = new Float32Array(N);
  const chords = [
    { root: 38, notes: [50, 57, 62, 65] }, // Dm
    { root: 34, notes: [53, 58, 62, 65] }, // Bb
    { root: 41, notes: [48, 53, 57, 64] }, // F (maj7)
    { root: 36, notes: [55, 60, 64, 67] }, // C
  ];
  const seg = 8;
  const fade = 2.6;
  chords.forEach((c, ci) => {
    const t0 = ci * seg - 1.4; // tumpang tindih dengan akord sebelumnya
    const dur = seg + 2.8;
    const len = Math.round(dur * SR);
    c.notes.forEach((m, ni) => {
      const f = mtof(m);
      for (let i = 0; i < len; i++) {
        const t = i / SR;
        const up = Math.min(1, t / fade);
        const down = Math.min(1, (dur - t) / fade);
        const env = Math.pow(Math.sin((Math.min(up, down) * Math.PI) / 2), 2);
        const ph = TAU * t;
        const v =
          Math.sin(ph * f * 0.9965) + Math.sin(ph * f * 1.0035) +
          0.28 * Math.sin(ph * f * 2) + 0.1 * Math.sin(ph * f * 3);
        const idx = (((Math.round(t0 * SR) + i) % N) + N) % N;
        pad[idx] += v * env * (0.05 - ni * 0.004);
      }
    });
    // dasar akord, satu oktaf di atas nada terendah agar terdengar di speaker ponsel
    const fr = mtof(c.root + 12);
    for (let i = 0; i < len; i++) {
      const t = i / SR;
      const up = Math.min(1, t / fade);
      const down = Math.min(1, (dur - t) / fade);
      const env = Math.pow(Math.sin((Math.min(up, down) * Math.PI) / 2), 2);
      const idx = (((Math.round(t0 * SR) + i) % N) + N) % N;
      pad[idx] += (Math.sin(TAU * fr * t) + 0.3 * Math.sin(TAU * fr * 2 * t)) * env * 0.09;
    }
  });
  // buat hangat: saring dua putaran supaya sambungan loop tidak patah
  const twice = new Float32Array(N * 2);
  twice.set(pad, 0);
  twice.set(pad, N);
  const warm = lowpass(twice, 1800).subarray(N);

  // denting lonceng jarang, nadanya mengikuti akord
  const bells = new Float32Array(N);
  const hits = [
    [1.2, 81], [4.8, 77],
    [9.0, 74], [12.6, 77], [14.8, 82],
    [17.4, 84], [20.8, 81], [23.0, 77],
    [25.2, 76], [28.4, 79], [30.6, 84],
  ];
  hits.forEach(([t, m]) => bellTone(bells, t, m, 0.06, true));

  // desir ruangan: derau rendah, ujungnya dipadukan agar tidak terputus
  const rand = rng(7);
  const noise = lowpass(Float32Array.from({ length: N }, () => rand() * 2 - 1), 500);
  const room = new Float32Array(N);
  for (let i = 0; i < N; i++) {
    const w = Math.sin((Math.PI * i) / N);
    room[i] = noise[i] * w + noise[(i + N / 2) % N] * Math.sqrt(Math.max(0, 1 - w * w));
  }

  const mix = new Float32Array(N);
  for (let i = 0; i < N; i++) mix[i] = warm[i] + bells[i] + room[i] * 0.55;
  const wet = reverb(mix, 0.38, true);
  const out = normalize(wet, 0.5).map((v) => Math.tanh(v * 1.1));
  writeWav('ambient_hall.wav', out);
}

// ---------- Efek: ketukan ----------
function tap() {
  const n = Math.round(SR * 0.14);
  const x = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const t = i / SR;
    x[i] = (Math.sin(TAU * 1250 * t) * 0.8 + Math.sin(TAU * 1880 * t) * 0.3) * Math.exp(-t / 0.028) * Math.min(1, i / (SR * 0.002));
  }
  writeWav('tap.wav', normalize(x, 0.45));
}

// ---------- Efek: lonceng quest ----------
function bell() {
  const n = Math.round(SR * 3.2);
  const x = new Float32Array(n);
  bellTone(x, 0.0, 74, 0.5, false, 1.2);
  bellTone(x, 0.16, 81, 0.5, false, 1.3);
  bellTone(x, 0.32, 86, 0.55, false, 1.6);
  const withEcho = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const d = Math.round(SR * 0.23);
    withEcho[i] = x[i] + (i >= d ? withEcho[i - d] * 0.28 : 0);
  }
  writeWav('bell.wav', normalize(reverb(withEcho, 0.25, false), 0.6));
}

// ---------- Efek: pintu guild terbuka ----------
function door() {
  const T = 3.0;
  const n = Math.round(SR * T);
  const rand = rng(21);
  const raw = Float32Array.from({ length: n }, () => rand() * 2 - 1);
  const rumble = lowpass(raw, 160);
  const scrape = highpass(lowpass(raw, 1100), 260);
  const x = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const t = i / SR;
    const swell = Math.min(1, Math.max(0, (t - 0.45) / 0.6)) * Math.min(1, Math.max(0, (2.35 - t) / 0.7));
    const wobble = 0.65 + 0.35 * Math.sin(TAU * 2.3 * t);
    const thump = Math.sin(TAU * (52 - 18 * Math.min(1, t)) * t) * Math.exp(-t / 0.22);
    const creak = Math.sin(TAU * (190 - 28 * (t / T)) * t + 3 * Math.sin(TAU * 11 * t)) * Math.min(1, Math.max(0, (t - 0.5) / 0.4)) * Math.min(1, Math.max(0, (2.0 - t) / 0.6));
    x[i] = rumble[i] * 14 * swell + scrape[i] * 5 * swell * wobble + thump * 0.8 + creak * 0.07;
  }
  bellTone(x, 2.05, 81, 0.16, false, 1.0);
  writeWav('door.wav', normalize(reverb(x, 0.2, false), 0.7));
}

ambient();
tap();
bell();
door();
