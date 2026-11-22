/**
 * Membuat Google Form riset pengguna "Guild Petualang".
 *
 * Cara pakai:
 * 1. Buka https://script.google.com lalu klik "Proyek baru".
 * 2. Hapus isi bawaan, tempel seluruh isi file ini.
 * 3. Isi tiga baris "ISI DULU" di bawah.
 * 4. Pilih fungsi buatFormGuildPetualang di bilah atas, klik Jalankan, lalu izinkan aksesnya.
 * 5. Buka menu Eksekusi (Execution log) untuk melihat link isian, link edit, dan link spreadsheet jawaban.
 */

// ===== ISI DULU =====
var PENELITI = '[Isi namamu]';
var PROGRAM = '[Isi: mahasiswa Magister Teknik Informatika, nama kampus]';
var KONTAK = '[Isi email atau WhatsApp yang boleh dihubungi]';
// ====================

var OPSI_LAIN = true;

var SEKSI_A = [
  {t: 'pilih', j: 'Berapa rentang usiamu?', o: ['Di bawah 20 tahun', '20–24 tahun', '25–29 tahun', '30–39 tahun', '40 tahun atau lebih']},
  {t: 'pilih', j: 'Apa pendidikan terakhirmu?', o: ['SD atau SMP', 'SMA/SMK sederajat', 'Diploma (D1–D3)', 'Sarjana (S1/D4)', 'Pascasarjana (S2/S3)']},
  {t: 'pilih', j: 'Bagaimana kondisimu saat ini?', o: ['Belum bekerja dan sedang mencari', 'Bekerja, tetapi mencari tambahan penghasilan', 'Bekerja tidak tetap (harian, borongan, lepas)', 'Sedang kuliah dan mencari pekerjaan paruh waktu'], l: OPSI_LAIN},
  {t: 'teks', j: 'Di kota atau kabupaten mana kamu tinggal?', b: 'Cukup nama kota atau kabupaten, tidak perlu alamat lengkap.'},
  {t: 'pilih', j: 'Sudah berapa lama kamu mencari pekerjaan atau penghasilan tambahan?', o: ['Baru mulai (kurang dari 1 bulan)', '1–3 bulan', '3–6 bulan', '6–12 bulan', 'Lebih dari 1 tahun', 'Saat ini tidak sedang mencari']},
  {t: 'centang', j: 'Lewat mana saja kamu biasa mencari?', o: ['Portal atau aplikasi lowongan online', 'Media sosial atau grup WhatsApp/Telegram', 'Kenalan, teman, atau keluarga', 'Datang langsung ke tempat usaha', 'Agen atau penyalur tenaga kerja'], l: OPSI_LAIN},
  {t: 'para', j: 'Ceritakan pengalaman terakhirmu mencari atau melamar pekerjaan. Apa yang kamu lakukan dan apa yang terjadi?', b: 'Misalnya: lowongan apa, bagaimana prosesnya, dan hasilnya.'},
  {t: 'centang', j: 'Apa tiga hambatan terbesar yang kamu rasakan?', o: ['Belum punya pengalaman kerja', 'Syarat lowongan terasa terlalu tinggi atau tidak berkaitan dengan pekerjaannya (usia, ijazah, penampilan, dll.)', 'Lowongan di sekitarku sedikit', 'Gaji yang ditawarkan tidak cukup untuk kebutuhan', 'Tidak tahu di mana info lowongan yang tepercaya', 'Proses seleksi panjang atau tidak ada kabar', 'Biaya dan jarak ke tempat kerja', 'Takut tertipu atau tidak dibayar'], l: OPSI_LAIN, maks: 3},
  {t: 'centang', j: 'Pernah menolak atau melepas pekerjaan yang ditawarkan? Apa alasannya?', b: 'Boleh pilih lebih dari satu.', o: ['Upah terlalu kecil', 'Jarak atau biaya transportasi', 'Jam atau kondisi kerja', 'Khawatir pandangan orang lain terhadap pekerjaan itu', 'Merasa belum mampu', 'Tidak pernah menolak'], l: OPSI_LAIN},
  {t: 'pilih', j: 'Pernah mengerjakan pekerjaan kecil atau lepas (harian, borongan, freelance)?', o: ['Ya, cukup sering', 'Ya, beberapa kali', 'Belum pernah, tetapi mau mencoba', 'Belum pernah dan kurang tertarik']},
  {t: 'pilih', j: 'Pernah mengalami pekerjaan yang tidak dibayar, dibayar kurang, atau ditipu?', o: ['Ya, pernah', 'Belum pernah, tetapi saya khawatir', 'Belum pernah dan tidak terlalu khawatir']},
  {t: 'para', j: 'Apa yang membuatmu merasa aman menerima pekerjaan dari orang yang belum kamu kenal?'},
  {t: 'pilih', j: 'Untuk pekerjaan kecil sekitar 2–3 jam, berapa imbalan minimal yang membuatmu mau mengambilnya?', o: ['Kurang dari Rp50.000', 'Rp50.000–Rp100.000', 'Rp100.000–Rp200.000', 'Lebih dari Rp200.000', 'Tergantung jenis pekerjaannya']},
  {t: 'centang', j: 'Apa saja yang biasa kamu gunakan?', o: ['Ponsel Android', 'iPhone', 'Dompet digital atau transfer bank lewat ponsel', 'Aplikasi ojek atau belanja online', 'Media sosial', 'Saya belum punya ponsel pintar']}
];

var SEKSI_B = [
  {t: 'centang', j: 'Seperti apa usaha atau kebutuhanmu?', o: ['Kuliner', 'Toko atau retail', 'Jasa (bengkel, salon, laundry, dll.)', 'Usaha kreatif atau toko online', 'Pertanian atau peternakan', 'Kebutuhan rumah tangga atau pribadi'], l: OPSI_LAIN},
  {t: 'pilih', j: 'Berapa orang yang bekerja tetap bersamamu (di luar dirimu)?', o: ['Tidak ada', '1–2 orang', '3–5 orang', '6–10 orang', 'Lebih dari 10 orang', 'Bukan usaha (kebutuhan pribadi)']},
  {t: 'pilih', j: 'Seberapa sering kamu butuh bantuan untuk pekerjaan singkat atau sekali-sekali?', o: ['Hampir setiap minggu', 'Beberapa kali sebulan', 'Beberapa kali setahun', 'Hampir tidak pernah']},
  {t: 'centang', j: 'Pekerjaan seperti apa yang paling sering kamu butuhkan?', o: ['Antar atau angkut barang', 'Bersih-bersih, perbaikan, atau pertukangan', 'Administrasi, pencatatan, atau input data', 'Desain, promosi, atau konten media sosial', 'Menjaga toko atau melayani pelanggan', 'Website, aplikasi, atau urusan teknologi', 'Penulisan atau penerjemahan'], l: OPSI_LAIN},
  {t: 'para', j: 'Ceritakan terakhir kali kamu mencari orang untuk membantu pekerjaan. Bagaimana caranya, dan bagian mana yang paling merepotkan?'},
  {t: 'centang', j: 'Apa tiga hal yang paling kamu khawatirkan saat memakai tenaga yang belum dikenal?', o: ['Hasil kerja tidak sesuai harapan', 'Tidak amanah atau tiba-tiba menghilang', 'Keamanan barang, uang, atau tempat usaha', 'Harga tidak sesuai atau berubah-ubah', 'Sulit berkomunikasi', 'Urusan pembayaran dan bukti', 'Tidak ada jaminan jika pekerjaan gagal'], l: OPSI_LAIN, maks: 3},
  {t: 'centang', j: 'Syarat apa yang biasa kamu minta dari orang yang kamu pakai?', o: ['Pengalaman kerja', 'Ijazah atau pendidikan tertentu', 'Tinggal di sekitar usaha', 'Portofolio atau contoh hasil kerja', 'Rekomendasi dari orang yang dikenal', 'Tes singkat', 'Tidak ada syarat khusus'], l: OPSI_LAIN},
  {t: 'para', j: 'Dari syarat itu, mana yang benar-benar penting untuk hasil pekerjaan, dan mana yang sebenarnya hanya kebiasaan?'},
  {t: 'pilih', j: 'Berapa biaya yang biasa kamu keluarkan untuk satu pekerjaan kecil?', o: ['Kurang dari Rp100.000', 'Rp100.000–Rp300.000', 'Rp300.000–Rp1.000.000', 'Lebih dari Rp1.000.000', 'Berbeda-beda']},
  {t: 'centang', j: 'Bagaimana biasanya kamu membayar?', o: ['Tunai setelah selesai', 'Transfer atau dompet digital setelah selesai', 'Bayar sebagian di depan (DP)', 'Bayar penuh di depan', 'Tidak ada pola tetap'], l: OPSI_LAIN}
];

var SEKSI_C = [
  {t: 'centang', j: 'Apa bidang keterampilanmu?', o: ['Desain grafis atau konten visual', 'Pemrograman atau teknologi', 'Penulisan atau penerjemahan', 'Administrasi atau pembukuan', 'Pertukangan, perbaikan, atau kerajinan', 'Pengajaran atau pelatihan', 'Pelayanan kesehatan atau farmasi', 'Memasak atau tata boga'], l: OPSI_LAIN},
  {t: 'pilih', j: 'Sudah berapa lama kamu menerima pekerjaan lepas atau proyek?', o: ['Belum pernah', 'Kurang dari 1 tahun', '1–3 tahun', 'Lebih dari 3 tahun']},
  {t: 'centang', j: 'Dari mana biasanya kamu mendapat klien atau pekerjaan?', o: ['Kenalan atau teman', 'Media sosial', 'Platform freelance', 'Grup komunitas', 'Agensi atau perusahaan', 'Belum mendapat klien'], l: OPSI_LAIN},
  {t: 'centang', j: 'Bukti kemampuan apa yang biasa kamu pakai untuk meyakinkan klien?', o: ['Portofolio', 'Sertifikat atau pelatihan', 'Ijazah', 'Testimoni klien', 'Tes atau contoh langsung', 'Belum ada bukti'], l: OPSI_LAIN},
  {t: 'para', j: 'Pernah ditolak atau diragukan karena belum punya pengalaman formal atau ijazah tertentu? Ceritakan.'},
  {t: 'centang', j: 'Apa tiga masalah terbesar saat bekerja lepas?', o: ['Klien terlambat membayar atau tidak membayar', 'Permintaan berubah-ubah atau revisi tanpa batas', 'Tarif ditawar terlalu rendah', 'Sulit mendapat klien', 'Tidak ada kontrak atau bukti kesepakatan', 'Sengketa tanpa pihak penengah', 'Penghasilan tidak stabil'], l: OPSI_LAIN, maks: 3},
  {t: 'skala', j: 'Bayangkan semua orang harus mulai dari tingkat terendah di sebuah sistem. Namun jika kamu membuktikan keahlianmu, kamu boleh langsung naik beberapa tingkat (tetap satu atau dua tingkat di bawah kemampuanmu). Seberapa adil menurutmu?', lab: ['Tidak adil', 'Sangat adil']},
  {t: 'para', j: 'Apa alasanmu memberi nilai itu?'}
];

var SEKSI_D = [
  {t: 'pilih', j: 'Kamu mewakili peran apa?', o: ['HRD atau bagian rekrutmen perusahaan', 'Pemilik atau pengelola usaha', 'Perangkat desa atau kelurahan, atau pemerintah daerah', 'Dinas atau lembaga pelatihan kerja', 'Komunitas atau organisasi sosial'], l: OPSI_LAIN},
  {t: 'para', j: 'Ceritakan pengalamanmu terkait pencari kerja atau pengangguran di lingkunganmu. Apa yang kamu lihat sehari-hari?'},
  {t: 'centang', j: 'Apa tiga kendala terbesar dalam mempertemukan pencari kerja dengan pekerjaan?', o: ['Informasi lowongan tidak sampai ke yang membutuhkan', 'Kualifikasi pencari kerja tidak sesuai', 'Upah yang ditawarkan tidak sesuai harapan', 'Kurangnya kepercayaan antara kedua pihak', 'Kurangnya pelatihan keterampilan', 'Keterbatasan anggaran atau sumber daya', 'Aturan atau perizinan'], l: OPSI_LAIN, maks: 3},
  {t: 'para', j: 'Aturan atau standar apa yang menurutmu harus dipenuhi layanan yang mempertemukan pekerja dan pemberi kerja?', b: 'Misalnya soal perlindungan data, hubungan kerja, atau pembayaran.'},
  {t: 'centang', j: 'Apa yang kamu perlukan sebelum bersedia mendukung atau bermitra dengan platform baru?', o: ['Legalitas yang jelas', 'Keamanan dan perlindungan data pribadi', 'Verifikasi identitas pengguna', 'Transparansi biaya', 'Mekanisme penanganan sengketa', 'Laporan dampak yang terukur', 'Tanpa biaya untuk lembaga kami'], l: OPSI_LAIN},
  {t: 'pilih', j: 'Seberapa sering kamu atau organisasimu membutuhkan tenaga untuk pekerjaan singkat?', o: ['Sering', 'Kadang-kadang', 'Jarang', 'Tidak pernah']},
  {t: 'para', j: 'Jika pernah, pekerjaan apa saja contohnya?'}
];

var DESKRIPSI_GAGASAN =
  'Guild Petualang adalah gagasan aplikasi ponsel yang mempertemukan orang yang butuh bantuan dengan orang yang mau mengerjakannya, dikemas seperti permainan peran (RPG).\n\n' +
  '• Siapa pun bisa memasang pekerjaan kecil yang disebut "quest", mulai dari membantu pindahan sampai membuat desain atau website.\n' +
  '• Pemberi quest membayar di muka. Uangnya ditahan platform dan baru diserahkan setelah pekerjaan selesai.\n' +
  '• Pekerja ("petualang") mulai dari tingkat F, lalu naik tingkat setelah menyelesaikan quest. Keahlian tertentu bisa dibuktikan lewat portofolio atau ujian.\n' +
  '• Jika ada perselisihan, staf manusia yang menengahi.\n\n' +
  'Ini baru gagasan. Kritik dan keraguanmu sangat membantu.';

var SEKSI_FINAL = [
  {t: 'skala', j: 'Seberapa menarik gagasan ini menurutmu?', lab: ['Tidak menarik', 'Sangat menarik'], w: true},
  {t: 'skala', j: 'Seberapa mungkin kamu mencobanya jika aplikasinya tersedia?', lab: ['Tidak mungkin', 'Sangat mungkin'], w: true},
  {t: 'para', j: 'Bagian mana yang paling kamu sukai, dan mengapa?'},
  {t: 'para', j: 'Bagian mana yang paling kamu ragukan atau khawatirkan, dan mengapa?'},
  {t: 'centang', j: 'Fitur mana yang paling penting bagimu?', o: ['Uang ditahan platform sampai pekerjaan selesai', 'Pembayaran bertahap sesuai tahapan pekerjaan', 'Verifikasi identitas pengguna', 'Penengah manusia saat terjadi sengketa', 'Tingkat (rank) dan keahlian yang terlihat di profil', 'Label perilaku baik dan buruk yang bisa dilihat semua orang', 'Pekerjaan jarak jauh (remote)', 'Pekerjaan kecil di sekitar tempat tinggal', 'Tampilan bergaya permainan dan karakter resepsionis'], maks: 3},
  {t: 'pilih', j: 'Bagaimana pendapatmu tentang tampilan bergaya permainan (tingkat, quest, karakter) untuk urusan pekerjaan?', o: ['Membuat saya lebih tertarik mencoba', 'Tidak berpengaruh bagi saya', 'Membuatnya terasa kurang serius', 'Saya khawatir mengganggu urusan penting seperti uang']},
  {t: 'pilih', j: 'Jika platform mengambil sebagian imbalan sebagai biaya layanan, berapa yang menurutmu masih wajar?', o: ['Tidak ada, harus gratis', 'Sampai 5%', '6–10%', '11–15%', '16–20%', 'Lebih dari 20%', 'Tergantung layanan yang saya dapat']},
  {t: 'para', j: 'Ada saran atau kritik lain untuk gagasan ini?'},
  {t: 'pilih', j: 'Bersediakah kamu dihubungi untuk wawancara singkat (sekitar 20 menit) atau mencoba prototipe?', o: ['Ya, bersedia wawancara', 'Ya, bersedia mencoba prototipe', 'Ya, keduanya', 'Tidak, terima kasih']},
  {t: 'teks', j: 'Jika bersedia, tulis cara menghubungimu (email atau WhatsApp).', b: 'Hanya dipakai untuk mengundang wawancara. Tidak dipublikasikan, boleh dikosongkan.'}
];

function tambahPertanyaan(form, daftar) {
  daftar.forEach(function (q) {
    var it;
    if (q.t === 'pilih') {
      it = form.addMultipleChoiceItem();
      it.setChoiceValues(q.o);
      if (q.l) it.showOtherOption(true);
    } else if (q.t === 'centang') {
      it = form.addCheckboxItem();
      it.setChoiceValues(q.o);
      if (q.l) it.showOtherOption(true);
      if (q.maks) {
        it.setValidation(FormApp.createCheckboxValidation()
          .requireSelectAtMost(q.maks)
          .setHelpText('Pilih maksimal ' + q.maks + '.')
          .build());
      }
    } else if (q.t === 'skala') {
      it = form.addScaleItem();
      it.setBounds(1, 5).setLabels(q.lab[0], q.lab[1]);
    } else if (q.t === 'teks') {
      it = form.addTextItem();
    } else {
      it = form.addParagraphTextItem();
    }
    it.setTitle(q.j);
    var bantuan = q.b || (q.maks ? 'Pilih maksimal ' + q.maks + '.' : '');
    if (bantuan) it.setHelpText(bantuan);
    it.setRequired(!!q.w);
  });
}

function buatFormGuildPetualang() {
  if (PENELITI.indexOf('[') > -1 || PROGRAM.indexOf('[') > -1 || KONTAK.indexOf('[') > -1) {
    throw new Error('Isi dulu PENELITI, PROGRAM, dan KONTAK di bagian atas skrip.');
  }

  var form = FormApp.create('Riset Pengalaman Mencari dan Menawarkan Pekerjaan');
  form.setDescription(
    'Halo! Saya ' + PENELITI + ' (' + PROGRAM + '). Saya sedang meneliti pengalaman orang dalam mencari pekerjaan dan mencari tenaga untuk pekerjaan kecil, sebagai bagian dari tugas kuliah.\n\n' +
    'Mengisi formulir ini sekitar 10 menit. Tidak ada jawaban benar atau salah. Jawaban jujur, termasuk kritik, justru paling membantu.\n\n' +
    'Privasi: formulir ini tidak meminta nama lengkap, nomor identitas, atau alamat. Jawaban hanya dipakai untuk tugas ini dan dilaporkan secara gabungan. ' +
    'Kontak yang kamu isi di akhir (jika ada) hanya dipakai untuk mengundang wawancara lanjutan.\n\n' +
    'Pertanyaan? Hubungi ' + KONTAK + '.');
  form.setCollectEmail(false);
  form.setLimitOneResponsePerUser(false);
  form.setAllowResponseEdits(false);
  form.setProgressBar(true);
  form.setShowLinkToRespondAgain(false);
  form.setConfirmationMessage('Terima kasih sudah meluangkan waktu. Jawabanmu sangat berarti.');

  form.addCheckboxItem()
    .setTitle('Persetujuan')
    .setChoiceValues(['Saya mengerti tujuan penelitian ini dan bersedia mengisi secara sukarela. Saya boleh berhenti kapan saja.'])
    .setRequired(true);

  var peran = form.addMultipleChoiceItem()
    .setTitle('Peran mana yang paling menggambarkan kamu saat ini?')
    .setHelpText('Jika lebih dari satu, pilih yang paling dominan. Pertanyaan berikutnya menyesuaikan pilihanmu.')
    .setRequired(true);

  var pbA = form.addPageBreakItem().setTitle('Bagian A · Pencari kerja').setHelpText('Ceritakan pengalamanmu sendiri apa adanya.');
  tambahPertanyaan(form, SEKSI_A);

  var pbB = form.addPageBreakItem().setTitle('Bagian B · Pemberi pekerjaan atau pemilik usaha').setHelpText('Ceritakan pengalamanmu mencari tenaga untuk pekerjaan.');
  tambahPertanyaan(form, SEKSI_B);

  var pbC = form.addPageBreakItem().setTitle('Bagian C · Pekerja lepas atau punya keterampilan khusus').setHelpText('Ceritakan pengalamanmu menawarkan keahlian.');
  tambahPertanyaan(form, SEKSI_C);

  var pbD = form.addPageBreakItem().setTitle('Bagian D · Pengelola atau pengambil keputusan').setHelpText('Ceritakan pandanganmu dari sisi organisasi atau lingkungan.');
  tambahPertanyaan(form, SEKSI_D);

  var pbF = form.addPageBreakItem().setTitle('Bagian terakhir · Gagasan Guild Petualang').setHelpText(DESKRIPSI_GAGASAN);
  tambahPertanyaan(form, SEKSI_FINAL);

  peran.setChoices([
    peran.createChoice('Saya sedang mencari pekerjaan atau penghasilan tambahan', pbA),
    peran.createChoice('Saya punya usaha atau sering butuh bantuan untuk pekerjaan (UMKM, toko, perorangan)', pbB),
    peran.createChoice('Saya pekerja lepas atau punya keterampilan khusus (desain, teknologi, terjemahan, dll.)', pbC),
    peran.createChoice('Saya mewakili organisasi atau pengambil keputusan (HRD, perangkat desa, dinas, komunitas)', pbD)
  ]);

  pbB.setGoToPage(pbF);
  pbC.setGoToPage(pbF);
  pbD.setGoToPage(pbF);

  var ss = SpreadsheetApp.create('Jawaban Riset Guild Petualang');
  form.setDestination(FormApp.DestinationType.SPREADSHEET, ss.getId());

  Logger.log('LINK ISIAN (bagikan ini): ' + form.getPublishedUrl());
  Logger.log('LINK EDIT: ' + form.getEditUrl());
  Logger.log('SPREADSHEET JAWABAN: ' + ss.getUrl());
}
