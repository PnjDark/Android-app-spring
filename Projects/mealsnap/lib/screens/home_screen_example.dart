import 'package:flutter/material.dart';
import '../models/firebase_models.dart';
import '../services/firestore_service.dart';
import '../widgets/nutrition_card.dart';
import '../widgets/nutrition_sections.dart';
import '../widgets/recent_activities_section.dart';
import '../widgets/suggestions_section.dart';
import 'history_screen.dart';

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

                // Personalized Suggestions
                SuggestionsSection(
                  userId: widget.userId,
                  firestoreService: widget.firestoreService,
                  showCompactView: false,
                ),
                const SizedBox(height: 24),

                // Recent Activities
                RecentActivitiesSection(
                  userId: widget.userId,
                  firestoreService: widget.firestoreService,
                  mealCount: 5,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(
                          userId: widget.userId,
                          firestoreService: widget.firestoreService,
                        ),
                      ),
                    );
                  },
                  showCompactView: false,
                ),
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

  /// Helper method to get today's daily stats
  Future<DailyStatsModel?> _getDailyStats() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return widget.firestoreService.getDailyStats(widget.userId, todayStr);
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
