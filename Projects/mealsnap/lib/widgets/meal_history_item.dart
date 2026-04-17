import 'package:flutter/material.dart';
import '../models/firebase_models.dart';

/// Individual meal history card widget
class MealHistoryItem extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showImage;
  final bool showTimestamp;

  const MealHistoryItem({
    super.key,
    required this.meal,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showImage = true,
    this.showTimestamp = true,
  });

  /// Format timestamp to readable string
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final mealDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final timeStr =
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour < 12 ? 'AM' : 'PM'}';
    final dateStr =
        '${_monthName(timestamp.month)} ${timestamp.day}, $timeStr';

    if (mealDate == today) {
      return 'Today, $timeStr';
    } else if (mealDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return dateStr;
    }
  }

  /// Get month name
  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  /// Get source icon and label
  (IconData, String) _getSourceIcon() {
    switch (meal.source) {
      case 'camera':
        return (Icons.camera_alt, 'Camera');
      case 'gallery':
        return (Icons.image, 'Gallery');
      case 'receipt':
        return (Icons.receipt, 'Receipt');
      case 'voice':
        return (Icons.mic, 'Voice');
      default:
        return (Icons.fastfood, 'Meal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (sourceIcon, sourceLabel) = _getSourceIcon();
    final timeString = _formatTime(meal.timestamp);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Food name + Source icon
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.foodName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (showTimestamp) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    sourceIcon,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$sourceLabel • $timeString',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Calories badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              meal.calories.toStringAsFixed(0),
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
                  const SizedBox(height: 12),

                  // Macro breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMacroChip(
                        label: 'Protein',
                        value: meal.protein.toStringAsFixed(1),
                        unit: 'g',
                        color: Colors.green,
                      ),
                      _buildMacroChip(
                        label: 'Carbs',
                        value: meal.carbs.toStringAsFixed(1),
                        unit: 'g',
                        color: Colors.orange,
                      ),
                      _buildMacroChip(
                        label: 'Fats',
                        value: meal.fats.toStringAsFixed(1),
                        unit: 'g',
                        color: Colors.red,
                      ),
                    ],
                  ),

                  // Notes if present
                  if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meal.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  // Verified badge if applicable
                  if (meal.verified) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified AI Analysis',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.green[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons (edit/delete)
            if (onEdit != null || onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        onTap: onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        onTap: onDelete,
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build a macro chip
  Widget _buildMacroChip({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Compact version of MealHistoryItem for smaller spaces
class MealHistoryItemCompact extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onTap;

  const MealHistoryItemCompact({
    super.key,
    required this.meal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foodName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${meal.timestamp.hour}:${meal.timestamp.minute.toString().padLeft(2, '0')} ${meal.timestamp.hour < 12 ? 'AM' : 'PM'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${meal.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
