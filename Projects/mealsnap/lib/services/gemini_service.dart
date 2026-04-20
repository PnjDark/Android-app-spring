import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: const GenerationConfig(
        temperature: 0.1,
        topP: 0.8,
        topK: 40,
      ),
      responseMimeType: 'application/json',  // Force JSON output
    );
  }

  Future<Map<String, dynamic>> analyzeMealImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = DataPart('image/jpeg', imageBytes);

      const prompt = '''
Analyze this food/meal photo. Return ONLY valid JSON matching this EXACT schema:

{
  "estimated_calories": number,
  "confidence": number (0-1),
  "main_ingredients": ["string"],
  "meal_type": "string" (breakfast/lunch/dinner/snack/etc),
  "macros": {
    "protein_g": number,
    "carbs_g": number,
    "fat_g": number,
    "fiber_g": number
  },
  "cuisine": "string" (Western/African/Asian/etc),
  "health_score": number (0-10)
}

Include common African foods like jollof rice, fufu, egusi soup, suya, plantain, moi moi, chin chin, ndole, etc.
Be specific with portion sizes and regional dishes.
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), image])
      ]);

      final text = response.text ?? '{}';
      final data = jsonDecode(text) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {
        'error': 'Gemini analysis failed: $e',
        'estimated_calories': 0,
        'main_ingredients': [],
      };
    }
  }

  Future<Map<String, dynamic>> analyzeIngredientsImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = DataPart('image/jpeg', imageBytes);

      const prompt = '''
Identify ALL ingredients in this fridge/pantry/market photo. Return ONLY valid JSON:

{
  "ingredients": [
    {
      "name": "string",
      "quantity": "string" (e.g. "2 cups", "1kg", "handful"),
      "confidence": number (0-1),
      "state": "string" (raw/cooked/chopped/etc)
    }
  ],
  "suitable_for": ["breakfast", "lunch", "dinner", "dessert"]
}

Include African staples: yam, cassava, plantain, egusi seeds, dried fish, palm oil, etc.
List everything visible.
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), image])
      ]);

      final text = response.text ?? '[]';
      final data = jsonDecode(text) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {
        'error': 'Ingredients analysis failed: $e',
        'ingredients': [],
      };
    }
  }

  Future<Map<String, dynamic>> analyzeReceiptImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = DataPart('image/jpeg', imageBytes);

      const prompt = '''
Extract receipt data. Return ONLY valid JSON:

{
  "store_name": "string",
  "date": "string" (YYYY-MM-DD),
  "items": [
    {
      "name": "string",
      "quantity": number,
      "price_per_unit": number,
      "total_price": number
    }
  ],
  "subtotal": number,
  "tax": number,
  "total": number,
  "currency": "string" (USD, NGN, etc)
}

Focus on food/grocery items only.
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), image])
      ]);

      final text = response.text ?? '{}';
      final data = jsonDecode(text) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {
        'error': 'Receipt analysis failed: $e',
        'items': [],
        'total': 0.0,
      };
    }
  }

  Future<Map<String, dynamic>> analyzeText(String text, String mode) async {
    // Text analysis fallback for voice mode (when implemented)
    const prompt = 'Analyze this food text description and return structured JSON matching meal analysis schema.';
    try {
      final response = await _model.generateContent([Content.text('$prompt\n\n$text')]);
      final jsonText = response.text ?? '{}';
      return jsonDecode(jsonText) as Map<String, dynamic>;
    } catch (e) {
      return {'error': 'Text analysis failed: $e'};
    }
  }
}

