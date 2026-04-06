import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static bool _isTestMode = false;
  static bool get isTestMode => _isTestMode;

  static void setTestMode() {
    _isTestMode = true;
  }

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (_isTestMode) return;

    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
}
