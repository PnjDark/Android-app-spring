import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import 'main_shell.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final onAuth = loc == '/login' || loc == '/signup';
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/';
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
