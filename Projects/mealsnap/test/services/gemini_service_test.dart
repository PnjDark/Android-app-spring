import 'package:flutter_test/flutter_test.dart';
import 'package:mealsnap/services/gemini_service.dart';

void main() {
  late GeminiService geminiService;

  setUp(() {
    geminiService = GeminiService('test-api-key');
  });

  group('GeminiService', () {
    test('parseMealResult correctly parses a valid JSON response', () {
      const rawJson = '''
      {
        "meal_name": "Jollof Rice",
        "meal_category": "lunch",
        "confidence": "high",
        "health_rating": "good",
        "portion_size": "Medium (400 g)",
        "dietary_tags": ["spicy"],
        "ingredients": [
          {
            "name": "Rice",
            "estimated_amount": "1 cup",
            "calories": 200,
            "is_major": true
          }
        ],
        "nutrition": {
          "total_calories": 520,
          "protein_g": 28,
          "carbs_g": 55,
          "fat_g": 18,
          "fiber_g": 4,
          "sodium_mg": 680,
          "sugar_g": 6
        }
      }
      ''';

      final result = geminiService.parseMealResult(rawJson);

      expect(result, isA<MealAnalysisResult>());
      expect(result.mealName, 'Jollof Rice');
      expect(result.ingredients.length, 1);
      expect(result.ingredients.first.name, 'Rice');
      expect(result.nutrition.totalCalories, 520);
    });

    test('parseMealResult handles malformed JSON gracefully', () {
      const rawJson = 'this is not a valid json string';

      final result = geminiService.parseMealResult(rawJson);

      expect(result, isA<MealAnalysisResult>());
      expect(result.mealName, 'Parse Error');
      expect(result.parseError, isNotNull);
    });
  });
}
