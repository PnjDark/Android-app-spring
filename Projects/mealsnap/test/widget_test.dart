import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealsnap/main.dart';
import 'package:mealsnap/screens/scan_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MealSnapApp());

    // Verify that the ScanScreen is displayed.
    expect(find.byType(ScanScreen), findsOneWidget);
  });
}
