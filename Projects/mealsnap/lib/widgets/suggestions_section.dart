import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/suggestion_service.dart';
import 'suggestion_card.dart';

/// Section widget for displaying personalized meal suggestions on the home screen
class SuggestionsSection extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;
  final bool showCompactView;
  final VoidCallback? onSeeAll;

  const SuggestionsSection({
    super.key,
    required this.userId,
    required this.firestoreService,
    this.showCompactView = false,
    this.onSeeAll,
  });

  @override
  State<SuggestionsSection> createState() => _SuggestionsSectionState();
}

class _SuggestionsSectionState extends State<SuggestionsSection> {
  late final SuggestionService _suggestionService;
  List<PersonalizedSuggestion> _suggestions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _suggestionService = SuggestionService(widget.firestoreService);
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final suggestions = await _suggestionService.getPersonalizedSuggestions(widget.userId);

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Suggested for You',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (widget.onSeeAll != null && !_loading && _suggestions.isNotEmpty)
              TextButton(
                onPressed: widget.onSeeAll,
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Content
        if (_loading)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load suggestions',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  TextButton(
                    onPressed: _loadSuggestions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_suggestions.isEmpty)
          SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    'No suggestions available yet',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add more meals to get personalized suggestions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          widget.showCompactView
              ? _buildCompactView()
              : _buildFullView(),
      ],
    );
  }

  Widget _buildFullView() {
    return Column(
      children: _suggestions.map((suggestion) {
        return SuggestionCard(
          suggestion: suggestion,
          onTap: () => _onSuggestionTap(suggestion),
        );
      }).toList(),
    );
  }

  Widget _buildCompactView() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return SuggestionCardCompact(
            suggestion: suggestion,
            onTap: () => _onSuggestionTap(suggestion),
          );
        },
      ),
    );
  }

  void _onSuggestionTap(PersonalizedSuggestion suggestion) {
    // Show suggestion details in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(suggestion.foodName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(suggestion.reason),
            const SizedBox(height: 16),
            const Text(
              'Estimated Nutrition (per serving):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNutritionRow('Calories', '${suggestion.estimatedCalories.toInt()} kcal'),
            _buildNutritionRow('Protein', '${suggestion.estimatedProtein.toInt()}g'),
            _buildNutritionRow('Carbs', '${suggestion.estimatedCarbs.toInt()}g'),
            _buildNutritionRow('Fats', '${suggestion.estimatedFats.toInt()}g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to meal logging screen with this suggestion pre-filled
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Log "${suggestion.foodName}" as a meal')),
              );
            },
            child: const Text('Log This Meal'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}