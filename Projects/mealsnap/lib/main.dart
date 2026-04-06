import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'services/firebase_service.dart';
import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/suggestions_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  await FirebaseService.initialize();
  runApp(const MealSnapApp());
}

class MealSnapApp extends StatelessWidget {
  const MealSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MealSnap+',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/suggestions',
          builder: (context, state) => const SuggestionsScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const CameraScreen(),
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
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
                selectedIcon: Icon(Symbols.home, fill: 1),
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
