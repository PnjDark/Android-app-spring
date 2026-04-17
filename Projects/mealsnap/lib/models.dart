import 'package:cloud_firestore/cloud_firestore.dart';

class MealEntry {
  final String id;
  final String userId;
  final String type; // 'meal', 'ingredients', 'receipt'
  final String description;
  final Map<String, dynamic> analysis;
  final DateTime timestamp;
  final String? imageUrl;

  MealEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.analysis,
    required this.timestamp,
    this.imageUrl,
  });

  factory MealEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      analysis: data['analysis'] ?? {},
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'description': description,
      'analysis': analysis,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
    };
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}