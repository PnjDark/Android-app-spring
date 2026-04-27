import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/firebase_models.dart';
import '../services/firestore_service.dart';

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

class NutritionData {
  final double calories, maxCalories;
  final double protein, maxProtein;
  final double carbs, maxCarbs;
  final double fats, maxFats;

  const NutritionData({
    required this.calories, required this.maxCalories,
    required this.protein, required this.maxProtein,
    required this.carbs, required this.maxCarbs,
    required this.fats, required this.maxFats,
  });

  static NutritionData get placeholder => const NutritionData(
    calories: 0, maxCalories: 2200,
    protein: 0, maxProtein: 120,
    carbs: 0, maxCarbs: 250,
    fats: 0, maxFats: 70,
  );
}

// ---------------------------------------------------------------------------
// HomeScreen
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = FirestoreService();

  NutritionData _nutrition = NutritionData.placeholder;
  List<MealModel> _recentMeals = [];
  bool _nutritionLoading = true;
  bool _mealsLoading = true;

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  String get _userName {
    final u = FirebaseAuth.instance.currentUser;
    if (u?.displayName?.isNotEmpty == true) return u!.displayName!;
    if (u?.email?.isNotEmpty == true) return u!.email!.split('@').first;
    return 'Chef';
  }

  @override
  void initState() {
    super.initState();
    _loadNutrition();
    _loadRecentMeals();
  }

  Future<void> _loadNutrition() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _nutritionLoading = false);
      return;
    }
    try {
      final results = await Future.wait([
        _service.getDailyStats(uid, _todayKey),
        _service.getUser(uid),
      ]).timeout(const Duration(seconds: 8));

      final stats = results[0] as DailyStatsModel?;
      final user = results[1] as UserModel?;
      final goal = user?.settings.dailyCalorieGoal.toDouble() ?? 2200;

      if (mounted && stats != null) {
        setState(() {
          _nutrition = NutritionData(
            calories: stats.totalCalories,
            maxCalories: goal,
            protein: stats.protein,
            maxProtein: 120,
            carbs: stats.carbs,
            maxCarbs: 250,
            fats: stats.fats,
            maxFats: 70,
          );
        });
      }
    } catch (_) {
      // Keep placeholder
    } finally {
      if (mounted) setState(() => _nutritionLoading = false);
    }
  }

  Future<void> _loadRecentMeals() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _mealsLoading = false);
      return;
    }
    try {
      final meals = await _service
          .getRecentMeals(uid, limit: 5)
          .timeout(const Duration(seconds: 8));
      if (mounted) setState(() => _recentMeals = meals);
    } catch (_) {
      // Leave empty
    } finally {
      if (mounted) setState(() => _mealsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(children: [
          const Icon(Symbols.restaurant, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            'MealSnap+',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primary,
                  letterSpacing: -1,
                ),
          ),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'M',
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _nutritionLoading = true;
            _mealsLoading = true;
          });
          await Future.wait([_loadNutrition(), _loadRecentMeals()]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.outline,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hello, $_userName!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              _buildNutritionProgress(context, _nutrition, _nutritionLoading),
              const SizedBox(height: 32),
              _buildActionButtons(context),
              const SizedBox(height: 32),
              _buildRecentActivity(context, _recentMeals, _mealsLoading),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Nutrition card
  // -------------------------------------------------------------------------

  Widget _buildNutritionProgress(
      BuildContext context, NutritionData n, bool loading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Daily Nutrition Progress',
              style: Theme.of(context).textTheme.titleLarge),
          if (loading)
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          _buildCircularProgress(context, n),
          const SizedBox(width: 32),
          Expanded(
            child: Column(children: [
              _buildProgressBar(context, 'Protein',
                  '${n.protein.toInt()}g / ${n.maxProtein.toInt()}g',
                  n.maxProtein > 0 ? n.protein / n.maxProtein : 0,
                  AppTheme.primary),
              const SizedBox(height: 16),
              _buildProgressBar(context, 'Carbs',
                  '${n.carbs.toInt()}g / ${n.maxCarbs.toInt()}g',
                  n.maxCarbs > 0 ? n.carbs / n.maxCarbs : 0,
                  AppTheme.secondaryContainer),
              const SizedBox(height: 16),
              _buildProgressBar(context, 'Fats',
                  '${n.fats.toInt()}g / ${n.maxFats.toInt()}g',
                  n.maxFats > 0 ? n.fats / n.maxFats : 0,
                  AppTheme.tertiaryContainer),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _buildCircularProgress(BuildContext context, NutritionData n) {
    final ratio = n.maxCalories > 0 ? n.calories / n.maxCalories : 0.0;
    return SizedBox(
      width: 120, height: 120,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 120, height: 120,
          child: CircularProgressIndicator(
            value: ratio.clamp(0, 1),
            strokeWidth: 12,
            backgroundColor: AppTheme.surfaceContainerLow,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${n.calories.toInt()}',
              style: Theme.of(context).textTheme.headlineMedium),
          Text('/ ${n.maxCalories.toInt()} KCAL',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 10, color: AppTheme.outline)),
        ]),
      ]),
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, String value,
      double progress, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
        Text(value,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress.clamp(0, 1),
          minHeight: 8,
          backgroundColor: AppTheme.surfaceContainerLow,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
  }

  // -------------------------------------------------------------------------
  // Action buttons
  // -------------------------------------------------------------------------

  Widget _buildActionButtons(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _buildActionButton(context, 'Scan Meal',
            Symbols.center_focus_strong, AppTheme.primary, Colors.white, true),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildActionButton(context, 'Ingredients',
            Symbols.fact_check, AppTheme.surfaceContainerLowest,
            AppTheme.onSurface, false),
      ),
    ]);
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color bg, Color text, bool hasShadow) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: hasShadow
            ? [BoxShadow(
                color: bg.withValues(alpha: 0.2),
                blurRadius: 15, offset: const Offset(0, 8))]
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
                  color: text.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: text, size: 32),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: TextStyle(
                      color: text, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Recent activity — now driven by real MealModel list
  // -------------------------------------------------------------------------

  Widget _buildRecentActivity(
      BuildContext context, List<MealModel> meals, bool loading) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Activity',
            style: Theme.of(context).textTheme.titleLarge),
        if (loading)
          const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          TextButton(
            onPressed: () {},
            child: const Text('View All',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
      ]),
      const SizedBox(height: 8),
      if (!loading && meals.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text('No recent activity yet.\nScan a meal to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.outline)),
          ),
        )
      else
        ...meals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMealItem(context, meal),
            )),
    ]);
  }

  Widget _buildMealItem(BuildContext context, MealModel meal) {
    final hour = meal.timestamp.hour;
    final timeStr =
        '${hour % 12 == 0 ? 12 : hour % 12}:${meal.timestamp.minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Symbols.restaurant,
              color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(meal.foodName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(timeStr,
                style: const TextStyle(
                    color: AppTheme.outline, fontSize: 12)),
          ]),
        ),
        Text('${meal.calories.toInt()} kcal',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
      ]),
    );
  }
}
