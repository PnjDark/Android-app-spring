import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../firebase_config.dart';
import '../models/firebase_models.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../services/local_recognition_service.dart';

enum ScanMode { meal, ingredients, receipt, voice }

// -----------------------------------------------------------------------------
// ScanScreen widget
// -----------------------------------------------------------------------------

class ScanScreen extends StatefulWidget {
  final ScanMode initialMode;
  final List<CameraDescription>? cameras;
  final LocalRecognitionService? localRecognitionService;
  final CameraController? controller;

  const ScanScreen({
    super.key,
    this.initialMode = ScanMode.meal,
    this.cameras,
    this.localRecognitionService,
    this.controller,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  // -- Camera ------------------------------------------------------------------
  CameraController? _cameraController;
  Future<void>? _cameraReady;
  bool _flashOn = false;

  // -- Scan state ---------------------------------------------------------------
  ScanMode _mode = ScanMode.meal;
  bool _isAnalyzing = false;
  String _statusText = '';
  List<String> _overlayTags = [];
  String _resultText = '';
  bool _hasResult = false;
  bool _isOfflineResult = false;

  // -- Services -----------------------------------------------------------------
  late final LocalRecognitionService _localService;
  late final AiService _aiService;

  // -- Animation for scan line --------------------------------------------------
  late final AnimationController _scanLineAnim;
  late final Animation<double> _scanLinePos;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _statusText = _idleStatus(_mode);

    _localService = widget.localRecognitionService ?? LocalRecognitionService();
    _aiService = AiService(
      geminiKeys: geminiApiKeys,
      openAiKey: openAiApiKey,
      claudeKey: claudeApiKey,
      groqKey: groqApiKey,
    );

    _scanLineAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLinePos = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineAnim, curve: Curves.easeInOut),
    );

    if (widget.controller != null) {
      _cameraController = widget.controller;
      _cameraReady = _cameraController!.initialize();
    } else {
      _initCamera();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _cameraController?.dispose();
    }
    _localService.dispose();
    _scanLineAnim.dispose();
    super.dispose();
  }

  // -- Camera init --------------------------------------------------------------

  Future<void> _initCamera() async {
    try {
      final cameras = widget.cameras ?? await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(back, ResolutionPreset.high,
          enableAudio: false);
      _cameraReady = ctrl.initialize();
      _cameraController = ctrl;
      await _cameraReady;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() => _statusText = 'Camera unavailable: $e');
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _flashOn = !_flashOn;
    await _cameraController!
        .setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    if (mounted) setState(() {});
  }

  // -- Capture / gallery --------------------------------------------------------

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isAnalyzing) {
      return;
    }
    if (_mode == ScanMode.voice) {
      _showVoiceUnsupported();
      return;
    }
    setState(() {
      _isAnalyzing = true;
      _hasResult = false;
      _overlayTags = [];
      _statusText = 'Capturing...';
    });
    try {
      final file = await _cameraController!.takePicture();
      _lastImage = File(file.path);
      await _processImage(_lastImage!);
    } catch (e) {
      _setError('Capture failed: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isAnalyzing) return;
    if (_mode == ScanMode.voice) {
      _showVoiceUnsupported();
      return;
    }
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    _lastImage = File(picked.path);
    setState(() {
      _isAnalyzing = true;
      _hasResult = false;
      _overlayTags = [];
      _statusText = 'Loading image...';
    });
    await _processImage(_lastImage!);
  }

  // -- Core processing pipeline -------------------------------------------------

  Future<void> _processImage(File image) async {
    try {
      if (_mode == ScanMode.receipt) {
        await _processReceipt(image);
      } else {
        await _processFoodOrIngredients(image);
      }
    } catch (e) {
      _setError('Analysis failed: $e');
    }
  }

  Future<void> _processFoodOrIngredients(File image) async {
    // Step 1 -- fast ML Kit pass to populate overlay tags immediately.
    setState(() => _statusText = 'Detecting food...');
    final localResult = await _localService.recognizeFoodImage(image);
    if (mounted) {
      setState(() {
        _overlayTags = localResult.foodLabels
            .take(4)
            .map((l) => l['label'] as String)
            .toList();
      });
    }

    // Step 2 -- Gemini deep analysis with local fallback.
    setState(() => _statusText = 'Analysing with AI...');
    MealAnalysisResult geminiResult;
    bool usedFallback = false;
    try {
      if (_mode == ScanMode.ingredients) {
        geminiResult = await _aiService.analyzeIngredientsImage(image);
      } else {
        geminiResult = await _aiService.analyzeMealImage(image);
      }
    } catch (_) {
      // Gemini failed -- fall back to local TFLite + nutrition DB.
      setState(() => _statusText = 'Using offline estimate...');
      geminiResult = _localService.buildFallbackResult(localResult);
      usedFallback = true;
    }

    // Step 3 -- update overlay tags.
    final smartTags = geminiResult.majorIngredientNames;
    if (mounted) {
      setState(() {
        _overlayTags = smartTags.isNotEmpty ? smartTags : _overlayTags;
      });
    }

    // Step 4 -- save to Firestore.
    final combined = {
      'local_labels': localResult.foodLabels,
      'gemini_analysis': geminiResult.toJson(),
      'enhanced': !usedFallback,
    };
    await _saveToFirestore(image.path, combined);

    // Step 5 -- display result.
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _hasResult = true;
        _isOfflineResult = usedFallback;
        _statusText = _idleStatus(_mode);
        _resultText = _formatMealResult(geminiResult);
      });
    }
  }

  Future<void> _processReceipt(File image) async {
    // Step 1 -- OCR text via ML Kit.
    setState(() => _statusText = 'Reading receipt text...');
    await _localService.recognizeReceiptText(image);

    // Step 2 -- AI parses the OCR text into structured data.
    setState(() => _statusText = 'Parsing receipt with AI...');
    final result = await _aiService.analyzeReceiptImage(image);

    await _saveToFirestore(image.path, result.toJson());

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _hasResult = true;
        _overlayTags = result.items
            .where((i) => i.isFood)
            .take(4)
            .map((i) => i.name)
            .toList();
        _statusText = _idleStatus(_mode);
        _resultText = _formatReceiptResult(result);
      });
    }
  }

  // -- Firestore ----------------------------------------------------------------

  Future<void> _saveToFirestore(
      String imagePath, Map<String, dynamic> analysis) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Extract structured nutrition from the Gemini result stored in analysis.
    final gemini = analysis['gemini_analysis'] as Map<String, dynamic>?;
    final nutrition =
        gemini != null ? (gemini['nutrition'] as Map<String, dynamic>?) : null;

    final meal = MealModel(
      id: '',
      userId: user.uid,
      foodName: gemini?['meal_name'] as String? ?? 'Unknown Meal',
      calories: (nutrition?['total_calories'] as num?)?.toDouble() ?? 0,
      protein: (nutrition?['protein_g'] as num?)?.toDouble() ?? 0,
      carbs: (nutrition?['carbs_g'] as num?)?.toDouble() ?? 0,
      fats: (nutrition?['fat_g'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.now(),
      source: _mode == ScanMode.receipt ? 'receipt' : 'camera',
      notes: gemini?['portion_size'] as String?,
    );

    await FirestoreService().addMeal(user.uid, meal);
  }

  // -- Helpers ------------------------------------------------------------------

  // -- Error state -------------------------------------------------------------
  File? _lastImage; // kept for retry

  void _setError(String msg) {
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _statusText = msg;
        _hasResult = false;
      });
    }
  }

  void _showVoiceUnsupported() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice mode coming soon!')),
    );
  }

  void _setMode(ScanMode mode) {
    setState(() {
      _mode = mode;
      _statusText = _idleStatus(mode);
      _overlayTags = [];
      _hasResult = false;
      _isOfflineResult = false;
      _resultText = '';
    });
  }

  static String _idleStatus(ScanMode mode) {
    switch (mode) {
      case ScanMode.meal:
        return 'Point at your meal and tap the button.';
      case ScanMode.ingredients:
        return 'Show the ingredients to identify them.';
      case ScanMode.receipt:
        return 'Hold the receipt flat under good light.';
      case ScanMode.voice:
        return 'Voice input -- coming soon.';
    }
  }

  // -- Result formatting --------------------------------------------------------

  String _formatMealResult(MealAnalysisResult r) {
    final n = r.nutrition;
    final ings = r.ingredients.isNotEmpty
        ? r.ingredients.map((i) => i.name).join(', ')
        : 'None detected';
    final tags =
        r.dietaryTags.isNotEmpty ? r.dietaryTags.join(' - ') : '';

    final confidenceEmoji = switch (r.confidence) {
      'high' => '[HIGH]',
      'medium' => '[MED]',
      _ => '[LOW]',
    };
    final healthEmoji = switch (r.healthRating) {
      'excellent' => '[EXCELLENT]',
      'good' => '[GOOD]',
      'moderate' => '[MED]',
      _ => '[LOW]',
    };

    return '${r.mealName}  $confidenceEmoji ${r.confidence} confidence\n'
        '${r.mealCategory.toUpperCase()}  -  ${r.portionSize}\n'
        '$healthEmoji ${r.healthRating.toUpperCase()}'
        '${tags.isNotEmpty ? '  -  $tags' : ''}\n\n'
        ' ${n.totalCalories.round()} kcal\n'
        ' Protein ${n.proteinG.round()} g  '
        ' Carbs ${n.carbsG.round()} g  '
        ' Fat ${n.fatG.round()} g\n'
        ' Fibre ${n.fiberG.round()} g  '
        ' Sodium ${n.sodiumMg.round()} mg\n\n'
        ' Ingredients:\n$ings';
  }

  String _formatReceiptResult(ReceiptAnalysisResult r) {
    final foodItems =
        r.items.where((i) => i.isFood).toList();
    final lines = foodItems
        .map((i) =>
            '  ${i.quantity != null ? "${i.quantity} " : ""}${i.name}  '
            '\$${i.price.toStringAsFixed(2)}')
        .join('\n');

    return ' ${r.storeName ?? "Receipt"}'
        '${r.date != null ? "  -  ${r.date}" : ""}\n\n'
        'Food items:\n$lines\n\n'
        '${r.total != null ? "Total: \$${r.total!.toStringAsFixed(2)}" : ""}';
  }

  // -- Build --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          _buildCameraPreview(),
          _buildDimOverlay(),
          _buildViewfinder(),
          _buildTopBar(),
          _buildBottomPanel(),
        ]),
      ),
    );
  }

  // -- Camera preview -----------------------------------------------------------

  Widget _buildCameraPreview() {
    if (_cameraReady == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return FutureBuilder<void>(
      future: _cameraReady,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        if (snap.hasError) {
          return Center(
            child: Text('Camera error: ${snap.error}',
                style: const TextStyle(color: Colors.white)),
          );
        }
        return Positioned.fill(child: CameraPreview(_cameraController!));
      },
    );
  }

  // -- Dim overlay --------------------------------------------------------------

  Widget _buildDimOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.35),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.25, 0.65, 1],
          ),
        ),
      ),
    );
  }

  // -- Viewfinder ---------------------------------------------------------------

  Widget _buildViewfinder() {
    return Center(
      child: SizedBox(
        width: 290,
        height: 290,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
            ),

            // Corner accents
            ..._buildCorners(),

            // Animated scan line (only while analysing)
            if (_isAnalyzing)
              AnimatedBuilder(
                animation: _scanLinePos,
                builder: (_, __) => Positioned(
                  top: _scanLinePos.value * 278 + 6,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFFA3F69C),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Dynamic ingredient tags
            if (_overlayTags.isNotEmpty) ..._buildOverlayTags(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const r = 20.0;
    const t = 3.0;
    const l = 28.0;
    const c = Color(0xFFA3F69C);

    Widget corner(
            {double? top, double? left, double? right, double? bottom}) =>
        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: SizedBox(
            width: l,
            height: l,
            child: CustomPaint(
              painter: _CornerPainter(
                topLeft: top != null && left != null,
                topRight: top != null && right != null,
                bottomLeft: bottom != null && left != null,
                bottomRight: bottom != null && right != null,
                radius: r,
                strokeWidth: t,
                color: c,
              ),
            ),
          ),
        );

    return [
      corner(top: 0, left: 0),
      corner(top: 0, right: 0),
      corner(bottom: 0, left: 0),
      corner(bottom: 0, right: 0),
    ];
  }

  List<Widget> _buildOverlayTags() {
    // Place tags at a few fixed offsets inside the viewfinder.
    final positions = [
      const Offset(12, 12),
      const Offset(12, 240),
      const Offset(160, 20),
      const Offset(150, 240),
    ];
    return List.generate(
      _overlayTags.length.clamp(0, positions.length),
      (i) => Positioned(
        left: positions[i].dx,
        top: positions[i].dy,
        child: _IngredientTag(label: _overlayTags[i]),
      ),
    );
  }

  // -- Top bar -------------------------------------------------------------------

  Widget _buildTopBar() {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleBtn(
              icon: Icons.close,
              onTap: () => Navigator.of(context).pop()),
          Row(children: [
            _CircleBtn(
              icon: _flashOn ? Icons.flash_on : Icons.flash_off,
              onTap: _toggleFlash,
            ),
            const SizedBox(width: 10),
            _CircleBtn(icon: Icons.tune, onTap: () {}),
          ]),
        ],
      ),
    );
  }

  // -- Bottom panel -------------------------------------------------------------

  Widget _buildBottomPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status / result card
          _buildStatusCard(),
          const SizedBox(height: 8),

          // Mode selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ScanMode.values
                  .map((m) => _ModeChip(
                        mode: m,
                        selected: _mode == m,
                        onTap: () => _setMode(m),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Shutter row
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BottomControl(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: _pickFromGallery,
                ),
                _ShutterButton(
                  isAnalyzing: _isAnalyzing,
                  onTap: _capturePhoto,
                ),
                // Spacer so shutter stays centred
                const SizedBox(width: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isError = !_isAnalyzing && !_hasResult &&
        (_statusText.startsWith('Analysis failed') ||
            _statusText.startsWith('Capture failed') ||
            _statusText.startsWith('All Gemini'));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFF7F1D1D).withOpacity(0.85)
            : Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isError
              ? Colors.red.withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: _isAnalyzing
          ? _buildAnalyzingContent()
          : _hasResult
              ? _buildResultContent()
              : isError
                  ? _buildErrorContent()
                  : _buildIdleContent(),
    );
  }

  Widget _buildErrorContent() {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFFCA5A5), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _statusText,
            style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (_lastImage != null)
          TextButton(
            onPressed: () {
              setState(() {
                _isAnalyzing = true;
                _hasResult = false;
                _overlayTags = [];
                _statusText = 'Retrying...';
              });
              _processImage(_lastImage!);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFCA5A5),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildIdleContent() {
    return Row(
      children: [
        const Icon(Icons.center_focus_weak,
            color: Color(0xFFA3F69C), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _statusText,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingContent() {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFA3F69C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _isOfflineResult ? Icons.wifi_off : Icons.check_circle_outline,
              color: _isOfflineResult ? const Color(0xFFFBBF24) : const Color(0xFFA3F69C),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _isOfflineResult ? 'Offline estimate' : 'Analysis complete',
              style: TextStyle(
                color: _isOfflineResult ? const Color(0xFFFBBF24) : const Color(0xFFA3F69C),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_isOfflineResult) ...([
              const SizedBox(width: 6),
              const Tooltip(
                message: 'AI unavailable — values estimated from local model. Retry when connected.',
                child: Icon(Icons.info_outline, color: Color(0xFFFBBF24), size: 14),
              ),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() {
                _hasResult = false;
                _isOfflineResult = false;
                _resultText = '';
                _overlayTags = [];
                _statusText = _idleStatus(_mode);
              }),
              child: const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _resultText,
          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.55),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Small reusable widgets
// -----------------------------------------------------------------------------

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _IngredientTag extends StatelessWidget {
  final String label;
  const _IngredientTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D631B).withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final ScanMode mode;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip(
      {required this.mode, required this.selected, required this.onTap});

  static String _label(ScanMode m) {
    switch (m) {
      case ScanMode.meal:
        return 'Meal';
      case ScanMode.ingredients:
        return 'Ingredients';
      case ScanMode.receipt:
        return 'Receipt';
      case ScanMode.voice:
        return 'Voice';
    }
  }

  static IconData _icon(ScanMode m) {
    switch (m) {
      case ScanMode.meal:
        return Icons.restaurant;
      case ScanMode.ingredients:
        return Icons.eco_outlined;
      case ScanMode.receipt:
        return Icons.receipt_long_outlined;
      case ScanMode.voice:
        return Icons.mic_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.22)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFA3F69C)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(mode),
                size: 13,
                color: selected ? Colors.white : Colors.white60),
            const SizedBox(width: 5),
            Text(
              _label(mode),
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool isAnalyzing;
  final VoidCallback onTap;
  const _ShutterButton({required this.isAnalyzing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isAnalyzing
              ? const LinearGradient(
                  colors: [Color(0xFF555555), Color(0xFF333333)])
              : const LinearGradient(
                  colors: [Color(0xFFFC820C), Color(0xFF0D631B)]),
          boxShadow: [
            BoxShadow(
              color: (isAnalyzing
                      ? Colors.grey
                      : const Color(0xFF0D631B))
                  .withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Center(
          child: isAnalyzing
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : const Icon(Icons.camera_alt, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _BottomControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomControl(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Corner accent painter
// -----------------------------------------------------------------------------

class _CornerPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  final double radius, strokeWidth;
  final Color color;

  const _CornerPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.radius,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (topLeft) {
      path
        ..moveTo(0, size.height * 0.5)
        ..lineTo(0, radius)
        ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
        ..lineTo(size.width * 0.5, 0);
    }
    if (topRight) {
      path
        ..moveTo(size.width * 0.5, 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(Offset(size.width, radius),
            radius: Radius.circular(radius))
        ..lineTo(size.width, size.height * 0.5);
    }
    if (bottomLeft) {
      path
        ..moveTo(0, size.height * 0.5)
        ..lineTo(0, size.height - radius)
        ..arcToPoint(Offset(radius, size.height),
            radius: Radius.circular(radius), clockwise: false)
        ..lineTo(size.width * 0.5, size.height);
    }
    if (bottomRight) {
      path
        ..moveTo(size.width * 0.5, size.height)
        ..lineTo(size.width - radius, size.height)
        ..arcToPoint(Offset(size.width, size.height - radius),
            radius: Radius.circular(radius), clockwise: false)
        ..lineTo(size.width, size.height * 0.5);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
