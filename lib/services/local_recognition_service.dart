import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Raw result from ML Kit -- used as a fast pre-pass before Gemini.
class LocalLabelResult {
  final List<Map<String, dynamic>> foodLabels;
  final List<Map<String, dynamic>> allLabels;

  const LocalLabelResult({
    required this.foodLabels,
    required this.allLabels,
  });
}

class LocalRecognitionService {
  late final ImageLabeler _imageLabeler;
  late final TextRecognizer _textRecognizer;

  LocalRecognitionService({double confidenceThreshold = 0.45})
      : _imageLabeler = ImageLabeler(
          options: ImageLabelerOptions(
            confidenceThreshold: confidenceThreshold,
          ),
        ),
        _textRecognizer = TextRecognizer(
          script: TextRecognitionScript.latin,
        );

  // -- Public API --------------------------------------------------------------

  /// Returns ML Kit labels for a food/ingredients photo.
  /// The result is used by ScanScreen to build the initial overlay tags
  /// while Gemini is still running in the background.
  Future<LocalLabelResult> recognizeFoodImage(File imageFile) async {
    final input = InputImage.fromFilePath(imageFile.path);
    final labels = await _imageLabeler.processImage(input);

    final all = labels
        .map((l) => <String, dynamic>{
              'label': l.label,
              'confidence': l.confidence,
            })
        .toList();

    final food = all
        .where((item) => _isFoodRelated(item['label'] as String))
        .toList()
      ..sort((a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double));

    // If food filter is too aggressive, fall back to top-5 overall labels.
    final chosen = food.isNotEmpty ? food : all.take(5).toList();

    return LocalLabelResult(foodLabels: chosen, allLabels: all);
  }

  /// OCR a receipt image; returns raw text lines for Gemini to parse.
  Future<String> recognizeReceiptText(File imageFile) async {
    final input = InputImage.fromFilePath(imageFile.path);
    final result = await _textRecognizer.processImage(input);
    return result.text;
  }

  Future<void> dispose() async {
    _imageLabeler.close();
    _textRecognizer.close();
  }

  // -- Food label classifier ----------------------------------------------------
  //
  // ML Kit labels are broad (e.g. "Food", "Ingredient", "Dish", "Fruit").
  // We cast a wide net so we don't accidentally hide valid food labels.
  // Gemini does the precise identification -- this is just a coarse filter.

  static const _foodCategories = <String>{
    // ML Kit top-level categories
    'food', 'dish', 'meal', 'cuisine', 'ingredient', 'recipe',
    'drink', 'beverage', 'snack', 'dessert', 'produce',

    // Cooking & serving
    'plate', 'bowl', 'cup', 'glass', 'pot', 'pan', 'grill',
    'roast', 'fried', 'baked', 'steamed', 'boiled', 'raw',

    // Protein
    'meat', 'chicken', 'beef', 'pork', 'lamb', 'goat', 'fish',
    'seafood', 'shrimp', 'prawn', 'crab', 'lobster', 'egg',
    'tofu', 'legume', 'bean', 'lentil', 'pea',

    // Grains & starch
    'rice', 'pasta', 'bread', 'noodle', 'flour', 'wheat',
    'corn', 'maize', 'oat', 'barley', 'cassava', 'yam',
    'potato', 'plantain', 'fufu', 'ugali',

    // Vegetables
    'vegetable', 'salad', 'tomato', 'onion', 'pepper', 'garlic',
    'carrot', 'lettuce', 'spinach', 'kale', 'okra', 'mushroom',
    'eggplant', 'zucchini', 'broccoli', 'cabbage', 'celery',

    // Fruit
    'fruit', 'apple', 'banana', 'mango', 'orange', 'lemon',
    'lime', 'pineapple', 'avocado', 'coconut', 'papaya', 'guava',
    'watermelon', 'grape', 'strawberry', 'berry',

    // Dairy & fat
    'cheese', 'milk', 'cream', 'butter', 'yogurt', 'dairy',
    'oil', 'sauce', 'gravy', 'soup', 'stew', 'curry', 'broth',

    // Baked / sweet
    'cake', 'cookie', 'pastry', 'donut', 'waffle', 'pancake',
    'chocolate', 'candy', 'sugar', 'honey', 'jam',

    // African / regional
    'jollof', 'ndole', 'egusi', 'eru', 'suya', 'kilishi',
    'puff', 'akara', 'moi', 'chin', 'waakye', 'banku', 'kenkey',
    'injera', 'tibs', 'doro', 'berbere', 'baobab',
  };

  bool _isFoodRelated(String label) {
    final lower = label.toLowerCase();
    return _foodCategories.any((kw) => lower.contains(kw));
  }
}
