import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isFlashOn = false;
  ScanMode _mode = ScanMode.meal;
  String _statusText = 'Tap SCAN to analyze your meal';
  bool _isAnalyzing = false;
  List<String> _overlayTags = []; // Dynamic tags
  Map<String, dynamic>? _analysisResult;
  late AnimationController _pulseController;
  late final LocalRecognitionService _recognitionService;
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _recognitionService = LocalRecognitionService();
    _geminiService = GeminiService(geminiApiKey);
    _mode = widget.initialMode;
    _updateStatusText();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    _recognitionService.dispose();
    super.dispose();
  }

  void _updateStatusText() {
    if (_isAnalyzing) {
      _statusText = 'Analyzing with AI...';
    } else if (_analysisResult != null) {
      _statusText = 'Analysis complete! Tap to save.';
    } else {
      switch (_mode) {
        case ScanMode.meal:
          _statusText = 'Center your meal in frame';
          break;
        case ScanMode.ingredients:  
          _statusText = 'Scan your ingredients';
          break;
        case ScanMode.receipt:
          _statusText = 'Point at receipt total';
          break;
        case ScanMode.voice:
          _statusText = 'Voice mode coming soon';
          break;
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(backCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } catch (e) {
      _statusText = 'Camera error: $e';
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || _isAnalyzing) return;

    try {
      setState(() {
        _isAnalyzing = true;
        _overlayTags.clear();
        _updateStatusText();
      });

      final picture = await _controller!.takePicture();
      
      // Quick MLKit preview tags
      final localResult = await _recognitionService.recognizeFoodImage(
        File(picture.path),
        ingredientsMode: _mode == ScanMode.ingredients,
      );
      final previewTags = List<String>.from(localResult['top_labels'] ?? []);
      
      if (mounted) {
        setState(() {
          _overlayTags = previewTags;
        });
      }

      await _processImage(picture.path, localResult);
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Capture failed: $e';
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isAnalyzing) return;
    
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isAnalyzing = true;
      _overlayTags.clear();
      _updateStatusText();
    });

    final localResult = await _recognitionService.recognizeFoodImage(
      File(image.path),
      ingredientsMode: _mode == ScanMode.ingredients,
    );
    final previewTags = List<String>.from(localResult['top_labels'] ?? []);
    
    if (mounted) {
      setState(() {
        _overlayTags = previewTags;
      });
    }

    await _processImage(image.path, localResult);
  }

  Future<void> _processImage(String path, Map<String, dynamic> localResult) async {
    Map<String, dynamic> geminiResult;
    
    switch (_mode) {
      case ScanMode.meal:
        geminiResult = await _geminiService.analyzeMealImage(File(path));
        break;
      case ScanMode.ingredients:
        geminiResult = await _geminiService.analyzeIngredientsImage(File(path));
        break;
      case ScanMode.receipt:
        final receiptLocal = await _recognitionService.recognizeReceiptImage(File(path));
        geminiResult = await _geminiService.analyzeReceiptImage(File(path));
        geminiResult['local_ocr'] = receiptLocal;
        break;
      case ScanMode.voice:
        return; // Not implemented
    }

    final combined = {
      ...localResult,
      'gemini': geminiResult,
      'mode': _mode.name,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (mounted) {
      setState(() {
        _analysisResult = combined;
        _overlayTags = List<String>.from(geminiResult['main_ingredients'] ?? localResult['top_labels'] ?? []);
        _isAnalyzing = false;
        _updateStatusText();
      });
      
      await _saveToFirestore(path, combined);
    }
  }

  Future<void> _clearResults() {
    setState(() {
      _analysisResult = null;
      _overlayTags.clear();
      _updateStatusText();
    });
  }

  Future<void> _saveToFirestore(String imagePath, Map<String, dynamic> analysis) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // TODO: Upload image to Storage
    final mealEntry = {
      'userId': user.uid,
      'type': _mode.name,
      'imagePath': imagePath,
      'analysis': analysis,
      'timestamp': FieldValue.serverTimestamp(),
      'source': 'camera',
    };

    await FirebaseFirestore.instance.collection('meals').add(mealEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_initializeControllerFuture != null)
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller!);
                  }
                  return const ColoredBox(color: Colors.black);
                },
              ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Top controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, 
                                  color: Colors.white),
                        onPressed: _toggleFlash,
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scan frame + dynamic tags
            Center(
              child: Stack(
                children: [
                  // Frame
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  
                  // Dynamic overlay tags
                  if (_overlayTags.isNotEmpty)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _overlayTags.take(6).map((tag) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tag, style: const TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                            )),
                          ),
                        ).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Status panel
            Positioned(
              bottom: 220,
              left: 24,
              right: 24,
              child: Material(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status/Progress
                      if (_isAnalyzing)
                        Column(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.greenAccent,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      
                      Text(
                        _statusText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      if (_analysisResult != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton.icon(
                            onPressed: _clearResults,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Save & New Scan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ScanMode.values.map((mode) {
                          final isActive = _mode == mode;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _mode = mode;
                                _updateStatusText();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green : Colors.white24,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isActive ? Colors.greenAccent : Colors.white38,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                mode.name.toUpperCase(),
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery
                        GestureDetector(
                          onTap: _isAnalyzing ? null : _pickFromGallery,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.photo_library, color: Colors.white, size: 28),
                              ),
                              const SizedBox(height: 8),
                              const Text('Gallery', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        
                        // Shutter (main button)
                        GestureDetector(
                          onTap: _isAnalyzing ? null : _capturePhoto,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isAnalyzing 
                                  ? [Colors.grey]
                                  : [Colors.orange, Colors.green],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isAnalyzing ? Colors.grey : Colors.white)
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: _isAnalyzing
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.circle, color: Colors.white, size: 48),
                          ),
                        ),
                        
                        // Spacer (for symmetry)
                        const SizedBox(width: 80),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

