import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum ScanMode { meal, ingredients, receipt, voice }

class ScanScreen extends StatefulWidget {
  final ScanMode initialMode;

  const ScanScreen({super.key, this.initialMode = ScanMode.meal});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isFlashOn = false;
  ScanMode _mode = ScanMode.meal;
  String _scanResult = 'Ready to scan your meal.';
  bool _isAnalyzing = false;
  late final stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceTranscript = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _mode = widget.initialMode;
    _scanResult = 'Ready to scan ${widget.initialMode.name}';
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      setState(() {});
    } catch (e) {
      setState(() {
        _scanResult = 'Camera failed to initialize: $e';
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (_) {
      setState(() {
        _scanResult = 'Unable to toggle flash.';
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      setState(() {
        _isAnalyzing = true;
        _scanResult = 'Capturing image...';
      });
      final picture = await _controller!.takePicture();
      await _processImage(picture.path);
    } catch (e) {
      setState(() {
        _scanResult = 'Capture failed: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _isAnalyzing = true;
      _scanResult = 'Scanning gallery image...';
    });
    await _processImage(image.path);
  }

  Future<void> _processImage(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final result = await recognizer.processImage(inputImage);
      final extractedText = result.text.trim();

      if (_mode == ScanMode.receipt) {
        setState(() {
          _scanResult = extractedText.isEmpty
              ? 'No readable receipt text found. Try a clearer photo.'
              : 'Receipt detected:\n$extractedText';
          _isAnalyzing = false;
        });
      } else if (_mode == ScanMode.ingredients) {
        final found = _extractIngredients(extractedText);
        setState(() {
          _scanResult = found.isNotEmpty
              ? 'Ingredients recognized: ${found.join(', ')}'
              : 'No ingredient labels found. Try a different angle.';
          _isAnalyzing = false;
        });
      } else {
        final found = _extractIngredients(extractedText);
        setState(() {
          _scanResult = found.isNotEmpty
              ? 'Detected: ${found.join(', ')}'
              : 'Try a clearer photo of your meal or packaging.';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Image analysis failed: $e';
        _isAnalyzing = false;
      });
    } finally {
      recognizer.close();
    }
  }

  List<String> _extractIngredients(String text) {
    const known = [
      'tomato',
      'onion',
      'chicken',
      'plantain',
      'rice',
      'garlic',
      'cheese',
      'pepper',
      'lettuce',
      'spinach',
      'potato',
      'egg',
      'carrot',
    ];
    final lower = text.toLowerCase();
    return known.where((item) => lower.contains(item)).toList();
  }

  Future<void> _toggleVoiceRecording() async {
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (status) {},
        onError: (errorNotification) {},
      );
      if (!available) {
        setState(() {
          _scanResult = 'Voice recognition unavailable.';
        });
        return;
      }
      setState(() {
        _isListening = true;
        _voiceTranscript = '';
        _scanResult = 'Listening for voice input...';
      });
      _speech.listen(onResult: _onSpeechResult);
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
        _scanResult = _voiceTranscript.isEmpty
            ? 'No voice input captured.'
            : 'Voice input recognized: $_voiceTranscript';
      });
    }
  }

  void _onSpeechResult(dynamic result) {
    setState(() {
      _voiceTranscript = result.recognizedWords ?? '';
      _scanResult = 'Voice input: $_voiceTranscript';
    });
  }

  void _setMode(ScanMode mode) {
    setState(() {
      _mode = mode;
      _scanResult = 'Ready to scan ${_mode.name}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_initializeControllerFuture != null)
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller!);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )
            else
              const Center(child: CircularProgressIndicator()),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.25), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      _buildCircleButton(
                        icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        onPressed: _toggleFlash,
                      ),
                      const SizedBox(width: 12),
                      _buildCircleButton(
                        icon: Icons.settings,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0xFFA3F69C), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildTag('Tomato'),
                    ),
                    Positioned(
                      bottom: 60,
                      right: 24,
                      child: _buildTag('Onion'),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: true,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scanning for ingredients...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _scanResult,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ScanMode.values.map((mode) {
                        return _buildModeButton(mode);
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBottomControl(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onPressed: _pickFromGallery,
                        ),
                        GestureDetector(
                          onTap: _isAnalyzing ? null : _capturePhoto,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFC820C), Color(0xFF0D631B)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _isAnalyzing ? Icons.hourglass_top : Icons.camera_alt,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        _buildBottomControl(
                          icon: Icons.mic,
                          label: 'Voice',
                          onPressed: _toggleVoiceRecording,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.black.withOpacity(0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D631B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildModeButton(ScanMode mode) {
    final isSelected = _mode == mode;
    final label = mode.name.replaceFirst(mode.name[0], mode.name[0].toUpperCase());
    return GestureDetector(
      onTap: () => _setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? const Color(0xFFA3F69C) : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControl({required IconData icon, required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
