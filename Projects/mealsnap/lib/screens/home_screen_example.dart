import 'package:flutter/material.dart';
import '../models/firebase_models.dart';
import '../services/firestore_service.dart';
import '../widgets/nutrition_card.dart';
import '../widgets/nutrition_sections.dart';

/// Example Home Screen showing how to use nutrition widgets with Firestore data
class HomeScreenExample extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;

  const HomeScreenExample({
    super.key,
    required this.userId,
    required this.firestoreService,
  });

  @override
  State<HomeScreenExample> createState() => _HomeScreenExampleState();
}

class _HomeScreenExampleState extends State<HomeScreenExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MealSnap'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh daily stats and recent meals
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Nutrition Card
                Text(
                  'Today\'s Nutrition',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildDailyNutritionCard(),
                const SizedBox(height: 24),

                // Weekly Summary
                Text(
                  'Weekly Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                WeeklyNutritionSummary(
                  userId: widget.userId,
                  firestoreService: widget.firestoreService,
                ),
                const SizedBox(height: 24),

                // Recent Meals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Meals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to full history screen
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(...)));
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecentMealsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the daily nutrition card with real-time data from Firestore
  Widget _buildDailyNutritionCard() {
    return FutureBuilder<(DailyStatsModel?, UserModel?)>(
      future: Future.wait([
        _getDailyStats(),
        widget.firestoreService.getUser(widget.userId),
      ]).then(
        (results) => (results[0] as DailyStatsModel?, results[1] as UserModel?),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading nutrition data: ${snapshot.error}'),
          );
        }

        final (dailyStats, user) = snapshot.data ?? (null, null);

        // Default values if no data
        final calories = dailyStats?.totalCalories ?? 0;
        final protein = dailyStats?.protein ?? 0;
        final carbs = dailyStats?.carbs ?? 0;
        final fats = dailyStats?.fats ?? 0;
        final calorieGoal = user?.settings.dailyCalorieGoal.toDouble() ?? 2000;

        return NutritionCard(
          calories: calories,
          protein: protein,
          carbs: carbs,
          fats: fats,
          calorieGoal: calorieGoal,
          showGoal: true,
        );
      },
    );
  }

  /// Builds the recent meals list with real-time data
  Widget _buildRecentMealsList() {
    return FutureBuilder<List<MealModel>>(
      future: _getRecentMeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final meals = snapshot.data ?? [];

        if (meals.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.fastfood_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No meals logged yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by scanning a meal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return MealNutritionPreview(
              meal: meals[index],
              onTap: () {
                // Handle meal tap - show details or edit
              },
            );
          },
        );
      },
    );
  }

  /// Helper method to get today's daily stats
  Future<DailyStatsModel?> _getDailyStats() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return widget.firestoreService.getDailyStats(widget.userId, todayStr);
  }

  /// Helper method to get recent meals
  Future<List<MealModel>> _getRecentMeals() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return widget.firestoreService.getMealsByDateRange(
      widget.userId,
      startDate: sevenDaysAgo,
      endDate: now,
    );
  }
}

/// Example of how to use just the NutritionCompactCard in a smaller space
class CompactNutritionExample extends StatelessWidget {
  const CompactNutritionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compact Card Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Full Card:'),
                const SizedBox(height: 16),
                NutritionCard(
                  calories: 1850,
                  protein: 45,
                  carbs: 225,
                  fats: 55,
                  calorieGoal: 2000,
                  showGoal: true,
                ),
                const SizedBox(height: 32),
                const Text('Compact Card (for sidebars, headers, etc.):'),
                const SizedBox(height: 16),
                NutritionCompactCard(
                  calories: 1850,
                  protein: 45,
                  carbs: 225,
                  fats: 55,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
