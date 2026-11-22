import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/quests.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'post_screen.dart';

/// Daftar quest yang dipasang pengguna beserta statusnya.
class MyRequestsScreen extends StatelessWidget {
  final AppState state;
  const MyRequestsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.ink900,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final list = state.posted;
            return Column(children: [
              GuildTopBar(title: 'PERMINTAANKU', onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
                  if (list.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(child: Text('Belum ada permintaan', style: body(16, weight: FontWeight.w700))),
                    const SizedBox(height: 6),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 290),
                        child: Text('Pasang quest pertamamu. Siapa pun boleh memasang, tanpa imbalan minimum.', textAlign: TextAlign.center, style: body(13, color: C.mist2, height: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GoldButton('Pasang quest', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostQuestScreen(state: state)))),
                  ] else ...[
                    CutCard(
                      fill: const Color(0xFF0F2A2B),
                      edge: C.jade,
                      cut: 10,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(children: [
                        const AppIcon('shield', color: C.jade, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Dana ditahan guild', style: body(12, color: const Color(0xFFB9E6DC))),
                            Text(rp(state.escrowTotal), style: body(18, color: C.jade, weight: FontWeight.w800)),
                          ]),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    for (final q in list)
                      Padding(padding: const EdgeInsets.only(bottom: 12), child: _RequestCard(state: state, quest: q)),
                    const SizedBox(height: 4),
                    GoldButton('Pasang quest lagi', ghost: true, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostQuestScreen(state: state)))),
                  ],
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final AppState state;
  final Quest quest;
  const _RequestCard({required this.state, required this.quest});

  @override
  Widget build(BuildContext context) {
    final q = quest;
    return CutCard(
      fill: const Color(0xFF132532),
      edge: C.lineSoft,
      onTap: () => openQuest(context, state, q.id),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: RankSeal(q.rank, width: 46)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(q.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: body(15, weight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 8),
            q.inReview
                ? const Pill('Menunggu pemeriksaan', color: C.lanternHi, border: C.lanternLo, fill: Color(0xFF2A2412), icon: Icons.hourglass_empty)
                : const Pill('Terbit · menunggu petualang', color: C.jade, border: Color(0xFF245A50), icon: Icons.check),
            const SizedBox(height: 10),
            Wrap(spacing: 12, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(rp(q.reward), style: body(16, color: C.lanternHi, weight: FontWeight.w800)),
              Text('${q.stages.length} tahap', style: body(12, color: C.mist2)),
              Text(q.place, style: body(12, color: C.mist2)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
