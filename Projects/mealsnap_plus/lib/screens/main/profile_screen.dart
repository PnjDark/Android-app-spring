import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/app_theme.dart';
import '../../widgets/top_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const MealSnapTopAppBar(
        showMenu: true,
        showSettings: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Hero Profile Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(colors: [AppTheme.primaryColor, Color(0xFFFC820C)]),
                        ),
                        child: const CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCEif0oc34897eYm8Bfy9XXAOG4uFyNaRzUjJIU0QaQOkUkT6N8hrot3IoJfpK7JruAJ9xz48RLIqlV4BhnuE-fEzFnmfKi_BJrHXTX0LG3ST_TtlR0nVsfmagBgQ2hZ4x0rtWwCShOUuiTZnOLtApSpp0V0XOW-qwKP4wCK1zyw1XdO_5RkMmx-MsJWqEKPOWQAipeAOMUmfEVc2Rb6whhK6qCey8CTxT5kCzJ9o8FbbngCjvD18Q5QmYreYIHkhPC6IKsQWASjTsU'),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Symbols.edit, size: 14, color: Colors.white, fill: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sarah Mitchell',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  ),
                  const Text(
                    'sarah.m@culinarycurator.com',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.outlineColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Health Goals Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('HEALTH GOALS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.outlineColor)),
                Text('Update', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Symbols.monitor_weight, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weight Goal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('5kg to go', style: TextStyle(fontSize: 12, color: AppTheme.outlineColor)),
                              ],
                            ),
                          ],
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
                            children: [
                              TextSpan(text: '65'),
                              TextSpan(text: '/70kg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.outlineColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(5)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.92,
                        child: Container(decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(5))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Dietary Preferences Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('DIETARY PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.outlineColor)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                _buildPreferenceChip('High Protein', Symbols.restaurant, active: true),
                _buildPreferenceChip('Gluten-Free', Symbols.eco),
                _buildPreferenceChip('Low Carb', Symbols.bolt),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    border: Border.all(color: AppTheme.outlineVariantColor, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Symbols.add, size: 24, color: AppTheme.outlineColor),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Settings Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('SETTINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.outlineColor)),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildSettingItem(context, 'Notifications', Symbols.notifications),
                  const Divider(height: 1, indent: 64),
                  _buildSettingItem(context, 'Account Security', Symbols.security),
                  const Divider(height: 1, indent: 64),
                  _buildSettingItem(context, 'Privacy', Symbols.privacy_tip),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceContainerHighest,
                  foregroundColor: AppTheme.errorColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Symbols.logout, size: 20, weight: 700),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildPreferenceChip(String label, IconData icon, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryFixed : AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: active ? AppTheme.onPrimaryFixed : AppTheme.onSurfaceColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: active ? AppTheme.onPrimaryFixed : AppTheme.onSurfaceColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.secondaryColor),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Symbols.chevron_right, color: AppTheme.outlineColor, size: 20),
      onTap: () {},
    );
  }
}
