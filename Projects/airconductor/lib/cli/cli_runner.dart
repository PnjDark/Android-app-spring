import 'dart:async';
import 'dart:io';

import '../core/app_state.dart';
import '../features/player/music_controller.dart';
import '../features/gestures/gesture_controller.dart';
import '../features/gestures/gesture_recognizer.dart';
import '../features/voice/voice_controller.dart';
import '../features/voice/command_parser.dart';

class CliRunner {
  final AppState appState;
  final MusicController musicController;
  final GestureController gestureController;
  final VoiceController voiceController;

  CliRunner({
    required this.appState,
    required this.musicController,
    required this.gestureController,
    required this.voiceController,
  });

  Future<void> run() async {
    _printBanner();

    // Initialize subsystems
    stdout.write('Initializing camera');
    if (appState.cameraEnabled) {
      await gestureController.initialize();
      stdout.write(' ✓\n');
    } else {
      stdout.write(' [disabled]\n');
    }

    stdout.write('Initializing microphone');
    if (appState.micEnabled) {
      await voiceController.initialize();
      stdout.write(' ✓\n');
    } else {
      stdout.write(' [disabled]\n');
    }

    stdout.writeln('\nLoaded ${musicController.playlist.length} tracks.');
    stdout.writeln('Type "help" for commands, "quit" to exit.\n');

    _startStatusPrinter();

    // Main CLI loop
    stdin.lineMode = true;
    stdin.echoMode = true;

    await for (final line in stdin.transform(const SystemEncoding().decoder).transform(const LineSplitter())) {
      final input = line.trim();
      if (input.isEmpty) continue;
      if (!await _handleCommand(input)) break;
    }

    await _cleanup();
  }

  Timer? _statusTimer;

  void _startStatusPrinter() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _printStatus();
    });
  }

  void _printStatus() {
    final cam = appState.cameraEnabled ? 'Camera: ${gestureController.isActive ? "Active" : "Inactive"}' : 'Camera: Disabled';
    final mic = appState.micEnabled ? 'Mic: ${voiceController.isListening ? "Listening" : "Idle"}' : 'Mic: Disabled';
    final track = musicController.statusLine;
    final vol = '🔊 ${(musicController.volume * 100).round()}%';

    _clearLine();
    stdout.write('[$cam | $mic | $vol]\n> $track\n');
  }

  Future<bool> _handleCommand(String input) async {
    final lower = input.toLowerCase();

    // First try as a voice command
    final vc = CommandParser.parse(input);
    if (vc.type != VoiceCommandType.unknown) {
      _executeVoiceCommand(vc, input);
      return true;
    }

    // CLI-specific commands
    switch (lower) {
      case 'help':
        _printHelp();
        break;

      case 'quit':
      case 'exit':
      case 'q':
        return false;

      case 'list':
      case 'ls':
        _printPlaylist();
        break;

      case 'status':
        _printStatus();
        break;

      // Gesture simulation
      case 'peace':
      case 'peace sign':
        _simulateGesture(Gesture.peace, input);
        break;
      case 'thumbs up':
      case '+1':
        _simulateGesture(Gesture.thumbsUp, input);
        break;
      case 'thumbs down':
      case '-1':
        _simulateGesture(Gesture.thumbsDown, input);
        break;
      case 'open hand':
      case 'open':
        _simulateGesture(Gesture.openHand, input);
        break;
      case 'fist':
      case 'closed':
        _simulateGesture(Gesture.fist, input);
        break;

      default:
        stdout.writeln('Unknown command: "$input". Type "help" for commands.');
    }

    return true;
  }

  void _executeVoiceCommand(dynamic vc, String input) {
    switch (vc.type) {
      case VoiceCommandType.play:
        musicController.play();
        _log('▶ Playing');
        break;
      case VoiceCommandType.pause:
        musicController.pause();
        _log('⏸ Paused');
        break;
      case VoiceCommandType.next:
        musicController.next();
        _log('⏭ Next track');
        break;
      case VoiceCommandType.previous:
        musicController.previous();
        _log('⏮ Previous track');
        break;
      case VoiceCommandType.volumeUp:
        musicController.volumeUp();
        _log('🔊 Volume: ${(musicController.volume * 100).round()}%');
        break;
      case VoiceCommandType.volumeDown:
        musicController.volumeDown();
        _log('🔉 Volume: ${(musicController.volume * 100).round()}%');
        break;
      case VoiceCommandType.playMood:
        if (vc.mood != null) {
          musicController.playMoodPlaylist(vc.mood);
          _log('🎭 Playing ${vc.mood.name} mood playlist');
        }
        break;
      default:
        break;
    }
  }

  void _simulateGesture(Gesture gesture, String input) {
    _log('[Gesture] ${gesture.emoji} ${gesture.label} → ${gesture.action}');
    gestureController.simulateGesture(gesture);
  }

  void _log(String message) {
    stdout.writeln('[AirConductor] $message');
  }

  void _clearLine() {
    stdout.write('\x1B[2K\r'); // ANSI clear line
  }

  void _printBanner() {
    stdout.writeln('''
╔══════════════════════════════════════════════════╗
║          🎵  AirConductor  v1.0.0  🎵            ║
║     Hands-free Music Player — CLI Mode           ║
╚══════════════════════════════════════════════════╝
''');
  }

  void _printHelp() {
    stdout.writeln('''
┌─────────────────────────────────────────────────┐
│  VOICE COMMANDS                                  │
│  play / resume         → Start playback          │
│  pause / stop          → Pause                   │
│  next / skip           → Next track              │
│  previous / back       → Previous track          │
│  volume up / louder    → Increase volume         │
│  volume down / softer  → Decrease volume         │
│  play happy/sad/calm   → Mood playlist           │
│                                                  │
│  GESTURE SIMULATION                              │
│  peace                 → ✌️  Play/Pause            │
│  thumbs up             → 👍 Next                  │
│  thumbs down           → 👎 Previous              │
│  open hand             → 🖐  Volume Up             │
│  fist                  → ✊ Volume Down            │
│                                                  │
│  OTHER                                           │
│  list / ls             → Show playlist           │
│  status                → Show current status     │
│  quit / exit / q       → Exit                    │
└─────────────────────────────────────────────────┘
''');
  }

  void _printPlaylist() {
    stdout.writeln('\n📋 Playlist (${musicController.playlist.length} tracks):');
    for (var i = 0; i < musicController.playlist.length; i++) {
      final track = musicController.playlist[i];
      final marker = i == musicController.currentIndex ? '▶' : ' ';
      stdout.writeln('  $marker ${(i + 1).toString().padLeft(2)}. $track [${track.mood.name}]');
    }
    stdout.writeln();
  }

  Future<void> _cleanup() async {
    _statusTimer?.cancel();
    await gestureController.stop();
    await musicController.dispose();
    stdout.writeln('\n👋 AirConductor stopped. Goodbye!');
  }
}

class LineSplitter implements StreamTransformer<String, String> {
  const LineSplitter();

  @override
  Stream<String> bind(Stream<String> stream) async* {
    String buffer = '';
    await for (final chunk in stream) {
      buffer += chunk;
      while (buffer.contains('\n')) {
        final idx = buffer.indexOf('\n');
        yield buffer.substring(0, idx).trimRight();
        buffer = buffer.substring(idx + 1);
      }
    }
    if (buffer.isNotEmpty) yield buffer;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() => StreamTransformer.castFrom(this);
}