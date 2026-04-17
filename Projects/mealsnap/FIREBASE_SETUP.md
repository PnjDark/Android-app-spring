# Firebase Configuration Guide for MealSnap+

## Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Project name: **MealSnap**
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

---

## Step 2: Android App Setup

### Add Android App to Firebase

1. In Firebase Console, click **"Add app"** → Select **Android**
2. Fill in the form:
   - **Android package name**: `com.example.mealsnap` (from `android/app/build.gradle.kts`)
   - **App nickname**: MealSnap+ (optional)
3. Click **"Register app"**

### Download google-services.json

1. Click **"Download google-services.json"**
2. Place the file in: `android/app/`
3. **DO NOT** edit this file manually

### Update Android Build Files

1. **File: `android/build.gradle.kts`**
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```

2. **File: `android/app/build.gradle.kts`**
   Add at the top:
   ```gradle
   plugins {
     id 'com.android.application'
     id 'kotlin-android'
     id 'com.google.gms.google-services'  // ADD THIS LINE
   }
   ```

---

## Step 3: Enable Firebase Services

In Firebase Console, go to **Build** section and enable:

### 1. **Authentication**
- Click "Authentication" → "Get Started"
- Enable providers:
  - ✅ Email/Password
  - ✅ Google Sign-In
- Configure Google Sign-In:
  - Web SDK configuration needed for OAuth
  - Get from Cloud Console > APIs & Services

### 2. **Cloud Firestore**
- Click "Firestore Database" → "Create database"
- Select region: `us-central1` (or closest to your users)
- Security rules:
  ```firestore
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if request.auth != null;
      }
    }
  }
  ```

### 3. **Storage**
- Click "Storage" → "Get started"
- Location: `us-central1`
- Security rules:
  ```
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      match /{allPaths=**} {
        allow read, write: if request.auth != null;
      }
    }
  }
  ```

### 4. **Analytics**
- Automatically enabled if you selected it during project creation

---

## Step 4: Initialize Firebase in Flutter

### Run Flutter Firebase CLI

```bash
cd ~/flutter

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your project
flutterfire configure --project=mealsnap-xxxxx
```

This command:
- ✅ Creates `lib/firebase_options.dart`
- ✅ Updates Android build files
- ✅ Updates iOS configuration (if needed)

### Manual Initialization (if CLI fails)

If `flutterfire configure` doesn't work:

1. Create `lib/firebase_options.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'mealsnap-xxxxx',
    databaseURL: 'https://mealsnap-xxxxx.firebaseio.com',
    storageBucket: 'mealsnap-xxxxx.appspot.com',
  );

  static FirebaseOptions currentPlatform = android;
}
```

Get these values from Firebase Console:
- Project Settings → Your apps → Android app

---

## Step 5: Update main.dart

```dart
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.init();
  runApp(const MealSnapApp());
}
```

---

## Step 6: Add Dependencies to pubspec.yaml

Already added in `pubspec.yaml`. Run:

```bash
flutter pub get
```

---

## Step 7: Test Firebase Connection

Create a test screen to verify Firebase is working:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Test Authentication
Future<void> testFirebase() async {
  try {
    // Test Auth
    UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'testpassword123',
    );
    print('✅ Auth test success: ${userCred.user?.email}');

    // Test Firestore
    await FirebaseFirestore.instance.collection('test').doc('demo').set({
      'timestamp': DateTime.now(),
      'message': 'Firebase is working!',
    });
    print('✅ Firestore test success');
  } catch (e) {
    print('❌ Firebase test failed: $e');
  }
}
```

---

## Firestore Database Structure (Recommended)

```
users/
  {uid}/
    - email: string
    - displayName: string
    - profilePicture: string (URL)
    - createdAt: timestamp
    - preferences: map
      - dietaryRestrictions: array
      - calorieGoal: number
      - weightGoal: number

meals/
  {mealId}/
    - userId: string
    - title: string
    - calories: number
    - macros: map
      - protein: number
      - carbs: number
      - fat: number
    - photoURL: string
    - createdAt: timestamp
    - category: string

expenses/
  {expenseId}/
    - userId: string
    - amount: number
    - category: string
    - date: timestamp
    - mealId: string (reference)

analytics/
  {userId}/
    - totalCalories: number
    - totalExpense: number
    - weeklyAverageCalories: number
    - lastUpdated: timestamp
```

---

## Troubleshooting

### Error: "google-services.json not found"
- Make sure `android/app/google-services.json` exists
- Check file permissions: `chmod 644 android/app/google-services.json`

### Error: "Firebase initialization error"
- Ensure you called `WidgetsFlutterBinding.ensureInitialized()`
- Check firebase_options.dart exists and has correct credentials

### Error: "Authentication not enabled"
- Go to Firebase Console > Authentication > Sign-in method
- Enable Email/Password provider

### Error: "Firestore rules deny requests"
- Go to Firebase Console > Firestore > Rules
- Update security rules to allow authenticated users

---

## Next Steps

1. ✅ Firebase initialized
2. Implement Authentication (Login/Sign Up)
   - Update `lib/screens/auth/login_screen.dart`
   - Update `lib/screens/auth/signup_screen.dart`
3. Implement User Profile
   - Store user data in Firestore
4. Implement Meal Logging
   - Create meals collection
   - Upload meal photos to Storage
5. Implement Analytics
   - Read and aggregate meal data

---

## File Locations Reference

| File | Purpose |
|------|---------|
| `lib/firebase_config.dart` | Firebase initialization |
| `lib/firebase_options.dart` | Auto-generated Firebase credentials |
| `android/app/google-services.json` | Android Firebase configuration |
| `android/app/build.gradle.kts` | Android build config |
| `lib/screens/auth/login_screen.dart` | Authentication UI |
| `lib/screens/auth/signup_screen.dart` | Registration UI |

---

## Resources

- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)
- [Cloud Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
