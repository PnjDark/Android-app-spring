import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/meal_suggestion_service.dart';

class MealSuggestionsScreen extends StatefulWidget {
  const MealSuggestionsScreen({super.key});

  @override
  State<MealSuggestionsScreen> createState() => _MealSuggestionsScreenState();
}

class _MealSuggestionsScreenState extends State<MealSuggestionsScreen> {
  final List<String> _selectedIngredients = [
    'Tomatoes',
    'Onions',
    'Plantain',
    'Chicken',
  ];

  List<MealSuggestion> get _suggestions =>
      MealSuggestionService.getSuggestions(_selectedIngredients);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MealSnap+',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What can I cook?',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),

            // Ingredients Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedIngredients
                  .map(
                    (ingredient) => Chip(
                      label: Text(ingredient),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedIngredients.remove(ingredient);
                        });
                      },
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      side: BorderSide(
                        color: colorScheme.primary,
                        width: 1,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),

            // Suggestions from service
            if (_suggestions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No suggestions match your ingredients.\nTry adding more!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              Column(
                children: _suggestions.map((s) {
                  final pct = MealSuggestionService.getSuggestions(
                          _selectedIngredients)
                      .indexOf(s);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _MealCard(
                      title: s.name,
                      matchPercentage: 80 - (pct * 8).clamp(0, 40),
                      difficulty: s.difficulty,
                      duration: '${s.cookingTime} mins',
                      tag: s.nutrition.calories.round().toString() + ' kcal',
                      imageIcon: Icons.restaurant,
                      matchColor: Theme.of(context).colorScheme.primary,
                      onAddMeal: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('✓ ${s.name} added to meal plan')),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final int matchPercentage;
  final String difficulty;
  final String duration;
  final String tag;
  final IconData imageIcon;
  final Color matchColor;
  final VoidCallback onAddMeal;

  const _MealCard({
    required this.title,
    required this.matchPercentage,
    required this.difficulty,
    required this.duration,
    required this.tag,
    required this.imageIcon,
    required this.matchColor,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder
          Container(
            width: double.infinity,
            height: 160,
            color: colorScheme.surfaceContainer,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    imageIcon,
                    size: 64,
                    color: colorScheme.primaryContainer,
                  ),
                ),
                // Match Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: matchColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 14,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$matchPercentage% Match',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      difficulty,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tag,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: matchColor,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onAddMeal,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_task, size: 18),
                        SizedBox(width: 8),
                        Text('Add to Meal Plan'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
