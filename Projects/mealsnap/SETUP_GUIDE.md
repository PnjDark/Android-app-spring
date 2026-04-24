# MealSnap+ Setup & Build Guide

## Overview
MealSnap+ is a Flutter application built with a modern Material 3 design system. The app implements the exact UI from the Figma prototype with real Flutter widgets.

## ✅ Build Status: SUCCESSFUL
- **APK Build**: ✅ Completed successfully
- **Test Suite**: ✅ All tests passing
- **Production APK**: Generated at `build/app/outputs/flutter-apk/app-release.apk` (12.4MB)

## Build Targets & Issues

### ⚠️ Linux Build Issue

The Flutter snap installation lacks the required linker tools (`ld`/`ld.lld`). To resolve this:

**Option 1: Install Flutter from Source (Recommended)**

```bash
# Remove snap version
sudo snap remove flutter

# Install from official Flutter releases
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"

# Add to your shell profile permanently
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter --version
flutter doctor
```

**Option 2: Install Required Build Tools (Linux)**
```bash
# Add LLVM/linker to path manually
sudo apt-get install binutils-dev
export LD_LIBRARY_PATH=/usr/lib/llvm-10/lib:$LD_LIBRARY_PATH
flutter run
```

**Option 3: Build for Android Instead** ✅ (Successfully implemented)
```bash
# Install Android Studio and SDK
flutter config --enable-android
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Build Targets Supported

### 1. **Android** ✅ (Successfully Built)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (12.4MB)
# Status: ✅ Build successful, ready for deployment
```

### 2. **Linux Desktop** (After fixing build tools)
```bash
flutter run -d linux
# or build production
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

### 3. **Web** (For browser testing)
```bash
flutter run -d web
# or build production
flutter build web --release
# Output: build/web/
```

### 4. **iOS** (macOS required)
```bash
flutter build ios --release
```

## Development Setup

### Prerequisites
- Flutter 3.11.3+
- Dart 3.11.3+
- Android SDK (for Android builds)
- VS Code with Flutter extension

### Install Dependencies
```bash
cd /path/to/mealsnap
flutter pub get
```

### Run Tests
```bash
flutter test
# Status: ✅ All tests passing
```

### Run on Device/Emulator
```bash
# List devices
flutter devices

# Run on connected device (recommended for network issues)
flutter run --no-pub

# Run on specific device
flutter run -d <device-id> --no-pub

# Alternative: Run normally (may have network issues)
flutter run
```

### Network Issues During Run
If you encounter "Connection reset" errors during `flutter run`:

**Solution: Use offline mode**
```bash
flutter run --no-pub
```

This bypasses package manifest fetching that can fail due to network connectivity issues.

## Project Structure

```
lib/
├── main.dart              # App entry point & UI implementation
├── main_old.dart          # Original boilerplate (backup)
├── models.dart            # Data models (implementation ready)
└── logic.dart             # Business logic (implementation ready)

test/
└── widget_test.dart       # UI tests

android/                   # Android build configuration
ios/                       # iOS build configuration
linux/                     # Linux build configuration
web/                       # Web build configuration
```

## Current Implementation Status

### ✅ Completed
- [x] Custom Material 3 theme with brand colors
- [x] Home page with all UI components
  - Greeting section
  - Nutrition tracking card
  - Macro breakdown
  - Quick action buttons (Meal Photo, Ingredients, Receipt, Voice)
  - Suggested meal card
  - Recent activity feed
- [x] Bottom navigation bar with FAB
- [x] Google Fonts integration  
- [x] Unit & widget tests passing
- [x] Code analysis warnings resolved (only deprecation notes)

### 🔄 Next Steps
1. **AI Integration** (TensorFlow Lite for food recognition)
2. **Camera Features** (image_picker, camera packages)
3. **Data Persistence** (Firebase/Firestore)
4. **Authentication** (Google Sign-In)
5. **Analytics Dashboard**
6. **Receipt OCR** (Google ML Kit)

## Common Issues & Solutions

### Issue: "Failed to find any of [ld.lld, ld] in LocalDirectory"
**Solution:** See "Linux Build Issue" section above

### Issue: "No supported devices connected"
```bash
# Enable platform
flutter config --enable-linux-desktop

# Or build for Android
flutter config --enable-android
```

### Issue: "NDK did not have a source.properties file"
**Solution: Delete and re-download NDK**
```bash
# Find the corrupted NDK version
ls ~/Android/Sdk/ndk/

# Delete the corrupted NDK (replace VERSION with actual version)
rm -rf ~/Android/Sdk/ndk/VERSION

# Flutter will automatically re-download the correct NDK on next build
flutter run --no-pub
```

### Issue: "Gradle task assembleRelease failed"
**Solution: Clean and rebuild**
```bash
# Clean build cache
flutter clean
flutter pub get
flutter build apk --release
```

### Issue: "Build interrupted or hangs with Flutter master channel"
**Solution: Switch to stable channel**
```bash
# Switch to stable channel
cd ~/flutter
git checkout stable
git pull

# Verify version
flutter --version

# Try build again
flutter build apk --release
```

## Performance Optimization

### Current Metrics
- App size (debug APK): ~50-60MB
- Build time: ~2-3 minutes (first build)
- Hot reload: <1 second
- Test execution: <1 second

### Future Optimization
- App size reduction: Code splitting, asset optimization
- Build time: Parallel compilation
- Runtime: Lazy loading, caching strategies

## Deployment

### Android Release
```bash
# Generate release APK
flutter build apk --release

# Generate release app bundle (Google Play)
flutter build appbundle --release
```

### Linux Release
```bash
flutter build linux --release
```

### Web Release
```bash
flutter build web --release
# Deploy from build/web/ directory
```

## Troubleshooting

**Q: App crashes on startup?**
A: Check `flutter logs`, ensure all platforms are properly generated

**Q: Hot reload not working?**
A: Try hot restart (`r`), or `flutter pub get` + restart

**Q: Build hangs?**
A: Check internet connection, run `flutter clean` and try again

## Documentation & Resources

- [Flutter Official Docs](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [MealSnap+ Documentation](./documentation.md)
- [UI Prototype](./mealsnap_prototype.html)

## Support & Contribution

For issues or improvements:
1. Check existing issues in the repository
2. Run `flutter doctor` for environment diagnostics
3. Provide `flutter logs` output with bug reports
