import 'package:cloud_firestore/cloud_firestore.dart';

/// User model matching Firestore structure
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final UserSettings settings;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    required this.settings,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      settings: UserSettings.fromMap(data['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'settings': settings.toMap(),
    };
  }
}

/// User settings/preferences
class UserSettings {
  final int dailyCalorieGoal;
  final double monthlyBudget;
  final List<String> dietaryPreferences;
  final String healthGoal;
  final List<String> preferredCuisines;
  final int? age;
  final double? height;
  final double? currentWeight;
  final double? targetWeight;

  UserSettings({
    this.dailyCalorieGoal = 2000,
    this.monthlyBudget = 100000,
    this.dietaryPreferences = const [],
    this.healthGoal = 'maintain',
    this.preferredCuisines = const ['african', 'international'],
    this.age,
    this.height,
    this.currentWeight,
    this.targetWeight,
  });

  factory UserSettings.fromMap(Map<String, dynamic> data) {
    return UserSettings(
      dailyCalorieGoal: data['dailyCalorieGoal'] ?? 2000,
      monthlyBudget: (data['monthlyBudget'] ?? 100000).toDouble(),
      dietaryPreferences: List<String>.from(data['dietaryPreferences'] ?? []),
      healthGoal: data['healthGoal'] ?? 'maintain',
      preferredCuisines: List<String>.from(data['preferredCuisines'] ?? ['african', 'international']),
      age: data['age'],
      height: data['height']?.toDouble(),
      currentWeight: data['currentWeight']?.toDouble(),
      targetWeight: data['targetWeight']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyCalorieGoal': dailyCalorieGoal,
      'monthlyBudget': monthlyBudget,
      'dietaryPreferences': dietaryPreferences,
      'healthGoal': healthGoal,
      'preferredCuisines': preferredCuisines,
      'age': age,
      'height': height,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
    };
  }
}

/// Meal entry model
class MealModel {
  final String id;
  final String userId;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime timestamp;
  final String? imageUrl;
  final String source; // 'camera', 'gallery', 'receipt', 'voice'
  final bool verified;
  final String? notes;

  MealModel({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.timestamp,
    this.imageUrl,
    required this.source,
    this.verified = false,
    this.notes,
  });

  factory MealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      foodName: data['foodName'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fats: (data['fats'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      source: data['source'] ?? 'camera',
      verified: data['verified'] ?? false,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'source': source,
      'verified': verified,
      'notes': notes,
    };
  }
}

/// Daily stats aggregate
class DailyStatsModel {
  final String date; // YYYY-MM-DD format
  final double totalCalories;
  final double totalSpent;
  final int mealCount;
  final double protein;
  final double carbs;
  final double fats;

  DailyStatsModel({
    required this.date,
    required this.totalCalories,
    required this.totalSpent,
    required this.mealCount,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory DailyStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyStatsModel(
      date: doc.id,
      totalCalories: (data['totalCalories'] ?? 0).toDouble(),
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      mealCount: data['mealCount'] ?? 0,
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fats: (data['fats'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalCalories': totalCalories,
      'totalSpent': totalSpent,
      'mealCount': mealCount,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }
}

/// Expense model
class ExpenseModel {
  final String id;
  final String userId;
  final double amount;
  final String category; // 'groceries', 'restaurant', 'snacks'
  final String? mealId;
  final DateTime timestamp;
  final String? description;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.mealId,
    required this.timestamp,
    this.description,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'groceries',
      mealId: data['mealId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'mealId': mealId,
      'timestamp': timestamp,
      'description': description,
    };
  }
}
