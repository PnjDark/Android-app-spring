# MealSnap+ — AI-Powered Meal & Expense Tracking

A revolutionary Flutter mobile application that leverages AI, computer vision, and OCR to create a seamless food logging and meal planning experience.

## ✅ Current Status: PRODUCTION APK READY & RUNNING
- **Build Status**: ✅ APK successfully built and ready for deployment
- **File Location**: `build/app/outputs/flutter-apk/app-release.apk` (12.4MB)
- **Test Status**: ✅ All widget tests passing
- **Device Testing**: ✅ Successfully running on Samsung A05s (SM A055F)
- **Network Issues**: ✅ Resolved with `--no-pub` flag
- **NDK Issues**: ✅ Resolved by re-downloading corrupted NDK
- **Flutter Installation**: ✅ Stable channel (3.41.5) working perfectly

## Features

### 🎯 Core Features
- 📸 **Meal Photo Scanning** — AI identifies dishes and calculates nutrition
- 🖼️ **Image Import** — Process screenshots or gallery photos
- 🧾 **Receipt Scanning** — OCR extracts items and tracks expenses
- 🥬 **Ingredient Detection** — Get meal suggestions from fridge photos
- 🍳 **Meal Suggestions** — Generate recipes from detected ingredients
- 📊 **Nutrition Dashboard** — Track calories, macros, and trends
- 💰 **Expense Tracking** — Monitor food spending by category
- 🗣️ **Voice Input** — Log meals via natural language

### 🌍 Localization
Specifically tailored for African culinary contexts with support for:
- Ndolé, Eru, Fufu, Plantain, Jollof Rice, and more
- Regional price estimation
- Ingredient mapping for local foods

## Quick Start

### Prerequisites
- Flutter 3.11.3 or newer
- Dart 3.11.3 or newer
- Android SDK (for Android builds) or Xcode (for iOS)

### Installation

1. **Clone the repository**
```bash
cd Projects/mealsnap
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**

**Option A: Linux Desktop (requires linker tools fix - see SETUP_GUIDE.md)**
```bash
flutter run
```

**Option B: Android Device/Emulator (Recommended for testing)** ✅
```bash
flutter run --no-pub  # Use --no-pub to avoid network issues
# or specify device
flutter run -d <device-id> --no-pub
```

**Option C: Build for Release** ✅
```bash
flutter build apk --release  # Android - SUCCESSFULLY BUILT
flutter build ios            # iOS (macOS required)
flutter build web            # Web/Browser
```

## Build Issue Resolution

### Current Issue
The Flutter snap installation lacks linker tools needed for Linux builds:
```
ERROR: Target dart_build failed: Error: Failed to find any of [ld.lld, ld]
```

### Solutions ✅
See **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** for detailed solutions:
1. Install Flutter from source (recommended)
2. Install LLVM/linker tools
3. **Build for Android instead** ✅ (Successfully implemented - APK generated)

## Project Structure

```
lib/
├── main.dart                          # App entry point & bottom navigation
├── firebase_config.dart               # Firebase initialization wrapper
├── firebase_options.dart              # Auto-generated Firebase credentials
├── models.dart                        # Data models (ready for implementation)
├── logic.dart                         # Business logic (ready for implementation)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Login UI (Firebase integration ready)
│   │   └── signup_screen.dart        # Sign Up UI (Firebase integration ready)
│   ├── profile_screen.dart           # User profile & settings
│   ├── analytics_screen.dart         # Analytics dashboard & charts
│   └── meal_suggestions_screen.dart  # AI-powered meal recommendations

test/
└── widget_test.dart                  # UI validation tests

android/                               # Android configuration
├── app/
│   ├── google-services.json          # Firebase Android config (ADD AFTER SETUP)
│   └── build.gradle.kts
└── build.gradle.kts

ios/                                   # iOS configuration
linux/                                 # Linux desktop
web/                                   # Web/browser
```

## Architecture

### Technology Stack
- **Frontend**: Flutter (Dart) — Cross-platform UI
- **Design System**: Material 3 — Modern design language
- **Fonts**: Google Fonts (Plus Jakarta Sans, Inter)
- **AI/ML**: TensorFlow Lite (food recognition)
- **OCR**: Google ML Kit (receipt scanning)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Database**: Firestore + Hive (offline caching)

### UI Components Implemented
✅ Custom Material 3 Color Scheme  
✅ **Home Page**: Greeting, nutrition card, macro breakdown, action buttons, meal suggestions  
✅ **Analytics Screen**: 7-day charts, budget tracking, export to PDF  
✅ **Profile Screen**: Health goals, dietary preferences, settings menu  
✅ **Meal Suggestions**: Match percentage, ingredient-based recommendations  
✅ **Login Screen**: Email/password + Google Sign-In UI (Firebase integration ready)  
✅ **Sign Up Screen**: Registration UI with validation (Firebase integration ready)  
✅ Bottom Navigation Bar with 5 screens  
✅ SliverAppBar with Gradient Logo  

## Development Workflow

### Running Tests
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test
```

### Code Quality
```bash
flutter analyze                 # Check for lint errors
flutter format lib/            # Format code
```

### Hot Reload
```bash
# During development
flutter run
# Press 'r' for hot reload, 'R' for hot restart
```

## Implementation Roadmap

### Phase 1: MVP (Weeks 1-4) ✅ COMPLETED
- [x] Basic Flutter project structure
- [x] Material 3 themed home page
- [x] Navigation framework
- [x] Widget tests passing
- [x] **Production APK successfully built** ✅
- [x] Android deployment ready

### Phase 2: Core Integration (Weeks 5-10) 🔄 NEXT
- [ ] TensorFlow Lite food detection model
- [ ] Camera integration
- [ ] Image processing pipeline
- [ ] Meal suggestion engine

### Phase 3: Backend & Data (Weeks 11-16)
- [ ] Firebase authentication
- [ ] Firestore database schema
- [ ] Cloud Functions for AI processing
- [ ] Offline sync strategy

### Phase 4: Production (Weeks 17-20)
- [ ] App store submission
- [ ] Performance optimization
- [ ] User testing & refinement
- [ ] Documentation & deployment

## Testing

All UI tests pass successfully:
```bash
flutter test
# ✅ All tests passed!
```

Current test coverage:
- Widget rendering tests
- UI element existence validation
- Integration tests ready for next phase

## Deployment

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

## Documentation

- **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** — Build setup & troubleshooting
- **[documentation.md](./documentation.md)** — Full project documentation & architecture
- **[mealsnap_prototype.html](./mealsnap_prototype.html)** — Interactive Figma prototype
- **[Flutter Docs](https://flutter.dev/docs)** — Official Flutter documentation

## Version Info

- **Flutter**: 3.11.3+
- **Dart**: 3.11.3+
- **Material 3**: ✅ Enabled
- **Min SDK**: Android API 21+

## Contributors

**NARMAYE GBAMAN PATRICK JOYCE**  
Course: Android Application Development  
Date: March 2026

## License

This project is part of an academic course. All rights reserved.

## Support

For setup/build issues, see [SETUP_GUIDE.md](./SETUP_GUIDE.md).  
For feature requests or bugs, check the project documentation.

---

**Status**: Core UI implementation complete ✅ — Ready for AI/Backend integration 🚀  
Below are the guidelines and next steps for the complete app implementation.

## 🔹 Branch Strategy
- Main: Always stable and defense-ready.
- Develop: Used for backend, logic, and feature integration.
- UI/feature branches: For visual updates or isolated components created by Jules.

## 🔹 Next Steps for Implementation (Backend & Logic)

### 1. Set Up Clean Architecture Structure
Create the following directories under lib/:

lib/
  app/
  core/
  features/
    auth/
    meals/
    receipts/
    suggestions/
    profile/
    common/

### 2. Implement Firebase Initialization
- Add Firebase core
- Add Firebase Auth
- Add Cloud Firestore
- Prepare Google Sign-In
- Setup providers for dependency injection (Riverpod recommended)

### 3. Implement Domain Models
Create models for:
- Meal
- Ingredient
- Receipt
- Suggestion
- UserProfile

Place them in:
features/<feature>/domain/models/

### 4. Implement Services/Controllers
These handle all business logic:

features/<feature>/data/
  - auth_service.dart
  - meal_service.dart
  - receipt_service.dart
  - suggestion_service.dart
  - profile_service.dart

### 5. Connect UI to Logic (When Ready)
Jules' UI must plug into:
- Auth state stream
- Meal logging services
- Receipt scanning service
- Ingredient-to-meal suggestion engine
- Profile settings logic

### 6. AI & Sensor Features (Future Iterations)
- Image-to-meal recognition (AI API)
- Ingredient recognition from pictures
- Receipt OCR scanning
- Local gallery import for screenshots
- Camera + mic optional integrations

---

## 🔹 Collaboration Guidelines (For Jules)
- UI changes go to feature branches (no backend code).
- Keep widgets, pages, and components inside:
  features/<feature>/presentation/

## 🔹 Collaboration Guidelines (For Backend)
- Avoid modifying UI widgets.
- Only work inside app/, core/, and features/*/data or domain.
- Ensure everything is modular and testable.

---

This document must accompany all future contributions.
