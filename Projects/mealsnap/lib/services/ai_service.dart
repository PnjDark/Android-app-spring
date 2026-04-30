import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

// Re-export models so scan_screen import path doesn't change.
export 'gemini_service.dart'
    show
        MealAnalysisResult,
        NutritionBreakdown,
        DetectedIngredient,
        ReceiptAnalysisResult,
        ReceiptItem;

import 'gemini_service.dart';

enum AiProvider { gemini, openAi, claude, groq }

class AiResult {
  final MealAnalysisResult meal;
  final AiProvider provider;
  const AiResult(this.meal, this.provider);
}

/// Unified AI service.
/// Tries providers in order: Gemini → OpenAI → Claude → Groq.
/// Any provider whose key is empty/placeholder is skipped automatically.
class AiService {
  final List<String> _geminiKeys;
  final String _openAiKey;
  final String _claudeKey;
  final String _groqKey;

  int _geminiKeyIndex = 0;

  AiService({
    required List<String> geminiKeys,
    required String openAiKey,
    required String claudeKey,
    required String groqKey,
  })  : _geminiKeys = geminiKeys,
        _openAiKey = openAiKey,
        _claudeKey = claudeKey,
        _groqKey = groqKey;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns the meal result AND which provider succeeded.
  Future<AiResult> analyzeMealImage(File imageFile) async {
    final bytes = await _compressImage(imageFile);
    return _runWithFallbackTracked(
        prompt: GeminiService.mealPrompt, imageBytes: bytes);
  }

  Future<AiResult> analyzeIngredientsImage(File imageFile) async {
    final bytes = await _compressImage(imageFile);
    return _runWithFallbackTracked(
        prompt: GeminiService.ingredientsPrompt, imageBytes: bytes);
  }

  Future<ReceiptAnalysisResult> analyzeReceiptImage(File imageFile) async {
    final bytes = await _compressImage(imageFile, quality: 85);
    final raw = await _runWithFallbackRaw(
      prompt: GeminiService.receiptPrompt,
      imageBytes: bytes,
    );
    return _parseReceipt(raw);
  }

  Future<AiResult> analyzeMealText(String description) async {
    final prompt =
        '${GeminiService.mealTextPreamble}\n\nMeal description: "$description"';
    return _runWithFallbackTracked(prompt: prompt, imageBytes: null);
  }

  // ── Fallback chain ──────────────────────────────────────────────────────────

  Future<AiResult> _runWithFallbackTracked({
    required String prompt,
    required Uint8List? imageBytes,
  }) async {
    final providers = _enabledProviders();
    Exception? lastError;

    for (final provider in providers) {
      try {
        final raw = await _callProvider(
            provider: provider, prompt: prompt, imageBytes: imageBytes);
        return AiResult(_parseMeal(raw), provider);
      } catch (e) {
        lastError = Exception('[$provider] $e');
      }
    }
    throw lastError ?? Exception('All AI providers failed');
  }

  Future<String> _runWithFallbackRaw({
    required String prompt,
    required Uint8List? imageBytes,
  }) async {
    final providers = _enabledProviders();
    Exception? lastError;

    for (final provider in providers) {
      try {
        return await _callProvider(
          provider: provider,
          prompt: prompt,
          imageBytes: imageBytes,
        );
      } catch (e) {
        lastError = Exception('[$provider] $e');
      }
    }
    throw lastError ?? Exception('All AI providers failed');
  }

  List<AiProvider> _enabledProviders() {
    final list = <AiProvider>[];
    if (_geminiKeys.any(_isValidKey)) list.add(AiProvider.gemini);
    if (_isValidKey(_openAiKey)) list.add(AiProvider.openAi);
    if (_isValidKey(_claudeKey)) list.add(AiProvider.claude);
    if (_isValidKey(_groqKey)) list.add(AiProvider.groq);
    return list;
  }

  bool _isValidKey(String key) =>
      key.isNotEmpty && !key.startsWith('<YOUR_');

  // ── Per-provider callers ────────────────────────────────────────────────────

  Future<String> _callProvider({
    required AiProvider provider,
    required String prompt,
    required Uint8List? imageBytes,
  }) {
    switch (provider) {
      case AiProvider.gemini:
        return _callGemini(prompt, imageBytes);
      case AiProvider.openAi:
        return _callOpenAi(prompt, imageBytes);
      case AiProvider.claude:
        return _callClaude(prompt, imageBytes);
      case AiProvider.groq:
        return _callGroq(prompt, imageBytes);
    }
  }

  // ── Gemini ──────────────────────────────────────────────────────────────────

  Future<String> _callGemini(String prompt, Uint8List? imageBytes) async {
    final validKeys = _geminiKeys.where(_isValidKey).toList();
    Exception? last;

    for (var i = 0; i < validKeys.length; i++) {
      final key = validKeys[_geminiKeyIndex % validKeys.length];
      try {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: key,
          generationConfig: GenerationConfig(temperature: 0.1),
        );
        final parts = <Part>[TextPart(prompt)];
        if (imageBytes != null) parts.add(DataPart('image/jpeg', imageBytes));
        final response = await model
            .generateContent([Content.multi(parts)])
            .timeout(const Duration(seconds: 9));
        return response.text ?? '';
      } catch (e) {
        last = Exception(e.toString());
        _geminiKeyIndex = (_geminiKeyIndex + 1) % validKeys.length;
      }
    }
    throw last ?? Exception('Gemini failed');
  }

  // ── OpenAI ──────────────────────────────────────────────────────────────────

  Future<String> _callOpenAi(String prompt, Uint8List? imageBytes) async {
    final content = <Map<String, dynamic>>[
      {'type': 'text', 'text': prompt},
      if (imageBytes != null)
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,${base64Encode(imageBytes)}',
            'detail': 'low',
          },
        },
    ];

    final response = await http
        .post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_openAiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': [
              {'role': 'user', 'content': content},
            ],
            'max_tokens': 1024,
            'temperature': 0.1,
          }),
        )
        .timeout(const Duration(seconds: 9));

    _assertOk(response, 'OpenAI');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  // ── Claude ──────────────────────────────────────────────────────────────────

  Future<String> _callClaude(String prompt, Uint8List? imageBytes) async {
    final content = <Map<String, dynamic>>[];
    if (imageBytes != null) {
      content.add({
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': 'image/jpeg',
          'data': base64Encode(imageBytes),
        },
      });
    }
    content.add({'type': 'text', 'text': prompt});

    final response = await http
        .post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'x-api-key': _claudeKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'claude-3-haiku-20240307',
            'max_tokens': 1024,
            'messages': [
              {'role': 'user', 'content': content},
            ],
          }),
        )
        .timeout(const Duration(seconds: 9));

    _assertOk(response, 'Claude');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['content'] as List).first['text'] as String;
  }

  // ── Groq ────────────────────────────────────────────────────────────────────

  Future<String> _callGroq(String prompt, Uint8List? imageBytes) async {
    final content = <Map<String, dynamic>>[
      {'type': 'text', 'text': prompt},
      if (imageBytes != null)
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,${base64Encode(imageBytes)}',
          },
        },
    ];

    final response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_groqKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'llama-3.2-11b-vision-preview',
            'messages': [
              {'role': 'user', 'content': content},
            ],
            'max_tokens': 1024,
            'temperature': 0.1,
          }),
        )
        .timeout(const Duration(seconds: 9));

    _assertOk(response, 'Groq');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _assertOk(http.Response response, String provider) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          '$provider HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Parsers are pure JSON functions — no API key needed.
  MealAnalysisResult _parseMeal(String raw) =>
      _sharedParser.parseMealResult(raw);

  ReceiptAnalysisResult _parseReceipt(String raw) =>
      _sharedParser.parseReceiptResult(raw);

  // Single parser instance with a dummy key — only used for JSON parsing.
  static final _sharedParser = GeminiService('_parser_only_');

  static Future<Uint8List> _compressImage(File file, {int quality = 75}) async {
    final bytes = await file.readAsBytes();
    return compute(_compressBytes, _CompressArgs(bytes, quality));
  }

  static Uint8List _compressBytes(_CompressArgs args) {
    final decoded = img.decodeImage(args.bytes);
    if (decoded == null) return args.bytes;
    final resized = decoded.width > decoded.height
        ? img.copyResize(decoded, width: 800)
        : img.copyResize(decoded, height: 800);
    return Uint8List.fromList(img.encodeJpg(resized, quality: args.quality));
  }
}

class _CompressArgs {
  final Uint8List bytes;
  final int quality;
  const _CompressArgs(this.bytes, this.quality);
}
