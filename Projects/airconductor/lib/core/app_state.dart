import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  AppState({
    required bool cameraEnabled,
    required bool micEnabled,
    this.musicDir,
  })  : _cameraEnabled = cameraEnabled,
        _micEnabled = micEnabled;

  bool _cameraEnabled;
  bool _micEnabled;
  final String? musicDir;

  bool get cameraEnabled => _cameraEnabled;
  bool get micEnabled => _micEnabled;

  set cameraEnabled(bool value) {
    if (_cameraEnabled == value) return;
    _cameraEnabled = value;
    notifyListeners();
  }

  set micEnabled(bool value) {
    if (_micEnabled == value) return;
    _micEnabled = value;
    notifyListeners();
  }

  void toggleCamera() {
    cameraEnabled = !cameraEnabled;
  }

  void toggleMic() {
    micEnabled = !micEnabled;
  }
}
