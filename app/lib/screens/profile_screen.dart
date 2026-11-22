import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/quests.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sound_controls.dart';

/// Profil dasar. Editor avatar dan Kartu Petualang menyusul.
class ProfileScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onRegister;
  const ProfileScreen({super.key, required this.state, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return ListView(
          padding: EdgeInsets.fromLTRB(18, mq.padding.top + 26, 18, 112 + mq.padding.bottom),
          children: [
            Text('PROFIL', style: display(24, spacing: 0.8)),
            const SizedBox(height: 18),
            if (!state.registered) ...[
              CutCard(
                fill: const Color(0xFF132532),
                edge: C.lantern.withValues(alpha: 0.55),
                cut: 16,
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1B3040), border: Border.all(color: C.line)),
                    child: Center(child: Text('?', style: display(22, color: C.lanternHi))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Warga Biasa', style: body(20, weight: FontWeight.w700)),
                      Text('Belum terdaftar sebagai petualang', style: body(13, color: C.mist2)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
                child: Text('Daftar sebagai petualang untuk mulai mengumpulkan EXP, mengubah avatar, dan mengambil quest. Kamu boleh memakai nama samaran di Rank F.', style: body(13, color: C.mist2, height: 1.55)),
              ),
              const SizedBox(height: 16),
              GoldButton('Daftar sebagai Petualang', onTap: onRegister),
            ] else ...[
              CutCard(
                fill: const Color(0xFF132532),
                edge: C.lantern.withValues(alpha: 0.55),
                cut: 16,
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  Row(children: [
                    const RankSeal('F', width: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(state.name, style: body(20, weight: FontWeight.w700)),
                        Text('Rank F · ${rankName['F']}', style: body(13, color: C.mist2)),
                        Text('Anonim (nama samaran)', style: body(12, color: C.mist3)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text.rich(TextSpan(children: [TextSpan(text: '0 ', style: body(12, color: C.lanternHi, weight: FontWeight.w800)), TextSpan(text: 'EXP', style: body(12, color: C.mist2))])),
                    Text('1.000 untuk Rank E', style: body(12, color: C.mist2)),
                  ]),
                  const SizedBox(height: 7),
                  Container(
                    height: 9,
                    decoration: BoxDecoration(color: const Color(0xFF0A141D), borderRadius: BorderRadius.circular(99), border: Border.all(color: C.lineSoft)),
                  ),
                ]),
              ),
              const SectionTitle('Stat umum'),
              for (final n in const ['Ketelitian', 'Komunikasi', 'Pemecahan masalah', 'Kedisiplinan'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Row(children: [
                    SizedBox(width: 130, child: Text(n, style: body(13, color: C.mist2))),
                    Expanded(child: Container(height: 9, decoration: BoxDecoration(color: const Color(0xFF0A141D), borderRadius: BorderRadius.circular(99), border: Border.all(color: C.lineSoft)))),
                    SizedBox(width: 34, child: Text('—', textAlign: TextAlign.right, style: body(13, color: C.mist3, weight: FontWeight.w700))),
                  ]),
                ),
              Text('Stat umum terisi setelah quest pertama selesai.', style: body(12, color: C.mist3)),
              const SectionTitle('Stat khusus'),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
                child: Text('Belum ada. Ajukan portofolio atau sertifikat, atau ikut ujian guild untuk membuka stat seperti Pemrograman atau Desain Grafis.', style: body(13, color: C.mist2, height: 1.55)),
              ),
              const SectionTitle('Achievement'),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
                child: Text('Belum ada. Selesaikan quest pertamamu.', style: body(13, color: C.mist2)),
              ),
              const SizedBox(height: 22),
              Text('Editor avatar dan Kartu Petualang menyusul.', textAlign: TextAlign.center, style: body(12, color: C.mist3)),
            ],
            const SectionTitle('Pengaturan'),
            const SoundSetting(),
          ],
        );
      },
    );
  }
}
