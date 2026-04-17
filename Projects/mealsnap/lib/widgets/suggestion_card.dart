import 'package:flutter/material.dart';
import '../services/suggestion_service.dart';

/// Card widget to display a personalized meal suggestion
class SuggestionCard extends StatelessWidget {
  final PersonalizedSuggestion suggestion;
  final VoidCallback? onTap;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food name and category badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      suggestion.foodName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCategoryBadge(suggestion.category),
                ],
              ),
              const SizedBox(height: 8),

              // Reason for suggestion
              Text(
                suggestion.reason,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Nutrition info
              Row(
                children: [
                  _buildNutritionChip(
                    context,
                    '${suggestion.estimatedCalories.toInt()} cal',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildNutritionChip(
                    context,
                    '${suggestion.estimatedProtein.toInt()}g P',
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildNutritionChip(
                    context,
                    '${suggestion.estimatedCarbs.toInt()}g C',
                    Icons.grain,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildNutritionChip(
                    context,
                    '${suggestion.estimatedFats.toInt()}g F',
                    Icons.opacity,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    final (label, color) = switch (category) {
      'frequent' => ('Frequent', Colors.blue),
      'alternative' => ('Alternative', Colors.green),
      'variety' => ('New', Colors.orange),
      'healthy' => ('Healthy', Colors.purple),
      _ => ('Suggestion', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNutritionChip(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version of suggestion card for smaller spaces
class SuggestionCardCompact extends StatelessWidget {
  final PersonalizedSuggestion suggestion;
  final VoidCallback? onTap;

  const SuggestionCardCompact({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food name
              Text(
                suggestion.foodName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Calories
              Text(
                '${suggestion.estimatedCalories.toInt()} cal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Category badge
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(suggestion.category).withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getCategoryLabel(suggestion.category),
                    style: TextStyle(
                      color: _getCategoryColor(suggestion.category),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    return switch (category) {
      'frequent' => '★',
      'alternative' => '↗',
      'variety' => '✨',
      'healthy' => '♥',
      _ => '?',
    };
  }

  Color _getCategoryColor(String category) {
    return switch (category) {
      'frequent' => Colors.blue,
      'alternative' => Colors.green,
      'variety' => Colors.orange,
      'healthy' => Colors.purple,
      _ => Colors.grey,
    };
  }
}