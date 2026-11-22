import 'package:flutter/material.dart';

import '../audio.dart';
import '../theme.dart';
import 'common.dart';

/// Tombol bulat kecil untuk menyalakan atau mematikan suara latar.
class SoundButton extends StatelessWidget {
  const SoundButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService.current;
    return ListenableBuilder(
      listenable: audio,
      builder: (_, _) => Semantics(
        button: true,
        label: audio.muted ? 'Nyalakan suara' : 'Matikan suara',
        child: GestureDetector(
          onTap: () => audio.setMuted(!audio.muted),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: const Color(0xCC0A141D), shape: BoxShape.circle, border: Border.all(color: C.line)),
            child: Center(child: AppIcon(audio.muted ? 'mute' : 'sound', color: audio.muted ? C.mist3 : C.lanternHi, size: 19)),
          ),
        ),
      ),
    );
  }
}

/// Baris pengaturan suara di profil.
class SoundSetting extends StatelessWidget {
  const SoundSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService.current;
    return ListenableBuilder(
      listenable: audio,
      builder: (_, _) => Semantics(
        toggled: !audio.muted,
        label: 'Suara latar',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => audio.setMuted(!audio.muted),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
            child: Row(children: [
              AppIcon(audio.muted ? 'mute' : 'sound', color: audio.muted ? C.mist3 : C.lanternHi, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Suara latar', style: body(14, weight: FontWeight.w700)),
                  Text(audio.muted ? 'Mati' : 'Nyala · musik aula dan efek suara', style: body(12, color: C.mist2)),
                ]),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 26,
                padding: const EdgeInsets.all(3),
                alignment: audio.muted ? Alignment.centerLeft : Alignment.centerRight,
                decoration: BoxDecoration(color: audio.muted ? const Color(0xFF223648) : const Color(0xFF7A5A1C), borderRadius: BorderRadius.circular(99)),
                child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: audio.muted ? const Color(0xFF9DB0BE) : C.lanternHi)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
