import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_state.dart';
import '../audio.dart';
import '../data/post_rules.dart';
import '../data/quests.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';
import 'my_requests_screen.dart';
import 'sheets.dart';

/// Alur memasang quest: pekerjaan, imbalan & waktu, tahapan, tinjau & bayar.
class PostQuestScreen extends StatefulWidget {
  final AppState state;
  const PostQuestScreen({super.key, required this.state});
  @override
  State<PostQuestScreen> createState() => _PostQuestScreenState();
}

class _PostQuestScreenState extends State<PostQuestScreen> {
  static const _steps = ['Pekerjaan', 'Imbalan & waktu', 'Tahapan', 'Tinjau & bayar'];

  final _scroll = ScrollController();
  int _step = 0;

  String _giver = 'Warga';
  bool _remote = false;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _criteria = TextEditingController();
  final _area = TextEditingController();
  late final TextEditingController _who = TextEditingController(text: widget.state.registered ? widget.state.name : '');

  final _reward = TextEditingController();
  String _postWin = '3 hari';
  String _doneWin = '3 hari';

  int _preset = 1;
  final List<List<TextEditingController>> _labels = [
    for (final p in stagePresets) [for (final l in p.labels) TextEditingController(text: l)],
  ];

  int _raise = 0;
  final _raiseWhy = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    for (final c in [_scroll, _title, _desc, _criteria, _area, _who, _reward, _raiseWhy, for (final l in _labels) ...l]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _rewardVal => int.tryParse(_reward.text) ?? 0;
  int get _net => (_rewardVal * (1 - guildFee)).round();
  List<TextEditingController> get _stageCtl => _labels[_preset];
  void _refresh() => setState(() {});

  Suggestion get _sug => suggestFor(title: _title.text, desc: _desc.text, reward: _rewardVal);
  int _raiseFor(Suggestion s) => _raise.clamp(0, math.min(2, rankOrder.length - 1 - rankOrder.indexOf(s.rank)));
  String _rankFor(Suggestion s) => rankOrder[rankOrder.indexOf(s.rank) + _raiseFor(s)];

  /// Hal yang masih kurang di langkah ini, atau null bila sudah lengkap.
  String? _missing() {
    switch (_step) {
      case 0:
        if (_title.text.trim().length < 8) return 'Judul minimal 8 huruf.';
        if (_desc.text.trim().length < 20) return 'Uraian pekerjaan minimal 20 huruf.';
        if (_criteria.text.trim().length < 10) return 'Tulis kapan pekerjaan dianggap selesai.';
        if (!_remote && _area.text.trim().length < 3) return 'Isi lokasi atau area pengerjaan.';
        if (_who.text.trim().length < 3) return 'Isi nama yang ditampilkan (minimal 3 huruf).';
        return null;
      case 1:
        return _rewardVal <= 0 ? 'Isi imbalan.' : null;
      case 2:
        return _stageCtl.any((c) => c.text.trim().isEmpty) ? 'Setiap tahap perlu nama.' : null;
      default:
        if (_raiseFor(_sug) > 0 && _raiseWhy.text.trim().length < 10) return 'Tulis alasan menaikkan rank minimum.';
        if (!_agree) return 'Centang persetujuan di atas.';
        return null;
    }
  }

  void _go(int to) {
    setState(() => _step = to);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _back() => _step == 0 ? Navigator.of(context).pop() : _go(_step - 1);

  Quest _build(Suggestion sug, String rank, ReviewPath path) {
    final preset = stagePresets[_preset];
    return Quest(
      id: widget.state.nextPostedId(),
      title: _title.text.trim(),
      giver: _giver,
      who: _who.text.trim(),
      loc: _remote ? 'Remote' : _area.text.trim(),
      dist: '',
      remote: _remote,
      rank: rank,
      stat: sug.stat,
      reward: _rewardVal,
      exp: expFor(rank, preset.percents.length),
      left: _postWin,
      within: '$_doneWin setelah diambil',
      desc: _desc.text.trim(),
      criteria: _criteria.text.trim(),
      stages: [for (var i = 0; i < preset.percents.length; i++) Stage(_stageCtl[i].text.trim(), preset.percents[i])],
      badges: const [],
      mine: true,
      inReview: path != ReviewPath.auto,
      reviewNote: reviewNoteFor(path),
      rankReason: _raiseFor(sug) > 0 ? _raiseWhy.text.trim() : '',
    );
  }

  Future<void> _pay() async {
    final sug = _sug;
    final rank = _rankFor(sug);
    final ok = await showPaySheet(context, title: _title.text.trim(), amount: _rewardVal);
    if (!ok || !mounted) return;
    final q = _build(sug, rank, pathFor(sug, rank));
    widget.state.post(q);
    Navigator.of(context).pushReplacement(MaterialPageRoute(fullscreenDialog: true, builder: (_) => PostedScreen(state: widget.state, quest: q)));
  }

  @override
  Widget build(BuildContext context) {
    final missing = _missing();
    final last = _step == _steps.length - 1;
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(_step - 1);
      },
      child: Scaffold(
        backgroundColor: C.ink900,
        body: SafeArea(
          child: Column(children: [
            GuildTopBar(title: 'PASANG QUEST', onBack: _back),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  for (var i = 0; i < _steps.length; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 6),
                        decoration: BoxDecoration(color: i <= _step ? C.lantern : C.line, borderRadius: BorderRadius.circular(9)),
                      ),
                    ),
                ]),
                const SizedBox(height: 10),
                Text('Langkah ${_step + 1} dari ${_steps.length}', style: body(11.5, color: C.mist3, weight: FontWeight.w700, spacing: 0.4)),
                const SizedBox(height: 2),
                Text(_steps[_step].toUpperCase(), style: display(21, spacing: 0.8)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: switch (_step) {
                  0 => _stepWork(),
                  1 => _stepReward(),
                  2 => _stepStages(),
                  _ => _stepReview(),
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(color: C.ink900, border: Border(top: BorderSide(color: C.lineSoft))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (missing != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(missing, textAlign: TextAlign.center, style: body(12, color: C.mist2)),
                  ),
                Row(children: [
                  if (_step > 0) ...[
                    Expanded(flex: 2, child: GoldButton('Kembali', ghost: true, onTap: _back)),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 3,
                    child: GoldButton(
                      last ? 'Bayar & pasang quest' : 'Lanjut',
                      onTap: missing != null ? null : (last ? _pay : () => _go(_step + 1)),
                    ),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // Langkah 1: pekerjaan

  Widget _stepWork() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FieldLabel('Aku memasang sebagai'),
      ChoiceRow(
        options: const ['Warga', 'UMKM', 'Firma Dagang', 'Pemerintah'],
        selected: _giver,
        disabled: const {'Pemerintah'},
        onSelect: (v) => setState(() => _giver = v),
      ),
      const SizedBox(height: 8),
      InfoNote(
        _giver == 'Warga'
            ? 'Pemerintah hanya bisa memasang lewat jalur resmi instansi, bukan dari akun biasa.'
            : 'Skema harga khusus usaha belum ditetapkan. Sementara memakai biaya guild yang sama dengan warga.',
      ),
      const SizedBox(height: 20),
      GuildField(label: 'Judul quest', controller: _title, hint: 'Contoh: Antar 5 paket ke kantor pos', maxLength: 70, onChanged: (_) => _refresh()),
      GuildField(
        label: 'Jelaskan pekerjaannya',
        help: 'Apa yang harus dikerjakan, bahan apa yang kamu sediakan, dan hal yang perlu diperhatikan.',
        controller: _desc,
        hint: 'Tulis selengkap mungkin supaya petualang tidak salah paham.',
        maxLines: 4,
        maxLength: 600,
        onChanged: (_) => _refresh(),
      ),
      GuildField(
        label: 'Dianggap selesai jika…',
        help: 'Petualang bisa melihat ini sebelum mengambil quest, dan staff guild memakainya bila ada sengketa.',
        controller: _criteria,
        hint: 'Contoh: Dompet diserahkan langsung ke pemilik dan pemilik mengonfirmasi lewat chat guild.',
        maxLines: 3,
        maxLength: 240,
        onChanged: (_) => _refresh(),
      ),
      const FieldLabel('Cara pengerjaan'),
      ChoiceRow(
        options: const ['Di kotaku (Bandung)', 'Jarak jauh'],
        selected: _remote ? 'Jarak jauh' : 'Di kotaku (Bandung)',
        onSelect: (v) => setState(() => _remote = v == 'Jarak jauh'),
      ),
      const SizedBox(height: 18),
      if (!_remote)
        GuildField(label: 'Lokasi atau area', controller: _area, hint: 'Contoh: Taman Lansia, Bandung', maxLength: 50, onChanged: (_) => _refresh()),
      GuildField(
        label: 'Nama yang ditampilkan',
        help: 'Boleh nama samaran. Identitas aslimu tidak ditampilkan ke petualang.',
        controller: _who,
        hint: 'Contoh: Bu Ratna',
        maxLength: 24,
        onChanged: (_) => _refresh(),
      ),
    ]);
  }

  // Langkah 2: imbalan dan waktu

  Widget _stepReward() {
    final r = _rewardVal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GuildField(
        label: 'Imbalan',
        help: 'Tidak ada batas minimum. Kamu membayar sebesar ini di muka dan guild menyimpannya.',
        controller: _reward,
        hint: '0',
        prefix: 'Rp ',
        digitsOnly: true,
        maxLength: 10,
        onChanged: (_) => _refresh(),
      ),
      Transform.translate(
        offset: const Offset(0, -6),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in rewardShortcuts)
            OptionChip(label: rp(v), on: r == v, onTap: () => setState(() => _reward.text = '$v')),
        ]),
      ),
      const SizedBox(height: 14),
      CutCard(
        fill: const Color(0xFF1B1A14),
        edge: C.lantern.withValues(alpha: 0.55),
        cut: 14,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(children: [
          _Kv('Kamu bayar', r > 0 ? rp(r) : '—', strong: true, color: C.lanternHi),
          const SizedBox(height: 4),
          Container(height: 1, color: const Color(0xFF4A4026)),
          const SizedBox(height: 4),
          _Kv('Biaya guild (${(guildFee * 100).round()}%)', r > 0 ? '−${rp(r - _net)}' : '—'),
          _Kv('Petualang terima', r > 0 ? rp(_net) : '—', color: C.jade),
        ]),
      ),
      const SizedBox(height: 22),
      const FieldLabel('Quest dibuka selama', help: 'Jika lewat dan belum ada yang mengambil, quest dihapus otomatis dan dana kembali 100%.'),
      ChoiceRow(options: postWindows, selected: _postWin, onSelect: (v) => setState(() => _postWin = v)),
      const SizedBox(height: 22),
      const FieldLabel('Batas selesai setelah diambil', help: 'Hitungannya mulai saat petualang menerima quest.'),
      ChoiceRow(options: doneWindows, selected: _doneWin, onSelect: (v) => setState(() => _doneWin = v)),
    ]);
  }

  // Langkah 3: tahapan

  Widget _stepStages() {
    final preset = stagePresets[_preset];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FieldLabel('Berapa tahap?', help: 'Dana dilepas per tahap setelah kamu mengonfirmasinya. Pekerjaan kecil cukup satu tahap.'),
      ChoiceRow(
        options: [for (final p in stagePresets) p.name],
        selected: preset.name,
        onSelect: (v) => setState(() => _preset = stagePresets.indexWhere((p) => p.name == v)),
      ),
      const SizedBox(height: 22),
      for (var i = 0; i < preset.percents.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: C.ink900, border: Border.all(color: C.lanternLo, width: 2)),
              child: Text('${i + 1}', style: body(12, color: C.lanternHi, weight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(
                  controller: _stageCtl[i],
                  maxLength: 50,
                  onChanged: (_) => _refresh(),
                  style: body(15, weight: FontWeight.w600),
                  cursorColor: C.lantern,
                  decoration: guildInput('Nama tahap'),
                ),
                const SizedBox(height: 6),
                Text(
                  '${preset.percents[i]}% dari imbalan${_rewardVal > 0 ? ' · petualang terima ${rp((_net * preset.percents[i] / 100).round())}' : ''}',
                  style: body(12, color: C.mist3),
                ),
              ]),
            ),
          ]),
        ),
      const InfoNote('Tahapan dan nilainya tidak bisa diubah sepihak setelah quest diambil. Perubahan besar butuh persetujuan petualang atau ditinjau guild.', icon: 'shield', color: C.jade),
    ]);
  }

  // Langkah 4: tinjau dan bayar

  Widget _stepReview() {
    final sug = _sug;
    final raise = _raiseFor(sug);
    final rank = _rankFor(sug);
    final path = pathFor(sug, rank);
    final preset = stagePresets[_preset];
    final rankIdx = rankOrder.indexOf(sug.rank);
    final maxRaise = math.min(2, rankOrder.length - 1 - rankIdx);
    final rankOptions = [for (var i = 0; i <= maxRaise; i++) i == 0 ? 'Rank ${rankOrder[rankIdx]} · saran' : 'Rank ${rankOrder[rankIdx + i]}'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CutCard(
        fill: const Color(0xFF132532),
        edge: C.line,
        cut: 14,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            RankSeal(sug.rank, width: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Saran Terra', style: body(12, color: C.mist3, weight: FontWeight.w800, spacing: 0.6)),
                const SizedBox(height: 2),
                Text('Rank minimum ${sug.rank} · ${difficultyName[sug.rank]}', style: body(15, weight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          for (final w in sug.why)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(padding: EdgeInsets.only(top: 3), child: AppIcon('check', color: C.jade, size: 15)),
                const SizedBox(width: 8),
                Expanded(child: Text(w, style: body(13, color: C.mist2, height: 1.45))),
              ]),
            ),
          if (sug.stat != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Pill('${sug.stat!.name} minimal ${sug.stat!.min}', color: C.lanternHi, border: C.lanternLo, fill: const Color(0xFF2A2412), icon: Icons.lock_outline),
            ),
          const SizedBox(height: 12),
          Text('Perkiraan awal dari aturan sederhana. Versi sebenarnya dinilai AI lalu ditinjau staff guild.', style: body(11.5, color: C.mist3, height: 1.45)),
        ]),
      ),
      const SizedBox(height: 20),
      if (maxRaise > 0) ...[
        const FieldLabel('Rank minimum yang dipasang', help: 'Kamu boleh meminta syarat lebih tinggi dari saran, asalkan ada alasannya.'),
        ChoiceRow(
          options: rankOptions,
          selected: rankOptions[raise],
          onSelect: (v) => setState(() => _raise = rankOptions.indexOf(v)),
        ),
        const SizedBox(height: 16),
        if (raise > 0)
          GuildField(label: 'Alasan meminta rank lebih tinggi', controller: _raiseWhy, hint: 'Contoh: barang yang diantar bernilai tinggi.', maxLength: 120, onChanged: (_) => _refresh()),
      ],
      InfoNote(
        switch (path) {
          ReviewPath.auto => 'Lolos pemeriksaan otomatis. Quest langsung terbit di papan setelah dibayar.',
          ReviewPath.human => 'Rank C ke atas: penilai guild menyetujui dulu sebelum quest terbit. Dana tetap disimpan guild selama menunggu.',
          ReviewPath.staff => 'Isi quest memuat hal yang perlu ditinjau. Staff guild memeriksanya dulu sebelum terbit. Dana tetap disimpan guild selama menunggu.',
        },
        icon: path == ReviewPath.auto ? 'check' : (path == ReviewPath.staff ? 'warn' : 'clock'),
        color: path == ReviewPath.auto ? C.jade : C.lantern,
      ),
      const SectionTitle('Ringkasan'),
      CutCard(
        fill: const Color(0xFF10202C),
        edge: C.lineSoft,
        cut: 12,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(children: [
          _Kv('Kamu bayar', rp(_rewardVal), strong: true, color: C.lanternHi),
          _Kv('Biaya guild (${(guildFee * 100).round()}%)', '−${rp(_rewardVal - _net)}'),
          _Kv('Petualang terima', rp(_net), color: C.jade),
          _Kv('Hadiah EXP (ditetapkan guild)', '+${expFor(rank, preset.percents.length)} EXP'),
          _Kv('Tahapan', preset.name),
          _Kv('Dibuka selama', _postWin),
          _Kv('Batas selesai', '$_doneWin setelah diambil'),
          _Kv('Lokasi', _remote ? 'Jarak jauh' : _area.text.trim()),
        ]),
      ),
      const SizedBox(height: 14),
      const InfoNote('Dana disimpan guild sampai pekerjaan dikonfirmasi selesai. Jika kamu terbukti melanggar, dana tidak dikembalikan (sebagian atau penuh) dan kamu bisa dilarang memasang quest untuk sementara.', icon: 'shield', color: C.jade),
      const SizedBox(height: 16),
      Semantics(
        button: true,
        checked: _agree,
        label: 'Aku setuju pada ketentuan quest',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _agree = !_agree),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: _agree ? C.lantern : const Color(0xFF0A141D),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: _agree ? C.lanternHi : C.line, width: 1.5),
              ),
              child: _agree ? const Center(child: AppIcon('check', color: Color(0xFF2A1A00), size: 16)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Aku sudah memeriksa isi quest dan setuju pada ketentuan di atas, termasuk bahwa syarat tidak bisa kuubah sepihak setelah diambil.', style: body(13, color: C.mist2, height: 1.5)),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _Kv extends StatelessWidget {
  final String k, v;
  final bool strong;
  final Color? color;
  const _Kv(this.k, this.v, {this.strong = false, this.color});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(k, style: body(13, color: strong ? C.mist : C.mist2, weight: strong ? FontWeight.w700 : FontWeight.w500))),
          const SizedBox(width: 12),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: body(strong ? 17 : 13, color: color ?? C.mist, weight: FontWeight.w700))),
        ]),
      );
}

/// Layar setelah quest dibayar: terbit di papan, atau menunggu pemeriksaan.
class PostedScreen extends StatefulWidget {
  final AppState state;
  final Quest quest;
  const PostedScreen({super.key, required this.state, required this.quest});
  @override
  State<PostedScreen> createState() => _PostedScreenState();
}

class _PostedScreenState extends State<PostedScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final q = widget.quest;
    final nav = Navigator.of(context);
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
              Text(q.inReview ? 'QUEST DIPERIKSA' : 'QUEST TERPASANG', style: display(25, spacing: 1)),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 310),
                child: Text(
                  q.inReview
                      ? 'Dana ${rp(q.reward)} sudah disimpan guild. ${q.reviewNote} Quest muncul di papan setelah disetujui.'
                      : 'Quest-mu sudah ada di Papan Permintaan. Dana ${rp(q.reward)} disimpan guild sampai pekerjaan dikonfirmasi selesai.',
                  textAlign: TextAlign.center,
                  style: body(14, color: C.mist2, height: 1.5),
                ),
              ),
              const SizedBox(height: 22),
              CutCard(
                fill: const Color(0xFF132532),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(q.title, style: body(15, weight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Rank minimum ${q.rank} · petualang terima ${rp(q.net)}', style: body(13, color: C.mist2)),
                    Text('Dibuka ${q.left} · selesai ${q.within}', style: body(13, color: C.mist2)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              if (!q.inReview) ...[
                GoldButton('Lihat di papan', onTap: () {
                  widget.state.goTo(1);
                  nav.popUntil((r) => r.isFirst);
                }),
                const SizedBox(height: 10),
              ],
              GoldButton('Lihat permintaanku', ghost: !q.inReview, onTap: () {
                nav.popUntil((r) => r.isFirst);
                nav.push(MaterialPageRoute(builder: (_) => MyRequestsScreen(state: widget.state)));
              }),
            ]),
          ),
        ),
      ),
    );
  }
}
