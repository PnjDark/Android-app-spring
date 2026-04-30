import 'package:flutter/material.dart';
import '../models/firebase_models.dart';
import '../services/nutrition_api_service.dart';

/// Shows detected food + verified nutrition.
/// User can edit the food name and portion multiplier before confirming.
/// Returns a confirmed [MealModel] or null if dismissed.
Future<MealModel?> showMealConfirmSheet(
  BuildContext context, {
  required String detectedName,
  required ResolvedNutrition nutrition,
  required String source, // 'camera' | 'gallery' | 'offline'
  required String userId,
}) {
  return showModalBottomSheet<MealModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MealConfirmSheet(
      detectedName: detectedName,
      nutrition: nutrition,
      source: source,
      userId: userId,
    ),
  );
}

class _MealConfirmSheet extends StatefulWidget {
  final String detectedName;
  final ResolvedNutrition nutrition;
  final String source;
  final String userId;

  const _MealConfirmSheet({
    required this.detectedName,
    required this.nutrition,
    required this.source,
    required this.userId,
  });

  @override
  State<_MealConfirmSheet> createState() => _MealConfirmSheetState();
}

class _MealConfirmSheetState extends State<_MealConfirmSheet> {
  late final TextEditingController _nameCtrl;
  double _portionMultiplier = 1.0; // 0.5 = half, 2.0 = double

  static const _portions = [
    (label: 'Half', value: 0.5),
    (label: 'Normal', value: 1.0),
    (label: '1.5×', value: 1.5),
    (label: 'Double', value: 2.0),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.detectedName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  double get _scaledCalories => widget.nutrition.calories * _portionMultiplier;
  double get _scaledProtein => widget.nutrition.proteinG * _portionMultiplier;
  double get _scaledCarbs => widget.nutrition.carbsG * _portionMultiplier;
  double get _scaledFat => widget.nutrition.fatG * _portionMultiplier;

  void _confirm() {
    final meal = MealModel(
      id: '',
      userId: widget.userId,
      foodName: _nameCtrl.text.trim().isEmpty
          ? widget.detectedName
          : _nameCtrl.text.trim(),
      calories: _scaledCalories,
      protein: _scaledProtein,
      carbs: _scaledCarbs,
      fats: _scaledFat,
      timestamp: DateTime.now(),
      source: widget.source,
      verified: true,
      notes:
          '${widget.nutrition.servingDescription} × $_portionMultiplier | ${widget.nutrition.sourceLabel}',
    );
    Navigator.of(context).pop(meal);
  }

  @override
  Widget build(BuildContext context) {
    final isUnknown = widget.nutrition.source == NutritionSource.unknown;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2730),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Color(0xFFA3F69C), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Confirm your meal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                // Source badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isUnknown
                        ? const Color(0xFF7F4F00)
                        : const Color(0xFF0D3D1A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.nutrition.sourceLabel,
                    style: TextStyle(
                      color: isUnknown
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFA3F69C),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Food name field
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Food name',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.restaurant, color: Colors.white38, size: 18),
              ),
            ),
            const SizedBox(height: 14),

            // Portion selector
            const Text('Portion size',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              children: _portions.map((p) {
                final selected = _portionMultiplier == p.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _portionMultiplier = p.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0D631B)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFA3F69C)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.label,
                          style: TextStyle(
                            color:
                                selected ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Nutrition summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroChip(
                      label: 'Calories',
                      value: _scaledCalories.round().toString(),
                      unit: 'kcal',
                      color: const Color(0xFFFC820C)),
                  _MacroChip(
                      label: 'Protein',
                      value: _scaledProtein.round().toString(),
                      unit: 'g',
                      color: const Color(0xFF0073B2)),
                  _MacroChip(
                      label: 'Carbs',
                      value: _scaledCarbs.round().toString(),
                      unit: 'g',
                      color: const Color(0xFFA3F69C)),
                  _MacroChip(
                      label: 'Fat',
                      value: _scaledFat.round().toString(),
                      unit: 'g',
                      color: const Color(0xFFFBBF24)),
                ],
              ),
            ),

            if (isUnknown) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFFBBF24), size: 14),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Nutrition data unavailable — values will be 0. Edit the name to retry.',
                      style: TextStyle(
                          color: Color(0xFFFBBF24), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D631B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save meal',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value $unit',
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
