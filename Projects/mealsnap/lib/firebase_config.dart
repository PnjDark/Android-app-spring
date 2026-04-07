import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }
}
