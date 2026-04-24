import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Raw result from the local model -- used as a fast pre-pass before Gemini.
class LocalLabelResult {
  final List<Map<String, dynamic>> foodLabels;
  final List<Map<String, dynamic>> allLabels;

  const LocalLabelResult({
    required this.foodLabels,
    required this.allLabels,
  });
}

class LocalRecognitionService {
  Interpreter? _interpreter;
  List<String>? _labels;
  late final TextRecognizer _textRecognizer;

  LocalRecognitionService() {
    _loadModel();
    _textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
  }

  LocalRecognitionService.test(this._interpreter) {
    _loadLabels();
    _textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
  }

  Future<void> _loadModel() async {
    try {
      _loadLabels();
      _interpreter = await Interpreter.fromAsset('assets/ai/food_classifier.tflite');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _loadLabels() async {
      final labelsData = await rootBundle.loadString('assets/ai/food_labels.txt');
      _labels = labelsData.split('\n');
  }

  Future<LocalLabelResult> recognizeFoodImage(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      return const LocalLabelResult(foodLabels: [], allLabels: []);
    }

    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      return const LocalLabelResult(foodLabels: [], allLabels: []);
    }

    // Resize the image to the model's input size
    final inputImage = img.copyResize(originalImage, width: 224, height: 224);

    // Convert the image to a byte buffer
    final input = _imageToByteList(inputImage);

    // Define the output
    var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

    // Run inference
    _interpreter!.run(input, output);

    // Process the output
    final results = output[0] as List<double>;
    final List<Map<String, dynamic>> all = [];
    for (var i = 0; i < results.length; i++) {
      if (results[i] > 0.1) { // Confidence threshold
        all.add({
          'label': _labels![i],
          'confidence': results[i],
        });
      }
    }

    all.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

    return LocalLabelResult(foodLabels: all.take(5).toList(), allLabels: all);
  }

  ByteBuffer _imageToByteList(img.Image image) {
    var buffer = ByteData(1 * 224 * 224 * 3);
    var bufferIndex = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        var pixel = image.getPixel(x, y);
        buffer.setUint8(bufferIndex++, pixel.r.toInt());
        buffer.setUint8(bufferIndex++, pixel.g.toInt());
        buffer.setUint8(bufferIndex++, pixel.b.toInt());
      }
    }
    return buffer.buffer;
  }

  Future<String> recognizeReceiptText(File imageFile) async {
    final input = InputImage.fromFilePath(imageFile.path);
    final result = await _textRecognizer.processImage(input);
    return result.text;
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _textRecognizer.close();
  }
}
