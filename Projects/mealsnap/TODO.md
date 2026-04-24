# Flutter Mealsnap Debugging TODO

## Completed
- [x] Plan approved for main.dart brace fix and Symbols handling

## In Progress
1. **Read and surgically fix main.dart** - Remove broken NavigationDestination block (~lines 746+), uncomment Symbols import
2. Run `cd Projects/mealsnap && flutter analyze` to verify syntax
3. Fix const constructor errors (LoginScreen, ScanScreen) - remove invalid 'const'
4. Replace remaining Symbols.* across screens with Icons.*
5. Add missing imports/definitions for ScanScreen, ScanMode enum
6. `flutter pub get && flutter run` full test

## Pending
- Global Icons migration if Symbols package issues persist
- Full build/test APK
