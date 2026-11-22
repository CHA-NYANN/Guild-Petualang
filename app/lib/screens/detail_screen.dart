import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_state.dart';
import '../audio.dart';
import '../data/quests.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'board_screen.dart' show giverDot;
import 'sheets.dart';

void openQuest(BuildContext context, AppState state, String id) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(state: state, quest: state.questById(id))));
}

class DetailScreen extends StatelessWidget {
  final AppState state;
  final Quest quest;
  const DetailScreen({super.key, required this.state, required this.quest});

  Future<void> _take(BuildContext context) async {
    if (!state.registered) {
      final ok = await showRegisterSheet(context, state);
      if (!ok || !context.mounted) return;
    }
    final agree = await showConfirmSheet(context, quest);
    if (!agree || !context.mounted) return;
    state.take(quest.id);
    Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => AcceptedScreen(state: state, quest: quest)));
  }

  @override
  Widget build(BuildContext context) {
    final q = quest;
    final el = checkQuest(q);
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final taken = state.taken.contains(q.id);
        return Scaffold(
          backgroundColor: C.ink900,
          body: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                child: Row(children: [
                  Semantics(
                    button: true,
                    label: 'Kembali',
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: const Color(0xFF15293A), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
                        child: const Center(child: AppIcon('back', color: C.mist, size: 20)),
                      ),
                    ),
                  ),
                  Expanded(child: Center(child: Text('DETAIL QUEST', style: body(11, color: C.mist3, weight: FontWeight.w800, spacing: 1.5)))),
                  const SizedBox(width: 40),
                ]),
              ),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 20), children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    RankSeal(q.rank, width: 54),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(q.title, style: body(20, weight: FontWeight.w700, height: 1.25)),
                        const SizedBox(height: 6),
                        Text('Kesulitan ${difficultyName[q.rank]} · Rank minimum ${q.rank}', style: body(12, color: C.mist2)),
                      ]),
                    ),
                  ]),
                  if (q.inReview) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF2A2412), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.lanternLo)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const AppIcon('clock', color: C.lanternHi, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(TextSpan(style: body(12.5, color: C.lanternHi, height: 1.45), children: [
                            TextSpan(text: 'Menunggu pemeriksaan. ', style: body(12.5, color: C.lanternHi, weight: FontWeight.w800)),
                            TextSpan(text: '${q.reviewNote} Quest belum tampil di papan.'),
                          ])),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  CutCard(
                    fill: const Color(0xFF1B1A14),
                    edge: C.lantern.withValues(alpha: 0.55),
                    cut: 14,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Imbalan dari pemberi quest', style: body(12, color: C.mist2)),
                      const SizedBox(height: 6),
                      Text(rp(q.reward), style: body(30, color: C.lanternHi, weight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Container(height: 1, color: const Color(0xFF4A4026)),
                      const SizedBox(height: 12),
                      _kv('Biaya guild (${(guildFee * 100).round()}%)', '−${rp(q.fee)}'),
                      _kv(q.mine ? 'Petualang terima' : 'Kamu terima', rp(q.net), strong: true),
                      _kv('Hadiah EXP', '+${q.exp} EXP', color: C.jade),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF0F2A2B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1F5A52))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const AppIcon('shield', color: C.jade, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(TextSpan(style: body(12.5, color: const Color(0xFFB9E6DC), height: 1.45), children: [
                          TextSpan(text: 'Dana sudah aman. ', style: body(12.5, color: const Color(0xFFB9E6DC), weight: FontWeight.w800)),
                          TextSpan(
                            text: q.mine
                                ? 'Kamu sudah membayar ${rp(q.reward)} dan guild menahannya sampai pekerjaan dikonfirmasi selesai. Jika tidak ada yang mengambil sampai batas waktu, dana kembali 100%.'
                                : 'Pemberi quest membayar di muka dan guild menahan uangnya sampai pekerjaan dikonfirmasi selesai.',
                          ),
                        ])),
                      ),
                    ]),
                  ),
                  const SectionTitle('Pekerjaan'),
                  Text(q.desc, style: body(14, color: C.mist2, height: 1.65, weight: FontWeight.w400)),
                  if (q.criteria.isNotEmpty) ...[
                    const SectionTitle('Dianggap selesai jika'),
                    Text(q.criteria, style: body(14, color: C.mist2, height: 1.65, weight: FontWeight.w400)),
                  ],
                  const SectionTitle('Waktu'),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _fact('Quest ditutup', '${q.left} lagi')),
                    const SizedBox(width: 10),
                    Expanded(child: _fact('Lokasi', q.place)),
                  ]),
                  const SizedBox(height: 10),
                  _fact('Batas selesai', q.within),
                  const SectionTitle('Syarat'),
                  if (q.mine) ...[
                    _req(true, 'Rank ${q.rank} atau lebih tinggi', 'Syarat quest',
                        sub: q.rankReason.isNotEmpty ? 'Alasanmu: ${q.rankReason}' : (q.rank != 'F' ? 'Mulai Rank E, identitas wajib diverifikasi' : null)),
                    const SizedBox(height: 8),
                    if (q.stat != null)
                      _req(true, '${q.stat!.name} minimal ${q.stat!.min}', 'Syarat quest', sub: 'Stat khusus, tidak bisa digantikan rank')
                    else
                      _req(true, 'Tanpa stat khusus', 'Syarat quest', sub: 'Siapa pun yang rank-nya cukup boleh mengambil'),
                  ] else ...[
                    _req(rankOrder.indexOf(q.rank) == 0, 'Rank ${q.rank} atau lebih tinggi', rankOrder.indexOf(q.rank) == 0 ? 'Terpenuhi' : 'Kamu Rank F', sub: q.rank == 'E' ? 'Mulai Rank E, identitas wajib diverifikasi' : null),
                    const SizedBox(height: 8),
                    if (q.stat != null)
                      _req(false, '${q.stat!.name} minimal ${q.stat!.min}', 'Belum punya', sub: 'Stat khusus, tidak bisa digantikan rank')
                    else
                      _req(true, 'Tanpa stat khusus', 'Terpenuhi', sub: 'Siapa pun yang rank-nya cukup boleh mengambil'),
                  ],
                  const SectionTitle('Tahapan & pembayaran'),
                  for (var i = 0; i < q.stages.length; i++) _stage(i, q.stages[i], q),
                  const SectionTitle('Jika ada masalah'),
                  _rule('clock', 'Tenggat lewat, tapi sebagian besar selesai: ', 'dibayar sesuai tahap yang selesai, dengan EXP lebih kecil.'),
                  _rule('warn', 'Batal tanpa alasan valid: ', 'dikenai sanksi sesuai tingkat pelanggaran.'),
                  _rule('shield', 'Hasil ditolak: ', 'pemberi quest wajib menulis alasan. Guild menilai secara netral.'),
                  const SectionTitle('Pemberi quest'),
                  Row(children: [
                    ClipPath(
                      clipper: _HexClipper(),
                      child: Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF24465C), Color(0xFF16303F)])),
                        child: Text(q.who.substring(0, 1), style: display(18, color: C.lanternHi)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(q.who, style: body(15, weight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Row(children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: giverDot(q.giver))),
                          const SizedBox(width: 6),
                          Text(q.giver + (q.giver == 'Pemerintah' ? ' · tarif instansi' : ''), style: body(12.5, color: C.mist2)),
                        ]),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  if (q.badges.isEmpty) Text('Belum ada label perilaku.', style: body(12.5, color: C.mist3)),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final b in q.badges)
                      Pill(
                        b.note == null ? b.text : '${b.text} · ${b.note}',
                        color: b.good ? const Color(0xFF8FE3CD) : const Color(0xFFF4A597),
                        border: b.good ? const Color(0xFF2B7567) : const Color(0xFF7A3D34),
                        fill: b.good ? const Color(0xFF0E2A28) : const Color(0xFF2A1513),
                        icon: b.good ? Icons.star_border : Icons.warning_amber,
                      ),
                  ]),
                ]),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(color: C.ink900, border: Border(top: BorderSide(color: C.lineSoft))),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    q.mine
                        ? (q.inReview ? 'Quest akan terbit di papan setelah pemeriksaan selesai.' : 'Ini permintaanmu. Petualang lain yang bisa mengambilnya.')
                        : taken
                        ? 'Quest ini sedang kamu kerjakan.'
                        : !el.ok
                            ? (q.stat != null ? 'Ajukan portofolio, sertifikat, atau ikut ujian guild untuk membuka stat ini.' : 'Naikkan rank dengan menyelesaikan quest lain.')
                            : 'Baca syarat, tahapan, dan aturan di atas sebelum mengambil.',
                    textAlign: TextAlign.center,
                    style: body(12, color: C.mist2),
                  ),
                  const SizedBox(height: 10),
                  GoldButton(
                    q.mine ? 'Permintaanmu sendiri' : (taken ? 'Quest sedang berjalan' : (!el.ok ? 'Belum memenuhi syarat' : 'Ambil quest')),
                    onTap: (q.mine || taken || !el.ok) ? null : () => _take(context),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v, {bool strong = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: body(13, color: strong ? C.mist : C.mist2, weight: strong ? FontWeight.w700 : FontWeight.w500)),
          Text(v, style: body(strong ? 15 : 13, color: color ?? (strong ? C.jade : C.mist), weight: FontWeight.w700)),
        ]),
      );

  Widget _fact(String label, String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(color: const Color(0xFF10202C), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.lineSoft)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: body(10.5, color: C.mist3, weight: FontWeight.w800, spacing: 1.2)),
          const SizedBox(height: 6),
          Text(value, style: body(14, weight: FontWeight.w700)),
        ]),
      );

  Widget _req(bool ok, String text, String status, {String? sub}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(color: const Color(0xFF10202C), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.lineSoft)),
        child: Row(children: [
          AppIcon(ok ? 'check' : 'lock', color: ok ? C.jade : C.ember, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(text, style: body(13.5)),
              if (sub != null) Text(sub, style: body(12, color: C.mist3)),
            ]),
          ),
          const SizedBox(width: 8),
          Text(status, style: body(12, color: ok ? C.jade : const Color(0xFFF19C8E), weight: FontWeight.w700)),
        ]),
      );

  Widget _stage(int i, Stage s, Quest q) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 22,
            child: Column(children: [
              Container(
                width: 21,
                height: 21,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: C.ink900, border: Border.all(color: C.lanternLo, width: 2)),
                child: Text('${i + 1}', style: body(11, color: C.lanternHi, weight: FontWeight.w800)),
              ),
              if (i < q.stages.length - 1) Expanded(child: Container(width: 1, color: C.line)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.label, style: body(14, weight: FontWeight.w600)),
                Text('${s.percent}% dari imbalan', style: body(12, color: C.mist3)),
              ]),
            ),
          ),
          Text(rp((q.net * s.percent / 100).round()), style: body(14, color: C.lanternHi, weight: FontWeight.w700)),
        ]),
      );

  Widget _rule(String icon, String bold, String rest) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: AppIcon(icon, color: C.lantern, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(style: body(13, color: C.mist2, height: 1.45), children: [
              TextSpan(text: bold, style: body(13, weight: FontWeight.w700)),
              TextSpan(text: rest),
            ])),
          ),
        ]),
      );
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(s.width / 2, 0)
    ..lineTo(s.width, s.height * 0.25)
    ..lineTo(s.width, s.height * 0.75)
    ..lineTo(s.width / 2, s.height)
    ..lineTo(0, s.height * 0.75)
    ..lineTo(0, s.height * 0.25)
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

/// Layar "Quest diterima" dengan cap lambang guild.
class AcceptedScreen extends StatefulWidget {
  final AppState state;
  final Quest quest;
  const AcceptedScreen({super.key, required this.state, required this.quest});
  @override
  State<AcceptedScreen> createState() => _AcceptedScreenState();
}

class _AcceptedScreenState extends State<AcceptedScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))..forward();

  @override
  void initState() {
    super.initState();
    AudioService.current.sfx(Sfx.bell);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _backTo(int tab) {
    widget.state.goTo(tab);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quest;
    return Scaffold(
      backgroundColor: const Color(0xFF080E14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedBuilder(
                animation: _c,
                builder: (_, child) {
                  final t = Curves.elasticOut.transform(_c.value.clamp(0.0, 1.0));
                  return Opacity(
                    opacity: _c.value.clamp(0.0, 1.0),
                    child: Transform.rotate(angle: (1 - t) * -0.25, child: Transform.scale(scale: 1 + (1 - t) * 1.2, child: child)),
                  );
                },
                child: SvgPicture.asset('assets/scene/crest.svg', width: 150, height: 150),
              ),
              const SizedBox(height: 22),
              Text('QUEST DITERIMA', style: display(25, spacing: 1)),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text('Selesaikan sebelum batas waktu. Dana sudah ditahan guild dan akan cair setelah dikonfirmasi.', textAlign: TextAlign.center, style: body(14, color: C.mist2, height: 1.5)),
              ),
              const SizedBox(height: 22),
              CutCard(
                fill: const Color(0xFF132532),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(q.title, style: body(15, weight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Kamu terima ${rp(q.net)} · +${q.exp} EXP', style: body(13, color: C.mist2)),
                    Text('Batas selesai: ${q.within}', style: body(13, color: C.mist2)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              GoldButton('Kembali ke papan', onTap: () => _backTo(1)),
              const SizedBox(height: 10),
              GoldButton('Lihat profilku', ghost: true, onTap: () => _backTo(2)),
            ]),
          ),
        ),
      ),
    );
  }
}

