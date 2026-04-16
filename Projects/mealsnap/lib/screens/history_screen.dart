import 'package:flutter/material.dart';
import '../models/firebase_models.dart';
import '../services/firestore_service.dart';
import '../widgets/meal_history_item.dart';

/// Full meal history screen with date filtering
class HistoryScreen extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;
  final int? initialDaysBack;

  const HistoryScreen({
    super.key,
    required this.userId,
    required this.firestoreService,
    this.initialDaysBack = 30,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _daysBack;
  late Future<List<MealModel>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _daysBack = widget.initialDaysBack ?? 30;
    _loadMeals();
  }

  void _loadMeals() {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _daysBack));

    _mealsFuture = widget.firestoreService.getMealsByDateRange(
      widget.userId,
      startDate: startDate,
      endDate: now,
    );
  }

  void _updateDateRange(int days) {
    setState(() {
      _daysBack = days;
      _loadMeals();
    });
  }

  Future<void> _deleteMeal(MealModel meal) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal?'),
        content: Text('Are you sure you want to delete ${meal.foodName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.firestoreService.deleteMeal(widget.userId, meal.id);
        if (mounted) {
          setState(_loadMeals);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting meal: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _updateDateRange(7),
                child: const Text('Last 7 days'),
              ),
              PopupMenuItem(
                onTap: () => _updateDateRange(30),
                child: const Text('Last 30 days'),
              ),
              PopupMenuItem(
                onTap: () => _updateDateRange(90),
                child: const Text('Last 3 months'),
              ),
              PopupMenuItem(
                onTap: () => _updateDateRange(365),
                child: const Text('Last year'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Date filter chips
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Last 7 days'),
                    selected: _daysBack == 7,
                    onSelected: (_) => _updateDateRange(7),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Last 30 days'),
                    selected: _daysBack == 30,
                    onSelected: (_) => _updateDateRange(30),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Last 3 months'),
                    selected: _daysBack == 90,
                    onSelected: (_) => _updateDateRange(90),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Last year'),
                    selected: _daysBack == 365,
                    onSelected: (_) => _updateDateRange(365),
                  ),
                ],
              ),
            ),
          ),

          // Meals list
          Expanded(
            child: FutureBuilder<List<MealModel>>(
              future: _mealsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading meals',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final meals = snapshot.data ?? [];

                if (meals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No meals in this period',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by scanning or adding a meal',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                // Group meals by date
                final mealsByDate = _groupMealsByDate(meals);

                return ListView.builder(
                  itemCount: mealsByDate.length,
                  itemBuilder: (context, index) {
                    final date = mealsByDate.keys.elementAt(index);
                    final mealsOnDate = mealsByDate[date]!;
                    final totalCalories = mealsOnDate.fold<double>(
                      0,
                      (sum, meal) => sum + meal.calories,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header with daily total
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateHeader(DateTime.parse(date)),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '${mealsOnDate.length} meal${mealsOnDate.length != 1 ? 's' : ''}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      totalCalories.toStringAsFixed(0),
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                    ),
                                    Text(
                                      'kcal',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Colors.blue,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Meals for this date
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: mealsOnDate.length,
                            itemBuilder: (context, mealIndex) {
                              return MealHistoryItem(
                                meal: mealsOnDate[mealIndex],
                                onTap: () {
                                  // Navigate to meal detail screen
                                },
                                onEdit: () {
                                  // Navigate to edit meal screen
                                },
                                onDelete: () => _deleteMeal(mealsOnDate[mealIndex]),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Group meals by date (YYYY-MM-DD)
  Map<String, List<MealModel>> _groupMealsByDate(List<MealModel> meals) {
    final grouped = <String, List<MealModel>>{};

    for (final meal in meals) {
      final dateStr =
          '${meal.timestamp.year}-${meal.timestamp.month.toString().padLeft(2, '0')}-${meal.timestamp.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dateStr, () => []);
      grouped[dateStr]!.add(meal);
    }

    // Sort by date descending (newest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedGrouped = <String, List<MealModel>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      );
    }
    return sortedGrouped;
  }

  /// Format date header (e.g., "Today", "Yesterday", "Monday, April 15")
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final dayName = dayNames[date.weekday - 1];
      final monthName = monthNames[date.month - 1];
      return '$dayName, $monthName ${date.day}';
    }
  }
}
