import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../models/firebase_models.dart';
import '../services/firestore_service.dart';

// -----------------------------------------------------------------------------
// Analytics Screen -- Priority 8: real data + settings, no profile avatar
// -----------------------------------------------------------------------------

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _tab = 0; // 0 = Nutrition, 1 = Expenses
  bool _loading = true;

  final _fs = FirestoreService();
  String? _uid;

  // Nutrition data
  List<DailyStatsModel> _weekStats = [];
  double _weeklyTotalCal = 0;
  double _weeklyAvgCal = 0;
  String _topCategory = '--';

  // Expense data
  double _monthlyTotal = 0;
  double _monthlyBudget = 500;
  Map<String, double> _byCategory = {};

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_uid == null) return;
    setState(() => _loading = true);

    final now = DateTime.now();

    // -- 7-day nutrition ------------------------------------------------------
    final stats = await _fs.getDailyStatsRange(
      _uid!,
      startDate: now.subtract(const Duration(days: 6)),
      endDate: now,
    );

    double total = 0;
    for (final s in stats) {
      total += s.totalCalories;
    }

    // -- Monthly expenses -----------------------------------------------------
    final spending = await _fs.getMonthlySpending(_uid!);
    final user = await _fs.getUser(_uid!);

    if (mounted) {
      setState(() {
        _weekStats = stats;
        _weeklyTotalCal = total;
        _weeklyAvgCal = stats.isEmpty ? 0 : total / stats.length;
        _topCategory =
            stats.isNotEmpty ? 'African Dishes' : '--'; // placeholder
        _monthlyTotal = (spending['total'] as double?) ?? 0;
        _monthlyBudget =
            user?.settings.monthlyBudget.toDouble() ?? 500;
        _byCategory = Map<String, double>.from(
            (spending['byCategory'] as Map<dynamic, dynamic>?)
                    ?.map((k, v) => MapEntry(k.toString(),
                        (v as num).toDouble())) ??
                {});
        _loading = false;
      });
    }
  }

  Future<void> _showSettingsDialog() async {
    final budgetCtrl = TextEditingController(
        text: _monthlyBudget.toStringAsFixed(0));
    final weightCtrl = TextEditingController();
    final targetCtrl = TextEditingController();

    if (_uid != null) {
      final user = await _fs.getUser(_uid!);
      weightCtrl.text =
          user?.settings.currentWeight?.toStringAsFixed(1) ?? '';
      targetCtrl.text =
          user?.settings.targetWeight?.toStringAsFixed(1) ?? '';
      budgetCtrl.text =
          user?.settings.monthlyBudget.toStringAsFixed(0) ?? '500';
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Analytics Settings',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _SettingsField(
              controller: budgetCtrl,
              label: 'Monthly Food Budget',
              prefix: '\$',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _SettingsField(
              controller: weightCtrl,
              label: 'Current Weight (kg)',
              suffix: 'kg',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _SettingsField(
              controller: targetCtrl,
              label: 'Target Weight (kg)',
              suffix: 'kg',
              keyboardType: TextInputType.number,
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (_uid == null) return;
              final user = await _fs.getUser(_uid!);
              final settings = user?.settings ?? UserSettings();
              await _fs.updateUserSettings(
                _uid!,
                UserSettings(
                  dailyCalorieGoal: settings.dailyCalorieGoal,
                  monthlyBudget: double.tryParse(budgetCtrl.text) ??
                      settings.monthlyBudget,
                  dietaryPreferences: settings.dietaryPreferences,
                  healthGoal: settings.healthGoal,
                  preferredCuisines: settings.preferredCuisines,
                  age: settings.age,
                  height: settings.height,
                  currentWeight:
                      double.tryParse(weightCtrl.text) ??
                          settings.currentWeight,
                  targetWeight:
                      double.tryParse(targetCtrl.text) ??
                          settings.targetWeight,
                ),
              );
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Priority 8: settings icon, NO profile avatar
        title: Row(children: [
          const Icon(Symbols.restaurant, color: Color(0xFF0D631B)),
          const SizedBox(width: 8),
          Text('MealSnap+',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: const Color(0xFF0D631B))),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings,
                color: Color(0xFF0D631B)),
            tooltip: 'Analytics Settings',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  _buildSegmentControl(),
                  const SizedBox(height: 28),
                  if (_tab == 0) ...[
                    _buildNutritionChart(),
                    const SizedBox(height: 28),
                    _buildNutritionBento(),
                  ] else ...[
                    _buildExpenseCard(),
                    const SizedBox(height: 28),
                    _buildCategoryBreakdown(),
                  ],
                  const SizedBox(height: 28),
                  _buildExportButton(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
    );
  }

  // -- Segment control ------------------------------------------------------

  Widget _buildSegmentControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F6FD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _SegBtn('Nutrition', 0, _tab, () => setState(() => _tab = 0)),
          _SegBtn('Expenses', 1, _tab, () => setState(() => _tab = 1)),
        ],
      ),
    );
  }

  // -- Nutrition chart ------------------------------------------------------

  Widget _buildNutritionChart() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final maxCal = _weekStats.isEmpty
        ? 2200.0
        : _weekStats
                .map((s) => s.totalCalories)
                .reduce((a, b) => a > b ? a : b)
                .clamp(1.0, double.infinity) *
            1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('7-DAY ANALYSIS',
                  style: TextStyle(
                      color: const Color(0xFF0D631B).withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Calorie Intake',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                _weeklyTotalCal > 0
                    ? _weeklyTotalCal.round().toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]},')
                    : '0',
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF0D631B),
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              const Text('TOTAL KCAL',
                  style: TextStyle(
                      color: Color(0xFF707A6C),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ]),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxCal,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                  '${rod.toY.round()} kcal',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      days[v.toInt() % 7],
                      style: const TextStyle(
                          color: Color(0xFF707A6C),
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  ),
                ),
              ),
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (i) {
              final cal = i < _weekStats.length
                  ? _weekStats[_weekStats.length - 1 - i].totalCalories
                  : 0.0;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: cal,
                    color: const Color(0xFF0D631B),
                    width: 22,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxCal,
                      color: const Color(0xFFE9F6FD),
                    ),
                  ),
                ],
              );
            }),
          )),
        ),
      ],
    );
  }

  Widget _buildNutritionBento() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _BentoTile(
          label: 'Weekly Avg',
          value: '${_weeklyAvgCal.round()} kcal',
          icon: Symbols.avg_pace,
          color: const Color(0xFF0D631B),
          bg: const Color(0xFFE9F6FD),
        ),
        _BentoTile(
          label: 'Top Category',
          value: _topCategory,
          icon: Symbols.restaurant_menu,
          color: const Color(0xFF964900),
          bg: const Color(0xFFFFF3E0),
        ),
      ],
    );
  }

  // -- Expense card ---------------------------------------------------------

  Widget _buildExpenseCard() {
    final used = _monthlyBudget > 0
        ? (_monthlyTotal / _monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (_monthlyBudget - _monthlyTotal).clamp(0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('MONTHLY BUDGET',
                style: TextStyle(
                    color: Color(0xFF707A6C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '\$${_monthlyTotal.toStringAsFixed(0)} ',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: '/ \$${_monthlyBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ]),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF005A8C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Symbols.payments,
                color: Color(0xFF005A8C)),
          ),
        ]),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: used,
            minHeight: 12,
            backgroundColor: const Color(0xFFE3F0F8),
            valueColor: AlwaysStoppedAnimation(
              used > 0.85
                  ? const Color(0xFFBA1A1A)
                  : const Color(0xFF0073B2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(used * 100).round()}% SPENT',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF707A6C),
                  letterSpacing: 1)),
          Text('\$${remaining.toStringAsFixed(0)} REMAINING',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF707A6C),
                  letterSpacing: 1)),
        ]),
      ]),
    );
  }

  Widget _buildCategoryBreakdown() {
    if (_byCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: const Center(
            child: Text('No expense data yet.',
                style: TextStyle(color: Color(0xFF707A6C)))),
      );
    }

    final colors = [
      const Color(0xFF0D631B),
      const Color(0xFF964900),
      const Color(0xFF005A8C),
      const Color(0xFF2E7D32),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Category',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          ..._byCategory.entries.toList().asMap().entries.map((e) {
            final i = e.key;
            final cat = e.value.key;
            final amt = e.value.value;
            final pct = _monthlyTotal > 0 ? amt / _monthlyTotal : 0.0;
            final color = colors[i % colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text(
                          '\$${amt.toStringAsFixed(2)}  '
                          '${(pct * 100).round()}%',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE9F6FD),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // -- Export button --------------------------------------------------------

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF export coming soon!')),
          );
        },
        icon: const Icon(Symbols.picture_as_pdf, color: Colors.white),
        label: const Text('Export PDF Report',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF263238),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small widgets
// -----------------------------------------------------------------------------

class _SegBtn extends StatelessWidget {
  final String label;
  final int index, current;
  final VoidCallback onTap;
  const _SegBtn(this.label, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected
                  ? const Color(0xFF0D631B)
                  : const Color(0xFF707A6C),
            ),
          ),
        ),
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _BentoTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 30),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? prefix, suffix;
  final TextInputType? keyboardType;
  const _SettingsField(
      {required this.controller,
      required this.label,
      this.prefix,
      this.suffix,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
