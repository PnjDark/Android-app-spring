import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

// -----------------------------------------------------------------------------
// Data models returned by GeminiService
// -----------------------------------------------------------------------------

class DetectedIngredient {
  final String name;
  final String estimatedAmount;
  final double calories;
  final bool isMajor;

  const DetectedIngredient({
    required this.name,
    required this.estimatedAmount,
    required this.calories,
    required this.isMajor,
  });

  factory DetectedIngredient.fromJson(Map<String, dynamic> j) =>
      DetectedIngredient(
        name: (j['name'] as String?) ?? 'Unknown',
        estimatedAmount: (j['estimated_amount'] as String?) ?? '',
        calories: (j['calories'] as num?)?.toDouble() ?? 0,
        isMajor: (j['is_major'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'estimated_amount': estimatedAmount,
        'calories': calories,
        'is_major': isMajor,
      };
}

class NutritionBreakdown {
  final double totalCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sodiumMg;
  final double sugarG;

  const NutritionBreakdown({
    required this.totalCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sodiumMg,
    required this.sugarG,
  });

  factory NutritionBreakdown.empty() => const NutritionBreakdown(
        totalCalories: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        fiberG: 0,
        sodiumMg: 0,
        sugarG: 0,
      );

  factory NutritionBreakdown.fromJson(Map<String, dynamic> j) =>
      NutritionBreakdown(
        totalCalories: (j['total_calories'] as num?)?.toDouble() ?? 0,
        proteinG: (j['protein_g'] as num?)?.toDouble() ?? 0,
        carbsG: (j['carbs_g'] as num?)?.toDouble() ?? 0,
        fatG: (j['fat_g'] as num?)?.toDouble() ?? 0,
        fiberG: (j['fiber_g'] as num?)?.toDouble() ?? 0,
        sodiumMg: (j['sodium_mg'] as num?)?.toDouble() ?? 0,
        sugarG: (j['sugar_g'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'total_calories': totalCalories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'sodium_mg': sodiumMg,
        'sugar_g': sugarG,
      };
}

class MealAnalysisResult {
  final String mealName;
  final String mealCategory;
  final String confidence; // 'high' | 'medium' | 'low'
  final String healthRating; // 'excellent' | 'good' | 'moderate' | 'poor'
  final String portionSize;
  final List<String> dietaryTags;
  final List<DetectedIngredient> ingredients;
  final NutritionBreakdown nutrition;
  final String? parseError;

  const MealAnalysisResult({
    required this.mealName,
    required this.mealCategory,
    required this.confidence,
    required this.healthRating,
    required this.portionSize,
    required this.dietaryTags,
    required this.ingredients,
    required this.nutrition,
    this.parseError,
  });

  /// Names of major ingredients -- shown as overlay tags in the scan viewfinder.
  List<String> get majorIngredientNames =>
      ingredients.where((i) => i.isMajor).map((i) => i.name).toList();

  Map<String, dynamic> toJson() => {
        'meal_name': mealName,
        'meal_category': mealCategory,
        'confidence': confidence,
        'health_rating': healthRating,
        'portion_size': portionSize,
        'dietary_tags': dietaryTags,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'nutrition': nutrition.toJson(),
        if (parseError != null) 'parse_error': parseError,
      };
}

class ReceiptItem {
  final String name;
  final double price;
  final int? quantity;
  final bool isFood;

  const ReceiptItem({
    required this.name,
    required this.price,
    this.quantity,
    required this.isFood,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> j) => ReceiptItem(
        name: (j['name'] as String?) ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        quantity: j['quantity'] as int?,
        isFood: (j['is_food'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        if (quantity != null) 'quantity': quantity,
        'is_food': isFood,
      };
}

class ReceiptAnalysisResult {
  final List<ReceiptItem> items;
  final double? subtotal;
  final double? tax;
  final double? total;
  final String? storeName;
  final String? date;

  const ReceiptAnalysisResult({
    required this.items,
    this.subtotal,
    this.tax,
    this.total,
    this.storeName,
    this.date,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        if (subtotal != null) 'subtotal': subtotal,
        if (tax != null) 'tax': tax,
        if (total != null) 'total': total,
        if (storeName != null) 'store_name': storeName,
        if (date != null) 'date': date,
      };
}

// -----------------------------------------------------------------------------
// GeminiService
// -----------------------------------------------------------------------------

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      // Low temperature -> more deterministic, structured output.
      generationConfig: GenerationConfig(
        temperature: 0.1,
      ),
    );
  }

  // -- Public API --------------------------------------------------------------

  /// Analyse a meal photo.
  Future<MealAnalysisResult> analyzeMealImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = DataPart('image/jpeg', bytes);
    const prompt = _mealPrompt;
    return _runMealRequest([Content.multi([TextPart(prompt), image])]);
  }

  /// Identify raw ingredients from a photo.
  Future<MealAnalysisResult> analyzeIngredientsImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = DataPart('image/jpeg', bytes);
    const prompt = _ingredientsPrompt;
    return _runMealRequest([Content.multi([TextPart(prompt), image])]);
  }

  /// OCR + parse a receipt photo.
  Future<ReceiptAnalysisResult> analyzeReceiptImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = DataPart('image/jpeg', bytes);
    const prompt = _receiptPrompt;
    return _runReceiptRequest([Content.multi([TextPart(prompt), image])]);
  }

  /// Analyse a meal from a text description (e.g. voice input).
  Future<MealAnalysisResult> analyzeMealText(String description) async {
    final prompt = '$_mealTextPreamble\n\nMeal description: "$description"';
    return _runMealRequest([Content.text(prompt)]);
  }

  // -- Private runners ---------------------------------------------------------

  Future<MealAnalysisResult> _runMealRequest(
      List<Content> contents) async {
    final raw = await _generate(contents);
    return _parseMealResult(raw);
  }

  Future<ReceiptAnalysisResult> _runReceiptRequest(
      List<Content> contents) async {
    final raw = await _generate(contents);
    return _parseReceiptResult(raw);
  }

  Future<String> _generate(List<Content> contents) async {
    try {
      final response = await _model.generateContent(contents);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Gemini API error: $e');
    }
  }

  // -- Parsers -----------------------------------------------------------------

  MealAnalysisResult _parseMealResult(String raw) {
    try {
      final json = _extractJson(raw);
      final ingredients = (json['ingredients'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DetectedIngredient.fromJson)
          .toList();
      final nutrition = NutritionBreakdown.fromJson(
          (json['nutrition'] as Map<String, dynamic>?) ?? {});

      return MealAnalysisResult(
        mealName: (json['meal_name'] as String?) ?? 'Unknown Meal',
        mealCategory: (json['meal_category'] as String?) ?? 'meal',
        confidence: (json['confidence'] as String?) ?? 'low',
        healthRating: (json['health_rating'] as String?) ?? 'moderate',
        portionSize: (json['portion_size'] as String?) ?? 'Unknown',
        dietaryTags: (json['dietary_tags'] as List<dynamic>? ?? [])
            .map((t) => t.toString())
            .toList(),
        ingredients: ingredients,
        nutrition: nutrition,
      );
    } catch (e) {
      // Return a graceful fallback so the UI never crashes.
      return MealAnalysisResult(
        mealName: 'Parse Error',
        mealCategory: 'unknown',
        confidence: 'low',
        healthRating: 'moderate',
        portionSize: 'Unknown',
        dietaryTags: const [],
        ingredients: const [],
        nutrition: NutritionBreakdown.empty(),
        parseError: 'Failed to parse Gemini response: $e\n\nRaw: $raw',
      );
    }
  }

  ReceiptAnalysisResult _parseReceiptResult(String raw) {
    try {
      final json = _extractJson(raw);
      final items = (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ReceiptItem.fromJson)
          .toList();
      return ReceiptAnalysisResult(
        items: items,
        subtotal: (json['subtotal'] as num?)?.toDouble(),
        tax: (json['tax'] as num?)?.toDouble(),
        total: (json['total'] as num?)?.toDouble(),
        storeName: json['store_name'] as String?,
        date: json['date'] as String?,
      );
    } catch (e) {
      return const ReceiptAnalysisResult(items: []);
    }
  }

  /// Strips markdown fences and extracts the outermost JSON object.
  Map<String, dynamic> _extractJson(String raw) {
    String s = raw
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();

    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end > start) {
      s = s.substring(start, end + 1);
    }

    return jsonDecode(s) as Map<String, dynamic>;
  }

  // -- Prompt constants --------------------------------------------------------

  static const _mealPrompt = '''
You are a professional nutritionist and food-recognition AI with expertise in \
African, Asian, Western, and Latin cuisines.

Analyse this meal photo and respond ONLY with a single JSON object that \
matches the schema below -- no preamble, no markdown, no extra text.

{
  "meal_name": "Most likely dish name, e.g. Jollof Rice, Ndole, Egusi Soup, Spaghetti Bolognese",
  "meal_category": "One of: breakfast | lunch | dinner | snack | drink | dessert",
  "confidence": "One of: high | medium | low",
  "health_rating": "One of: excellent | good | moderate | poor",
  "portion_size": "Estimated size, e.g. Small (200 g) | Medium (400 g) | Large (600 g)",
  "dietary_tags": ["vegan","vegetarian","gluten-free","dairy-free","high-protein","low-carb","halal","spicy"],
  "ingredients": [
    {
      "name": "Precise name, e.g. Roma tomato, Boneless chicken thigh",
      "estimated_amount": "e.g. 150 g | 2 tbsp | 1 cup",
      "calories": 120,
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

Rules:
- Identify regional dishes precisely -- never fall back to "rice and stew" when \
  "Jollof Rice" or "Thieboudienne" is correct.
- List EVERY visible ingredient, mark top 3-4 as is_major:true.
- If multiple dishes are visible, analyse the main dish; list sides in ingredients.
- All numeric fields must be numbers, never strings.
- dietary_tags must only include tags that actually apply.
''';

  static const _ingredientsPrompt = '''
You are an expert chef and food scientist with global cuisine knowledge.

Identify ALL visible ingredients or food items in this image and respond ONLY \
with a single JSON object -- no preamble, no markdown, no extra text.

{
  "meal_name": "Describe what you see, e.g. Raw Chicken with Aromatics | Assorted Market Vegetables",
  "meal_category": "ingredients",
  "confidence": "One of: high | medium | low",
  "health_rating": "One of: excellent | good | moderate | poor",
  "portion_size": "Total estimated weight / volume of all items",
  "dietary_tags": ["applicable tags for the overall collection"],
  "ingredients": [
    {
      "name": "Specific name, e.g. Scotch bonnet pepper | Ripe plantain | Crayfish",
      "estimated_amount": "e.g. 3 pieces | 200 g | 2 tbsp",
      "calories": 45,
      "is_major": true
    }
  ],
  "nutrition": {
    "total_calories": 0,
    "protein_g": 0,
    "carbs_g": 0,
    "fat_g": 0,
    "fiber_g": 0,
    "sodium_mg": 0,
    "sugar_g": 0
  }
}

Rules:
- List EVERY distinct ingredient visible, even background items.
- Be culturally specific: "egusi seeds", "uziza leaf", "suya spice blend" etc.
- Mark the 3 most dominant ingredients as is_major:true.
- All numeric fields must be numbers.
''';

  static const _receiptPrompt = '''
You are a receipt OCR and data-extraction expert.

Extract all information from this receipt image and respond ONLY with a single \
JSON object -- no preamble, no markdown, no extra text.

{
  "store_name": "Store or restaurant name, or null",
  "date": "Date string if visible, or null",
  "items": [
    {
      "name": "Item name exactly as printed",
      "price": 4.99,
      "quantity": 2,
      "is_food": true
    }
  ],
  "subtotal": 18.50,
  "tax": 1.48,
  "total": 19.98
}

Rules:
- Extract EVERY line item, including non-food items.
- price must be a number (e.g. 4.99), never a string.
- quantity is an integer or null if not listed.
- is_food is true for any food or beverage item.
- subtotal / tax / total are numbers or null if not found.
''';

  static const _mealTextPreamble = '''
You are a professional nutritionist.
Analyse the user's meal description and respond ONLY with a single JSON \
object -- no preamble, no markdown, no extra text.

{
  "meal_name": "string",
  "meal_category": "breakfast | lunch | dinner | snack | drink | dessert",
  "confidence": "high | medium | low",
  "health_rating": "excellent | good | moderate | poor",
  "portion_size": "string",
  "dietary_tags": [],
  "ingredients": [
    {"name":"string","estimated_amount":"string","calories":0,"is_major":true}
  ],
  "nutrition": {
    "total_calories":0,"protein_g":0,"carbs_g":0,"fat_g":0,
    "fiber_g":0,"sodium_mg":0,"sugar_g":0
  }
}

Rules:
- Infer reasonable portion sizes if not stated.
- All numeric fields must be numbers.
''';
}
