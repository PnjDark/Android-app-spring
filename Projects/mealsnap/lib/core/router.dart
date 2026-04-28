import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/onboarding_screen.dart';
import '../services/cache_service.dart';
import 'main_shell.dart';

/// Notifies GoRouter whenever Firebase auth state changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

class AppRouter {
  static final _authNotifier = _AuthNotifier();

  static final router = GoRouter(
    initialLocation: '/',
    refreshListenable: _authNotifier,
    redirect: (context, state) async {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final onAuth = loc == '/login' || loc == '/signup';
      final onOnboarding = loc == '/onboarding';

      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) {
        final done = await CacheService.isOnboardingComplete();
        return done ? '/' : '/onboarding';
      }
      if (loggedIn && !onOnboarding && !onAuth) {
        final done = await CacheService.isOnboardingComplete();
        if (!done) return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const _HomeTab()),
          GoRoute(path: '/analytics', builder: (_, __) => const _AnalyticsTab()),
          GoRoute(path: '/suggestions', builder: (_, __) => const _SuggestTab()),
          GoRoute(path: '/profile', builder: (_, __) => const _ProfileTab()),
        ],
      ),
    ],
  );
}

// Thin wrappers so ShellRoute children resolve without circular imports.
// MainShell imports the real screen widgets directly.
class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _SuggestTab extends StatelessWidget {
  const _SuggestTab();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
