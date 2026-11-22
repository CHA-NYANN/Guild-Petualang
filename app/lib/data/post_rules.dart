import 'quests.dart';

/// Aturan untuk pemberi quest. Semuanya penanda sementara: versi sebenarnya
/// dinilai AI lalu ditinjau staff guild (KONSEP.md, bagian 4.4).

/// Siapa yang memeriksa quest sebelum terbit.
enum ReviewPath {
  /// Rutin dan berisiko rendah: lolos cek otomatis, langsung terbit.
  auto,

  /// Rank atas: penilai manusia menyetujui dulu.
  human,

  /// Mencurigakan: ditahan untuk diperiksa staff guild.
  staff,
}

const postWindows = ['6 jam', '1 hari', '3 hari', '7 hari'];
const doneWindows = ['4 jam', '24 jam', '3 hari', '7 hari', '14 hari'];
const rewardShortcuts = [50000, 100000, 250000, 500000, 1000000];

class StagePreset {
  final String name;
  final List<int> percents;
  final List<String> labels;
  const StagePreset(this.name, this.percents, this.labels);
}

const stagePresets = [
  StagePreset('1 tahap', [100], ['Pekerjaan selesai & dikonfirmasi']),
  StagePreset('2 tahap', [50, 50], ['Separuh pekerjaan selesai', 'Seluruhnya selesai & dicek']),
  StagePreset('3 tahap', [30, 40, 30], ['Konsep disetujui', 'Draf lengkap', 'Hasil akhir diserahkan']),
];

class Suggestion {
  final String rank;
  final StatReq? stat;
  final ReviewPath path;

  /// Alasan yang ditampilkan kepada pemberi quest.
  final List<String> why;
  const Suggestion(this.rank, this.stat, this.path, this.why);
}

class _StatRule {
  final String name;
  final int min;
  final List<String> words;
  const _StatRule(this.name, this.min, this.words);
}

const _statRules = [
  _StatRule('Desain Grafis', 40, ['desain', 'poster', 'logo', 'banner', 'ilustrasi']),
  _StatRule('Pemrograman', 60, ['website', 'situs web', 'aplikasi', 'pemrograman', 'coding']),
  _StatRule('Penerjemahan', 50, ['terjemah', 'translate']),
  _StatRule('Akuntansi', 50, ['pembukuan', 'akuntansi', 'laporan keuangan', 'pajak']),
];

final _riskWords = RegExp(r'\b(lansia|anak|bayi|balita|pasien|sakit|menemani|menjaga|antar jemput)\b');

const _flagged = [
  'judi', 'togel', 'pinjol', 'pinjaman online', 'tagih utang', 'tagih hutang', 'debt collector',
  'narkoba', 'miras', 'joki', 'ijazah palsu', 'pinjam rekening', 'transfer dulu', 'investasi cepat',
];

int _idx(String rank) => rankOrder.indexOf(rank);

/// Saran rank, stat, dan jalur pemeriksaan dari judul, uraian, dan imbalan.
Suggestion suggestFor({required String title, required String desc, required int reward}) {
  final text = '$title $desc'.toLowerCase();
  final why = <String>[];
  var rank = 0;

  _StatRule? stat;
  for (final r in _statRules) {
    if (r.words.any(text.contains) && (stat == null || r.min > stat.min)) stat = r;
  }
  if (stat != null) {
    why.add('Pekerjaan ini butuh keahlian khusus, jadi ${stat.name} minimal ${stat.min} diminta.');
    if (stat.min >= 60) {
      rank = _max(rank, _idx('C'));
    } else if (stat.min >= 50) {
      rank = _max(rank, _idx('D'));
    }
  }

  if (_riskWords.hasMatch(text)) {
    rank = _max(rank, _idx('E'));
    why.add('Menyangkut orang lain secara langsung, jadi petualang harus sudah terverifikasi (Rank E).');
  }

  if (reward >= 1000000) {
    rank = _max(rank, _idx('C'));
    why.add('Imbalan besar, jadi hanya petualang berpengalaman yang boleh mengambil.');
  } else if (reward >= 500000) {
    rank = _max(rank, _idx('D'));
    why.add('Imbalan cukup besar, jadi rank minimumnya dinaikkan.');
  } else if (reward >= 300000) {
    rank = _max(rank, _idx('E'));
    why.add('Imbalan Rp300.000 ke atas mensyaratkan petualang terverifikasi.');
  }

  if (why.isEmpty) why.add('Pekerjaan ringan tanpa keahlian khusus, terbuka untuk semua petualang baru.');

  final flagged = _flagged.any(text.contains);
  final path = flagged
      ? ReviewPath.staff
      : rank >= _idx('C')
          ? ReviewPath.human
          : ReviewPath.auto;
  return Suggestion(rankOrder[rank], stat == null ? null : StatReq(stat.name, stat.min), path, why);
}

int _max(int a, int b) => a > b ? a : b;

/// Jalur pemeriksaan setelah pemberi quest menaikkan rank dari saran.
ReviewPath pathFor(Suggestion s, String rank) {
  if (s.path == ReviewPath.staff) return ReviewPath.staff;
  return _idx(rank) >= _idx('C') ? ReviewPath.human : s.path;
}

String reviewNoteFor(ReviewPath p) => switch (p) {
      ReviewPath.auto => '',
      ReviewPath.human => 'Quest rank atas disetujui penilai guild sebelum terbit.',
      ReviewPath.staff => 'Staff guild memeriksa isi quest karena ada hal yang perlu ditinjau.',
    };

const _expBase = {'F': 50, 'E': 120, 'D': 250, 'C': 600, 'B': 1200, 'A': 2500, 'S': 5000};

/// EXP ditetapkan guild, bukan pemberi quest.
int expFor(String rank, int stageCount) => _expBase[rank]! + (stageCount - 1) * 10;
