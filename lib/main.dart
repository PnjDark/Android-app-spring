import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'screens/analytics_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meal_suggestions_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MealSnapApp());
}

// -----------------------------------------------------------------------------
// App root
// -----------------------------------------------------------------------------

class MealSnapApp extends StatelessWidget {
  const MealSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealSnap+',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const AuthGate(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
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
      textTheme: TextTheme(
        headlineLarge:
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        headlineMedium:
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        headlineSmall:
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        titleMedium:
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
        bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Auth gate -- listens to Firebase auth state
// -----------------------------------------------------------------------------

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
        if (!snapshot.hasData) return LoginScreen();
        return MainShell();
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Main shell with bottom navigation
// -----------------------------------------------------------------------------

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Pages rendered in-place by the bottom nav (no router needed).
  // Scan is pushed on top as a full-screen modal, so it's not in this list.
  static const _pages = <Widget>[
    HomeContent(),
    AnalyticsScreen(),
    _ScanPlaceholder(), // index 2 -- tap triggers push, never actually shown
    MealSuggestionsScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (index == 2) {
      // Scan: push as a full-screen route so the bottom nav disappears
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ScanScreen(initialMode: ScanMode.meal),
        ),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _ScanPlaceholder extends StatelessWidget {
  const _ScanPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// -----------------------------------------------------------------------------
// Bottom navigation bar
// -----------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF0D631B),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            // Scan -- centre button with accent style
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt,
                    color: Colors.white, size: 22),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt,
                    color: Colors.white, size: 22),
              ),
              label: 'Scan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'Suggest',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Home content (the actual home tab body)
// -----------------------------------------------------------------------------

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  String _greetingName() {
    final user = AuthService.currentUser;
    if (user == null) return 'Chef';
    if (user.displayName?.isNotEmpty == true) return user.displayName!;
    if (user.email?.isNotEmpty == true) {
      return user.email!.split('@').first;
    }
    return 'Chef';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // -- App bar ----------------------------------------------------------
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          elevation: 0,
          title: Row(children: [
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
                child: Text('M',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MealSnap+',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: const Color(0xFF111D23)),
            ),
          ]),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
              color: const Color(0xFF111D23),
            ),
            // Priority 9: settings icon removed from home bar
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Greeting
                Text(
                  '${_greeting()}, ${_greetingName()}! ',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111D23),
                  ),
                ),
                const SizedBox(height: 20),

                // -- Nutrition card ------------------------------------------
                _NutritionCard(),
                const SizedBox(height: 28),

                // -- Quick scan actions --------------------------------------
                Text(
                  'Ready to snap?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111D23),
                  ),
                ),
                const SizedBox(height: 14),
                _ScanActionGrid(),
                const SizedBox(height: 28),

                // -- Suggested meal ------------------------------------------
                Text(
                  'Suggested for you',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111D23),
                  ),
                ),
                const SizedBox(height: 14),
                const _SuggestedMealCard(),
                const SizedBox(height: 28),

                // -- Recent activity -----------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111D23),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All',
                          style: TextStyle(
                              color: Color(0xFF0D631B),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActivityItem(
                    'Lunch: Rice & Beans', '2 hours ago', '520 cal',
                    Icons.restaurant),
                const SizedBox(height: 10),
                _buildActivityItem(
                    'Breakfast: Oatmeal', '6 hours ago', '280 cal',
                    Icons.free_breakfast),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String title, String time, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D631B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF0D631B), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text(time,
                  style: const TextStyle(
                      color: Color(0xFF707A6C), fontSize: 12)),
            ],
          ),
        ),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D631B),
                fontSize: 13)),
      ]),
    );
  }
}

// -----------------------------------------------------------------------------
// Home sub-widgets
// -----------------------------------------------------------------------------

class _NutritionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Today\'s Nutrition',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFA3F69C).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('On Track',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D631B))),
          ),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: Column(children: [
              const Text('1,247',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D631B))),
              const Text('Calories',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF40493D))),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.57,
                  minHeight: 6,
                  backgroundColor: Color(0xFFE9F6FD),
                  valueColor: AlwaysStoppedAnimation(Color(0xFF0D631B)),
                ),
              ),
              Text('1,247 / 2,200 kcal',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[500])),
            ]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroRow('Protein', '78g', '65%',
                    const Color(0xFF964900)),
                const SizedBox(height: 10),
                _MacroRow('Carbs', '145g', '48%',
                    const Color(0xFF005A8C)),
                const SizedBox(height: 10),
                _MacroRow(
                    'Fat', '45g', '58%', const Color(0xFF2E7D32)),
              ],
            ),
          ),
        ]),
      ]),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label, value, pct;
  final Color color;
  const _MacroRow(this.label, this.value, this.pct, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF40493D))),
      const Spacer(),
      Text(value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(width: 6),
      Text(pct,
          style: TextStyle(fontSize: 11, color: color)),
    ]);
  }
}

class _ScanActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: _ScanBtn('Meal Photo', 'Snap your food',
                Icons.camera_alt, const Color(0xFF0D631B), () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) =>
                      ScanScreen(initialMode: ScanMode.meal)));
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _ScanBtn('Ingredients', 'What\'s in your fridge?',
                Icons.kitchen, const Color(0xFF964900), () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => ScanScreen(
                      initialMode: ScanMode.ingredients)));
        })),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _ScanBtn('Receipt', 'Track expenses',
                Icons.receipt_long, const Color(0xFF005A8C), () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => ScanScreen(
                      initialMode: ScanMode.receipt)));
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _ScanBtn('Voice', 'Tell me what you ate',
                Icons.mic, const Color(0xFF2E7D32), () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) =>
                      ScanScreen(initialMode: ScanMode.voice)));
        })),
      ]),
    ]);
  }
}

class _ScanBtn extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ScanBtn(this.title, this.subtitle, this.icon, this.color,
      this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF707A6C), fontSize: 11)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SuggestedMealCard extends StatelessWidget {
  const _SuggestedMealCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F6FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant, color: Color(0xFF005A8C)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chicken Stir Fry',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Text(
                  'From your ingredients: chicken, veggies',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF40493D))),
              const SizedBox(height: 6),
              Row(children: const [
                Icon(Icons.access_time,
                    size: 14, color: Color(0xFF707A6C)),
                SizedBox(width: 4),
                Text('25 min',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF707A6C))),
                SizedBox(width: 12),
                Icon(Icons.local_fire_department,
                    size: 14, color: Color(0xFF964900)),
                SizedBox(width: 4),
                Text('320 cal',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF964900))),
              ]),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios,
            size: 16, color: Color(0xFF707A6C)),
      ]),
    );
  }
}
