import 'package:flutter_test/flutter_test.dart';
import 'package:guild_petualang/data/post_rules.dart';

void main() {
  test('pekerjaan ringan: Rank F, tanpa stat, terbit otomatis', () {
    final s = suggestFor(title: 'Antar 5 paket ke kantor pos', desc: 'Paket sudah dibungkus, tinggal diantar.', reward: 80000);
    expect(s.rank, 'F');
    expect(s.stat, isNull);
    expect(s.path, ReviewPath.auto);
  });

  test('desain meminta stat Desain Grafis 40 tanpa menaikkan rank', () {
    final s = suggestFor(title: 'Desain poster promo', desc: 'Poster A3 untuk menu baru.', reward: 200000);
    expect(s.stat?.name, 'Desain Grafis');
    expect(s.stat?.min, 40);
    expect(s.rank, 'F');
  });

  test('website meminta Pemrograman 60, Rank C, dan penilai manusia', () {
    final s = suggestFor(title: 'Website katalog toko', desc: 'Satu halaman berisi 30 produk.', reward: 1500000);
    expect(s.stat?.name, 'Pemrograman');
    expect(s.rank, 'C');
    expect(s.path, ReviewPath.human);
  });

  test('menemani lansia memicu Rank E', () {
    final s = suggestFor(title: 'Temani ibu kontrol', desc: 'Menemani lansia ke puskesmas.', reward: 100000);
    expect(s.rank, 'E');
  });

  test('imbalan besar menaikkan rank minimum', () {
    expect(suggestFor(title: 'Pekerjaan umum', desc: 'Tanpa keahlian khusus.', reward: 300000).rank, 'E');
    expect(suggestFor(title: 'Pekerjaan umum', desc: 'Tanpa keahlian khusus.', reward: 500000).rank, 'D');
    expect(suggestFor(title: 'Pekerjaan umum', desc: 'Tanpa keahlian khusus.', reward: 1000000).rank, 'C');
  });

  test('kata terlarang ditahan untuk staff, walau rank rendah', () {
    final s = suggestFor(title: 'Tagih utang teman', desc: 'Datangi rumahnya.', reward: 50000);
    expect(s.rank, 'F');
    expect(s.path, ReviewPath.staff);
    expect(pathFor(s, 'F'), ReviewPath.staff);
  });

  test('menaikkan rank ke C membuat penilai manusia wajib', () {
    final s = suggestFor(title: 'Antar paket', desc: 'Paket kecil ke kantor.', reward: 50000);
    expect(pathFor(s, 'D'), ReviewPath.auto);
    expect(pathFor(s, 'C'), ReviewPath.human);
  });

  test('EXP ditetapkan guild menurut rank dan jumlah tahap', () {
    expect(expFor('F', 1), 50);
    expect(expFor('F', 3), 70);
    expect(expFor('C', 2), 610);
  });

  test('persentase tiap pilihan tahap berjumlah 100', () {
    for (final p in stagePresets) {
      expect(p.percents.fold(0, (a, b) => a + b), 100);
      expect(p.labels.length, p.percents.length);
    }
  });
}
