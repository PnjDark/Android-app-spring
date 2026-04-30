import 'dart:convert';
import 'package:http/http.dart' as http;

/// Groq is the sole LLM text layer in MealSnap.
/// Responsibility: interpret and explain — never calculate nutrition.
///
/// Two jobs:
///   1. [mealInsight]  — 1-2 sentence insight shown after a scan is confirmed.
///   2. [enrichReasons] — rewrites suggestion reason strings to be natural and
///                        personalised instead of hardcoded template text.
class GroqService {
  static const _url =
      'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  final String _apiKey;

  GroqService(this._apiKey);

  bool get isConfigured =>
      _apiKey.isNotEmpty && !_apiKey.startsWith('<YOUR_');

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Returns a 1-2 sentence plain-text insight about a confirmed meal.
  /// Focuses on what the numbers mean for the user's goal — never recalculates.
  /// Returns null silently if Groq is unavailable.
  Future<String?> mealInsight({
    required String mealName,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required String healthGoal, // 'lose_weight' | 'gain_muscle' | 'maintain'
  }) async {
    if (!isConfigured) return null;

    final prompt = '''
You are a concise nutrition coach inside a meal tracking app.
The user just logged: "$mealName" ($calories kcal, ${proteinG}g protein, ${carbsG}g carbs, ${fatG}g fat).
Their health goal is: ${_goalLabel(healthGoal)}.

Write exactly 1-2 short sentences that:
- Explain what this meal means for their goal (positive or constructive)
- Are conversational, not clinical
- Never repeat the raw numbers back
- Never use markdown, bullet points, or headers

Reply with only those sentences, nothing else.
''';

    return _call(prompt, maxTokens: 80);
  }

  /// Takes a list of suggestion entries and returns a parallel list of
  /// rewritten reason strings — natural, personalised, concise.
  /// Falls back to the original reasons if Groq is unavailable.
  Future<List<String>> enrichReasons({
    required List<({String foodName, String category, String originalReason})> suggestions,
    required String healthGoal,
  }) async {
    if (!isConfigured || suggestions.isEmpty) {
      return suggestions.map((s) => s.originalReason).toList();
    }

    final items = suggestions
        .asMap()
        .entries
        .map((e) =>
            '${e.key + 1}. ${e.value.foodName} (${e.value.category}): ${e.value.originalReason}')
        .join('\n');

    final prompt = '''
You are a nutrition coach inside a meal tracking app.
The user's health goal is: ${_goalLabel(healthGoal)}.

Below are ${suggestions.length} meal suggestions with their category and a raw reason.
Rewrite each reason into one short, natural, motivating sentence personalised to the user's goal.
Keep the same order. Reply ONLY with a JSON array of strings, e.g. ["reason1","reason2"].
No markdown, no extra text.

$items
''';

    final raw = await _call(prompt, maxTokens: 300);
    if (raw == null) return suggestions.map((s) => s.originalReason).toList();

    try {
      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start == -1 || end <= start) throw FormatException('no array');
      final decoded = jsonDecode(raw.substring(start, end + 1)) as List<dynamic>;
      final result = decoded.map((e) => e.toString()).toList();
      // Safety: if lengths don't match, fall back
      if (result.length != suggestions.length) {
        return suggestions.map((s) => s.originalReason).toList();
      }
      return result;
    } catch (_) {
      return suggestions.map((s) => s.originalReason).toList();
    }
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  Future<String?> _call(String prompt, {required int maxTokens}) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['choices'] as List?)?.first['message']['content']
          as String?;
    } catch (_) {
      return null;
    }
  }

  String _goalLabel(String goal) => switch (goal) {
        'lose_weight' => 'lose weight',
        'gain_muscle' => 'build muscle',
        _ => 'maintain a balanced diet',
      };
}
