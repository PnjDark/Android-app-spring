import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/analytics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/meal_suggestions_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/scan_screen.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    AnalyticsScreen(),
    _ScanPlaceholder(),
    MealSuggestionsScreen(),
    ProfileScreen(),
  ];

  static const _routes = ['/', '/analytics', '', '/suggestions', '/profile'];

  void _onTap(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const ScanScreen(),
        ),
      );
      return;
    }
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
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

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(242),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF0D631B),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Symbols.home, grade: 400, opticalSize: 22),
              activeIcon:
                  Icon(Symbols.home, grade: 700, opticalSize: 22, fill: 1),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.bar_chart, grade: 400, opticalSize: 22),
              activeIcon: Icon(Symbols.bar_chart,
                  grade: 700, opticalSize: 22, fill: 1),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: _ScanNavIcon(),
              activeIcon: _ScanNavIcon(active: true),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.lightbulb, grade: 400, opticalSize: 22),
              activeIcon: Icon(Symbols.lightbulb,
                  grade: 700, opticalSize: 22, fill: 1),
              label: 'Suggest',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.person, grade: 400, opticalSize: 22),
              activeIcon: Icon(Symbols.person,
                  grade: 700, opticalSize: 22, fill: 1),
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
