import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> analyzeMealImage(File imageFile, String mode) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = DataPart('image/jpeg', imageBytes);

      String prompt;
      switch (mode) {
        case 'meal':
          prompt = 'Analyze this meal image and provide: 1. Estimated calories, 2. Main ingredients, 3. Nutritional breakdown (protein, carbs, fat), 4. Meal type/category. Format as JSON.';
          break;
        case 'ingredients':
          prompt = 'Identify all visible ingredients in this image. List them with quantities if possible. Format as JSON array.';
          break;
        case 'receipt':
          prompt = 'Extract all food items, prices, and total from this receipt. Format as JSON with items array and total.';
          break;
        default:
          prompt = 'Describe what you see in this food-related image.';
      }

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), image])
      ]);

      return response.text ?? 'No analysis available';
    } catch (e) {
      return 'Error analyzing image: $e';
    }
  }

  Future<String> analyzeText(String text, String mode) async {
    try {
      String prompt;
      switch (mode) {
        case 'meal':
          prompt = 'Analyze this meal description and provide: 1. Estimated calories, 2. Main ingredients, 3. Nutritional breakdown. Format as JSON.';
          break;
        case 'ingredients':
          prompt = 'Parse this ingredient list and provide structured data. Format as JSON.';
          break;
        case 'receipt':
          prompt = 'Parse this receipt text and extract items and totals. Format as JSON.';
          break;
        default:
          prompt = 'Summarize this food-related text.';
      }

      final response = await _model.generateContent([
        Content.text('$prompt\n\nText: $text')
      ]);

      return response.text ?? 'No analysis available';
    } catch (e) {
      return 'Error analyzing text: $e';
    }
  }
}