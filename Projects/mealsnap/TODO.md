# MealSnap Scan Feature Fix - TODO
Current working directory: Projects/mealsnap/

## Plan Steps (5 files total)

### 1. ✅ Create this TODO.md

### 2. Update pubspec.yaml (deps versions)
- Replace dependencies section with latest versions
- Run `flutter pub get`

### 3. Refactor lib/main.dart (add GoRouter)
- Replace with GoRouter config (/scan?mode=...)
- Update MainShell nav (Scan → context.push('/scan'))

### 4. Fix lib/services/gemini_service.dart (JSON schemas)
- Add responseMimeType='application/json', temperature=0.1
- Schema-specific prompts (meal/ingredients/receipt)
- Return parsed Map, no raw fallback

### 5. Fix lib/services/local_recognition_service.dart (filter)
- Replace keywords List → Set broad terms
- Clean _isFoodLabel

### 6. Fix lib/screens/scan_screen.dart (dynamic UI)
- Dynamic overlay tags from MLKit → Gemini
- Mode-aware status, progress spinner
- Disable shutter during analysis
- Use typed service returns

### 7. Test
- `flutter pub get`
- `flutter analyze`
- `flutter run`
- Manual test: all scan modes, dynamic tags, nutrition JSON

**Next step: 2/7 - pubspec.yaml**

