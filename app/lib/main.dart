import 'package:flutter/material.dart';

import 'app.dart';
import 'audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audio = PlayerAudio();
  await audio.load();
  runApp(GuildApp(audio: audio));
}
