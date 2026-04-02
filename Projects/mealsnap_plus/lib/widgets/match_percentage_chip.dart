import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class MatchPercentageChip extends StatelessWidget {
  final int percentage;
  final Color color;
  final IconData icon;

  const MatchPercentageChip({
    super.key,
    required this.percentage,
    this.color = AppTheme.primaryColor,
    this.icon = Symbols.bolt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color, fill: 1),
          const SizedBox(width: 4),
          Text(
            '$percentage% Match',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
