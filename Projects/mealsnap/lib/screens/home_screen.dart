import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data Models
class NutritionData {
  final double calories;
  final double maxCalories;
  final double protein;
  final double maxProtein;
  final double carbs;
  final double maxCarbs;
  final double fats;
  final double maxFats;

  NutritionData({
    required this.calories,
    required this.maxCalories,
    required this.protein,
    required this.maxProtein,
    required this.carbs,
    required this.maxCarbs,
    required this.fats,
    required this.maxFats,
  });

  factory NutritionData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NutritionData(
      calories: (data['calories'] ?? 0).toDouble(),
      maxCalories: (data['maxCalories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      maxProtein: (data['maxProtein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      maxCarbs: (data['maxCarbs'] ?? 0).toDouble(),
      fats: (data['fats'] ?? 0).toDouble(),
      maxFats: (data['maxFats'] ?? 0).toDouble(),
    );
  }
}

class Meal {
  final String name;
  final String tag;
  final String imageUrl;

  Meal({required this.name, required this.tag, required this.imageUrl});

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Meal(
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class Activity {
  final String title;
  final String subtitle;
  final String trailing;
  final String icon;
  final String color;

  Activity({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    required this.color,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Activity(
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      trailing: data['trailing'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'] ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<NutritionData> _nutritionFuture;
  late Future<Meal> _mealFuture;
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _nutritionFuture = _fetchNutritionData();
    _mealFuture = _fetchSuggestedMeal();
    _activitiesFuture = _fetchRecentActivities();
  }

  Future<NutritionData> _fetchNutritionData() async {
    final doc = await FirebaseFirestore.instance
        .collection('nutrition')
        .doc('dailyProgress')
        .get();
    return NutritionData.fromFirestore(doc);
  }

  Future<Meal> _fetchSuggestedMeal() async {
    final doc = await FirebaseFirestore.instance
        .collection('meals')
        .doc('suggested')
        .get();
    return Meal.fromFirestore(doc);
  }

  Future<List<Activity>> _fetchRecentActivities() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('activities').get();
    return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
  }

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
            FutureBuilder<NutritionData>(
              future: _nutritionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                } else if (snapshot.hasData) {
                  return _buildNutritionProgress(context, snapshot.data!);
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context),
            const SizedBox(height: 32),
            FutureBuilder<Meal>(
              future: _mealFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                } else if (snapshot.hasData) {
                  return _buildSuggestedMeal(context, snapshot.data!);
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<Activity>>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                } else if (snapshot.hasData) {
                  return _buildRecentActivity(context, snapshot.data!);
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionProgress(BuildContext context, NutritionData nutrition) {
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
              _buildCircularProgress(context, nutrition),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildProgressBar(context, 'Protein', '${nutrition.protein}g / ${nutrition.maxProtein}g', nutrition.protein / nutrition.maxProtein, AppTheme.primary),
                    const SizedBox(height: 16),
                    _buildProgressBar(context, 'Carbs', '${nutrition.carbs}g / ${nutrition.maxCarbs}g', nutrition.carbs / nutrition.maxCarbs, AppTheme.secondaryContainer),
                    const SizedBox(height: 16),
                    _buildProgressBar(context, 'Fats', '${nutrition.fats}g / ${nutrition.maxFats}g', nutrition.fats / nutrition.maxFats, AppTheme.tertiaryContainer),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(BuildContext context, NutritionData nutrition) {
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
              value: nutrition.calories / nutrition.maxCalories,
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
                '${nutrition.calories.toInt()}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '/ ${nutrition.maxCalories.toInt()} KCAL',
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

  Widget _buildSuggestedMeal(BuildContext context, Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggested for Lunch', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: NetworkImage(meal.imageUrl),
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
                      child: Text(
                        meal.tag,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF002204)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meal.name,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildRecentActivity(BuildContext context, List<Activity> activities) {
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
        ...activities
            .map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityItem(
                    context,
                    activity.title,
                    activity.subtitle,
                    activity.trailing,
                    _getIconFromString(activity.icon),
                    _getColorFromString(activity.color),
                  ),
                ))
            .toList(),
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

  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'breakfast_dining':
        return Symbols.breakfast_dining;
      case 'receipt_long':
        return Symbols.receipt_long;
      default:
        return Symbols.restaurant;
    }
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'primary':
        return AppTheme.primary;
      case 'tertiary':
        return AppTheme.tertiary;
      default:
        return AppTheme.onSurface;
    }
  }
}
