# mealsnap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# MealSnap+ — Post-UI Integration Implementation Notes

This integration brings in the full UI foundation created by Jules.  
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
