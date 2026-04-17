import 'package:flutter/material.dart';

/// Nutrition information display widget
class NutritionCard extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double? calorieGoal;
  final bool showGoal;

  const NutritionCard({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.calorieGoal = 2000,
    this.showGoal = true,
  });

  /// Calculate macro percentages
  Map<String, double> _calculateMacroPercentages() {
    final totalMacros = protein + carbs + fats;
    if (totalMacros == 0) {
      return {'protein': 0, 'carbs': 0, 'fats': 0};
    }

    return {
      'protein': (protein / totalMacros) * 100,
      'carbs': (carbs / totalMacros) * 100,
      'fats': (fats / totalMacros) * 100,
    };
  }

  /// Calculate calorie progress percentage
  double _getCalorieProgress() {
    if (calorieGoal == null || calorieGoal! <= 0) return 0;
    return (calories / calorieGoal!) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final macroPercentages = _calculateMacroPercentages();
    final calorieProgress = _getCalorieProgress();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.withValues(alpha: 0.02),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with calorie count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Nutrition',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${calories.toStringAsFixed(0)} / ${calorieGoal?.toStringAsFixed(0) ?? '2000'} kcal',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCalorieStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${calorieProgress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getCalorieStatusColor(),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calorie progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (calorieProgress / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCalorieStatusColor(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Macro breakdown section
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Protein
            _buildMacroBar(
              context: context,
              label: 'Protein',
              value: protein,
              percentage: macroPercentages['protein'] ?? 0,
              color: Colors.green,
              unit: 'g',
            ),
            const SizedBox(height: 8),

            // Carbs
            _buildMacroBar(
              context: context,
              label: 'Carbs',
              value: carbs,
              percentage: macroPercentages['carbs'] ?? 0,
              color: Colors.orange,
              unit: 'g',
            ),
            const SizedBox(height: 8),

            // Fats
            _buildMacroBar(
              context: context,
              label: 'Fats',
              value: fats,
              percentage: macroPercentages['fats'] ?? 0,
              color: Colors.red,
              unit: 'g',
            ),
            const SizedBox(height: 16),

            // Recommendations (optional)
            if (showGoal) _buildRecommendations(context, macroPercentages),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar({
    required BuildContext context,
    required String label,
    required double value,
    required double percentage,
    required Color color,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Row(
              children: [
                Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0, 1),
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getCalorieStatusColor() {
    final progress = _getCalorieProgress();
    if (progress <= 80) {
      return Colors.green;
    } else if (progress <= 100) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildRecommendations(
    BuildContext context,
    Map<String, double> macroPercentages,
  ) {
    final proteinPercent = macroPercentages['protein'] ?? 0;
    final carbsPercent = macroPercentages['carbs'] ?? 0;
    final fatsPercent = macroPercentages['fats'] ?? 0;

    String recommendation = '';

    // Standard macronutrient ratios
    // Balanced: 30% protein, 40% carbs, 30% fats
    // Low-carb: 35% protein, 25% carbs, 40% fats
    // High-carb: 25% protein, 55% carbs, 20% fats

    final proteinOk = proteinPercent >= 25 && proteinPercent <= 35;
    final carbsOk = carbsPercent >= 35 && carbsPercent <= 55;
    final fatsOk = fatsPercent >= 20 && fatsPercent <= 35;

    if (proteinOk && carbsOk && fatsOk) {
      recommendation = '✅ Great macro balance!';
    } else if (proteinPercent < 25) {
      recommendation = '💪 Consider adding more protein';
    } else if (carbsPercent > 60) {
      recommendation = '🥗 Carbs are high, add veggies';
    } else if (fatsPercent > 40) {
      recommendation = '🥑 Fats are slightly high';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.blue[700],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version of nutrition card for small spaces
class NutritionCompactCard extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double? calorieGoal;

  const NutritionCompactCard({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.calorieGoal = 2000,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${calories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroChip('P', protein, Colors.green),
              _buildMacroChip('C', carbs, Colors.orange),
              _buildMacroChip('F', fats, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)}g',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
