import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path/path.dart' as p;

import '../../core/track.dart';

class MusicController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<Track> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  double _volume = 0.8;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Track? _currentTrack;

  List<Track> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  Duration get position => _position;
  Duration get duration => _duration;
  Track? get currentTrack => _currentTrack;

  Future<void> initialize({String? musicDir}) async {
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player state
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        next(); // Auto-advance
      }
    });

    // Load playlist
    if (musicDir != null) {
      await _loadFromDirectory(musicDir);
    } else {
      _playlist = List.from(demoPlaylist);
    }

    if (_playlist.isNotEmpty) {
      await _loadTrack(_playlist[0]);
    }

    await _player.setVolume(_volume);
  }

  Future<void> _loadFromDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      _playlist = List.from(demoPlaylist);
      return;
    }

    final files = dir.listSync(recursive: false).whereType<File>().where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return ['.mp3', '.m4a', '.aac', '.flac', '.wav', '.ogg'].contains(ext);
    }).toList();

    _playlist = files.asMap().entries.map((entry) {
      final file = entry.value;
      final name = p.basenameWithoutExtension(file.path);
      final parts = name.split(' - ');
      return Track(
        id: entry.key.toString(),
        title: parts.length > 1 ? parts.sublist(1).join(' - ') : name,
        artist: parts.length > 1 ? parts[0] : 'Unknown',
        path: file.path,
        mood: _guessMood(name),
      );
    }).toList();

    if (_playlist.isEmpty) {
      _playlist = List.from(demoPlaylist);
    }
  }

  Mood _guessMood(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('happy') || lower.contains('joy') || lower.contains('fun')) return Mood.happy;
    if (lower.contains('sad') || lower.contains('blues') || lower.contains('cry')) return Mood.sad;
    if (lower.contains('energy') || lower.contains('pump') || lower.contains('power')) return Mood.energetic;
    if (lower.contains('chill') || lower.contains('calm') || lower.contains('relax')) return Mood.calm;
    return Mood.any;
  }

  Future<void> _loadTrack(Track track) async {
    _currentTrack = track;
    try {
      if (track.path.startsWith('http')) {
        await _player.setUrl(track.path);
      } else {
        await _player.setFilePath(track.path);
      }
    } catch (e) {
      debugPrint('Error loading track: $e');
    }
    notifyListeners();
  }

  Future<void> play() async {
    await _player.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await _loadTrack(_playlist[_currentIndex]);
    if (_isPlaying) await play();
    notifyListeners();
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    // If > 3s in, restart; otherwise go to previous
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _loadTrack(_playlist[_currentIndex]);
      if (_isPlaying) await play();
    }
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    notifyListeners();
  }

  Future<void> volumeUp() => setVolume(_volume + 0.1);
  Future<void> volumeDown() => setVolume(_volume - 0.1);

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> playMoodPlaylist(Mood mood) async {
    final moodTracks = _playlist.where((t) => t.mood == mood || t.mood == Mood.any).toList();
    if (moodTracks.isEmpty) {
      await play();
      return;
    }
    // Find first matching track index
    final idx = _playlist.indexOf(moodTracks.first);
    _currentIndex = idx;
    await _loadTrack(_playlist[_currentIndex]);
    await play();
  }

  String get statusLine {
    if (_currentTrack == null) return 'No track loaded';
    final status = _isPlaying ? '▶' : '⏸';
    return '$status ${_currentTrack!.artist} — ${_currentTrack!.title}';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}