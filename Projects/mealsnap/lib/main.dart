import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:material_symbols_icons/symbols.dart'; // Fixed: use Icons instead
import 'package:google_fonts/google_fonts.dart';

import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/meal_suggestions_screen.dart';
import 'services/auth_service.dart';
import 'firebase_config.dart';

// TODO: Uncomment when Firebase is configured
// import 'firebase_config.dart';

void main() {
  runApp(const MealSnapApp());
}

class MealSnapApp extends StatelessWidget {
  const MealSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MealSnap+',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF0D631B),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF2E7D32),
          onPrimaryContainer: Color(0xFF002204),
          secondary: Color(0xFF964900),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFFC820C),
          onSecondaryContainer: Color(0xFF5E2C00),
          tertiary: Color(0xFF005A8C),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFF0073B2),
          onTertiaryContainer: Color(0xFFFFFFFF),
          error: Color(0xFFBA1A1A),
          onError: Color(0xFFFFFFFF),
          surface: Color(0xFFF4FAFF),
          onSurface: Color(0xFF111D23),
          surfaceContainerHighest: Color(0xFFD7E4EC),
          surfaceContainerHigh: Color(0xFFDDEAF2),
          surfaceContainer: Color(0xFFE3F0F8),
          surfaceContainerLow: Color(0xFFE9F6FD),
          surfaceContainerLowest: Color(0xFFFFFFFF),
          onSurfaceVariant: Color(0xFF40493D),
          outline: Color(0xFF707A6C),
          outlineVariant: Color(0xFFBFCABA),
          inverseSurface: Color(0xFF263238),
          onInverseSurface: Color(0xFFE3F0F8),
          inversePrimary: Color(0xFFA3F69C),
          shadow: Color(0xFF000000),
          surfaceTint: Color(0xFF0D631B),
        ),
        fontFamily: 'Inter',
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
          titleSmall: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
          bodySmall: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
          ),
          labelLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
          labelMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
          labelSmall: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return const HomePage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Screen list with proper navigation
  final List<Widget> _pages = <Widget>[
    const HomeContent(),
    const AnalyticsScreen(),
    const ScanScreen(),
    const MealSuggestionsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Suggest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withValues(alpha: 0.88),
        selectedItemColor: const Color(0xFF0D631B),
        unselectedItemColor: const Color(0xFF94A3B8),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 32),
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: const Color(0xFF0D631B),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  String _greetingName() {
    final user = AuthService.currentUser;
    if (user == null) return 'Chef';
    if (user.displayName?.isNotEmpty == true) {
      return user.displayName!;
    }
    if (user.email?.isNotEmpty == true) {
      return user.email!.split('@').first;
    }
    return 'Chef';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white.withValues(alpha: 0.93),
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'MealSnap+',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: const Color(0xFF111D23),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
              color: const Color(0xFF111D23),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
              color: const Color(0xFF111D23),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Good morning, ${_greetingName()}! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111D23),
                  ),
                ),
                const SizedBox(height: 16),
                // Nutrition Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF111D23).withValues(alpha: 0.06),
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
                          const Text(
                            'Today\'s Nutrition',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111D23),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA3F69C).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'On Track',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D631B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  '1,247',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D631B),
                                  ),
                                ),
                                const Text(
                                  'Calories',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF40493D),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: 0.7,
                                  backgroundColor: const Color(0xFFE9F6FD),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D631B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMacroItem('Protein', '78g', '62%', const Color(0xFF964900)),
                                const SizedBox(height: 12),
                                _buildMacroItem('Carbs', '145g', '48%', const Color(0xFF005A8C)),
                                const SizedBox(height: 12),
                                _buildMacroItem('Fat', '45g', '58%', const Color(0xFF2E7D32)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Ready to Snap
                const Text(
                  'Ready to snap?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111D23),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Meal Photo',
                        'Snap your food',
                        Icons.camera_alt,
                        const Color(0xFF0D631B),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(initialMode: ScanMode.meal),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        'Ingredients',
                        'What\'s in your fridge?',
                        Icons.kitchen,
                        const Color(0xFF964900),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(initialMode: ScanMode.ingredients),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Receipt',
                        'Track expenses',
                        Icons.receipt,
                        const Color(0xFF005A8C),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(initialMode: ScanMode.receipt),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        'Voice',
                        'Tell me what you ate',
                        Icons.mic,
                        const Color(0xFF2E7D32),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(initialMode: ScanMode.voice),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Suggested Meal
                const Text(
                  'Suggested for you',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111D23),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF111D23).withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFE9F6FD), // Placeholder color
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Color(0xFF005A8C),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chicken Stir Fry',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111D23),
                              ),
                            ),
                            const Text(
                              'From your ingredients: chicken, veggies',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF40493D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Color(0xFF707A6C),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '25 min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF707A6C),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                  color: Color(0xFF964900),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '320 cal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF964900),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {},
                        color: const Color(0xFF707A6C),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Recent Activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111D23),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentActivityItem(
                  'Lunch: Rice & Beans',
                  '2 hours ago',
                  '520 cal',
                  Icons.restaurant,
                ),
                const SizedBox(height: 12),
                _buildRecentActivityItem(
                  'Breakfast: Oatmeal',
                  '6 hours ago',
                  '280 cal',
                  Icons.free_breakfast,
                ),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildMacroItem(String label, String value, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF40493D),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111D23),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _buildActionButton(String title, String subtitle, IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppTheme.primary.withOpacity(0.1),
            selectedIndex: _calculateSelectedIndex(location),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Symbols.home),
Icon(Icons.home, fill: true),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Symbols.receipt_long),
                selectedIcon: Icon(Symbols.receipt_long, fill: 1),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Symbols.center_focus_strong),
                selectedIcon: Icon(Symbols.center_focus_strong, fill: 1),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Symbols.bar_chart),
                selectedIcon: Icon(Symbols.bar_chart, fill: 1),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Symbols.person),
                selectedIcon: Icon(Symbols.person, fill: 1),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location == '/suggestions') return 1;
    // index 2 is Scan (push)
    if (location == '/analytics') return 3;
    if (location == '/profile') return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/suggestions');
        break;
      case 2:
        context.push('/scan');
        break;
      case 3:
        context.go('/analytics');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

