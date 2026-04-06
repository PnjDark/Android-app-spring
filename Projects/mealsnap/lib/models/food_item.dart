import 'nutrition_info.dart';

class FoodItem {
  final String? id;
  final String name;
  final double quantity;
  final String unit;
  final NutritionInfo nutrition;

  FoodItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutrition,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map, [String? id]) {
    return FoodItem(
      id: id,
      name: map['foodName'] ?? map['name'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'g',
      nutrition: NutritionInfo.fromMap(map['nutrition'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodName': name,
      'quantity': quantity,
      'unit': unit,
      'nutrition': nutrition.toMap(),
    };
  }
}
