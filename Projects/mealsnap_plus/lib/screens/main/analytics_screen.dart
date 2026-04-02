import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../core/app_theme.dart';
import '../../widgets/top_app_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const MealSnapTopAppBar(
        showMenu: false,
        profileImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDIjyiMab1soPAEJNtiC2tgE7DKEoRONUu6St0cErxWOe0dcoX3a-tzhiGlzTkbzJimjSQo1S2JkGqcQ7BLP84RTzbLdGf_ARggtJdkU6Yxc-dYzsb9TzmD_Eao9vnFJXWZQNjvWhA0ab3Wxrn85jqOyFgBdVdVfDYt9hNlel4HivPIPAZI8XQZfbJ0coI8ZFnibycbwE5HCeIVIr0kGPtsEy7xleARuzej5JZ4rBzXyuO0gccfBTVFrndq__ROtrjPExtaBDexlJ00'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Segmented Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegment('Nutrition', active: true),
                  ),
                  Expanded(
                    child: _buildSegment('Expenses', active: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Calorie Intake Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7-DAY ANALYSIS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.5),
                    ),
                    Text(
                      'Calorie Intake',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '13,440',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: AppTheme.primaryColor),
                    ),
                    const Text(
                      'TOTAL KCAL',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outlineColor, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Custom Line Chart Representation
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.transparent],
                ),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              days[value.toInt() % 7],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: value == 3 ? AppTheme.primaryColor : AppTheme.outlineColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 75),
                    _buildBarGroup(1, 85),
                    _buildBarGroup(2, 65),
                    _buildBarGroup(3, 95, highlight: true),
                    _buildBarGroup(4, 70),
                    _buildBarGroup(5, 80),
                    _buildBarGroup(6, 60),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bento Grid
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard(
                    context,
                    label: 'Weekly Avg',
                    value: '1,920 kcal',
                    icon: Symbols.avg_pace,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBentoCard(
                    context,
                    label: 'Top Category',
                    value: 'African Dishes',
                    icon: Symbols.restaurant_menu,
                    color: AppTheme.secondaryColor,
                    isSecondary: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Financial Health Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Financial Health', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('View Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.tertiaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MONTHLY BUDGET', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.outlineColor, letterSpacing: 1.5)),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
                                  children: [
                                    const TextSpan(text: '\$320 '),
                                    TextSpan(
                                      text: '/ \$500',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.slate.shade400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: AppTheme.tertiaryColor.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Symbols.payments, color: AppTheme.tertiaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(6)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 320 / 500,
                          child: Container(decoration: BoxDecoration(color: AppTheme.tertiaryContainer, borderRadius: BorderRadius.circular(6))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('64% SPENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outlineColor, letterSpacing: 1.2)),
                          Text('\$180 REMAINING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outlineColor, letterSpacing: 1.2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Export Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF263238),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Symbols.picture_as_pdf, size: 24),
                    SizedBox(width: 12),
                    Text('Export PDF Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(String label, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: active ? AppTheme.primaryColor : Colors.slate.shade500,
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, {bool highlight = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: highlight ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.2),
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: AppTheme.primaryColor.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard(BuildContext context, {required String label, required String value, required IconData icon, required Color color, bool isSecondary = false}) {
    return Container(
      aspectRatio: 1,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSecondary ? color.withOpacity(0.05) : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: isSecondary ? Border.all(color: color.withOpacity(0.1)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 32, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSecondary ? color : AppTheme.outlineColor, letterSpacing: 1.2),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
