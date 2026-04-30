import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firebase_models.dart';
import 'firestore_service.dart';
import 'groq_service.dart';
import 'nutrition_database_service.dart';

/// Represents a personalized meal suggestion for the user
class PersonalizedSuggestion {
  final String foodName;
  final String reason;
  final String category; // 'frequent', 'alternative', 'variety', 'healthy'
  final double estimatedCalories;
  final double estimatedProtein;
  final double estimatedCarbs;
  final double estimatedFats;
  final DateTime suggestedAt;

  PersonalizedSuggestion({
    required this.foodName,
    required this.reason,
    required this.category,
    required this.estimatedCalories,
    required this.estimatedProtein,
    required this.estimatedCarbs,
    required this.estimatedFats,
    required this.suggestedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'reason': reason,
      'category': category,
      'estimatedCalories': estimatedCalories,
      'estimatedProtein': estimatedProtein,
      'estimatedCarbs': estimatedCarbs,
      'estimatedFats': estimatedFats,
      'suggestedAt': suggestedAt,
    };
  }

  factory PersonalizedSuggestion.fromMap(Map<String, dynamic> map) {
    return PersonalizedSuggestion(
      foodName: map['foodName'] ?? '',
      reason: map['reason'] ?? '',
      category: map['category'] ?? 'frequent',
      estimatedCalories: (map['estimatedCalories'] ?? 0).toDouble(),
      estimatedProtein: (map['estimatedProtein'] ?? 0).toDouble(),
      estimatedCarbs: (map['estimatedCarbs'] ?? 0).toDouble(),
      estimatedFats: (map['estimatedFats'] ?? 0).toDouble(),
      suggestedAt: (map['suggestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Service for generating personalized meal suggestions based on user preferences and habits
class SuggestionService {
  final FirestoreService _firestoreService;
  final GroqService _groq;

  final Map<String, List<PersonalizedSuggestion>> _suggestionCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(hours: 1);

  SuggestionService(this._firestoreService, this._groq);

  /// Get personalized suggestions for a user
  Future<List<PersonalizedSuggestion>> getPersonalizedSuggestions(String userId) async {
    // Check cache first
    if (_isCacheValid(userId)) {
      return _suggestionCache[userId] ?? [];
    }

    final suggestions = await _generateSuggestions(userId);

    // Cache the results
    _suggestionCache[userId] = suggestions;
    _cacheTimestamps[userId] = DateTime.now();

    return suggestions;
  }

  /// Check if cache is still valid
  bool _isCacheValid(String userId) {
    final lastUpdate = _cacheTimestamps[userId];
    if (lastUpdate == null) return false;

    return DateTime.now().difference(lastUpdate) < _cacheDuration;
  }

  /// Generate suggestions based on user data
  Future<List<PersonalizedSuggestion>> _generateSuggestions(String userId) async {
    final suggestions = <PersonalizedSuggestion>[];

    // Get user preferences and frequent foods
    final user = await _firestoreService.getUser(userId);
    final frequentFoods = await _firestoreService.getFrequentFoods(userId);

    if (user == null || frequentFoods.isEmpty) {
      return suggestions;
    }

    final settings = user.settings;

    // 1. Suggest top frequent meals (if not eaten recently)
    suggestions.addAll(await _suggestFrequentMeals(userId, frequentFoods, settings));

    // 2. Suggest low-carb alternatives if user prefers low-carb
    if (settings.dietaryPreferences.contains('low_carb')) {
      suggestions.addAll(await _suggestLowCarbAlternatives(userId, frequentFoods));
    }

    // 3. Suggest variety based on preferred cuisines
    suggestions.addAll(await _suggestCuisineVariety(userId, settings, frequentFoods));

    // 4. Suggest healthy alternatives based on health goal
    suggestions.addAll(await _suggestHealthGoalAlternatives(userId, settings, frequentFoods));

    suggestions.sort((a, b) => _getSuggestionPriority(b).compareTo(_getSuggestionPriority(a)));
    final top = suggestions.take(5).toList();

    // Enrich reason strings with Groq — falls back to originals if unavailable.
    final enriched = await _groq.enrichReasons(
      suggestions: top
          .map((s) => (
                foodName: s.foodName,
                category: s.category,
                originalReason: s.reason,
              ))
          .toList(),
      healthGoal: user.settings.healthGoal,
    );

    return List.generate(
      top.length,
      (i) => PersonalizedSuggestion(
        foodName: top[i].foodName,
        reason: enriched[i],
        category: top[i].category,
        estimatedCalories: top[i].estimatedCalories,
        estimatedProtein: top[i].estimatedProtein,
        estimatedCarbs: top[i].estimatedCarbs,
        estimatedFats: top[i].estimatedFats,
        suggestedAt: top[i].suggestedAt,
      ),
    );
  }

  /// Suggest meals from user's frequent list that they haven't eaten recently
  Future<List<PersonalizedSuggestion>> _suggestFrequentMeals(
    String userId,
    Map<String, int> frequentFoods,
    UserSettings settings,
  ) async {
    final suggestions = <PersonalizedSuggestion>[];

    // Get meals from last 7 days to avoid suggesting recently eaten foods
    final recentMeals = await _firestoreService.getMealsByDateRange(
      userId,
      startDate: DateTime.now().subtract(Duration(days: 7)),
      endDate: DateTime.now(),
    );

    final recentFoodNames = recentMeals.map((meal) => meal.foodName.toLowerCase()).toSet();

    // Sort frequent foods by frequency
    final sortedFrequentFoods = frequentFoods.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedFrequentFoods.take(3)) {
      final foodName = entry.key;
      final frequency = entry.value;

      // Skip if eaten recently
      if (recentFoodNames.contains(foodName.toLowerCase())) continue;

      // Skip if doesn't match dietary preferences
      if (!_matchesDietaryPreferences(foodName, settings.dietaryPreferences)) continue;

      final nutrition = NutritionDatabaseService.getNutritionInfo(foodName);
      if (nutrition != null) {
        suggestions.add(PersonalizedSuggestion(
          foodName: foodName,
          reason: 'You\'ve enjoyed this ${frequency}x in the last 30 days',
          category: 'frequent',
          estimatedCalories: nutrition.calories,
          estimatedProtein: nutrition.protein,
          estimatedCarbs: nutrition.carbs,
          estimatedFats: nutrition.fat,
          suggestedAt: DateTime.now(),
        ));
      }
    }

    return suggestions;
  }

  /// Suggest low-carb alternatives to high-carb frequent foods
  Future<List<PersonalizedSuggestion>> _suggestLowCarbAlternatives(
    String userId,
    Map<String, int> frequentFoods,
  ) async {
    final suggestions = <PersonalizedSuggestion>[];

    final lowCarbAlternatives = {
      'rice': ['cauliflower rice', 'quinoa', 'broccoli'],
      'bread': ['lettuce wraps', 'cloud bread', 'almond flour bread'],
      'pasta': ['zucchini noodles', 'spaghetti squash', 'shirataki noodles'],
      'potatoes': ['cauliflower mash', 'turnips', 'sweet potato'],
      'jollof rice': ['cauliflower jollof', 'quinoa jollof'],
      'eba': ['cauliflower mash', 'okra soup with vegetables'],
      'fufu': ['cauliflower fufu', 'mango fufu'],
    };

    for (final entry in frequentFoods.entries) {
      final foodName = entry.key.toLowerCase();

      if (lowCarbAlternatives.containsKey(foodName)) {
        final alternatives = lowCarbAlternatives[foodName]!;

        for (final alternative in alternatives.take(1)) { // Take one alternative per food
          final nutrition = NutritionDatabaseService.getNutritionInfo(alternative);
          if (nutrition != null && nutrition.carbs < 20) { // Low carb threshold
            suggestions.add(PersonalizedSuggestion(
              foodName: alternative,
              reason: 'Low-carb alternative to ${entry.key}',
              category: 'alternative',
              estimatedCalories: nutrition.calories,
              estimatedProtein: nutrition.protein,
              estimatedCarbs: nutrition.carbs,
              estimatedFats: nutrition.fat,
              suggestedAt: DateTime.now(),
            ));
          }
        }
      }
    }

    return suggestions.take(2).toList(); // Limit to 2 low-carb suggestions
  }

  /// Suggest variety based on preferred cuisines
  Future<List<PersonalizedSuggestion>> _suggestCuisineVariety(
    String userId,
    UserSettings settings,
    Map<String, int> frequentFoods,
  ) async {
    final suggestions = <PersonalizedSuggestion>[];

    final cuisineSuggestions = {
      'african': ['suya', 'moi moi', 'akara', 'puff puff', 'meat pie'],
      'international': ['grilled chicken', 'salad', 'stir fry vegetables', 'fish curry'],
      'comfort': ['chicken soup', 'beef stew', 'vegetable soup', 'rice pudding'],
      'low_calorie': ['green salad', 'grilled fish', 'steamed vegetables', 'fruit salad'],
    };

    for (final cuisine in settings.preferredCuisines) {
      if (cuisineSuggestions.containsKey(cuisine)) {
        final foods = cuisineSuggestions[cuisine]!;

        for (final food in foods) {
          // Skip if already in frequent foods
          if (!frequentFoods.containsKey(food.toLowerCase())) {
            final nutrition = NutritionDatabaseService.getNutritionInfo(food);
            if (nutrition != null) {
              suggestions.add(PersonalizedSuggestion(
                foodName: food,
                reason: 'Try something new from your preferred $cuisine cuisine',
                category: 'variety',
                estimatedCalories: nutrition.calories,
                estimatedProtein: nutrition.protein,
                estimatedCarbs: nutrition.carbs,
                estimatedFats: nutrition.fat,
                suggestedAt: DateTime.now(),
              ));
            }
          }
        }
      }
    }

    return suggestions.take(2).toList(); // Limit to 2 variety suggestions
  }

  /// Suggest alternatives based on health goals
  Future<List<PersonalizedSuggestion>> _suggestHealthGoalAlternatives(
    String userId,
    UserSettings settings,
    Map<String, int> frequentFoods,
  ) async {
    final suggestions = <PersonalizedSuggestion>[];

    final healthGoalSuggestions = {
      'lose_weight': ['grilled chicken salad', 'steamed fish', 'vegetable stir fry', 'green smoothie'],
      'gain_muscle': ['chicken breast', 'eggs', 'beans', 'nuts', 'greek yogurt'],
      'maintain': ['balanced meal', 'mixed vegetables', 'lean protein', 'whole grains'],
    };

    if (healthGoalSuggestions.containsKey(settings.healthGoal)) {
      final foods = healthGoalSuggestions[settings.healthGoal]!;

      for (final food in foods) {
        // Skip if already in frequent foods
        if (!frequentFoods.containsKey(food.toLowerCase())) {
          final nutrition = NutritionDatabaseService.getNutritionInfo(food);
          if (nutrition != null) {
            suggestions.add(PersonalizedSuggestion(
              foodName: food,
              reason: 'Supports your ${settings.healthGoal.replaceAll('_', ' ')} goal',
              category: 'healthy',
              estimatedCalories: nutrition.calories,
              estimatedProtein: nutrition.protein,
              estimatedCarbs: nutrition.carbs,
              estimatedFats: nutrition.fat,
              suggestedAt: DateTime.now(),
            ));
          }
        }
      }
    }

    return suggestions.take(2).toList(); // Limit to 2 health goal suggestions
  }

  /// Check if a food matches user's dietary preferences
  bool _matchesDietaryPreferences(String foodName, List<String> preferences) {
    final food = foodName.toLowerCase();

    for (final preference in preferences) {
      switch (preference) {
        case 'vegetarian':
          if (food.contains('chicken') || food.contains('beef') || food.contains('fish') ||
              food.contains('pork') || food.contains('meat')) {
            return false;
          }
          break;
        case 'vegan':
          if (food.contains('chicken') || food.contains('beef') || food.contains('fish') ||
              food.contains('pork') || food.contains('meat') || food.contains('egg') ||
              food.contains('milk') || food.contains('cheese')) {
            return false;
          }
          break;
        case 'no_pork':
          if (food.contains('pork')) {
            return false;
          }
          break;
      }
    }

    return true;
  }

  /// Get priority score for suggestion ordering
  int _getSuggestionPriority(PersonalizedSuggestion suggestion) {
    switch (suggestion.category) {
      case 'frequent': return 4;
      case 'alternative': return 3;
      case 'healthy': return 2;
      case 'variety': return 1;
      default: return 0;
    }
  }

  /// Clear cache for a user (useful when preferences change)
  void clearCache(String userId) {
    _suggestionCache.remove(userId);
    _cacheTimestamps.remove(userId);
  }
}