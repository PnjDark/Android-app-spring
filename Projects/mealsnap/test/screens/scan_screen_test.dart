import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealsnap/screens/scan_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mealsnap/services/local_recognition_service.dart';
import 'package:mealsnap/services/gemini_service.dart';

import 'scan_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CameraDescription>(),
  MockSpec<LocalRecognitionService>(),
  MockSpec<GeminiService>(),
  MockSpec<CameraController>()
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalRecognitionService mockLocalRecognitionService;
  late MockGeminiService mockGeminiService;
  late MockCameraDescription mockCameraDescription;
  late MockCameraController mockCameraController;

  setUp(() {
    mockLocalRecognitionService = MockLocalRecognitionService();
    mockGeminiService = MockGeminiService();
    mockCameraDescription = MockCameraDescription();
    mockCameraController = MockCameraController();

    when(mockCameraDescription.name).thenReturn('0');
    when(mockCameraDescription.lensDirection)
        .thenReturn(CameraLensDirection.back);
    when(mockCameraDescription.sensorOrientation).thenReturn(90);
  });

  testWidgets('ScanScreen displays initial UI elements',
      (WidgetTester tester) async {
    final completer = Completer<void>();
    when(mockCameraController.initialize()).thenAnswer((_) => completer.future);
    when(mockCameraController.value).thenReturn(CameraValue(
      isInitialized: true,
      isTakingPicture: false,
      isRecordingVideo: false,
      isRecordingPaused: false,
      isStreamingImages: false,
      flashMode: FlashMode.off,
      exposureMode: ExposureMode.auto,
      focusMode: FocusMode.auto,
      exposurePointSupported: false,
      focusPointSupported: false,
      deviceOrientation: DeviceOrientation.portraitUp,
      description: mockCameraDescription,
      errorDescription: null,
      lockedCaptureOrientation: null,
      recordingOrientation: null,
      isPreviewPaused: false,
      previewSize: const Size(1920, 1080),
    ));
    when(mockCameraController.buildPreview()).thenReturn(Container());

    await tester.pumpWidget(
      MaterialApp(
        home: ScanScreen(
          cameras: [mockCameraDescription],
          localRecognitionService: mockLocalRecognitionService,
          geminiService: mockGeminiService,
          controller: mockCameraController, // Injected controller
        ),
      ),
    );

    // Complete the future to simulate initialization
    completer.complete();
    await tester.pump();

    expect(find.byType(CameraPreview), findsOneWidget);

    expect(find.text('Meal'), findsOneWidget);

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
