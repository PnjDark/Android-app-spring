import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// GEMINI API SETUP:
/// 1. Go to https://makersuite.google.com/app/apikey
/// 2. Create an API key
/// 3. Replace the GEMINI_API_KEY below with your key
///    (In production, use environment variables or secure storage)

/// Primary key + fallbacks. GeminiService rotates through these on failure.
/// Replace with your actual keys; keep at least one valid entry.
const List<String> geminiApiKeys = [
  'AIzaSyCIKIzi22_p-tpvzTgBm5-rQew0vRSNg', // key 1 – replace
  // 'AIzaSy_YOUR_SECOND_KEY_HERE',          // key 2 – add more as needed
];

/// Convenience getter used by legacy call-sites.
String get geminiApiKey => geminiApiKeys.first;

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
