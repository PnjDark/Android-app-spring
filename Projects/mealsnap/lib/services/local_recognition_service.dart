import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LocalRecognitionService {
  final ImageLabeler _imageLabeler;
  final TextRecognizer _textRecognizer;

  // Clean, broad food categories - no duplicates, covers most cases
  static final Set<String> _foodKeywords = {
    // Categories
    'food', 'dish', 'meal', 'vegetable', 'fruit', 'meat', 'fish', 'grain', 'bread', 'pasta',
    'rice', 'soup', 'salad', 'dessert', 'snack', 'beverage', 'drink',
    
    // Proteins
    'chicken', 'beef', 'pork', 'lamb', 'goat', 'fish', 'shrimp', 'egg', 'cheese', 'tofu',
    
    // Carbs
    'rice', 'pasta', 'noodle', 'bread', 'potato', 'yam', 'cassava', 'plantain', 'corn',
    
    // Veggies/Fruits
    'tomato', 'onion', 'lettuce', 'carrot', 'apple', 'banana', 'orange', 'grape',
    
    // African staples
    'jollof', 'fufu', 'egusi', 'moi', 'chin', 'suya', 'plantain', 'yam', 'cassava', 'gari',
    
    // Generic indicators
    'cook', 'eat', 'dinner', 'lunch', 'breakfast', 'ingredient', 'recipe',
  };

  LocalRecognitionService({double confidenceThreshold = 0.5})
      : _imageLabeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: confidenceThreshold),
        ),
        _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<Map<String, dynamic>> recognizeFoodImage(
    File imageFile, {
    required bool ingredientsMode,
  }) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final labels = await _imageLabeler.processImage(inputImage);

    final labelData = labels.map((label) => <String, Object?>{
      'label': label.label.toLowerCase(),
      'confidence': label.confidence,
      'index': label.index,
    }).toList();

    // Filter using broad keywords - more reliable than exact matches
    final foodLabels = labelData.where((item) => _isFoodLabel(item['label'] as String)).toList();

    final selectedLabels = foodLabels.isNotEmpty
        ? foodLabels.take(5).toList()  // Top 5 food labels
        : labelData.take(3).toList();  // Fallback to top 3 any labels

    return {
      'mode': ingredientsMode ? 'ingredients' : 'meal',
      'labels': selectedLabels,
      'all_labels': labelData,
      'food_detected': foodLabels.isNotEmpty,
      'top_labels': selectedLabels.map((l) => l!['label']).take(3).toList(),
    };
  }

  Future<Map<String, dynamic>> recognizeReceiptImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text.trim())
        .where((line) => line.isNotEmpty && line.length > 2)
        .toList();

    // Improved regex for prices and items
    final itemRegex = RegExp(r'^(.+?)\s+[\$£€₦]?(\d+(?:\.\d{2})?)(?:\s+x?\s*(\d+))?$');
    final totalRegex = RegExp(r'(?:total|amount|sum|balance)[:\s]*[\$£€₦]?(\d+(?:\.\d{2})?)', caseSensitive: false);

    final items = <Map<String, dynamic>>[];
    double subtotal = 0.0;
    
    for (final line in lines) {
      final totalMatch = totalRegex.firstMatch(line.toLowerCase());
      if (totalMatch != null) {
        // Total found, skip further processing
        break;
      }

      final itemMatch = itemRegex.firstMatch(line);
      if (itemMatch != null && itemMatch.group(1)!.trim().isNotEmpty) {
        final name = itemMatch.group(1)!.trim();
        final priceStr = itemMatch.group(2)!;
        final qtyStr = itemMatch.group(3);
        final price = double.tryParse(priceStr) ?? 0.0;
        final qty = qtyStr != null ? int.tryParse(qtyStr) ?? 1 : 1;
        
        subtotal += price * qty;
        items.add({
          'name': name,
          'price_per_unit': price,
          'quantity': qty,
          'total_price': price * qty,
        });
      }
    }

    return {
      'mode': 'receipt',
      'items': items,
      'subtotal': subtotal,
      'raw_text': recognizedText.text,
      'line_count': lines.length,
    };
  }

  bool _isFoodLabel(String label) {
    final lowerLabel = label.toLowerCase();
    return _foodKeywords.any((keyword) => lowerLabel.contains(keyword));
  }

  Future<void> dispose() async {
    _imageLabeler.close();
    _textRecognizer.close();
  }
}

