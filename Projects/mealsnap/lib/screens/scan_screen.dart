import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/local_recognition_service.dart';
import '../services/gemini_service.dart';
import '../firebase_config.dart';
import '../models.dart';

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
  late final LocalRecognitionService _recognitionService;
  late final GeminiService _geminiService;
  // late final stt.SpeechToText _speech;
  // bool _isListening = false;
  // String _voiceTranscript = '';

  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText();
    _recognitionService = LocalRecognitionService();
    _geminiService = GeminiService(geminiApiKey);
    _mode = widget.initialMode;
    _scanResult = 'Ready to scan ${widget.initialMode.name}';
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recognitionService.dispose();
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
    if (_mode == ScanMode.voice) {
      setState(() {
        _scanResult = 'Voice mode is not supported for photo capture yet.';
      });
      return;
    }

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
    if (_mode == ScanMode.voice) {
      setState(() {
        _scanResult = 'Voice mode is not supported for gallery images.';
      });
      return;
    }

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _isAnalyzing = true;
      _scanResult = 'Scanning gallery image...';
    });
    await _processImage(image.path);
  }

  Future<void> _processImage(String path) async {
    final imageFile = File(path);

    try {
      setState(() {
        _isAnalyzing = true;
        _scanResult = 'Analyzing image...';
      });

      Map<String, dynamic> parsedAnalysis;

      if (_mode == ScanMode.receipt) {
        parsedAnalysis = await _recognitionService.recognizeReceiptImage(imageFile);
      } else {
        // First, get basic recognition from ML Kit
        final basicAnalysis = await _recognitionService.recognizeFoodImage(
          imageFile,
          ingredientsMode: _mode == ScanMode.ingredients,
        );

        // Then enhance with Gemini for better analysis
        setState(() {
          _scanResult = 'Enhancing analysis with AI...';
        });

        final modeString = _mode == ScanMode.ingredients ? 'ingredients' : 'meal';
        final geminiAnalysis = await _geminiService.analyzeMealImage(imageFile, modeString);

        // Combine results
        parsedAnalysis = _combineAnalyses(basicAnalysis, geminiAnalysis);
      }

      await _saveToFirestore(path, parsedAnalysis);

      setState(() {
        _scanResult = _formatAnalysisResult(parsedAnalysis);
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _scanResult = 'Analysis failed: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _saveToFirestore(String imagePath, Map<String, dynamic> analysis) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final mealEntry = MealEntry(
      id: '', // Firestore will generate
      userId: user.uid,
      type: _mode.name,
      description: _formatAnalysisResult(analysis),
      analysis: analysis,
      timestamp: DateTime.now(),
      // TODO: Upload image to Firebase Storage and get URL
    );

    await FirebaseFirestore.instance.collection('meals').add(mealEntry.toFirestore());
  }

  Map<String, dynamic> _combineAnalyses(Map<String, dynamic> basic, String gemini) {
    // Try to parse Gemini response as JSON
    try {
      // Clean the response (remove markdown formatting)
      String cleanResponse = gemini
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('```\n', '')
          .trim();

      // Find JSON content
      final jsonStart = cleanResponse.indexOf('{');
      final jsonEnd = cleanResponse.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
      }

      final geminiData = jsonDecode(cleanResponse);

      // Combine the analyses
      return {
        ...basic,
        'gemini_analysis': geminiData,
        'enhanced': true,
      };
    } catch (e) {
      // If JSON parsing fails, return basic analysis with raw Gemini response
      return {
        ...basic,
        'gemini_raw': gemini,
        'enhanced': false,
      };
    }
  }

  // Future<void> _analyzeVoiceInput(String transcript) async {
  //   setState(() {
  //     _isAnalyzing = true;
  //     _scanResult = 'Analyzing voice input...';
  //   });

  //   try {
  //     final analysis = await _geminiService.analyzeText(transcript, _mode.name);

  //     Map<String, dynamic> parsedAnalysis;
  //     try {
  //       String cleanAnalysis = analysis.replaceAll('```json', '').replaceAll('```', '').trim();
  //       parsedAnalysis = jsonDecode(cleanAnalysis);
  //     } catch (e) {
  //       parsedAnalysis = {'raw_response': analysis};
  //     }

  //     await _saveVoiceToFirestore(transcript, parsedAnalysis);

  //     setState(() {
  //       _scanResult = _formatAnalysisResult(parsedAnalysis);
  //       _isAnalyzing = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _scanResult = 'Voice analysis failed: $e';
  //       _isAnalyzing = false;
  //     });
  //   }
  // }

  // Future<void> _saveVoiceToFirestore(String transcript, Map<String, dynamic> analysis) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final mealEntry = MealEntry(
  //     id: '',
  //     userId: user.uid,
  //     type: '${_mode.name}_voice',
  //     description: transcript,
  //     analysis: analysis,
  //     timestamp: DateTime.now(),
  //   );

  //   await FirebaseFirestore.instance.collection('meals').add(mealEntry.toFirestore());
  // }

  // Future<void> _toggleVoiceRecording() async {
  //   if (!_isListening) {
  //     final available = await _speech.initialize(
  //       onStatus: (status) {},
  //       onError: (errorNotification) {},
  //     );
  //     if (!available) {
  //       setState(() {
  //         _scanResult = 'Voice recognition unavailable.';
  //       });
  //       return;
  //     }
  //     setState(() {
  //       _isListening = true;
  //       _voiceTranscript = '';
  //       _scanResult = 'Listening for voice input...';
  //     });
  //     _speech.listen(onResult: _onSpeechResult);
  //   } else {
  //     _speech.stop();
  //     setState(() {
  //       _isListening = false;
  //     });
  //     if (_voiceTranscript.isNotEmpty) {
  //       await _analyzeVoiceInput(_voiceTranscript);
  //     } else {
  //       setState(() {
  //         _scanResult = 'No voice input captured.';
  //       });
  //     }
  //   }
  // }

  // void _onSpeechResult(dynamic result) {
  //   setState(() {
  //     _voiceTranscript = result.recognizedWords ?? '';
  //     _scanResult = 'Voice input: $_voiceTranscript';
  //   });
  // }

  void _setMode(ScanMode mode) {
    setState(() {
      _mode = mode;
      _scanResult = 'Ready to scan ${_mode.name}';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    colors: [Colors.black.withValues(alpha: 0.25), Colors.transparent],
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
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
                      color: Colors.white.withValues(alpha: 0.12),
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
                      color: Colors.black.withValues(alpha: 0.4),
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
                                  color: Colors.black.withValues(alpha: 0.3),
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
      color: Colors.black.withValues(alpha: 0.4),
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
        color: const Color(0xFF0D631B).withValues(alpha: 0.8),
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
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? const Color(0xFFA3F69C) : Colors.white.withValues(alpha: 0.12),
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
              color: Colors.white.withValues(alpha: 0.1),
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

  String _formatAnalysisResult(Map<String, dynamic> analysis) {
    if (analysis.containsKey('gemini_analysis')) {
      final geminiData = analysis['gemini_analysis'] as Map<String, dynamic>;

      if (geminiData.containsKey('estimated_calories')) {
        final calories = geminiData['estimated_calories'];
        final ingredients = (geminiData['main_ingredients'] as List<dynamic>?)?.join(', ') ?? 'N/A';
        final protein = geminiData['protein_g'] ?? 'N/A';
        final carbs = geminiData['carbs_g'] ?? 'N/A';
        final fat = geminiData['fat_g'] ?? 'N/A';

        return '🍽️ Enhanced Analysis:\n'
               'Calories: $calories kcal\n'
               'Ingredients: $ingredients\n'
               'Protein: ${protein}g, Carbs: ${carbs}g, Fat: ${fat}g';
      } else if (geminiData.containsKey('ingredients')) {
        final ingredients = (geminiData['ingredients'] as List<dynamic>?)?.join(', ') ?? 'N/A';
        return '🥬 Detected Ingredients:\n$ingredients';
      }
    }

    // Fallback to basic analysis
    if (analysis.containsKey('labels')) {
      final labels = (analysis['labels'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      if (labels.isEmpty) {
        return 'No food labels were detected. Try a clearer photo of your meal.';
      }

      final detected = labels.map((item) => item['label']).join(', ');
      final confidence = labels
          .map((item) {
            final score = (item['confidence'] as num?)?.toDouble() ?? 0.0;
            return '${item['label']}: ${(score * 100).toStringAsFixed(0)}%';
          })
          .join(', ');

      return 'Detected: $detected\nConfidence: $confidence';
    } else if (analysis.containsKey('items')) {
      final items = analysis['items'] as List<dynamic>? ?? [];
      final total = analysis['total'] ?? 'N/A';
      return 'Receipt Items:\n${items.map((item) => '- ${item['name']}: \$${item['price']}').join('\n')}\nTotal: \$$total';
    } else if (analysis.containsKey('raw_response')) {
      return analysis['raw_response'];
    } else if (analysis.containsKey('gemini_raw')) {
      return 'AI Analysis: ${analysis['gemini_raw']}';
    } else {
      return 'Analysis complete. Data saved.';
    }
  }
}
