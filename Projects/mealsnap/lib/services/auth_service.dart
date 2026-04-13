import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static User? get currentUser => auth.currentUser;

  static Stream<User?> authStateChanges() => auth.authStateChanges();

  static Future<void> signIn(String email, String password) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await _updateUserDocument(credential.user);
  }

  static Future<void> signUp(String name, String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.reload();
      await _updateUserDocument(user);
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<void> updateDisplayName(String name) async {
    final user = currentUser;
    if (user == null) return;

    await user.updateDisplayName(name.trim());
    await user.reload();
    await _updateUserDocument(user);
  }

  static Future<void> _updateUserDocument(User? user) async {
    if (user == null) return;

    final doc = db.collection('users').doc(user.uid);
    await doc.set(
      {
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'lastSignIn': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
