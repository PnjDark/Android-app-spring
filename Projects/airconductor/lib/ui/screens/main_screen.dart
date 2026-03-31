import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../features/player/music_controller.dart';
import '../../features/gestures/gesture_recognizer.dart';
import '../../features/voice/command_parser.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final musicController = context.watch<MusicController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AirConductor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Camera: ${appState.cameraEnabled ? 'Enabled' : 'Disabled'}'),
            Text('Mic: ${appState.micEnabled ? 'Enabled' : 'Disabled'}'),
            const SizedBox(height: 12),
            Text('Now ${musicController.isPlaying ? 'Playing' : 'Paused'}'),
            Text('Track: ${musicController.currentTrack?.toString() ?? 'None'}'),
            Text('Volume: ${(musicController.volume * 100).round()}%'),
            const SizedBox(height: 12),
            const Text('Gestures available:'),
            Wrap(children: Gesture.values.map((g) => Padding(
              padding: const EdgeInsets.all(4),
              child: Chip(label: Text('${g.emoji} ${g.label}')),
            )).toList()),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                musicController.togglePlayPause();
              },
              child: const Text('Play/Pause'),
            ),
          ],
        ),
      ),
    );
  }
}
