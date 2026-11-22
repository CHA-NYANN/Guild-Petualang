import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/quests.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'my_requests_screen.dart';
import 'post_screen.dart';

class BoardScreen extends StatelessWidget {
  final AppState state;
  const BoardScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final list = state.visibleQuests();
        final open = state.openQuests;
        final nLocal = open.where((q) => !q.remote).length;
        final nRemote = open.length - nLocal;
        const cats = ['Semua', 'Warga', 'UMKM', 'Pemerintah', 'Spesialis'];
        return ListView(
          padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 26, 18, 112 + MediaQuery.of(context).padding.bottom),
          children: [
            Text('PAPAN PERMINTAAN', style: display(24, spacing: 0.8)),
            const SizedBox(height: 8),
            Row(children: [
              const AppIcon('pin', color: C.lantern, size: 15),
              const SizedBox(width: 6),
              Text('Guild Bandung', style: body(13, color: C.mist2)),
              const SizedBox(width: 8),
              Text('data contoh', style: body(12, color: C.mist3)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _HeaderAction(
                  icon: 'plus',
                  label: 'Pasang quest',
                  strong: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostQuestScreen(state: state))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderAction(
                  icon: 'board',
                  label: state.posted.isEmpty ? 'Permintaanku' : 'Permintaanku · ${state.posted.length}',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyRequestsScreen(state: state))),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _Tabs(state: state, nLocal: nLocal, nRemote: nRemote),
            if (state.taken.isNotEmpty) ...[
              const SizedBox(height: 14),
              CutCard(
                fill: const Color(0xFF0F2A2B),
                edge: C.jade,
                cut: 10,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: () => openQuest(context, state, state.taken.last),
                child: Row(children: [
                  const AppIcon('check', color: C.jade, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${state.taken.length} quest sedang berjalan', style: body(13)),
                      Text(state.questById(state.taken.last).title, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(12, color: C.mist2)),
                    ]),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final c in cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(label: c, on: state.category == c, onTap: () => state.setCategory(c)),
                  ),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hanya yang bisa kuambil', style: body(13, weight: FontWeight.w700)),
                  Text('${state.registered ? 'Kamu Rank F' : 'Rank F, tanpa stat khusus'} · ${state.eligibleCount} dari ${state.takeableTotal} quest', style: body(13, color: C.mist2)),
                ]),
              ),
              Semantics(
                toggled: state.onlyEligible,
                label: 'Hanya yang bisa kuambil',
                child: GestureDetector(
                  onTap: state.toggleOnlyEligible,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 26,
                    padding: const EdgeInsets.all(3),
                    alignment: state.onlyEligible ? Alignment.centerRight : Alignment.centerLeft,
                    decoration: BoxDecoration(color: state.onlyEligible ? const Color(0xFF7A5A1C) : const Color(0xFF223648), borderRadius: BorderRadius.circular(99)),
                    child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: state.onlyEligible ? C.lanternHi : const Color(0xFF9DB0BE))),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 34),
                child: Column(children: [
                  Text('Tidak ada quest yang cocok', style: body(14, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Coba ganti kategori atau matikan filter.', style: body(13, color: C.mist2)),
                ]),
              ),
            for (final q in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuestCard(quest: q, onTap: () => openQuest(context, state, q.id)),
              ),
          ],
        );
      },
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final String icon, label;
  final bool strong;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.label, required this.onTap, this.strong = false});

  @override
  Widget build(BuildContext context) {
    final color = strong ? C.lanternHi : C.mist2;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: strong ? const Color(0xFF2A2412) : const Color(0xFF0E1A24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: strong ? C.lantern : C.line),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            AppIcon(icon, color: color, size: 17),
            const SizedBox(width: 8),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(13, color: color, weight: FontWeight.w700))),
          ]),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final AppState state;
  final int nLocal, nRemote;
  const _Tabs({required this.state, required this.nLocal, required this.nRemote});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, String icon, int n, bool remote) {
      final on = state.remoteTab == remote;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          label: label,
          child: GestureDetector(
            onTap: () => state.setTab(remote),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: on ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF24465C), Color(0xFF1B3548)]) : null,
                border: on ? Border.all(color: const Color(0xFF3D6682)) : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppIcon(icon, color: on ? C.mist : C.mist2, size: 17),
                const SizedBox(width: 8),
                Text(label, style: body(13.5, color: on ? C.mist : C.mist2, weight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(color: const Color(0xFF0A141D), borderRadius: BorderRadius.circular(99)),
                  child: Text('$n', style: body(11, color: C.lanternHi, weight: FontWeight.w700)),
                ),
              ]),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xFF0A141D), borderRadius: BorderRadius.circular(14), border: Border.all(color: C.lineSoft)),
      child: Row(children: [tab('Di kotaku', 'pin', nLocal, false), tab('Jarak jauh', 'globe', nRemote, true)]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.on, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: on,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: on ? const Color(0xFF2A2412) : const Color(0xFF0E1A24),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: on ? C.lantern : C.line),
            ),
            child: Text(label, style: body(12.5, color: on ? C.lanternHi : C.mist2, weight: FontWeight.w600)),
          ),
        ),
      );
}

Color giverDot(String giver) => switch (giver) {
      'Warga' => C.jade,
      'UMKM' => C.lantern,
      'Pemerintah' => C.sky,
      _ => C.mist3,
    };

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onTap;
  const QuestCard({super.key, required this.quest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final q = quest;
    final el = checkQuest(q);
    final locked = !q.mine && !el.ok;
    return CutCard(
      fill: locked ? const Color(0xFF0F1C27) : const Color(0xFF132532),
      edge: C.lineSoft,
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: RankSeal(q.rank, width: 46, opacity: locked ? 0.62 : 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Opacity(opacity: locked ? 0.62 : 1, child: Text(q.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: body(15, weight: FontWeight.w700, height: 1.3))),
            const SizedBox(height: 7),
            Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF0B1620), borderRadius: BorderRadius.circular(5), border: Border.all(color: C.line)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: giverDot(q.giver))),
                  const SizedBox(width: 6),
                  Text(q.giver, style: body(11, weight: FontWeight.w700)),
                ]),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                AppIcon(q.remote ? 'globe' : 'pin', color: C.mist2, size: 13),
                const SizedBox(width: 4),
                Flexible(child: Text(q.remote ? 'Remote' : q.place, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(12, color: C.mist2))),
              ]),
            ]),
            const SizedBox(height: 11),
            Wrap(spacing: 12, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(rp(q.reward), style: body(16, color: C.lanternHi, weight: FontWeight.w800)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const AppIcon('bolt', color: C.jade, size: 13),
                const SizedBox(width: 3),
                Text('+${q.exp} EXP', style: body(12.5, color: C.jade, weight: FontWeight.w700)),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const AppIcon('clock', color: C.mist2, size: 13),
                const SizedBox(width: 4),
                Text(q.left, style: body(12, color: C.mist2)),
              ]),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (q.mine)
                const Pill('Permintaanmu', color: C.lanternHi, border: C.lanternLo, fill: Color(0xFF2A2412), icon: Icons.person_outline)
              else if (el.ok)
                const Pill('Memenuhi syarat', color: C.jade, border: Color(0xFF245A50), icon: Icons.check)
              else
                for (final r in el.reasons) Pill(r, color: const Color(0xFFF19C8E), border: const Color(0xFF6B3A33), fill: const Color(0xFF1C1214), icon: Icons.lock_outline),
            ]),
          ]),
        ),
      ]),
    );
  }
}
