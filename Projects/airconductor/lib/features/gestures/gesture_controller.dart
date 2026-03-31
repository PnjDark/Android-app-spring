import 'package:flutter/foundation.dart';

import '../../core/app_state.dart';
import '../../core/track.dart';
import '../gestures/gesture_recognizer.dart';
import '../player/music_controller.dart';

class GestureController extends ChangeNotifier {
  GestureController({
    required this.musicController,
    required this.appState,
  });

  final MusicController musicController;
  final AppState appState;

  bool _isActive = false;
  bool get isActive => _isActive;

  Future<void> initialize() async {
    _isActive = appState.cameraEnabled;
    notifyListeners();
  }

  Future<void> stop() async {
    _isActive = false;
    notifyListeners();
  }

  Future<void> simulateGesture(Gesture gesture) async {
    switch (gesture) {
      case Gesture.peace:
        await musicController.togglePlayPause();
        break;
      case Gesture.thumbsUp:
        await musicController.next();
        break;
      case Gesture.thumbsDown:
        await musicController.previous();
        break;
      case Gesture.openHand:
        await musicController.volumeUp();
        break;
      case Gesture.fist:
        await musicController.volumeDown();
        break;
      case Gesture.none:
        break;
    }
    notifyListeners();
  }
}
