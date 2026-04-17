import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedIndex = 0;

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
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryContainer.withOpacity(0.2), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDIjyiMab1soPAEJNtiC2tgE7DKEoRONUu6St0cErxWOe0dcoX3a-tzhiGlzTkbzJimjSQo1S2JkGqcQ7BLP84RTzbLdGf_ARggtJdkU6Yxc-dYzsb9TzmD_Eao9vnFJXWZQNjvWhA0ab3Wxrn85jqOyFgBdVdVfDYt9hNlel4HivPIPAZI8XQZfbJ0coI8ZFnibycbwE5HCeIVIr0kGPtsEy7xleARuzej5JZ4rBzXyuO0gccfBTVFrndq__ROtrjPExtaBDexlJ00'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSegmentedControl(),
            const SizedBox(height: 32),
            _buildNutritionOverview(context),
            const SizedBox(height: 32),
            _buildBentoGrid(context),
            const SizedBox(height: 32),
            _buildFinancialHealth(context),
            const SizedBox(height: 32),
            _buildExportButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0 ? AppTheme.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: _selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  'Nutrition',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedIndex == 0 ? AppTheme.primary : AppTheme.outline,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? AppTheme.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: _selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  'Expenses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedIndex == 1 ? AppTheme.primary : AppTheme.outline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7-DAY ANALYSIS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary.withOpacity(0.7),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 4),
                Text('Calorie Intake', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '13,440',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primary,
                        fontSize: 32,
                      ),
                ),
                Text(
                  'TOTAL KCAL',
                  style: TextStyle(
                    color: AppTheme.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primary.withOpacity(0.1), Colors.transparent],
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          days[value.toInt() % 7],
                          style: TextStyle(
                            color: value.toInt() == 3 ? AppTheme.primary : AppTheme.outline,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
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
                _buildBarGroup(3, 95, isHighlighted: true),
                _buildBarGroup(4, 70),
                _buildBarGroup(5, 80),
                _buildBarGroup(6, 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, {bool isHighlighted = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primary,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(9999)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: AppTheme.primary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildBentoItem(
          context,
          'Weekly Avg',
          '1,920 kcal',
          Symbols.avg_pace,
          AppTheme.primary,
          AppTheme.surfaceContainerLow,
        ),
        _buildBentoItem(
          context,
          'Top Category',
          'African Dishes',
          Symbols.restaurant_menu,
          AppTheme.secondary,
          AppTheme.secondary.withOpacity(0.05),
          borderColor: AppTheme.secondary.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildBentoItem(BuildContext context, String label, String value, IconData icon, Color color, Color bg, {Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.outline,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealth(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Financial Health', style: Theme.of(context).textTheme.titleLarge),
            const Text('View Details', style: TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY BUDGET',
                        style: TextStyle(
                          color: AppTheme.outline,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$320 ',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const TextSpan(
                              text: '/ \$500',
                              style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Symbols.payments, color: AppTheme.tertiary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.64,
                  minHeight: 12,
                  backgroundColor: AppTheme.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.tertiaryContainer),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('64% SPENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outline, letterSpacing: 1)),
                  Text('\$180 REMAINING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outline, letterSpacing: 1)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Symbols.picture_as_pdf, color: Colors.white),
        label: const Text('Export PDF Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF263238),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      ),
    );
  }
}
