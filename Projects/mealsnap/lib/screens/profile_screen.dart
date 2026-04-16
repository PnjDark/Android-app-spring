import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/firebase_models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _user;
  bool _loading = true;

  static const _goalLabels = {
    'lose_weight': 'Lose Weight',
    'maintain': 'Maintain',
    'gain_muscle': 'Gain Muscle',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final loadedUser = await _firestoreService.getUser(currentUser.uid);
    setState(() {
      _user = loadedUser;
      _loading = false;
    });
  }

  Future<void> _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileSettingsScreen(),
      ),
    );
    await _loadProfile();
  }

  double _calculateWeightProgress(UserSettings settings) {
    if (settings.currentWeight == null || settings.targetWeight == null || settings.currentWeight == 0) {
      return 0.0;
    }
    if (settings.healthGoal == 'gain_muscle') {
      return (settings.currentWeight! / settings.targetWeight!).clamp(0.0, 1.0);
    }
    return (settings.targetWeight! / settings.currentWeight!).clamp(0.0, 1.0);
  }

  String _dietaryLabel(String key) {
    switch (key) {
      case 'vegetarian':
        return 'Vegetarian';
      case 'vegan':
        return 'Vegan';
      case 'low_carb':
        return 'Low-Carb';
      case 'no_pork':
        return 'No Pork';
      case 'pescatarian':
        return 'Pescatarian';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _cuisineLabel(String key) {
    switch (key) {
      case 'african':
        return 'African';
      case 'international':
        return 'International';
      case 'comfort':
        return 'Comfort';
      case 'low_calorie':
        return 'Low-Calorie';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName ?? 'Chef';
    final email = currentUser?.email ?? 'chef@mealsnap.com';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MealSnap+',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: colorScheme.primary.withAlpha(30),
                          foregroundImage: _user != null && _user!.photoUrl != null && _user!.photoUrl!.isNotEmpty
                              ? NetworkImage(_user!.photoUrl!) as ImageProvider
                              : null,
                          child: _user == null || _user!.photoUrl == null || _user!.photoUrl!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 56,
                                  color: colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _user?.name ?? displayName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 160,
                          child: OutlinedButton(
                            onPressed: _navigateToSettings,
                            child: const Text('Update Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HEALTH GOALS',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                            ),
                            TextButton(
                              onPressed: _navigateToSettings,
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary.withAlpha(30),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.fitness_center,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Weight Goal',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              _user?.settings.healthGoal != null
                                                  ? _goalLabels[_user!.settings.healthGoal] ?? 'Personal Goal'
                                                  : 'Personal Goal',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${_user?.settings.currentWeight?.toStringAsFixed(1) ?? '--'}kg',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          '/${_user?.settings.targetWeight?.toStringAsFixed(1) ?? '--'}kg',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _user != null
                                        ? _calculateWeightProgress(_user!.settings)
                                        : 0.0,
                                    minHeight: 8,
                                    backgroundColor: colorScheme.surfaceContainerHigh,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_user != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAILY TARGETS',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Calories',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        '${_user!.settings.dailyCalorieGoal} kcal',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Budget',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        '₦${_user!.settings.monthlyBudget.toStringAsFixed(0)}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DIETARY PREFERENCES',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (_user!.settings.dietaryPreferences.isEmpty)
                            Text(
                              'No dietary preferences configured yet.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _user!.settings.dietaryPreferences.map((preference) {
                                return Chip(
                                  label: Text(_dietaryLabel(preference)),
                                  backgroundColor: colorScheme.primary.withAlpha(30),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREFERRED CUISINES',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (_user!.settings.preferredCuisines.isEmpty)
                            Text(
                              'No cuisine preferences configured yet.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _user!.settings.preferredCuisines.map((cuisine) {
                                return Chip(
                                  label: Text(_cuisineLabel(cuisine)),
                                  backgroundColor: colorScheme.secondary.withAlpha(30),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SETTINGS',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Column(
                            children: [
                              _SettingsTile(
                                icon: Icons.notifications,
                                title: 'Notifications',
                                onTap: _navigateToSettings,
                              ),
                              Divider(
                                height: 1,
                                color: colorScheme.surfaceContainer,
                              ),
                              _SettingsTile(
                                icon: Icons.security,
                                title: 'Account Security',
                                onTap: _navigateToSettings,
                              ),
                              Divider(
                                height: 1,
                                color: colorScheme.surfaceContainer,
                              ),
                              _SettingsTile(
                                icon: Icons.privacy_tip,
                                title: 'Privacy',
                                onTap: _navigateToSettings,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () async {
                          await AuthService.signOut();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.secondary),
                const SizedBox(width: 16),
                Text(title),
              ],
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
