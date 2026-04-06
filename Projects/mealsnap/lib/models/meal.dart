import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_item.dart';

class Meal {
  final String id;
  final String userId;
  final String imageUrl;
  final String source; // camera, gallery, receipt, voice
  final DateTime timestamp;
  final List<FoodItem> items;
  final double totalCalories;
  final String? notes;
  final bool verified;

  Meal({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.source,
    required this.timestamp,
    required this.items,
    required this.totalCalories,
    this.notes,
    this.verified = false,
  });

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Meal(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageURL'] ?? '',
      source: data['source'] ?? 'camera',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      items: (data['items'] as List? ?? [])
          .map((item) => FoodItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalCalories: (data['totalCalories'] ?? 0.0).toDouble(),
      notes: data['notes'],
      verified: data['verified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageURL': imageUrl,
      'source': source,
      'timestamp': Timestamp.fromDate(timestamp),
      'items': items.map((item) => item.toMap()).toList(),
      'totalCalories': totalCalories,
      'notes': notes,
      'verified': verified,
    };
  }
}
