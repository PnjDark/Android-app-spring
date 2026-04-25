import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealsnap/main.dart';
import 'package:mealsnap/screens/auth/login_screen.dart';

import 'mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(
          'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'initializeCore') {
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'MOCK_API_KEY',
                'appId': 'MOCK_APP_ID',
                'messagingSenderId': 'MOCK_SENDER_ID',
                'projectId': 'MOCK_PROJECT_ID',
              },
              'pluginConstants': {},
            }
          ];
        }
        return null;
      },
    );
    await Firebase.initializeApp();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MealSnapApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
