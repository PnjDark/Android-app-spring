import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

Future<T> setupFirebase<T>(Future<T> Function() callback) async {
  await Firebase.initializeApp();
  return callback();
}

void setupFirebaseAuthMocks() {
  final auth = MockFirebaseAuth();
  // Your custom mock setup for FirebaseAuth goes here, if needed.
}
