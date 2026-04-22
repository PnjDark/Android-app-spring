import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealsnap/services/local_recognition_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'local_recognition_service_test.mocks.dart';

// A minimal valid JPEG image (a single red pixel).
final Uint8List minimalValidJpeg = Uint8List.fromList([
  0xff,
  0xd8,
  0xff,
  0xe0,
  0x00,
  0x10,
  0x4a,
  0x46,
  0x49,
  0x46,
  0x00,
  0x01,
  0x01,
  0x01,
  0x00,
  0x48,
  0x00,
  0x48,
  0x00,
  0x00,
  0xff,
  0xdb,
  0x00,
  0x43,
  0x00,
  0x03,
  0x02,
  0x02,
  0x02,
  0x02,
  0x02,
  0x03,
  0x02,
  0x02,
  0x02,
  0x03,
  0x03,
  0x03,
  0x03,
  0x04,
  0x06,
  0x04,
  0x04,
  0x04,
  0x04,
  0x04,
  0x08,
  0x06,
  0x06,
  0x05,
  0x06,
  0x09,
  0x08,
  0x0a,
  0x0a,
  0x09,
  0x08,
  0x09,
  0x09,
  0x0a,
  0x0c,
  0x0f,
  0x0c,
  0x0a,
  0x0b,
  0x0e,
  0x0b,
  0x09,
  0x09,
  0x0d,
  0x11,
  0x0d,
  0x0e,
  0x0f,
  0x10,
  0x10,
  0x11,
  0x10,
  0x0a,
  0x0c,
  0x12,
  0x13,
  0x12,
  0x10,
  0x13,
  0x0f,
  0x10,
  0x10,
  0x10,
  0xff,
  0xc9,
  0x00,
  0x0b,
  0x08,
  0x00,
  0x01,
  0x00,
  0x01,
  0x01,
  0x01,
  0x11,
  0x00,
  0xff,
  0xcc,
  0x00,
  0x06,
  0x00,
  0x10,
  0x10,
  0x05,
  0xff,
  0xda,
  0x00,
  0x08,
  0x01,
  0x01,
  0x00,
  0x00,
  0x3f,
  0x10,
  0xff,
  0xd9,
]);

@GenerateMocks([Interpreter])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalRecognitionService localRecognitionService;
  late MockInterpreter mockInterpreter;

  setUp(() {
    mockInterpreter = MockInterpreter();
    localRecognitionService = LocalRecognitionService.test(mockInterpreter);

    // Mock the model and labels loading
    const MethodChannel channel = MethodChannel('tflite_flutter');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'loadModel') {
        return 'ok';
      }
      return null;
    });
  });

  test('recognizeFoodImage returns LocalLabelResult on successful inference', () async {
    // Create a dummy image file
    final tempDir = await Directory.systemTemp.createTemp();
    final imageFile = File('${tempDir.path}/test_image.jpg');
    await imageFile.writeAsBytes(minimalValidJpeg);

    // Mock the interpreter
    when(mockInterpreter.run(any, any)).thenAnswer((invocation) {
      final output = (invocation.positionalArguments[1] as List<List<double>>)[0];
      for (var i = 0; i < output.length; i++) {
        output[i] = 0.5;
      }
    });

    final result = await localRecognitionService.recognizeFoodImage(imageFile);

    expect(result, isA<LocalLabelResult>());
    expect(result.foodLabels, isNotEmpty);

    await tempDir.delete(recursive: true);
  });
}
