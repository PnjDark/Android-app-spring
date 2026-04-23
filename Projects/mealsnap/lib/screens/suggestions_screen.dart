import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Symbols.restaurant, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              'MealSnap+',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primary,
                    letterSpacing: -1,
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.surfaceContainerHighest,
              backgroundImage: const NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDkAMQCZdDpzuMgsskzhhiGivMzVk8ZMj3eEg2nWv6KbaBOUzWNeuVpzYXdm2Ursw-daTm8mwK7VmAqs2WNAQLSdpeB7dTOX82VauMFROVIw2wAtwpbZBAaQLXto2UsV-EYGmpqFGz9p-TAeWsE9KQJMtXXW0lxbnEdCrf5czZSkYTNMNFFvxbl2uWZvxPEU_h4r6bwz8Y8sQN8081f77oUNFKAXlpLPva198QUVXUQri50bReYeu7ccZpoT1UpodT5isPfS5AE8uIm'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What can I cook?', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            _buildIngredientChips(),
            const SizedBox(height: 32),
            _buildSuggestionCard(
              context,
              'Chicken & Plantain Roast',
              '30 MINS • EASY • HIGH PROTEIN',
              '95% Match',
              Symbols.bolt,
              AppTheme.primary,
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCPmqUzJZLDNmzWEWuwbECHyE2_EkIx-kSnsdJwkt0XQ4VFJyPDINxdIwArty3ljLivDenDxz7wTmYPvxXs0JZ6FG0NFW9qhvuW7b7h1Ah9i36x5ulH886gLP_21Gsz-aE-7LjxVFhI_Gbi5sYekyVESTMZfdHm2tI-gZDvnxWEoxlI-kBefDqk8i2dWRegJQi-FZLN-CF6zV9rKWCdJtxoRBP2czelTdVuvB2-zrnPZlJQvgyw3NHutCkgsaG9JsgyxNJ7jvWANfRz',
            ),
            const SizedBox(height: 32),
            _buildSuggestionCard(
              context,
              'Tomato Stew with Fried Plantain',
              '20 MINS • BEGINNER',
              '88% Match',
              Symbols.auto_awesome,
              AppTheme.secondary,
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA90z4PFT9nJJBqg18ZIycxcP_9t4XKPCU7_T3LgRRWyKWLBFsCEojljcnz5YZuJqB6gwGrBEP66Lp93QAVt4GSwyNIk1s7Orc1V7KQLGYF3x32aojx2l-dkpmqMoxyTUNVD6aDSpdQDd4L9Py7BTWct6NoSMjxEjsqakoZAZNoyR4k_s_X0W-vyVXK_G3CKbzjKJvNE3OJGmW5mIwgXXNY44ihgU-K_JHryd2yCo4JjWAepPz6ATgDIEDE3Wv6q6CrY3tMl1YjzR9-',
            ),
            const SizedBox(height: 32),
            _buildMissingIngredientsCard(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientChips() {
    final ingredients = ['Tomatoes', 'Onions', 'Plantain', 'Chicken'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ingredients.map((ing) => _buildChip(ing)).toList(),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.check_circle, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    String title,
    String subtitle,
    String match,
    IconData matchIcon,
    Color matchColor,
    String imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(matchIcon, size: 14, color: matchColor),
                      const SizedBox(width: 4),
                      Text(
                        match,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: matchColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Symbols.add_task),
                    label: const Text('Log as Meal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      elevation: 0,
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

  Widget _buildMissingIngredientsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: const Border(left: BorderSide(color: AppTheme.secondaryContainer, width: 4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jollof Rice', style: Theme.of(context).textTheme.titleLarge),
              const Text('60% Match', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Symbols.warning, size: 18, color: AppTheme.secondary),
                SizedBox(width: 8),
                Text('Missing: Rice, Oil', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Symbols.add_task),
              label: const Text('Log as Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceContainer,
                foregroundColor: AppTheme.outline.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
