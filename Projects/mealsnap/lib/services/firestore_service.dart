import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  /// Create or update a user
  Future<void> setUser(String userId, UserModel user) async {
    await _db.collection('users').doc(userId).set(user.toFirestore(), SetOptions(merge: true));
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  /// Update user settings
  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    await _db.collection('users').doc(userId).update({
      'settings': settings.toMap(),
    });
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId, {
    required String name,
    String? photoUrl,
  }) async {
    await _db.collection('users').doc(userId).update({
      'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  // ==================== MEAL OPERATIONS ====================

  /// Add a new meal
  Future<String> addMeal(String userId, MealModel meal) async {
    final docRef = await _db.collection('users').doc(userId).collection('meals').add(meal.toFirestore());
    
    // Update daily stats
    await _updateDailyStats(userId, meal);
    
    return docRef.id;
  }

  /// Get meals for a specific date range
  Future<List<MealModel>> getMealsByDateRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => MealModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }

  /// Get recent meals (last 7 days)
  Future<List<MealModel>> getRecentMeals(String userId, {int limit = 10}) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('timestamp', isGreaterThan: sevenDaysAgo)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => MealModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching recent meals: $e');
      return [];
    }
  }

  /// Get top foods by frequency (last 30 days)
  Future<Map<String, int>> getFrequentFoods(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('timestamp', isGreaterThan: thirtyDaysAgo)
          .get();

      final frequency = <String, int>{};
      for (var doc in snapshot.docs) {
        final meal = MealModel.fromFirestore(doc);
        frequency[meal.foodName] = (frequency[meal.foodName] ?? 0) + 1;
      }

      return frequency;
    } catch (e) {
      print('Error fetching frequent foods: $e');
      return {};
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(String userId, String mealId) async {
    await _db.collection('users').doc(userId).collection('meals').doc(mealId).delete();
  }

  // ==================== DAILY STATS OPERATIONS ====================

  /// Get daily stats
  Future<DailyStatsModel?> getDailyStats(String userId, String date) async {
    try {
      final doc = await _db.collection('users').doc(userId).collection('dailyStats').doc(date).get();
      if (doc.exists) {
        return DailyStatsModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching daily stats: $e');
      return null;
    }
  }

  /// Get daily stats for a date range
  Future<List<DailyStatsModel>> getDailyStatsRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('dailyStats')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: _formatDate(startDate))
          .where(FieldPath.documentId, isLessThanOrEqualTo: _formatDate(endDate))
          .orderBy(FieldPath.documentId, descending: true)
          .get();

      return snapshot.docs.map((doc) => DailyStatsModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching daily stats range: $e');
      return [];
    }
  }

  /// Update daily stats (internal use)
  Future<void> _updateDailyStats(String userId, MealModel meal) async {
    final dateStr = _formatDate(meal.timestamp);
    
    await _db.collection('users').doc(userId).collection('dailyStats').doc(dateStr).set({
      'totalCalories': FieldValue.increment(meal.calories),
      'protein': FieldValue.increment(meal.protein),
      'carbs': FieldValue.increment(meal.carbs),
      'fats': FieldValue.increment(meal.fats),
      'mealCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // ==================== EXPENSE OPERATIONS ====================

  /// Add an expense
  Future<String> addExpense(String userId, ExpenseModel expense) async {
    final docRef = await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add(expense.toFirestore());
    
    // Update daily stats spending
    final dateStr = _formatDate(expense.timestamp);
    await _db.collection('users').doc(userId).collection('dailyStats').doc(dateStr).set({
      'totalSpent': FieldValue.increment(expense.amount),
    }, SetOptions(merge: true));
    
    return docRef.id;
  }

  /// Get monthly spending
  Future<Map<String, dynamic>> getMonthlySpending(String userId, {DateTime? month}) async {
    try {
      final date = month ?? DateTime.now();
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0);

      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .where('timestamp', isLessThanOrEqualTo: endOfMonth)
          .get();

      double total = 0;
      final byCategory = <String, double>{};

      for (var doc in snapshot.docs) {
        final expense = ExpenseModel.fromFirestore(doc);
        total += expense.amount;
        byCategory[expense.category] = (byCategory[expense.category] ?? 0) + expense.amount;
      }

      // Get user's monthly budget
      final user = await getUser(userId);
      final monthlyBudget = user?.settings.monthlyBudget ?? 100000;

      return {
        'total': total,
        'byCategory': byCategory,
        'remainingBudget': monthlyBudget - total,
        'budgetUsedPercent': (total / monthlyBudget) * 100,
      };
    } catch (e) {
      print('Error fetching monthly spending: $e');
      return {
        'total': 0,
        'byCategory': {},
        'remainingBudget': 0,
        'budgetUsedPercent': 0,
      };
    }
  }

  /// Get expenses for a date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }
  }

  // ==================== UTILITY METHODS ====================

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Batch add meals (for performance)
  Future<void> batchAddMeals(String userId, List<MealModel> meals) async {
    final batch = _db.batch();
    final userRef = _db.collection('users').doc(userId);

    for (var meal in meals) {
      final mealRef = userRef.collection('meals').doc();
      batch.set(mealRef, meal.toFirestore());

      // Update daily stats
      final dateStr = _formatDate(meal.timestamp);
      final statsRef = userRef.collection('dailyStats').doc(dateStr);
      batch.set(
        statsRef,
        {
          'totalCalories': FieldValue.increment(meal.calories),
          'protein': FieldValue.increment(meal.protein),
          'carbs': FieldValue.increment(meal.carbs),
          'fats': FieldValue.increment(meal.fats),
          'mealCount': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Get total stats for user (all time)
  Future<Map<String, dynamic>> getUserTotalStats(String userId) async {
    try {
      final meals = await _db
          .collection('users')
          .doc(userId)
          .collection('meals')
          .get();

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFats = 0;

      for (var doc in meals.docs) {
        final meal = MealModel.fromFirestore(doc);
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFats += meal.fats;
      }

      return {
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFats': totalFats,
        'mealCount': meals.docs.length,
      };
    } catch (e) {
      print('Error fetching user total stats: $e');
      return {
        'totalCalories': 0,
        'totalProtein': 0,
        'totalCarbs': 0,
        'totalFats': 0,
        'mealCount': 0,
      };
    }
  }
}
