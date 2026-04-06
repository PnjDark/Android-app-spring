import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              backgroundImage: const NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuARA7Sofpa2ibcYYmFFe7qQY54II-5dG5r3FD3C-J-N-j4SJCuztVV9fgxprfkqMkaH0uKgI7SOXkK7ujHENu_z1f2NduRnPUdaIYVAGpNZ3thpS7KuoeSDu_tOWQt_N7BNb_VVQL-G3PpR6EpIPFVzhkqb4rD4HA_nqOIm94BK1zK9hmWIqN8ILkVjcczLyJ3RofZ9OYALoVy3J968yiliB-WqavpwIyLya7xGn_c3wzc859YwPso-jrz5Su_iQ1125UMyWkqtLCgb'),
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
              'GOOD MORNING',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.outline,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, Sarah!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 32),
            _buildNutritionProgress(context),
            const SizedBox(height: 32),
            _buildActionButtons(context),
            const SizedBox(height: 32),
            _buildSuggestedMeal(context),
            const SizedBox(height: 32),
            _buildRecentActivity(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Daily Nutrition Progress',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCircularProgress(context),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildProgressBar(context, 'Protein', '85g / 120g', 0.7, AppTheme.primary),
                    const SizedBox(height: 16),
                    _buildProgressBar(context, 'Carbs', '180g / 250g', 0.72, AppTheme.secondaryContainer),
                    const SizedBox(height: 16),
                    _buildProgressBar(context, 'Fats', '45g / 70g', 0.64, AppTheme.tertiaryContainer),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1450 / 2200,
              strokeWidth: 12,
              backgroundColor: AppTheme.surfaceContainerLow,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1,450',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '/ 2,200 KCAL',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 10,
                      color: AppTheme.outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppTheme.surfaceContainerLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Scan Meal',
            Symbols.center_focus_strong,
            AppTheme.primary,
            Colors.white,
            true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            'Check Ingredients',
            Symbols.fact_check,
            AppTheme.surfaceContainerLowest,
            AppTheme.onSurface,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color bg, Color text, bool hasShadow) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: bg.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: text.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: text, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedMeal(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggested for Lunch', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB4L0BmYcmY6hpUDnyzl_pjvQEk8lg0QVc-Fwl1DzPhMYGtv7wlMFPtxjgkbrRtt1SbHGphZk5sfjmfRw08RP_1iiJPJbaq_OO3D06SP1sy72pN1KFhQgyh6Yg04pcOlqg7n4NlfI3dPG2Yk-CyE8YOkeXmO4pywi8sRJWdV5iYriPiVEBsQ0xb5lyR0QPLG-qB69gHD4wac24whRU0r4y28lppe2o2lqV-NVXqm_OUOuwvjEPCICgIddQr9gr4qsAess8g1mtUx7ak'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA3F69C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'HIGH IN PROTEIN',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF002204)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Plantain & Egg Stew',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Symbols.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          context,
          'Breakfast: Fufu & Ndolé',
          'Today, 8:30 AM',
          '850 kcal',
          Symbols.breakfast_dining,
          AppTheme.primary,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          context,
          'Grocery Receipt',
          'Yesterday, 5:45 PM',
          '\$45.20',
          Symbols.receipt_long,
          AppTheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String subtitle, String trailing, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: AppTheme.outline, fontSize: 12)),
              ],
            ),
          ),
          Text(trailing, style: TextStyle(fontWeight: FontWeight.bold, color: color == AppTheme.primary ? AppTheme.primary : AppTheme.onSurface)),
        ],
      ),
    );
  }
}
