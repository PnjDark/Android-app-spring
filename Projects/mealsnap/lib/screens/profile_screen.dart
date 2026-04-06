import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCEif0oc34897eYm8Bfy9XXAOG4uFyNaRzUjJIU0QaQOkUkT6N8hrot3IoJfpK7JruAJ9xz48RLIqlV4BhnuE-fEzFnmfKi_BJrHXTX0LG3ST_TtlR0nVsfmagBgQ2hZ4x0rtWwCShOUuiTZnOLtApSpp0V0XOW-qwKP4wCK1zyw1XdO_5RkMmx-MsJWqEKPOWQAipeAOMUmfEVc2Rb6whhK6qCey8CTxT5kCzJ9o8FbbngCjvD18Q5QmYreYIHkhPC6IKsQWASjTsU'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 2),
                ),
                child: const Icon(Symbols.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Sarah Mitchell',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          'sarah.m@culinarycurator.com',
          style: TextStyle(color: AppTheme.outline, fontWeight: FontWeight.w500),
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
        onPressed: () {},
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
