import '../../core/track.dart';

/// Parsed voice command result
class VoiceCommand {
  final VoiceCommandType type;
  final Mood? mood;
  final String rawText;

  const VoiceCommand({
    required this.type,
    this.mood,
    required this.rawText,
  });

  @override
  String toString() => 'VoiceCommand(${type.name}, mood: $mood, raw: "$rawText")';
}

enum VoiceCommandType {
  play,
  pause,
  next,
  previous,
  volumeUp,
  volumeDown,
  playMood,
  unknown,
}

extension VoiceCommandInfo on VoiceCommandType {
  String get action {
    switch (this) {
      case VoiceCommandType.play: return 'Playing';
      case VoiceCommandType.pause: return 'Paused';
      case VoiceCommandType.next: return 'Next track';
      case VoiceCommandType.previous: return 'Previous track';
      case VoiceCommandType.volumeUp: return 'Volume up';
      case VoiceCommandType.volumeDown: return 'Volume down';
      case VoiceCommandType.playMood: return 'Playing mood playlist';
      case VoiceCommandType.unknown: return 'Unknown command';
    }
  }
}

class CommandParser {
  static VoiceCommand parse(String text) {
    final lower = text.toLowerCase().trim();

    // Pause / Stop
    if (_matches(lower, ['pause', 'stop', 'halt', 'freeze'])) {
      return VoiceCommand(type: VoiceCommandType.pause, rawText: text);
    }

    // Next
    if (_matches(lower, ['next', 'skip', 'forward', 'next track', 'next song'])) {
      return VoiceCommand(type: VoiceCommandType.next, rawText: text);
    }

    // Previous
    if (_matches(lower, ['previous', 'back', 'last', 'go back', 'prev', 'rewind'])) {
      return VoiceCommand(type: VoiceCommandType.previous, rawText: text);
    }

    // Volume up
    if (_matches(lower, ['volume up', 'louder', 'turn up', 'increase volume', 'more volume'])) {
      return VoiceCommand(type: VoiceCommandType.volumeUp, rawText: text);
    }

    // Volume down
    if (_matches(lower, ['volume down', 'quieter', 'turn down', 'decrease volume', 'less volume', 'softer'])) {
      return VoiceCommand(type: VoiceCommandType.volumeDown, rawText: text);
    }

    // Mood play commands
    final mood = _extractMood(lower);
    if (mood != null) {
      return VoiceCommand(type: VoiceCommandType.playMood, mood: mood, rawText: text);
    }

    // Generic play
    if (_matches(lower, ['play', 'start', 'resume', 'go', 'music'])) {
      return VoiceCommand(type: VoiceCommandType.play, rawText: text);
    }

    return VoiceCommand(type: VoiceCommandType.unknown, rawText: text);
  }

  static bool _matches(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  static Mood? _extractMood(String text) {
    if (!text.contains('play')) return null;

    if (_matches(text, ['happy', 'upbeat', 'cheerful', 'joyful', 'fun'])) return Mood.happy;
    if (_matches(text, ['sad', 'melancholy', 'blue', 'somber', 'emotional'])) return Mood.sad;
    if (_matches(text, ['energetic', 'pump', 'workout', 'fast', 'hype', 'energy'])) return Mood.energetic;
    if (_matches(text, ['calm', 'chill', 'relax', 'sleep', 'peaceful', 'soft'])) return Mood.calm;

    return null;
  }
}