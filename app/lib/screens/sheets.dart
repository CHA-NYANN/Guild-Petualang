import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/quests.dart';
import '../theme.dart';
import '../widgets/common.dart';

Future<T?> _sheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xA804090D),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
        decoration: const BoxDecoration(
          color: Color(0xFF122332),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0x8CF0B14A))),
        ),
        child: SafeArea(top: false, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 18), child: child)),
      ),
    ),
  );
}

Widget _grip() => Center(child: Container(width: 42, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: C.line, borderRadius: BorderRadius.circular(9))));

/// Mendaftar sebagai petualang. Mengembalikan true bila berhasil.
Future<bool> showRegisterSheet(BuildContext context, AppState state) async {
  final ok = await _sheet<bool>(context, _RegisterSheet(state: state));
  return ok == true;
}

class _RegisterSheet extends StatefulWidget {
  final AppState state;
  const _RegisterSheet({required this.state});
  @override
  State<_RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<_RegisterSheet> {
  final _c = TextEditingController();
  bool get _valid => _c.text.trim().length >= 3;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grip(),
      Text('DAFTAR SEBAGAI PETUALANG', style: display(19, spacing: 0.6)),
      const SizedBox(height: 6),
      Text('Satu langkah lagi sebelum kamu bisa mengambil quest.', style: body(13.5, color: C.mist2)),
      const SizedBox(height: 18),
      Text('Nama petualang', style: body(12.5, color: C.mist2, weight: FontWeight.w700)),
      const SizedBox(height: 7),
      TextField(
        controller: _c,
        maxLength: 18,
        autofocus: false,
        onChanged: (_) => setState(() {}),
        style: body(16, weight: FontWeight.w600),
        cursorColor: C.lantern,
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Contoh: Elang Biru',
          hintStyle: body(16, color: const Color(0xFF546A7B)),
          filled: true,
          fillColor: const Color(0xFF0A141D),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.lanternHi, width: 2)),
        ),
      ),
      const SizedBox(height: 14),
      _Note('Rank F boleh anonim. Kamu cukup memakai nama samaran. Mulai Rank E, guild akan meminta identitas dan bukti identitasmu.'),
      const SizedBox(height: 18),
      GoldButton('Resmi jadi Petualang', onTap: _valid
          ? () {
              widget.state.register(_c.text);
              Navigator.of(context).pop(true);
            }
          : null),
      const SizedBox(height: 10),
      GoldButton('Nanti saja', ghost: true, onTap: () => Navigator.of(context).pop(false)),
    ]);
  }
}

class _Note extends StatelessWidget {
  final String text;
  const _Note(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF10202C), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.lineSoft)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(top: 1), child: AppIcon('info', color: C.lantern, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: body(12.5, color: C.mist2, height: 1.5))),
        ]),
      );
}

/// Rangkuman sebelum mengambil quest. Mengembalikan true bila disetujui.
Future<bool> showConfirmSheet(BuildContext context, Quest q) async {
  final ok = await _sheet<bool>(
    context,
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grip(),
      Text('CEK SEBELUM MENGAMBIL', style: display(19, spacing: 0.6)),
      const SizedBox(height: 6),
      Text(q.title, style: body(13.5, color: C.mist2)),
      const SizedBox(height: 16),
      _Row('Kamu terima', rp(q.net)),
      _Row('Hadiah EXP', '+${q.exp} EXP'),
      _Row('Batas selesai', q.within),
      _Row('Tahapan', '${q.stages.length} tahap'),
      const SizedBox(height: 6),
      _Note('Jika kamu membatalkan tanpa alasan valid atau lalai, dana kembali ke pemberi quest dan kamu bisa terkena sanksi. Dengan menekan tombol di bawah, kamu setuju pada ketentuan quest ini.'),
      const SizedBox(height: 18),
      Builder(builder: (ctx) => GoldButton('Terima & ambil quest', onTap: () => Navigator.of(ctx).pop(true))),
      const SizedBox(height: 10),
      Builder(builder: (ctx) => GoldButton('Kembali', ghost: true, onTap: () => Navigator.of(ctx).pop(false))),
    ]),
  );
  return ok == true;
}

/// Pembayaran di muka ke guild. Masih simulasi: belum ada penyedia pembayaran.
Future<bool> showPaySheet(BuildContext context, {required String title, required int amount}) async {
  final ok = await _sheet<bool>(
    context,
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grip(),
      Text('BAYAR KE GUILD', style: display(19, spacing: 0.6)),
      const SizedBox(height: 6),
      Text(title, style: body(13.5, color: C.mist2)),
      const SizedBox(height: 16),
      _Row('Dibayar sekarang', rp(amount)),
      _Row('Disimpan guild', 'Sampai pekerjaan dikonfirmasi selesai'),
      _Row('Biaya guild', '${(guildFee * 100).round()}% dari imbalan, diambil saat selesai'),
      const SizedBox(height: 6),
      _Note('Jika sampai batas waktu tidak ada petualang yang mengambil, dana kembali 100% kepadamu. Ini masih simulasi: belum ada uang sungguhan yang berpindah.'),
      const SizedBox(height: 18),
      Builder(builder: (ctx) => GoldButton('Bayar ${rp(amount)} (simulasi)', onTap: () => Navigator.of(ctx).pop(true))),
      const SizedBox(height: 10),
      Builder(builder: (ctx) => GoldButton('Kembali', ghost: true, onTap: () => Navigator.of(ctx).pop(false))),
    ]),
  );
  return ok == true;
}

class _Row extends StatelessWidget {
  final String k, v;
  const _Row(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: body(13.5, color: C.mist2)),
          const SizedBox(width: 14),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: body(13.5, weight: FontWeight.w700))),
        ]),
      );
}
