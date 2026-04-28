import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../models/firebase_models.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/firestore_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  // Step 1 – Goals
  String _healthGoal = 'maintain';

  // Step 2 – Nutrition targets
  final _calorieController = TextEditingController(text: '2000');

  // Step 3 – Dietary preferences
  final _dietOptions = ['Vegetarian', 'Vegan', 'Gluten-Free', 'Dairy-Free', 'Halal', 'Keto', 'None'];
  final _selectedDiet = <String>{};

  // Step 4 – Cuisines
  final _cuisineOptions = ['African', 'International', 'Asian', 'Mediterranean', 'American', 'Indian'];
  final _selectedCuisines = <String>{'African', 'International'};

  // Step 5 – Budget
  final _budgetController = TextEditingController(text: '100000');

  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _calorieController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _prev() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final uid = AuthService.currentUser?.uid;
      if (uid == null) return;

      final settings = UserSettings(
        healthGoal: _healthGoal,
        dailyCalorieGoal: int.tryParse(_calorieController.text) ?? 2000,
        dietaryPreferences: _selectedDiet.toList(),
        preferredCuisines: _selectedCuisines.map((c) => c.toLowerCase()).toList(),
        monthlyBudget: double.tryParse(_budgetController.text) ?? 100000,
      );

      await FirestoreService().updateUserSettings(uid, settings);
      await CacheService.saveUserSettings(settings);

      // Mark onboarding done on Firestore + local cache
      await AuthService.db.collection('users').doc(uid).set(
        {'onboardingComplete': true},
        SetOptions(merge: true),
      );
      await CacheService.setOnboardingComplete();

      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: List.generate(5, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _page ? AppTheme.primary : AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('${_page + 1} / 5',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.outline)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _GoalPage(selected: _healthGoal, onChanged: (v) => setState(() => _healthGoal = v)),
                  _CaloriePage(controller: _calorieController),
                  _DietPage(options: _dietOptions, selected: _selectedDiet, onToggle: (v) => setState(() {
                    if (_selectedDiet.contains(v)) _selectedDiet.remove(v); else _selectedDiet.add(v);
                  })),
                  _CuisinePage(options: _cuisineOptions, selected: _selectedCuisines, onToggle: (v) => setState(() {
                    if (_selectedCuisines.contains(v)) _selectedCuisines.remove(v); else _selectedCuisines.add(v);
                  })),
                  _BudgetPage(controller: _budgetController),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  if (_page > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prev,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _saving ? null : _next,
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_page == 4 ? 'Get Started' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step pages ────────────────────────────────────────────────────────────────

class _GoalPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _GoalPage({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final goals = [
      ('lose', 'Lose Weight', Icons.trending_down_rounded),
      ('maintain', 'Maintain Weight', Icons.balance_rounded),
      ('gain', 'Gain Muscle', Icons.trending_up_rounded),
    ];
    return _PageShell(
      title: "What's your goal?",
      subtitle: 'We\'ll personalise your calorie targets and meal suggestions.',
      child: Column(
        children: goals.map((g) {
          final isSelected = selected == g.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectCard(
              label: g.$2,
              icon: g.$3,
              selected: isSelected,
              onTap: () => onChanged(g.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CaloriePage extends StatelessWidget {
  final TextEditingController controller;
  const _CaloriePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Daily calorie goal',
      subtitle: 'You can change this anytime in settings.',
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Calories (kcal)',
          border: OutlineInputBorder(),
          suffixText: 'kcal',
        ),
      ),
    );
  }
}

class _DietPage extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _DietPage({required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Dietary preferences',
      subtitle: 'Select all that apply.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((o) => FilterChip(
          label: Text(o),
          selected: selected.contains(o),
          onSelected: (_) => onToggle(o),
        )).toList(),
      ),
    );
  }
}

class _CuisinePage extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _CuisinePage({required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Favourite cuisines',
      subtitle: 'Used to personalise meal suggestions.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((o) => FilterChip(
          label: Text(o),
          selected: selected.contains(o),
          onSelected: (_) => onToggle(o),
        )).toList(),
      ),
    );
  }
}

class _BudgetPage extends StatelessWidget {
  final TextEditingController controller;
  const _BudgetPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Monthly food budget',
      subtitle: 'We\'ll track your spending against this.',
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Budget',
          border: OutlineInputBorder(),
          prefixText: '₦ ',
        ),
      ),
    );
  }
}

// ── Shared layout ─────────────────────────────────────────────────────────────

class _PageShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _PageShell({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.outline)),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

class _SelectCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SelectCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.surfaceContainerLowest,
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.outline, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? AppTheme.primary : AppTheme.outline),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppTheme.primary : AppTheme.onSurface,
          )),
          const Spacer(),
          if (selected) const Icon(Icons.check_circle, color: AppTheme.primary),
        ]),
      ),
    );
  }
}
