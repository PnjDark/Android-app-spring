import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Meal Collection Reference
  CollectionReference get _mealsCollection => _db.collection('meals');

  // Save a new meal
  Future<void> saveMeal(Meal meal) async {
    try {
      await _mealsCollection.doc(meal.id).set(meal.toFirestore());
    } catch (e) {
      print('Error saving meal: $e');
      rethrow;
    }
  }

  // Get meals for a specific user
  Stream<List<Meal>> streamUserMeals(String uid) {
    return _mealsCollection
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList());
  }

  // Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _mealsCollection.doc(mealId).delete();
    } catch (e) {
      print('Error deleting meal: $e');
      rethrow;
    }
  }

  // Update a meal
  Future<void> updateMeal(Meal meal) async {
    try {
      await _mealsCollection.doc(meal.id).update(meal.toFirestore());
    } catch (e) {
      print('Error updating meal: $e');
      rethrow;
    }
  }
}
