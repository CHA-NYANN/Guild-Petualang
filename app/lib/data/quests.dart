const rankOrder = ['F', 'E', 'D', 'C', 'B', 'A', 'S'];

const rankName = {
  'F': 'Petualang baru',
  'E': 'Petualang junior',
  'D': 'Petualang senior',
  'C': 'Petualang tingkat atas',
  'B': 'Petualang berpengalaman',
  'A': 'Petualang expert',
  'S': 'Petualang tertinggi',
};

const difficultyName = {
  'F': 'Ringan',
  'E': 'Cukup ringan',
  'D': 'Sedang',
  'C': 'Menantang',
  'B': 'Berat',
  'A': 'Sangat berat',
  'S': 'Legendaris',
};

const guildFee = 0.10; // sementara; hipotesis dari wawancara (5-10%)

class StatReq {
  final String name;
  final int min;
  const StatReq(this.name, this.min);
}

class Stage {
  final String label;
  final int percent;
  const Stage(this.label, this.percent);
}

class Badge {
  final bool good;
  final String text;
  final String? note;
  const Badge(this.good, this.text, [this.note]);
}

class Quest {
  final String id, title, giver, who, loc, dist, rank, left, within, desc;
  final bool remote;
  final StatReq? stat;
  final int reward, exp;
  final List<Stage> stages;
  final List<Badge> badges;

  /// Hasil yang diharapkan; kosong pada data contoh.
  final String criteria;

  /// Dipasang oleh pengguna aplikasi ini (bukan data contoh).
  final bool mine;

  /// Belum terbit di papan: menunggu pemeriksaan staff atau penilai guild.
  final bool inReview;
  final String reviewNote;

  /// Alasan pemberi quest meminta rank lebih tinggi dari saran.
  final String rankReason;

  const Quest({
    required this.id,
    required this.title,
    required this.giver,
    required this.who,
    required this.loc,
    required this.dist,
    required this.remote,
    required this.rank,
    required this.stat,
    required this.reward,
    required this.exp,
    required this.left,
    required this.within,
    required this.desc,
    required this.stages,
    required this.badges,
    this.criteria = '',
    this.mine = false,
    this.inReview = false,
    this.reviewNote = '',
    this.rankReason = '',
  });

  int get net => (reward * (1 - guildFee)).round();
  int get fee => reward - net;

  String get place => remote ? 'Jarak jauh' : (dist.isEmpty ? loc : '$loc · $dist');
}

/// Hasil pemeriksaan syarat untuk pengguna Rank F tanpa stat khusus.
class Eligibility {
  final bool ok;
  final List<String> reasons;
  const Eligibility(this.ok, this.reasons);
}

Eligibility checkQuest(Quest q) {
  final why = <String>[];
  if (rankOrder.indexOf(q.rank) > 0) {
    why.add('Rank ${q.rank}${q.rank == 'E' ? ' (butuh verifikasi identitas)' : ''}');
  }
  if (q.stat != null) why.add('${q.stat!.name} minimal ${q.stat!.min}');
  return Eligibility(why.isEmpty, why);
}

const quests = <Quest>[
  Quest(
    id: 'q1',
    title: 'Cari dompet yang hilang di Taman Lansia',
    giver: 'Warga', who: 'Bu Ratna', loc: 'Bandung', dist: '2,1 km', remote: false,
    rank: 'F', stat: null, reward: 75000, exp: 40, left: '1 hari', within: '24 jam setelah diambil',
    desc: 'Dompet cokelat hilang kemarin sore di sekitar bangku dekat danau kecil. Isinya KTP dan beberapa kartu. Kabari lewat chat guild begitu ketemu, lalu serahkan langsung ke pemiliknya.',
    stages: [Stage('Dompet ditemukan & difoto', 50), Stage('Diserahkan ke pemilik & dikonfirmasi', 50)],
    badges: [Badge(true, 'Pembayar Tepat Waktu')],
  ),
  Quest(
    id: 'q2',
    title: 'Bantu pindahan kos ke lantai 3',
    giver: 'Warga', who: 'Pak Hendra', loc: 'Bandung', dist: '3,4 km', remote: false,
    rank: 'F', stat: null, reward: 150000, exp: 60, left: '2 hari', within: '4 jam setelah mulai',
    desc: 'Pindahan dari kamar lantai 1 ke lantai 3, tanpa lift. Ada kasur lipat, dua lemari plastik, dan sekitar 12 kardus. Dibutuhkan satu orang yang kuat dan teliti dengan barang pecah belah.',
    stages: [Stage('Barang dipindahkan & dicek bersama', 100)],
    badges: [Badge(false, 'Moving Goalpost', 'aktif 12 hari lagi')],
  ),
  Quest(
    id: 'q3',
    title: 'Input 200 data stok barang ke spreadsheet',
    giver: 'UMKM', who: 'Toko Kain Sari', loc: 'Remote', dist: '', remote: true,
    rank: 'F', stat: null, reward: 120000, exp: 50, left: '3 hari', within: '48 jam setelah diambil',
    desc: 'Catatan stok masih di buku tulis. Foto halamannya akan dikirim lewat chat guild. Ketik ke templat spreadsheet yang disediakan: nama barang, ukuran, warna, jumlah.',
    stages: [Stage('100 data pertama diinput', 50), Stage('Seluruh data selesai & dicek', 50)],
    badges: [Badge(true, 'Pembayar Tepat Waktu'), Badge(true, 'Jelas Memberi Arahan')],
  ),
  Quest(
    id: 'q4',
    title: 'Antar 12 kotak nasi ke Balai Kelurahan',
    giver: 'Pemerintah', who: 'Kelurahan Cipaganti', loc: 'Bandung', dist: '1,2 km', remote: false,
    rank: 'F', stat: null, reward: 180000, exp: 70, left: '5 jam', within: '2 jam setelah diambil',
    desc: 'Kotak nasi untuk rapat warga diambil di warung mitra, lalu diantar ke Balai Kelurahan sebelum pukul 11.30. Harus membawa kendaraan sendiri.',
    stages: [Stage('Kotak nasi diterima di balai & dihitung', 100)],
    badges: [Badge(true, 'Pembayar Tepat Waktu')],
  ),
  Quest(
    id: 'q5',
    title: 'Desain poster promo kopi susu',
    giver: 'UMKM', who: 'Kopi Senja', loc: 'Bandung', dist: '0,8 km', remote: false,
    rank: 'F', stat: StatReq('Desain Grafis', 40), reward: 200000, exp: 90, left: '2 hari', within: '3 hari setelah diambil',
    desc: 'Poster A3 untuk promo menu baru. Logo dan foto produk disediakan. Warna mengikuti identitas kedai: cokelat tua dan krem. Hasil akhir dalam format siap cetak dan versi untuk Instagram.',
    stages: [Stage('Konsep & tata letak disetujui', 30), Stage('Draf lengkap', 40), Stage('File akhir siap cetak', 30)],
    badges: [Badge(true, 'Pembayar Tepat Waktu')],
  ),
  Quest(
    id: 'q6',
    title: 'Temani lansia kontrol rutin ke puskesmas',
    giver: 'Warga', who: 'Keluarga Pak Dedi', loc: 'Bandung', dist: '4,0 km', remote: false,
    rank: 'E', stat: null, reward: 100000, exp: 120, left: '3 hari', within: 'Hari kontrol, sekitar 4 jam',
    desc: 'Ibu berusia 72 tahun perlu didampingi dari rumah ke puskesmas dan kembali lagi. Jalannya pelan, bisa memakai tongkat. Perlu sabar dan komunikatif.',
    stages: [Stage('Pulang dengan selamat & dikonfirmasi keluarga', 100)],
    badges: [Badge(true, 'Pembayar Tepat Waktu')],
  ),
  Quest(
    id: 'q7',
    title: 'Website katalog sederhana untuk toko batik',
    giver: 'UMKM', who: 'Batik Parahyangan', loc: 'Remote', dist: '', remote: true,
    rank: 'C', stat: StatReq('Pemrograman', 60), reward: 1500000, exp: 600, left: '6 hari', within: '14 hari setelah diambil',
    desc: 'Situs satu halaman berisi katalog 30 produk, tombol pesan ke WhatsApp, dan peta lokasi toko. Konten dan foto produk disediakan pemilik. Hosting dan domain sudah ada.',
    stages: [Stage('Desain halaman disetujui', 25), Stage('Katalog & konten terpasang', 45), Stage('Peluncuran & serah terima', 30)],
    badges: [Badge(true, 'Jelas Memberi Arahan')],
  ),
  Quest(
    id: 'q8',
    title: 'Terjemahkan brosur wisata ID ke Inggris',
    giver: 'Pemerintah', who: 'Dinas Pariwisata Kota', loc: 'Remote', dist: '', remote: true,
    rank: 'D', stat: StatReq('Penerjemahan', 50), reward: 350000, exp: 250, left: '4 hari', within: '5 hari setelah diambil',
    desc: 'Brosur 6 halaman tentang wisata sejarah kota. Terjemahan harus natural, bukan kata per kata, dan nama tempat mengikuti ejaan resmi.',
    stages: [Stage('Separuh pertama diterjemahkan', 50), Stage('Selesai & ditinjau', 50)],
    badges: [Badge(true, 'Pembayar Tepat Waktu')],
  ),
];
