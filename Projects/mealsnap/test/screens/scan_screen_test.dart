import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealsnap/screens/scan_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mealsnap/services/local_recognition_service.dart';
import 'package:mealsnap/services/gemini_service.dart';

import 'scan_screen_test.mocks.dart';

@GenerateMocks([CameraDescription, LocalRecognitionService, GeminiService, CameraController])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCameraController mockCameraController;
  late MockLocalRecognitionService mockLocalRecognitionService;
  late MockGeminiService mockGeminiService;

  setUp(() {
    mockCameraController = MockCameraController();
    mockLocalRecognitionService = MockLocalRecognitionService();
    mockGeminiService = MockGeminiService();
    when(mockCameraController.initialize()).thenAnswer((_) async {});
  });

  testWidgets('ScanScreen displays initial UI elements', (WidgetTester tester) async {
    final mockCamera = MockCameraDescription();
    when(mockCamera.name).thenReturn('0');
    when(mockCamera.lensDirection).thenReturn(CameraLensDirection.back);
    when(mockCamera.sensorOrientation).thenReturn(90);

    await tester.pumpWidget(
      MaterialApp(
        home: ScanScreen(
          cameras: [mockCamera],
          localRecognitionService: mockLocalRecognitionService,
          geminiService: mockGeminiService,
        ),
      ),
    );

    // Verify that the camera preview is displayed
    expect(find.byType(CameraPreview), findsOneWidget);

    // Verify that the initial mode is meal
    expect(find.text('Meal'), findsOneWidget);

    // Verify that the shutter button is displayed
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
