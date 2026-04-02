import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/app_theme.dart';
import '../../widgets/top_app_bar.dart';
import '../../widgets/macro_progress_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const MealSnapTopAppBar(
        showMenu: false,
        profileImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuARA7Sofpa2ibcYYmFFe7qQY54II-5dG5r3FD3C-J-N-j4SJCuztVV9fgxprfkqMkaH0uKgI7SOXkK7ujHENu_z1f2NduRnPUdaIYVAGpNZ3thpS7KuoeSDu_tOWQt_N7BNb_VVQL-G3PpR6EpIPFVzhkqb4rD4HA_nqOIm94BK1zK9hmWIqN8ILkVjcczLyJ3RofZ9OYALoVy3J968yiliB-WqavpwIyLya7xGn_c3wzc859YwPso-jrz5Su_iQ1125UMyWkqtLCgb'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GOOD MORNING',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.outlineColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, Sarah!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 24),

            // Nutrition Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Nutrition Progress',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Circular Progress
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: 1450 / 2200,
                                strokeWidth: 12,
                                color: AppTheme.primaryColor,
                                backgroundColor: AppTheme.surfaceContainerLow,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '1,450',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '/ 2,200 kcal',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.outlineColor.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Macro Bars
                        const Expanded(
                          child: Column(
                            children: [
                              MacroProgressIndicator(
                                label: 'Protein',
                                progress: '85g / 120g',
                                percentage: 85 / 120,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(height: 12),
                              MacroProgressIndicator(
                                label: 'Carbs',
                                progress: '180g / 250g',
                                percentage: 180 / 250,
                                color: Color(0xFFFC820C),
                              ),
                              SizedBox(height: 12),
                              MacroProgressIndicator(
                                label: 'Fats',
                                progress: '45g / 70g',
                                percentage: 45 / 70,
                                color: AppTheme.tertiaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Ready to Snap?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    label: 'Scan Meal',
                    icon: Symbols.center_focus_strong,
                    color: AppTheme.primaryColor,
                    onPrimary: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context,
                    label: 'Check Ingredients',
                    icon: Symbols.fact_check,
                    color: AppTheme.tertiaryColor,
                    onPrimary: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Suggested for Lunch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Featured Recommendation Card
            _buildFeaturedCard(
              context,
              title: 'Plantain & Egg Stew',
              tag: 'HIGH IN PROTEIN',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB4L0BmYcmY6hpUDnyzl_pjvQEk8lg0QVc-Fwl1DzPhMYGtv7wlMFPtxjgkbrRtt1SbHGphZk5sfjmfRw08RP_1iiJPJbaq_OO3D06SP1sy72pN1KFhQgyh6Yg04pcOlqg7n4NlfI3dPG2Yk-CyE8YOkeXmO4pywi8sRJWdV5iYriPiVEBsQ0xb5lyR0QPLG-qB69gHD4wac24whRU0r4y28lppe2o2lqV-NVXqm_OUOuwvjEPCICgIddQr9gr4qsAess8g1mtUx7ak',
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'View All',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              title: 'Breakfast: Fufu & Ndolé',
              subtitle: 'Today, 8:30 AM',
              value: '850 kcal',
              icon: Symbols.breakfast_dining,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              context,
              title: 'Grocery Receipt',
              subtitle: 'Yesterday, 5:45 PM',
              value: '\$45.20',
              icon: Symbols.receipt_long,
              color: AppTheme.tertiaryColor,
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String label, required IconData icon, required Color color, bool onPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: onPrimary ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: onPrimary ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: onPrimary ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: onPrimary ? Colors.white : color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: onPrimary ? Colors.white : AppTheme.onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, {required String title, required String tag, required String imageUrl}) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.onPrimaryFixed),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Symbols.chevron_right, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, {required String title, required String subtitle, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.outlineColor),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: value.contains('kcal') ? AppTheme.primaryColor : AppTheme.onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }
}
