import 'package:flutter/material.dart';
import '../models/firebase_models.dart';
import '../services/firestore_service.dart';
import 'nutrition_card.dart';

/// Widget that displays daily nutrition stats
class DailyNutritionSection extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;

  const DailyNutritionSection({
    super.key,
    required this.userId,
    required this.firestoreService,
  });

  @override
  State<DailyNutritionSection> createState() => _DailyNutritionSectionState();
}

class _DailyNutritionSectionState extends State<DailyNutritionSection> {
  late Future<DailyStatsModel?> _dailyStatsFuture;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Get today's date string (YYYY-MM-DD)
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    _dailyStatsFuture = widget.firestoreService.getDailyStats(widget.userId, todayStr);
    _userFuture = widget.firestoreService.getUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(DailyStatsModel?, UserModel?)>(
      future: Future.wait([_dailyStatsFuture, _userFuture]).then(
        (results) => (results[0] as DailyStatsModel?, results[1] as UserModel?),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final (dailyStats, user) = snapshot.data ?? (null, null);

        return NutritionCard(
          calories: dailyStats?.totalCalories ?? 0,
          protein: dailyStats?.protein ?? 0,
          carbs: dailyStats?.carbs ?? 0,
          fats: dailyStats?.fats ?? 0,
          calorieGoal: (user?.settings.dailyCalorieGoal.toDouble() ?? 2000),
          showGoal: true,
        );
      },
    );
  }
}

/// Widget that displays weekly nutrition summary
class WeeklyNutritionSummary extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;

  const WeeklyNutritionSummary({
    super.key,
    required this.userId,
    required this.firestoreService,
  });

  @override
  State<WeeklyNutritionSummary> createState() => _WeeklyNutritionSummaryState();
}

class _WeeklyNutritionSummaryState extends State<WeeklyNutritionSummary> {
  late Future<List<DailyStatsModel>> _dailyStatsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    _dailyStatsFuture = widget.firestoreService.getDailyStatsRange(
      widget.userId,
      startDate: sevenDaysAgo,
      endDate: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyStatsModel>>(
      future: _dailyStatsFuture,
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

        final dailyStats = snapshot.data ?? [];

        if (dailyStats.isEmpty) {
          return const Center(child: Text('No data for this week'));
        }

        // Calculate weekly totals
        double weeklyCalories = 0;
        double weeklyProtein = 0;
        double weeklyCarbs = 0;
        double weeklyFats = 0;

        for (var stat in dailyStats) {
          weeklyCalories += stat.totalCalories;
          weeklyProtein += stat.protein;
          weeklyCarbs += stat.carbs;
          weeklyFats += stat.fats;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Summary (Last 7 Days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      label: 'Avg Calories',
                      value: (weeklyCalories / dailyStats.length).toStringAsFixed(0),
                      unit: 'kcal',
                    ),
                    _buildStatItem(
                      label: 'Avg Protein',
                      value: (weeklyProtein / dailyStats.length).toStringAsFixed(1),
                      unit: 'g',
                    ),
                    _buildStatItem(
                      label: 'Avg Carbs',
                      value: (weeklyCarbs / dailyStats.length).toStringAsFixed(1),
                      unit: 'g',
                    ),
                    _buildStatItem(
                      label: 'Avg Fats',
                      value: (weeklyFats / dailyStats.length).toStringAsFixed(1),
                      unit: 'g',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Widget that shows nutrition progress for a specific meal
class MealNutritionPreview extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onTap;

  const MealNutritionPreview({
    super.key,
    required this.meal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.foodName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meal.calories.toStringAsFixed(0)} kcal',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'P: ${meal.protein.toStringAsFixed(0)}g',
                      style: const TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'C: ${meal.carbs.toStringAsFixed(0)}g',
                      style: const TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'F: ${meal.fats.toStringAsFixed(0)}g',
                      style: const TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
