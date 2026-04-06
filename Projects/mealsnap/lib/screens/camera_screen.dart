import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Viewfinder
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA7f_Get9WS5iYeDCc65bUCJID5c63ieUYKnCUWOihyBiYdIi04jI9rHBXGPuOE_tregX-7csiY_OyHtG17PjJh0adbNXzcMz0bPR_DLgimlU6tt3wgQeifoe2h0ZFgTBCV1EOEav4u3zTp50XIIdA0xqYsVjTN7-4onBDC1qp3Xai2wQtZoCzRhU2ZfADyyL9KXUErBziCl-SQ-VLDuK7i9FkJQEoR8M0HQKJ3idh2I30AL2GKkVko5TzmgwLRFv0jrOBMGyM6_ljf',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Scanning Reticle
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFA3F69C).withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  _buildCorner(top: -2, left: -2, isTop: true, isLeft: true),
                  _buildCorner(top: -2, right: -2, isTop: true, isLeft: false),
                  _buildCorner(bottom: -2, left: -2, isTop: false, isLeft: true),
                  _buildCorner(bottom: -2, right: -2, isTop: false, isLeft: false),

                  // Detection Indicators
                  Positioned(
                    top: 60,
                    left: 40,
                    child: _buildDetectionLabel('Tomato'),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 30,
                    child: _buildDetectionLabel('Onion'),
                  ),
                ],
              ),
            ),
          ),

          // Top Control Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(Symbols.close, () => Navigator.pop(context)),
                    Row(
                      children: [
                        _buildIconButton(Symbols.flash_on, () {}),
                        const SizedBox(width: 16),
                        _buildIconButton(Symbols.settings, () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // AI Feedback Card
          Positioned(
            bottom: 160,
            left: 24,
            right: 24,
            child: _buildAIFeedbackCard(),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Color(0xFFA3F69C), width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Color(0xFFA3F69C), width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Color(0xFFA3F69C), width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Color(0xFFA3F69C), width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(24) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(24) : Radius.zero,
            bottomLeft: !isTop && isLeft ? const Radius.circular(24) : Radius.zero,
            bottomRight: !isTop && !isLeft ? const Radius.circular(24) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.check_circle, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildAIFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Symbols.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AI ANALYST ACTIVE',
                  style: TextStyle(color: Color(0xFFA3F69C), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scanning for ingredients...',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    text: 'Detected: ',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Tomatoes, Onions',
                        style: TextStyle(color: Color(0xFFA3F69C), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeTab('Gallery', false),
              const SizedBox(width: 24),
              _buildModeTab('Receipt', false),
              const SizedBox(width: 24),
              _buildModeTab('Meal', true),
              const SizedBox(width: 24),
              _buildModeTab('Ingredients', false),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCameraAction('Library', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKM2L2VubLwpS-kh_0E7674WGamNI0Yoh-aYdPmpOgOVgjxbzsHyDsZBfdrPbpSPndnWMCA-S85LTG9oL29UTCCBxeozrYTrTwb9LeaoprHqJa04qs_3ITBBg9q_KVNOtP483RBB0Jfw8SkBwxAPTNaenc8NNTbVEqYl93RNEI-7VrHkMLVfTKnXioD1kfDyOBEqpm8l59C_pfaIBrLE6J_VDdB8O3YV-QRWs3lEZ1V66r-3jyKnO72WCJ2N7hgkvq1evM0TGhU7XU'),
              _buildShutterButton(),
              _buildCameraAction('Voice', null, icon: Symbols.mic),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeTab(String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive ? BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ) : null,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isActive ? const Color(0xFFA3F69C) : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        if (isActive) const SizedBox(height: 4),
        if (isActive) Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFA3F69C), shape: BoxShape.circle)),
      ],
    );
  }

  Widget _buildCameraAction(String label, String? imageUrl, {IconData? icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(imageUrl != null ? 16 : 28),
            border: imageUrl != null ? Border.all(color: Colors.white.withOpacity(0.2), width: 2) : null,
          ),
          child: imageUrl != null
              ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(imageUrl, fit: BoxFit.cover))
              : Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildShutterButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFA3F69C).withOpacity(0.2)),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryContainer.withOpacity(0.4),
                blurRadius: 40,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                ),
              ),
              const Icon(Symbols.photo_camera, color: Colors.white, size: 36),
            ],
          ),
        ),
      ],
    );
  }
}
