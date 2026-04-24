import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mealsnap/seed_data.dart';

import 'screens/analytics_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meal_suggestions_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'services/auth_service.dart';
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.init();
  await seedDatabase();
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
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'App error: \${snapshot.error}\nCheck Firebase setup.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
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
    HomeScreen(),
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
          builder: (_) => const ScanScreen(),
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
        color: Colors.white.withAlpha(242),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Symbols.home, grade: 400, opticalSize: 22),
              activeIcon: Icon(Symbols.home, grade: 700, opticalSize: 22, fill: 1),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.bar_chart, grade: 400, opticalSize: 22),
              activeIcon: Icon(Symbols.bar_chart, grade: 700, opticalSize: 22, fill: 1),
              label: 'Analytics',
            ),
            // Scan -- centre button with accent style
            BottomNavigationBarItem(
              icon: _ScanNavIcon(),
              activeIcon: _ScanNavIcon(active: true),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.lightbulb, grade: 400, opticalSize: 22),
              activeIcon: Icon(Symbols.lightbulb, grade: 700, opticalSize: 22, fill: 1),
              label: 'Suggest',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.person, grade: 400, opticalSize: 22),
              activeIcon: Icon(Symbols.person, grade: 700, opticalSize: 22, fill: 1),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanNavIcon extends StatelessWidget {
  final bool active;
  const _ScanNavIcon({this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Symbols.camera_alt, color: Colors.white, size: 22),
    );
  }
}
