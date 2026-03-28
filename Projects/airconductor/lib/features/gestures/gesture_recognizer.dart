/// Recognized hand gestures
enum Gesture {
  none,
  peace,      // ✌️ → Play/Pause
  thumbsUp,   // 👍 → Next
  thumbsDown, // 👎 → Previous
  openHand,   // 🖐  → Volume Up
  fist,       // ✊ → Volume Down
}

extension GestureInfo on Gesture {
  String get emoji {
    switch (this) {
      case Gesture.peace: return '✌️';
      case Gesture.thumbsUp: return '👍';
      case Gesture.thumbsDown: return '👎';
      case Gesture.openHand: return '🖐';
      case Gesture.fist: return '✊';
      case Gesture.none: return '—';
    }
  }

  String get label {
    switch (this) {
      case Gesture.peace: return 'Peace Sign';
      case Gesture.thumbsUp: return 'Thumbs Up';
      case Gesture.thumbsDown: return 'Thumbs Down';
      case Gesture.openHand: return 'Open Hand';
      case Gesture.fist: return 'Fist';
      case Gesture.none: return 'None';
    }
  }

  String get action {
    switch (this) {
      case Gesture.peace: return 'Play / Pause';
      case Gesture.thumbsUp: return 'Next Track';
      case Gesture.thumbsDown: return 'Previous Track';
      case Gesture.openHand: return 'Volume Up';
      case Gesture.fist: return 'Volume Down';
      case Gesture.none: return '';
    }
  }
}

/// ML Kit landmark indices for hand pose
class HandLandmarkIndex {
  static const wrist = 0;
  static const thumbCmc = 1;
  static const thumbMcp = 2;
  static const thumbIp = 3;
  static const thumbTip = 4;
  static const indexMcp = 5;
  static const indexPip = 6;
  static const indexDip = 7;
  static const indexTip = 8;
  static const middleMcp = 9;
  static const middlePip = 10;
  static const middleDip = 11;
  static const middleTip = 12;
  static const ringMcp = 13;
  static const ringPip = 14;
  static const ringDip = 15;
  static const ringTip = 16;
  static const pinkyMcp = 17;
  static const pinkyPip = 18;
  static const pinkyDip = 19;
  static const pinkyTip = 20;
}

/// Recognizes gestures from ML Kit pose landmarks
class GestureRecognizer {
  /// Analyze a list of [PoseLandmark] y/x values and return detected gesture.
  /// landmarks: map of landmarkIndex → {x, y, z, likelihood}
  static Gesture recognize(Map<int, Map<String, double>> landmarks) {
    if (landmarks.isEmpty) return Gesture.none;

    final fingerStates = _getFingerStates(landmarks);
    if (fingerStates == null) return Gesture.none;

    final thumbUp = fingerStates['thumb'] ?? false;
    final indexUp = fingerStates['index'] ?? false;
    final middleUp = fingerStates['middle'] ?? false;
    final ringUp = fingerStates['ring'] ?? false;
    final pinkyUp = fingerStates['pinky'] ?? false;

    // Peace: index + middle up, others down
    if (indexUp && middleUp && !ringUp && !pinkyUp) {
      return Gesture.peace;
    }

    // Open hand: all fingers up
    if (indexUp && middleUp && ringUp && pinkyUp) {
      return Gesture.openHand;
    }

    // Fist: all fingers down
    if (!indexUp && !middleUp && !ringUp && !pinkyUp) {
      final thumbDir = _thumbDirection(landmarks);
      if (thumbDir == 'up') return Gesture.thumbsUp;
      if (thumbDir == 'down') return Gesture.thumbsDown;
      return Gesture.fist;
    }

    return Gesture.none;
  }

  static Map<String, bool>? _getFingerStates(Map<int, Map<String, double>> lm) {
    try {
      bool isFingerUp(int mcp, int pip, int tip) {
        final mcpY = lm[mcp]!['y']!;
        final tipY = lm[tip]!['y']!;
        return tipY < mcpY; // In image coords, lower y = higher on screen
      }

      return {
        'index': isFingerUp(HandLandmarkIndex.indexMcp, HandLandmarkIndex.indexPip, HandLandmarkIndex.indexTip),
        'middle': isFingerUp(HandLandmarkIndex.middleMcp, HandLandmarkIndex.middlePip, HandLandmarkIndex.middleTip),
        'ring': isFingerUp(HandLandmarkIndex.ringMcp, HandLandmarkIndex.ringPip, HandLandmarkIndex.ringTip),
        'pinky': isFingerUp(HandLandmarkIndex.pinkyMcp, HandLandmarkIndex.pinkyPip, HandLandmarkIndex.pinkyTip),
      };
    } catch (_) {
      return null;
    }
  }

  static String _thumbDirection(Map<int, Map<String, double>> lm) {
    try {
      final wristY = lm[HandLandmarkIndex.wrist]!['y']!;
      final thumbTipY = lm[HandLandmarkIndex.thumbTip]!['y']!;
      final thumbMcpY = lm[HandLandmarkIndex.thumbMcp]!['y']!;
      final delta = thumbTipY - thumbMcpY;
      if (delta < -0.05) return 'up';
      if (delta > 0.05) return 'down';
      return 'neutral';
    } catch (_) {
      return 'neutral';
    }
  }
}