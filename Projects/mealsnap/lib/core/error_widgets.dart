import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';

/// Converts any exception into a user-friendly one-liner.
String friendlyError(Object e) {
  final msg = e.toString();

  // Firebase Auth
  if (msg.contains('user-not-found') ||
      msg.contains('wrong-password') ||
      msg.contains('invalid-credential')) return 'Incorrect email or password.';
  if (msg.contains('email-already-in-use')) return 'An account with this email already exists.';
  if (msg.contains('weak-password')) return 'Password must be at least 6 characters.';
  if (msg.contains('invalid-email')) return 'Please enter a valid email address.';
  if (msg.contains('too-many-requests')) return 'Too many attempts. Please wait a moment.';
  if (msg.contains('user-disabled')) return 'This account has been disabled.';

  // Network
  if (msg.contains('network-request-failed') ||
      msg.contains('SocketException') ||
      msg.contains('TimeoutException')) return 'No internet connection. Please try again.';

  // Firestore / Firebase general
  if (msg.contains('permission-denied')) return 'You don\'t have permission to do that.';
  if (msg.contains('unavailable')) return 'Service temporarily unavailable. Please try again.';

  // Gemini / AI
  if (msg.contains('All Gemini') || msg.contains('API key')) {
    return 'AI analysis unavailable. Showing offline estimate.';
  }

  if (e is FirebaseAuthException && e.message != null) return e.message!;

  return 'Something went wrong. Please try again.';
}

/// Inline error banner — drop into any Column above form fields.
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.error_outline, color: cs.onErrorContainer, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: TextStyle(color: cs.onErrorContainer, fontSize: 13)),
        ),
        if (onDismiss != null)
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: cs.onErrorContainer, size: 16),
          ),
      ]),
    );
  }
}

/// Full-screen or section-level error state with optional retry button.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.outline),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.outline)),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
