import 'package:flutter/material.dart';
import '../models/firebase_models.dart';
import '../services/firestore_service.dart';
import '../widgets/meal_history_item.dart';

/// Recent activities section widget for home screen
class RecentActivitiesSection extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;
  final int mealCount;
  final VoidCallback? onSeeAll;
  final bool showCompactView;

  const RecentActivitiesSection({
    super.key,
    required this.userId,
    required this.firestoreService,
    this.mealCount = 5,
    this.onSeeAll,
    this.showCompactView = false,
  });

  @override
  State<RecentActivitiesSection> createState() => _RecentActivitiesSectionState();
}

class _RecentActivitiesSectionState extends State<RecentActivitiesSection> {
  late Future<List<MealModel>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    _mealsFuture = widget.firestoreService
        .getMealsByDateRange(
          widget.userId,
          startDate: sevenDaysAgo,
          endDate: now,
        )
        .then((meals) {
      // Return only the most recent meals
      final sorted = meals.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted.take(widget.mealCount).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MealModel>>(
      future: _mealsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final meals = snapshot.data ?? [];

        if (meals.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with "See all" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Meals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: widget.onSeeAll,
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),

            // Meals list
            if (widget.showCompactView)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    return MealHistoryItemCompact(
                      meal: meals[index],
                      onTap: () {
                        // Navigate to meal detail
                      },
                    );
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    return MealHistoryItem(
                      meal: meals[index],
                      showImage: true,
                      showTimestamp: true,
                      onTap: () {
                        // Navigate to meal detail
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading meals...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by scanning a meal to track your nutrition',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onSeeAll,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Meal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading meals',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stream-based version for real-time updates
class RecentActivitiesStreamSection extends StatelessWidget {
  final String userId;
  final FirestoreService firestoreService;
  final int mealCount;
  final VoidCallback? onSeeAll;
  final bool showCompactView;

  const RecentActivitiesStreamSection({
    super.key,
    required this.userId,
    required this.firestoreService,
    this.mealCount = 5,
    this.onSeeAll,
    this.showCompactView = false,
  });

  @override
  Widget build(BuildContext context) {
    return RecentActivitiesSection(
      userId: userId,
      firestoreService: firestoreService,
      mealCount: mealCount,
      onSeeAll: onSeeAll,
      showCompactView: showCompactView,
    );
  }
}
