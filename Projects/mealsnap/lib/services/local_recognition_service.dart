import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LocalRecognitionService {
  final ImageLabeler _imageLabeler;
  final TextRecognizer _textRecognizer;

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

    final labelData = labels.map((label) {
      return <String, Object?>{
        'label': label.label,
        'confidence': label.confidence,
        'index': label.index,
      };
    }).toList();

    final filtered = labelData.where((item) {
      final label = (item['label'] as String).toLowerCase();
      return _isFoodLabel(label);
    }).toList();

    final selectedLabels = filtered.isNotEmpty
        ? filtered
        : labelData.take(6).toList();

    return {
      'mode': ingredientsMode ? 'ingredients' : 'meal',
      'labels': selectedLabels,
      'raw_labels': labelData,
    };
  }

  Future<Map<String, dynamic>> recognizeReceiptImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final items = <Map<String, Object>>[];
    String? total;
    final itemPattern = RegExp(r'^(.+?)\s+\$?([0-9]+(?:\.[0-9]{1,2})?)$');
    final totalPattern = RegExp(r'total[:\s]*\$?([0-9]+(?:\.[0-9]{1,2})?)', caseSensitive: false);

    for (final line in lines) {
      final lower = line.toLowerCase();
      final totalMatch = totalPattern.firstMatch(lower);
      if (totalMatch != null) {
        total = totalMatch.group(1)?.trim();
      }

      final itemMatch = itemPattern.firstMatch(line);
      if (itemMatch != null) {
        final name = itemMatch.group(1)?.trim() ?? '';
        final price = double.tryParse(itemMatch.group(2) ?? '0') ?? 0.0;
        items.add({'name': name, 'price': price});
      }
    }

    return {
      'mode': 'receipt',
      'items': items,
      'total': total,
      'raw_text': recognizedText.text,
      'lines': lines,
    };
  }

  bool _isFoodLabel(String label) {
    const foodKeywords = [
      // Common Western foods
      'apple', 'banana', 'bread', 'cheese', 'chicken', 'pizza', 'burger',
      'salad', 'soup', 'rice', 'pasta', 'egg', 'fish', 'steak', 'sandwich',
      'sushi', 'coffee', 'cake', 'pancake', 'fruit', 'vegetable', 'meat',
      'tomato', 'onion', 'potato', 'carrot', 'lettuce', 'curry', 'noodle',
      'waffle', 'donut', 'beans', 'taco',

      // African dishes and ingredients
      'jollof', 'rice', 'ndole', 'eru', 'fufu', 'plantain', 'egusi', 'soup',
      'palm', 'oil', 'cassava', 'yam', 'cocoyam', 'gari', 'eba', 'pounded',
      'akara', 'moi', 'moi', 'moi', 'chin', 'chin', 'chin', 'suya', 'kilishi',
      'puff', 'puff', 'meat', 'pie', 'roti', 'chapati', 'ugali', 'nsima',
      'sadza', 'banku', 'kenkey', 'waakye', 'jute', 'leaves', 'bitter', 'leaf',
      'okra', 'soup', 'groundnut', 'soup', 'peanut', 'stew', 'maize', 'corn',
      'millet', 'sorghum', 'teff', 'injera', 'tibs', 'doro', 'wat', 'lentils',
      'chickpeas', 'peas', 'beans', 'okra', 'tomatoes', 'peppers', 'onions',
      'garlic', 'ginger', 'cumin', 'coriander', 'cardamom', 'cloves', 'turmeric',
      'curry', 'powder', 'berbere', 'mitmita', 'niter', 'kibe', 'goat', 'lamb',
      'beef', 'chicken', 'fish', 'tilapia', 'catfish', 'shrimp', 'lobster',
      'coconut', 'mango', 'pineapple', 'banana', 'orange', 'lemon', 'lime',
      'avocado', 'pawpaw', 'papaya', 'guava', 'passion', 'fruit', 'cashew',
      'peanut', 'groundnut', 'sesame', 'flaxseed', 'chia', 'quinoa', 'amaranth',
      'fonio', 'millet', 'sorghum', 'teff', 'wheat', 'barley', 'oats', 'rye',
      'corn', 'maize', 'cassava', 'yam', 'sweet', 'potato', 'taro', 'cocoyam',
      'plantain', 'banana', 'breadfruit', 'jackfruit', 'durian', 'rambutan',
      'lychee', 'longan', 'mangosteen', 'salak', 'snake', 'fruit', 'dragon',
      'fruit', 'starfruit', 'carambola', 'tamarind', 'baobab', 'hibiscus',
      'kola', 'nut', 'alligator', 'pepper', 'grains', 'of', 'paradise',
      'african', 'potash', 'potassium', 'bicarbonate', 'baking', 'soda',
      'palm', 'wine', 'sorghum', 'beer', 'pito', 'burukutu', 'ogogoro',
      'akpeteshie', 'local', 'gin', 'kunu', 'zobo', 'sobolo', 'bissap',
      'ginger', 'beer', 'malt', 'drink', 'fanta', 'coke', 'pepsi', 'sprite',
      'mineral', 'water', 'pure', 'water', 'bottled', 'water', 'sachet', 'water',
    ];
    return foodKeywords.any((keyword) => label.toLowerCase().contains(keyword));
  }

  Future<void> dispose() async {
    _imageLabeler.close();
    _textRecognizer.close();
  }
}
