import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class MealSnapBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MealSnapBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.slate.shade400,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Symbols.home),
              activeIcon: Icon(Symbols.home, fill: 1),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.receipt_long),
              activeIcon: Icon(Symbols.receipt_long, fill: 1),
              label: 'HISTORY',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.center_focus_strong, size: 32, color: Colors.transparent),
              label: 'SCAN',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.bar_chart),
              activeIcon: Icon(Symbols.bar_chart, fill: 1),
              label: 'EXPENSES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.person),
              activeIcon: Icon(Symbols.person, fill: 1),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}

class ScanFab extends StatelessWidget {
  final VoidCallback onPressed;

  const ScanFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppTheme.primaryColor,
        shape: const CircleBorder(),
        elevation: 8,
        child: const Icon(Symbols.center_focus_strong, color: Colors.white, size: 30),
      ),
    );
  }
}
