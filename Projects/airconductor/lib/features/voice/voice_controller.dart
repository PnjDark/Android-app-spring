import 'package:flutter/foundation.dart';

import '../../core/app_state.dart';
import '../player/music_controller.dart';
import 'command_parser.dart';

class VoiceController extends ChangeNotifier {
  VoiceController({
    required this.musicController,
    required this.appState,
  });

  final MusicController musicController;
  final AppState appState;

  bool _isListening = false;
  bool get isListening => _isListening;

  Future<void> initialize() async {
    _isListening = appState.micEnabled;
    notifyListeners();
  }

  Future<void> stop() async {
    _isListening = false;
    notifyListeners();
  }

  void processVoiceInput(String input) {
    final command = CommandParser.parse(input);
    switch (command.type) {
      case VoiceCommandType.play:
        musicController.play();
        break;
      case VoiceCommandType.pause:
        musicController.pause();
        break;
      case VoiceCommandType.next:
        musicController.next();
        break;
      case VoiceCommandType.previous:
        musicController.previous();
        break;
      case VoiceCommandType.volumeUp:
        musicController.volumeUp();
        break;
      case VoiceCommandType.volumeDown:
        musicController.volumeDown();
        break;
      case VoiceCommandType.playMood:
        if (command.mood != null) {
          musicController.playMoodPlaylist(command.mood!);
        }
        break;
      case VoiceCommandType.unknown:
        break;
    }
  }
}
