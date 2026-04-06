import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final UserPreferences preferences;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    required this.preferences,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoURL': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences.toMap(),
    };
  }
}

class UserPreferences {
  final List<String> dietaryRestrictions;
  final double budgetLimit;
  final String defaultCurrency;

  UserPreferences({
    required this.dietaryRestrictions,
    required this.budgetLimit,
    required this.defaultCurrency,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      dietaryRestrictions: List<String>.from(map['dietaryRestrictions'] ?? []),
      budgetLimit: (map['budgetLimit'] ?? 0.0).toDouble(),
      defaultCurrency: map['defaultCurrency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dietaryRestrictions': dietaryRestrictions,
      'budgetLimit': budgetLimit,
      'defaultCurrency': defaultCurrency,
    };
  }
}
