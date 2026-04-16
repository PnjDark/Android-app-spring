import '../models.dart';

class NutritionDatabaseService {
  static final Map<String, NutritionInfo> _nutritionData = {
    // Common foods
    'apple': NutritionInfo(calories: 52, protein: 0.2, carbs: 14, fat: 0.2),
    'banana': NutritionInfo(calories: 89, protein: 1.1, carbs: 23, fat: 0.3),
    'chicken': NutritionInfo(calories: 165, protein: 31, carbs: 0, fat: 3.6),
    'rice': NutritionInfo(calories: 130, protein: 2.7, carbs: 28, fat: 0.3),
    'bread': NutritionInfo(calories: 265, protein: 9, carbs: 49, fat: 3.2),
    'egg': NutritionInfo(calories: 155, protein: 13, carbs: 1.1, fat: 11),
    'fish': NutritionInfo(calories: 206, protein: 22, carbs: 0, fat: 12),
    'beans': NutritionInfo(calories: 347, protein: 21, carbs: 63, fat: 1.2),

    // African dishes
    'jollof rice': NutritionInfo(calories: 180, protein: 4.5, carbs: 35, fat: 4.2),
    'fufu': NutritionInfo(calories: 267, protein: 1.2, carbs: 63, fat: 0.1),
    'eba': NutritionInfo(calories: 267, protein: 1.2, carbs: 63, fat: 0.1),
    'pounded yam': NutritionInfo(calories: 160, protein: 2.5, carbs: 37, fat: 0.3),
    'plantain': NutritionInfo(calories: 122, protein: 1.3, carbs: 32, fat: 0.4),
    'ndole': NutritionInfo(calories: 120, protein: 8.5, carbs: 12, fat: 6.2),
    'eru': NutritionInfo(calories: 95, protein: 7.2, carbs: 8.5, fat: 5.1),
    'egusi soup': NutritionInfo(calories: 140, protein: 12, carbs: 8, fat: 9.5),
    'akara': NutritionInfo(calories: 175, protein: 7.5, carbs: 18, fat: 9.2),
    'moi moi': NutritionInfo(calories: 120, protein: 8.5, carbs: 15, fat: 3.2),
    'suya': NutritionInfo(calories: 220, protein: 25, carbs: 2, fat: 12),
    'puff puff': NutritionInfo(calories: 180, protein: 3.5, carbs: 25, fat: 8.5),
    'meat pie': NutritionInfo(calories: 290, protein: 12, carbs: 30, fat: 14),
    'roti': NutritionInfo(calories: 150, protein: 4.2, carbs: 22, fat: 5.5),
    'chapati': NutritionInfo(calories: 135, protein: 3.8, carbs: 24, fat: 3.2),
    'ugali': NutritionInfo(calories: 160, protein: 3.2, carbs: 35, fat: 0.5),
    'banku': NutritionInfo(calories: 160, protein: 3.2, carbs: 35, fat: 0.5),
    'kenkey': NutritionInfo(calories: 160, protein: 3.2, carbs: 35, fat: 0.5),
    'waakye': NutritionInfo(calories: 180, protein: 6.5, carbs: 32, fat: 3.2),

    // African ingredients
    'cassava': NutritionInfo(calories: 160, protein: 1.4, carbs: 38, fat: 0.3),
    'yam': NutritionInfo(calories: 116, protein: 1.5, carbs: 27, fat: 0.1),
    'cocoyam': NutritionInfo(calories: 112, protein: 1.5, carbs: 26, fat: 0.2),
    'gari': NutritionInfo(calories: 360, protein: 2.5, carbs: 80, fat: 1.2),
    'groundnut': NutritionInfo(calories: 567, protein: 26, carbs: 16, fat: 49),
    'palm oil': NutritionInfo(calories: 884, protein: 0, carbs: 0, fat: 100),
    'coconut': NutritionInfo(calories: 354, protein: 3.3, carbs: 15, fat: 33),
    'mango': NutritionInfo(calories: 60, protein: 0.8, carbs: 15, fat: 0.4),
    'pineapple': NutritionInfo(calories: 50, protein: 0.5, carbs: 13, fat: 0.1),
    'avocado': NutritionInfo(calories: 160, protein: 2, carbs: 9, fat: 15),
    'pawpaw': NutritionInfo(calories: 43, protein: 0.5, carbs: 11, fat: 0.3),
    'cashew': NutritionInfo(calories: 553, protein: 18, carbs: 30, fat: 44),
    'tilapia': NutritionInfo(calories: 128, protein: 26, carbs: 0, fat: 2.7),
    'catfish': NutritionInfo(calories: 105, protein: 18, carbs: 0, fat: 2.1),
  };

  static NutritionInfo? getNutritionInfo(String foodName) {
    final normalizedName = foodName.toLowerCase().trim();
    return _nutritionData[normalizedName];
  }

  static List<String> searchFoods(String query) {
    final normalizedQuery = query.toLowerCase();
    return _nutritionData.keys
        .where((food) => food.contains(normalizedQuery))
        .toList();
  }

  static NutritionInfo estimateNutrition(List<String> ingredients, List<double> quantities) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (int i = 0; i < ingredients.length; i++) {
      final nutrition = getNutritionInfo(ingredients[i]);
      if (nutrition != null) {
        final quantity = quantities[i] / 100; // Convert to 100g portions
        totalCalories += nutrition.calories * quantity;
        totalProtein += nutrition.protein * quantity;
        totalCarbs += nutrition.carbs * quantity;
        totalFat += nutrition.fat * quantity;
      }
    }

    return NutritionInfo(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
    );
  }
}