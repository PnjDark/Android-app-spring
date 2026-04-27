import '../models/firebase_models.dart';

class MealSuggestion {
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTime; // in minutes
  final String difficulty;
  final NutritionInfo nutrition;

  MealSuggestion({
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.difficulty,
    required this.nutrition,
  });
}

class MealSuggestionService {
  static final List<MealSuggestion> _suggestions = [
    MealSuggestion(
      name: 'Jollof Rice with Chicken',
      ingredients: ['rice', 'chicken', 'tomato', 'onion', 'pepper', 'palm oil'],
      instructions: [
        'Cook rice with tomato paste and spices',
        'Fry chicken pieces until golden',
        'Combine rice and chicken, simmer for 20 minutes'
      ],
      cookingTime: 45,
      difficulty: 'Medium',
      nutrition: NutritionInfo(calories: 450, protein: 25, carbs: 55, fat: 15),
    ),
    MealSuggestion(
      name: 'Egusi Soup with Fufu',
      ingredients: ['egusi', 'palm oil', 'fish', 'onion', 'pepper', 'spinach'],
      instructions: [
        'Fry egusi seeds with palm oil',
        'Add fish and vegetables, simmer for 30 minutes',
        'Serve with pounded fufu'
      ],
      cookingTime: 40,
      difficulty: 'Medium',
      nutrition: NutritionInfo(calories: 380, protein: 20, carbs: 45, fat: 18),
    ),
    MealSuggestion(
      name: 'Moi Moi (Steamed Bean Pudding)',
      ingredients: ['beans', 'palm oil', 'onion', 'pepper', 'fish'],
      instructions: [
        'Blend beans with seasonings',
        'Add fish pieces and palm oil',
        'Steam in banana leaves for 45 minutes'
      ],
      cookingTime: 50,
      difficulty: 'Easy',
      nutrition: NutritionInfo(calories: 220, protein: 12, carbs: 28, fat: 8),
    ),
    MealSuggestion(
      name: 'Suya Skewers',
      ingredients: ['beef', 'groundnut', 'onion', 'pepper', 'spices'],
      instructions: [
        'Marinate beef strips in groundnut paste',
        'Skewer and grill for 15 minutes',
        'Serve with sliced onions and tomatoes'
      ],
      cookingTime: 25,
      difficulty: 'Easy',
      nutrition: NutritionInfo(calories: 320, protein: 35, carbs: 8, fat: 18),
    ),
    MealSuggestion(
      name: 'Plantain and Egg Sauce',
      ingredients: ['plantain', 'egg', 'tomato', 'onion', 'palm oil'],
      instructions: [
        'Fry plantain slices until golden',
        'Make tomato sauce with eggs',
        'Serve plantain with egg sauce'
      ],
      cookingTime: 20,
      difficulty: 'Easy',
      nutrition: NutritionInfo(calories: 280, protein: 8, carbs: 35, fat: 12),
    ),
    MealSuggestion(
      name: 'Waakye with Fish',
      ingredients: ['rice', 'beans', 'fish', 'onion', 'spices'],
      instructions: [
        'Cook rice and beans together',
        'Season with spices and serve with grilled fish'
      ],
      cookingTime: 60,
      difficulty: 'Medium',
      nutrition: NutritionInfo(calories: 420, protein: 22, carbs: 65, fat: 8),
    ),
  ];

  static List<MealSuggestion> getSuggestions(List<String> availableIngredients) {
    final normalizedIngredients = availableIngredients
        .map((ing) => ing.toLowerCase().trim())
        .toSet();

    return _suggestions.where((suggestion) {
      final requiredIngredients = suggestion.ingredients
          .map((ing) => ing.toLowerCase().trim())
          .toSet();

      // Calculate match percentage
      final matchedIngredients = requiredIngredients.intersection(normalizedIngredients);
      final matchPercentage = matchedIngredients.length / requiredIngredients.length;

      return matchPercentage >= 0.5; // At least 50% of ingredients available
    }).toList()
      ..sort((a, b) {
        // Sort by match percentage (descending)
        final aMatch = _calculateMatchPercentage(a, normalizedIngredients);
        final bMatch = _calculateMatchPercentage(b, normalizedIngredients);
        return bMatch.compareTo(aMatch);
      });
  }

  static double _calculateMatchPercentage(MealSuggestion suggestion, Set<String> available) {
    final required = suggestion.ingredients
        .map((ing) => ing.toLowerCase().trim())
        .toSet();

    final matched = required.intersection(available);
    return matched.length / required.length;
  }

  static MealSuggestion? getSuggestionByName(String name) {
    return _suggestions.firstWhere(
      (suggestion) => suggestion.name.toLowerCase() == name.toLowerCase(),
    );
  }

  static List<String> getAllRecipeNames() {
    return _suggestions.map((s) => s.name).toList();
  }
}