import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guild_petualang/app.dart';
import 'package:guild_petualang/audio.dart';
import 'package:guild_petualang/widgets/sound_controls.dart';
import 'package:guild_petualang/theme.dart';
import 'package:guild_petualang/widgets/common.dart';

Future<void> settle(WidgetTester t) async {
  await t.pump(const Duration(seconds: 4));
  await t.pump(const Duration(milliseconds: 400));
  // Rute yang baru ditutup baru dilepas satu frame setelah animasinya selesai.
  await t.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() => Fonts.useWebFonts = false);

  testWidgets('Terra menyapa pengguna baru lalu menawarkan pilihan', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 900));
    await t.pumpWidget(const GuildApp(showIntro: false));
    await t.pump(const Duration(milliseconds: 900));
    expect(find.text('Selamat datang di Guild Petualang.'), findsOneWidget);
    await t.tap(find.text('Lewati ›'));
    await t.pump();
    expect(find.text('Ya, daftarkan aku'), findsOneWidget);
    expect(find.text('Lihat papan quest dulu'), findsOneWidget);
  });

  testWidgets('Papan quest menampilkan quest terkunci beserta alasannya', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 900));
    await t.pumpWidget(const GuildApp(showIntro: false));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Papan'));
    await settle(t);
    expect(find.text('PAPAN PERMINTAAN'), findsOneWidget);
    expect(find.text('Cari dompet yang hilang di Taman Lansia'), findsOneWidget);
    await t.tap(find.text('UMKM'));
    await t.pump();
    expect(find.text('Desain poster promo kopi susu'), findsOneWidget);
    expect(find.text('Desain Grafis minimal 40'), findsOneWidget);
  });

  testWidgets('Alur utama: ambil quest pertama sampai diterima', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 900));
    await t.pumpWidget(const GuildApp(showIntro: false));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Papan'));
    await settle(t);
    await t.tap(find.text('Cari dompet yang hilang di Taman Lansia'));
    await settle(t);
    expect(find.text('Dana sudah aman. '), findsNothing); // teks digabung dalam RichText
    await t.tap(find.text('Ambil quest'));
    await settle(t);
    expect(find.text('DAFTAR SEBAGAI PETUALANG'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Elang Biru');
    await t.pump();
    await t.tap(find.text('Resmi jadi Petualang'));
    await settle(t);
    expect(find.text('CEK SEBELUM MENGAMBIL'), findsOneWidget);
    await t.tap(find.text('Terima & ambil quest'));
    await settle(t);
    expect(find.text('QUEST DITERIMA'), findsOneWidget);
    await t.tap(find.text('Kembali ke papan'));
    await settle(t);
    expect(find.textContaining('1 quest sedang berjalan'), findsOneWidget);
  });

  testWidgets('Pemberi quest: pasang quest sampai muncul di papan', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 1000));
    await t.pumpWidget(const GuildApp(showIntro: false));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Papan'));
    await settle(t);
    await t.tap(find.text('Pasang quest'));
    await settle(t);
    expect(find.text('PEKERJAAN'), findsOneWidget);

    // Langkah 1 belum lengkap: tombol Lanjut mati dan alasannya tampil.
    expect(find.text('Judul minimal 8 huruf.'), findsOneWidget);

    final fields = find.byType(TextField);
    await t.enterText(fields.at(0), 'Antar 5 paket ke kantor pos');
    await t.enterText(fields.at(1), 'Paket sudah dibungkus dan dialamatkan, tinggal diantar.');
    await t.enterText(fields.at(2), 'Resi kelima paket difoto dan dikirim lewat chat guild.');
    await t.enterText(fields.at(3), 'Dago, Bandung');
    await t.enterText(fields.at(4), 'Bu Ratna');
    await t.pump();
    await t.tap(find.text('Lanjut'));
    await settle(t);

    // Langkah 2: imbalan
    expect(find.text('IMBALAN & WAKTU'), findsOneWidget);
    expect(find.text('Isi imbalan.'), findsOneWidget);
    await t.tap(find.text('Rp100.000'));
    await t.pump();
    expect(find.text('Rp90.000'), findsOneWidget); // petualang terima setelah biaya 10%
    await t.tap(find.text('Lanjut'));
    await settle(t);

    // Langkah 3: tahapan
    expect(find.text('TAHAPAN'), findsOneWidget);
    await t.tap(find.text('1 tahap'));
    await t.pump();
    await t.tap(find.text('Lanjut'));
    await settle(t);

    // Langkah 4: tinjau
    expect(find.text('TINJAU & BAYAR'), findsOneWidget);
    expect(find.text('Rank minimum F · Ringan'), findsOneWidget);
    expect(find.textContaining('Lolos pemeriksaan otomatis'), findsOneWidget);
    expect(find.text('Centang persetujuan di atas.'), findsOneWidget);
    await t.ensureVisible(find.textContaining('Aku sudah memeriksa isi quest'));
    await t.pump();
    await t.tap(find.textContaining('Aku sudah memeriksa isi quest'));
    await t.pump();
    await t.tap(find.text('Bayar & pasang quest'));
    await settle(t);
    expect(find.text('BAYAR KE GUILD'), findsOneWidget);
    await t.tap(find.text('Bayar Rp100.000 (simulasi)'));
    await settle(t);

    expect(find.text('QUEST TERPASANG'), findsOneWidget);
    await t.tap(find.text('Lihat di papan'));
    await settle(t);
    expect(find.text('Antar 5 paket ke kantor pos'), findsOneWidget);
    expect(find.text('Permintaanmu'), findsOneWidget);
    expect(find.text('Permintaanku · 1'), findsOneWidget);

    // Quest milik sendiri tidak bisa diambil.
    await t.tap(find.text('Antar 5 paket ke kantor pos'));
    await settle(t);
    expect(find.text('Permintaanmu sendiri'), findsOneWidget);
    expect(find.text('Dianggap selesai jika'.toUpperCase()), findsOneWidget);
  });

  testWidgets('Terra menawarkan memasang permintaan dan langsung membuka alurnya', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 900));
    await t.pumpWidget(const GuildApp(showIntro: false));
    await t.pump(const Duration(milliseconds: 900));
    await t.tap(find.text('Lewati ›'));
    await t.pump();
    await t.tap(find.text('Aku mau memasang permintaan'));
    await settle(t);
    expect(find.text('PEKERJAAN'), findsOneWidget);
  });

  testWidgets('Suara: musik mulai, tombol bisu bekerja, efek lonceng saat quest dipasang', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 1000));
    final audio = SilentAudio();
    await t.pumpWidget(GuildApp(showIntro: false, audio: audio));
    await t.pump(const Duration(milliseconds: 600));
    expect(audio.musicWanted, isTrue);

    // Tombol suara di beranda mematikan lalu menyalakan lagi.
    await t.tap(find.byType(SoundButton));
    await t.pump();
    expect(audio.muted, isTrue);
    await t.tap(find.byType(SoundButton));
    await t.pump();
    expect(audio.muted, isFalse);

    // Ketukan pada dok berbunyi, dan di profil ada pengaturannya.
    await t.tap(find.text('Profil'));
    await settle(t);
    expect(audio.played, contains(Sfx.tap));
    await t.tap(find.text('Suara latar'));
    await t.pump();
    expect(audio.muted, isTrue);
    await t.tap(find.text('Suara latar'));
    await t.pump();
    expect(audio.muted, isFalse);

    // Quest dipasang: lonceng berbunyi.
    await t.tap(find.text('Papan'));
    await settle(t);
    await t.tap(find.text('Pasang quest'));
    await settle(t);
    final fields = find.byType(TextField);
    await t.enterText(fields.at(0), 'Antar 5 paket ke kantor pos');
    await t.enterText(fields.at(1), 'Paket sudah dibungkus dan dialamatkan, tinggal diantar.');
    await t.enterText(fields.at(2), 'Resi kelima paket difoto dan dikirim lewat chat guild.');
    await t.enterText(fields.at(3), 'Dago, Bandung');
    await t.enterText(fields.at(4), 'Bu Ratna');
    await t.pump();
    await t.tap(find.text('Lanjut'));
    await settle(t);
    await t.tap(find.text('Rp100.000'));
    await t.pump();
    await t.tap(find.text('Lanjut'));
    await settle(t);
    await t.tap(find.text('Lanjut'));
    await settle(t);
    await t.ensureVisible(find.textContaining('Aku sudah memeriksa isi quest'));
    await t.pump();
    await t.tap(find.textContaining('Aku sudah memeriksa isi quest'));
    await t.pump();
    audio.played.clear();
    await t.tap(find.text('Bayar & pasang quest'));
    await settle(t);
    await t.tap(find.text('Bayar Rp100.000 (simulasi)'));
    await settle(t);
    expect(find.text('QUEST TERPASANG'), findsOneWidget);
    expect(audio.played, contains(Sfx.bell));
  });

  testWidgets('Suara dimatikan: efek tidak dicatat', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 900));
    final audio = SilentAudio();
    await audio.setMuted(true);
    await t.pumpWidget(GuildApp(showIntro: false, audio: audio));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Papan'));
    await settle(t);
    expect(audio.played, isEmpty);
  });

  testWidgets('Pemberi quest: quest berisiko ditahan untuk diperiksa dan belum tampil di papan', (t) async {
    await t.binding.setSurfaceSize(const Size(430, 1000));
    await t.pumpWidget(const GuildApp(showIntro: false));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Papan'));
    await settle(t);
    await t.tap(find.text('Pasang quest'));
    await settle(t);
    final fields = find.byType(TextField);
    await t.enterText(fields.at(0), 'Tagih utang ke teman lama');
    await t.enterText(fields.at(1), 'Datangi rumahnya dan minta dia segera membayar.');
    await t.enterText(fields.at(2), 'Uangnya diterima lunas oleh saya.');
    await t.enterText(fields.at(3), 'Dago, Bandung');
    await t.enterText(fields.at(4), 'Pak Budi');
    await t.pump();
    await t.tap(find.text('Lanjut'));
    await settle(t);
    await t.tap(find.text('Rp50.000'));
    await t.pump();
    await t.tap(find.text('Lanjut'));
    await settle(t);
    await t.tap(find.text('Lanjut'));
    await settle(t);
    expect(find.textContaining('Staff guild memeriksanya dulu'), findsOneWidget);
    await t.ensureVisible(find.textContaining('Aku sudah memeriksa isi quest'));
    await t.pump();
    await t.tap(find.textContaining('Aku sudah memeriksa isi quest'));
    await t.pump();
    await t.tap(find.text('Bayar & pasang quest'));
    await settle(t);
    await t.tap(find.text('Bayar Rp50.000 (simulasi)'));
    await settle(t);
    expect(find.text('QUEST DIPERIKSA'), findsOneWidget);
    await t.tap(find.text('Lihat permintaanku'));
    await settle(t);
    expect(find.text('Menunggu pemeriksaan'), findsOneWidget);
    expect(find.text('Rp50.000'), findsWidgets);
    await t.tap(find.descendant(of: find.byType(GuildTopBar), matching: find.byType(GestureDetector)));
    await settle(t);
    expect(find.text('Tagih utang ke teman lama'), findsNothing);
  });
}
