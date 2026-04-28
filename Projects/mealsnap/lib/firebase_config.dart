import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ── AI Provider Keys ──────────────────────────────────────────────────────────
// Keys are tried in order: Gemini → OpenAI → Claude → Groq → local TFLite.
// Replace each placeholder with your real key before running the app.

/// Gemini — https://makersuite.google.com/app/apikey
const List<String> geminiApiKeys = [
  '<YOUR_GEMINI_KEY>',
];

/// OpenAI — https://platform.openai.com/api-keys
const String openAiApiKey = '<YOUR_OPENAI_KEY>';

/// Anthropic Claude — https://console.anthropic.com/settings/keys
const String claudeApiKey = '<YOUR_CLAUDE_KEY>';

/// Groq — https://console.groq.com/keys
const String groqApiKey = '<YOUR_GROQ_KEY>';

/// Firebase initialization
/// 
/// SETUP INSTRUCTIONS:
/// 1. Go to https://firebase.google.com/
/// 2. Create a new project called "MealSnap+"
/// 3. Enable these services:
///    - Authentication (Email/Google Sign-In)
///    - Cloud Firestore (Database)
///    - Storage (for meal photos)
///    - Analytics
/// 
/// 4. Download your configuration files:
///    - For Android: google-services.json → android/app/
///    - For iOS: GoogleService-Info.plist → ios/Runner/
/// 
/// 5. Run: firebase configure
///    This will auto-generate lib/firebase_options.dart

class FirebaseConfig {
  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('✅ Firebase initialized successfully'); // ignore: avoid_print
    } catch (e) {
      print('❌ Firebase initialization error: $e'); // ignore: avoid_print
      rethrow;
    }
  }
}
