import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    'Chicken'
  ];

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

            // Meal Suggestions
            Column(
              children: [
                // Card 1: 95% Match
                _MealCard(
                  title: 'Chicken & Plantain Roast',
                  matchPercentage: 95,
                  difficulty: 'Easy',
                  duration: '30 mins',
                  tag: 'High Protein',
                  imageIcon: Icons.domain_verification,
                  matchColor: colorScheme.primary,
                  onAddMeal: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Added to meal plan'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Card 2: 88% Match
                _MealCard(
                  title: 'Tomato Stew with Fried Plantain',
                  matchPercentage: 88,
                  difficulty: 'Beginner',
                  duration: '20 mins',
                  tag: 'Vegetarian',
                  imageIcon: Icons.restaurant,
                  matchColor: colorScheme.secondary,
                  onAddMeal: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Added to meal plan'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Card 3: 60% Match (Disabled)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jollof Rice',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '60% Match',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: colorScheme.secondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Missing 2 ingredients: Ginger, Rice',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.surfaceContainerHigh,
                              foregroundColor:
                                  colorScheme.onSurfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_task, size: 18),
                                SizedBox(width: 8),
                                Text('Add to Plan (Disabled)'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                      color: matchColor.withOpacity(0.9),
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
