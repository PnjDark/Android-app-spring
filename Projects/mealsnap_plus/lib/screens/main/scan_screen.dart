import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:ui';
import '../../core/app_theme.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

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
            ),
          ),

          // Scanning Reticle
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryFixed.withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  // Corner Accents
                  _buildCorner(top: -1, left: -1, borderRadius: const BorderRadius.only(topLeft: Radius.circular(32))),
                  _buildCorner(top: -1, right: -1, borderRadius: const BorderRadius.only(topRight: Radius.circular(32))),
                  _buildCorner(bottom: -1, left: -1, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32))),
                  _buildCorner(bottom: -1, right: -1, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32))),

                  // Detection Indicators
                  Positioned(
                    top: 50,
                    left: 30,
                    child: _buildDetectionBadge('Tomato'),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 40,
                    child: _buildDetectionBadge('Onion'),
                  ),
                ],
              ),
            ),
          ),

          // Header Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoundButton(Symbols.close, onPressed: () => Navigator.pop(context)),
                  Row(
                    children: [
                      _buildRoundButton(Symbols.flash_on),
                      const SizedBox(width: 16),
                      _buildRoundButton(Symbols.settings),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls and AI Feedback
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AI Feedback Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF2E7D32)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Symbols.auto_awesome, color: Colors.white, fill: 1),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI ANALYST ACTIVE',
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryFixed, letterSpacing: 1.5),
                                  ),
                                  Text(
                                    'Scanning for ingredients...',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    'Detected: Tomatoes, Onions',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeTab('GALLERY'),
                    const SizedBox(width: 24),
                    _buildModeTab('RECEIPT'),
                    const SizedBox(width: 24),
                    _buildModeTab('MEAL', active: true),
                    const SizedBox(width: 24),
                    _buildModeTab('INGREDIENTS'),
                  ],
                ),

                const SizedBox(height: 24),
                // Camera Action Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionItem(
                        context,
                        label: 'Library',
                        iconWidget: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDKM2L2VubLwpS-kh_0E7674WGamNI0Yoh-aYdPmpOgOVgjxbzsHyDsZBfdrPbpSPndnWMCA-S85LTG9oL29UTCCBxeozrYTrTwb9LeaoprHqJa04qs_3ITBBg9q_KVNOtP483RBB0Jfw8SkBwxAPTNaenc8NNTbVEqYl93RNEI-7VrHkMLVfTKnXioD1kfDyOBEqpm8l59C_pfaIBrLE6J_VDdB8O3YV-QRWs3lEZ1V66r-3jyKnO72WCJ2N7hgkvq1evM0TGhU7XU',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Shutter Button
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFC820C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Symbols.photo_camera, color: Colors.white, size: 32, fill: 1),
                        ),
                      ),

                      _buildActionItem(
                        context,
                        label: 'Voice',
                        iconWidget: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Symbols.mic, color: Colors.white, size: 24),
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
    );
  }

  Widget _buildCorner({double? top, double? left, double? right, double? bottom, required BorderRadius borderRadius}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: AppTheme.primaryFixed, width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: AppTheme.primaryFixed, width: 4) : BorderSide.none,
            right: right != null ? const BorderSide(color: AppTheme.primaryFixed, width: 4) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: AppTheme.primaryFixed, width: 4) : BorderSide.none,
          ),
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildDetectionBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.check_circle, size: 12, color: Colors.white, fill: 1),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, {VoidCallback? onPressed}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          color: Colors.black.withOpacity(0.2),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed ?? () {},
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, {bool active = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: active ? AppTheme.primaryFixed : Colors.white60,
            letterSpacing: 1.2,
          ),
        ),
        if (active) const SizedBox(height: 4),
        if (active) Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primaryFixed, shape: BoxShape.circle)),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, {required String label, required Widget iconWidget}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2),
        ),
      ],
    );
  }
}
