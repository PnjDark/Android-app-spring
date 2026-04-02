import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/app_theme.dart';
import '../../widgets/top_app_bar.dart';
import '../../widgets/match_percentage_chip.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const MealSnapTopAppBar(
        showMenu: false,
        profileImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDkAMQCZdDpzuMgsskzhhiGivMzVk8ZMj3eEg2nWv6KbaBOUzWNeuVpzYXdm2Ursw-daTm8mwK7VmAqs2WNAQLSdpeB7dTOX82VauMFROVIw2wAtwpbZBAaQLXto2UsV-EYGmpqFGz9p-TAeWsE9KQJMtXXW0lxbnEdCrf5czZSkYTNMNFFvxbl2uWZvxPEU_h4r6bwz8Y8sQN8081f77oUNFKAXlpLPva198QUVXUQri50bReYeu7ccZpoT1UpodT5isPfS5AE8uIm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'What can I cook?',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 24),

            // Ingredients Chips
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                _buildIngredientChip('Tomatoes'),
                _buildIngredientChip('Onions'),
                _buildIngredientChip('Plantain'),
                _buildIngredientChip('Chicken'),
              ],
            ),
            const SizedBox(height: 32),

            // Suggestion Cards
            _buildRecipeCard(
              context,
              title: 'Chicken & Plantain Roast',
              match: 95,
              time: '30 MINS',
              difficulty: 'EASY',
              tag: 'HIGH PROTEIN',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCPmqUzJZLDNmzWEWuwbECHyE2_EkIx-kSnsdJwkt0XQ4VFJyPDINxdIwArty3ljLivDenDxz7wTmYPvxXs0JZ6FG0NFW9qhvuW7b7h1Ah9i36x5ulH886gLP_21Gsz-aE-7LjxVFhI_Gbi5sYekyVESTMZfdHm2tI-gZDvnxWEoxlI-kBefDqk8i2dWRegJQi-FZLN-CF6zV9rKWCdJtxoRBP2czelTdVuvB2-zrnPZlJQvgyw3NHutCkgsaG9JsgyxNJ7jvWANfRz',
            ),
            const SizedBox(height: 32),

            _buildRecipeCard(
              context,
              title: 'Tomato Stew with Fried Plantain',
              match: 88,
              time: '20 MINS',
              difficulty: 'BEGINNER',
              icon: Symbols.auto_awesome,
              matchColor: AppTheme.secondaryColor,
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA90z4PFT9nJJBqg18ZIycxcP_9t4XKPCU7_T3LgRRWyKWLBFsCEojljcnz5YZuJqB6gwGrBEP66Lp93QAVt4GSwyNIk1s7Orc1V7KQLGYF3x32aojx2l-dkpmqMoxyTUNVD6aDSpdQDd4L9Py7BTWct6NoSMjxEjsqakoZAZNoyR4k_s_X0W-vyVXK_G3CKbzjKJvNE3OJGmW5mIwgXXNY44ihgU-K_JHryd2yCo4JjWAepPz6ATgDIEDE3Wv6q6CrY3tMl1YjzR9-',
            ),
            const SizedBox(height: 32),

            // Missing Ingredients Card
            _buildMissingIngredientsCard(
              context,
              title: 'Jollof Rice',
              match: 60,
              missing: 'Rice, Oil',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.check_circle, size: 18, color: AppTheme.primaryColor, fill: 1),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, {required String title, required int match, required String time, required String difficulty, String? tag, required String imageUrl, IconData icon = Symbols.bolt, Color matchColor = AppTheme.primaryColor}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 16,
                left: 16,
                child: MatchPercentageChip(percentage: match, color: matchColor, icon: icon),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildRecipeInfo(time),
                    _buildDot(),
                    _buildRecipeInfo(difficulty),
                    if (tag != null) _buildDot(),
                    if (tag != null) _buildRecipeInfo(tag),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.add_task, size: 20),
                        SizedBox(width: 8),
                        Text('Log as Meal', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildRecipeInfo(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariantColor, letterSpacing: 1.2),
    );
  }

  Widget _buildDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text('•', style: TextStyle(color: AppTheme.outlineColor, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMissingIngredientsCard(BuildContext context, {required String title, required int match, required String missing}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: const Border(left: BorderSide(color: AppTheme.secondaryColor, width: 4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('$match% Match', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Symbols.warning, color: AppTheme.secondaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Missing: $missing',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Opacity(
              opacity: 0.5,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceContainerHigh,
                  foregroundColor: AppTheme.onSurfaceVariantColor,
                  disabledBackgroundColor: AppTheme.surfaceContainerHigh,
                  disabledForegroundColor: AppTheme.onSurfaceVariantColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Symbols.add_task, size: 20),
                    SizedBox(width: 8),
                    Text('Log as Meal', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
