import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:args/args.dart';

import 'core/app_state.dart';
import 'features/player/music_controller.dart';
import 'features/gestures/gesture_controller.dart';
import 'features/voice/voice_controller.dart';
import 'ui/screens/main_screen.dart';
import 'ui/theme/app_theme.dart';
import 'cli/cli_runner.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final parser = ArgParser()
    ..addFlag('cli', abbr: 'c', help: 'Run in CLI mode', defaultsTo: false)
    ..addFlag('no-camera', help: 'Disable camera (gesture simulation only)', defaultsTo: false)
    ..addFlag('no-mic', help: 'Disable microphone', defaultsTo: false)
    ..addOption('music-dir', abbr: 'd', help: 'Directory with music files')
    ..addFlag('help', abbr: 'h', help: 'Show this help', defaultsTo: false);

  late ArgResults result;
  try {
    result = parser.parse(args);
  } catch (e) {
    print('Error: $e');
    print(parser.usage);
    exit(1);
  }

  if (result['help'] as bool) {
    print('''
AirConductor — Hands-free Music Player
=======================================
${parser.usage}

Gestures:
  ✌️  Peace sign     → Play / Pause
  👍 Thumbs up      → Next track
  👎 Thumbs down    → Previous track
  🖐  Open hand      → Volume up
  ✊ Fist           → Volume down

Voice Commands:
  "play"            → Start playback
  "pause" / "stop"  → Pause
  "next"            → Next track
  "previous"        → Previous track
  "volume up/down"  → Adjust volume
  "play happy/sad/energetic" → Mood playlist
''');
    exit(0);
  }

  final appState = AppState(
    cameraEnabled: !(result['no-camera'] as bool),
    micEnabled: !(result['no-mic'] as bool),
    musicDir: result['music-dir'] as String?,
  );

  final musicController = MusicController();
  final gestureController = GestureController(
    musicController: musicController,
    appState: appState,
  );
  final voiceController = VoiceController(
    musicController: musicController,
    appState: appState,
  );

  await musicController.initialize(musicDir: result['music-dir'] as String?);

  if (result['cli'] as bool) {
    final cli = CliRunner(
      appState: appState,
      musicController: musicController,
      gestureController: gestureController,
      voiceController: voiceController,
    );
    await cli.run();
  } else {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: musicController),
          ChangeNotifierProvider.value(value: gestureController),
          ChangeNotifierProvider.value(value: voiceController),
        ],
        child: const AirConductorApp(),
      ),
    );
  }
}

class AirConductorApp extends StatelessWidget {
  const AirConductorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirConductor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const MainScreen(),
    );
  }
}