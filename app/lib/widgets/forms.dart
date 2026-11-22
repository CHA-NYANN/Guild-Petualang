import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'common.dart';

InputDecoration guildInput(String hint, {String? prefix}) => InputDecoration(
      counterText: '',
      hintText: hint,
      hintStyle: body(15, color: const Color(0xFF546A7B)),
      prefixText: prefix,
      prefixStyle: body(16, color: C.mist2, weight: FontWeight.w700),
      filled: true,
      fillColor: const Color(0xFF0A141D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.lanternHi, width: 2)),
    );

/// Kolom isian berlabel dengan teks bantuan di bawahnya.
class GuildField extends StatelessWidget {
  final String label;
  final String? help;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final bool digitsOnly;
  final String? prefix;
  final ValueChanged<String> onChanged;

  const GuildField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.help,
    this.maxLines = 1,
    this.maxLength,
    this.digitsOnly = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: body(12.5, color: C.mist2, weight: FontWeight.w700)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          keyboardType: digitsOnly ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: body(15.5, weight: FontWeight.w600, height: maxLines > 1 ? 1.45 : null),
          cursorColor: C.lantern,
          decoration: guildInput(hint, prefix: prefix),
        ),
        if (help != null) ...[
          const SizedBox(height: 6),
          Text(help!, style: body(12, color: C.mist3, height: 1.45)),
        ],
      ]),
    );
  }
}

/// Judul kelompok isian.
class FieldLabel extends StatelessWidget {
  final String text;
  final String? help;
  const FieldLabel(this.text, {super.key, this.help});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text, style: body(12.5, color: C.mist2, weight: FontWeight.w700)),
          if (help != null) ...[
            const SizedBox(height: 4),
            Text(help!, style: body(12, color: C.mist3, height: 1.45)),
          ],
        ]),
      );
}

class OptionChip extends StatelessWidget {
  final String label;
  final bool on;
  final bool disabled;
  final VoidCallback onTap;
  const OptionChip({super.key, required this.label, required this.on, required this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: on,
        enabled: !disabled,
        label: label,
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: on ? const Color(0xFF2A2412) : const Color(0xFF0E1A24),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: on ? C.lantern : C.line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (disabled) ...[const AppIcon('lock', color: C.mist3, size: 14), const SizedBox(width: 6)],
              Text(label, style: body(13, color: disabled ? C.mist3 : (on ? C.lanternHi : C.mist2), weight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

/// Barisan pilihan tunggal.
class ChoiceRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final Set<String> disabled;
  const ChoiceRow({super.key, required this.options, required this.selected, required this.onSelect, this.disabled = const {}});

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: [
        for (final o in options) OptionChip(label: o, on: o == selected, disabled: disabled.contains(o), onTap: () => onSelect(o)),
      ]);
}

/// Catatan kecil berlambang info.
class InfoNote extends StatelessWidget {
  final String text;
  final String icon;
  final Color color;
  const InfoNote(this.text, {super.key, this.icon = 'info', this.color = C.lantern});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF10202C), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.lineSoft)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: AppIcon(icon, color: color, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: body(12.5, color: C.mist2, height: 1.5))),
        ]),
      );
}
