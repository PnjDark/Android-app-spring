import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';
import '../core/error_widgets.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String get _displayName {
    final u = FirebaseAuth.instance.currentUser;
    if (u?.displayName?.isNotEmpty == true) return u!.displayName!;
    if (u?.email?.isNotEmpty == true) return u!.email!.split('@').first;
    return 'Chef';
  }

  String get _email =>
      FirebaseAuth.instance.currentUser?.email ?? '';

  String get _initial =>
      _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'M';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.menu, color: AppTheme.primary),
          onPressed: () {},
        ),
        title: Text(
          'MealSnap+',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildHeroProfile(context),
            const SizedBox(height: 40),
            _buildHealthGoals(context),
            const SizedBox(height: 40),
            _buildDietaryPreferences(context),
            const SizedBox(height: 40),
            _buildSettingsList(context),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroProfile(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
          child: Text(
            _initial,
            style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _displayName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          _email,
          style: const TextStyle(
              color: AppTheme.outline, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildHealthGoals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HEALTH GOALS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.outline,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'Update',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
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
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Symbols.monitor_weight, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weight Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('5kg to go', style: TextStyle(color: AppTheme.outline, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '65',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextSpan(
                          text: '/70kg',
                          style: TextStyle(color: AppTheme.outline, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.92,
                  minHeight: 10,
                  backgroundColor: AppTheme.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryPreferences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIETARY PREFERENCES',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.outline,
                fontSize: 12,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPreferenceChip('High Protein', Symbols.restaurant, true),
            _buildPreferenceChip('Gluten-Free', Symbols.eco, false),
            _buildPreferenceChip('Low Carb', Symbols.bolt, false),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFCABA), style: BorderStyle.solid),
              ),
              child: const Icon(Symbols.add, color: AppTheme.outline, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferenceChip(String label, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFA3F69C) : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isActive ? const Color(0xFF002204) : AppTheme.onSurface),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF002204) : AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.outline,
                fontSize: 12,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(Symbols.notifications, 'Notifications'),
              _buildSettingItem(Symbols.security, 'Account Security'),
              _buildSettingItem(Symbols.privacy_tip, 'Privacy'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.secondary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Symbols.chevron_right, color: AppTheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await AuthService.signOut();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(friendlyError(e))),
              );
            }
          }
        },
        icon: const Icon(Symbols.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surfaceContainer,
          foregroundColor: AppTheme.error,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
