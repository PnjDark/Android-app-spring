import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppTheme.surface),
        child: Stack(
          children: [
            // Background Decorative Elements
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA5fIK_oEkU7FwNEjCnfPRIkEsrkJRWy3FdWzYfULpyCtjCtmhs5I8tzdSmEY7-fWrj0VugCCm4tOtykTlit0YVC0lnWtY6cciQSZMB8riGkVd1b-vIDvaeq-YWq7zdACTOjopsWlcKWcb9JLS0Q-f6--7v-DN0AUs9_xqI3lu71oA_Er1bvWp0Il9h0_XU96z35QBmPHFEiYBnm-TZZtYfvEKmYtAudkpOvTQSRGMSiKPWlyMcbEXkImpR3FYb4sSCXwwP4HdqFbR7',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    // Header Branding
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Symbols.restaurant_menu, color: AppTheme.primary, size: 40),
                            const SizedBox(width: 8),
                            Text(
                              'MealSnap+',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join our community of healthy food curators.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Sign Up Form Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Full Name'),
                          const SizedBox(height: 8),
                          _buildTextField(hint: 'Chef Kofi', icon: Symbols.person),
                          const SizedBox(height: 20),
                          _buildInputLabel('Email Address'),
                          const SizedBox(height: 8),
                          _buildTextField(hint: 'kofi@example.com', icon: Symbols.mail),
                          const SizedBox(height: 20),
                          _buildInputLabel('Password'),
                          const SizedBox(height: 8),
                          _buildTextField(hint: '••••••••', icon: Symbols.lock, isPassword: true),
                          const SizedBox(height: 32),
                          _buildPrimaryButton(context, 'Sign Up', Symbols.arrow_forward),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppTheme.surfaceContainer)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: TextStyle(
                                    color: AppTheme.outline.withOpacity(0.4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppTheme.surfaceContainer)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSocialButton('Google'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          'Sign In',
                          style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'By signing up, you agree to our Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.outline.withOpacity(0.6), fontSize: 10),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppTheme.outline,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.outline.withOpacity(0.4)),
          suffixIcon: isPassword ? const Icon(Symbols.visibility, color: AppTheme.outline) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: TextStyle(color: AppTheme.outline.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String label, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => context.go('/'),
        icon: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        label: Icon(icon, color: Colors.white, size: 20),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Symbols.account_circle, color: AppTheme.onSurface),
        label: Text(
          label,
          style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surfaceContainerLow,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      ),
    );
  }
}
