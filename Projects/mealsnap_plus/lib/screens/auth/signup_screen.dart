import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Header Branding
                  Column(
                    children: [
                      const Icon(Symbols.restaurant_menu, size: 48, color: AppTheme.primaryColor, fill: 1),
                      const SizedBox(height: 8),
                      Text(
                        'MealSnap+',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Join our community of healthy food curators.',
                        style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Sign Up Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('FULL NAME'),
                          _buildTextField(
                            hintText: 'Chef Kofi',
                            prefixIcon: Symbols.person,
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('EMAIL ADDRESS'),
                          _buildTextField(
                            hintText: 'kofi@example.com',
                            prefixIcon: Symbols.mail,
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('PASSWORD'),
                          _buildTextField(
                            hintText: '••••••••',
                            prefixIcon: Symbols.lock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => context.go('/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                elevation: 8,
                                shadowColor: AppTheme.primaryColor.withOpacity(0.25),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Symbols.arrow_forward, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppTheme.outlineColor.withOpacity(0.3))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outlineColor),
                                ),
                              ),
                              Expanded(child: Divider(color: AppTheme.outlineColor.withOpacity(0.3))),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Google Sign Up
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                backgroundColor: AppTheme.surfaceContainerLow,
                                foregroundColor: AppTheme.onSurfaceColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                    height: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'By signing up, you agree to our Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariantColor, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.onSurfaceVariantColor,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hintText, required IconData prefixIcon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppTheme.outlineColor.withOpacity(0.3)),
          prefixIcon: Icon(prefixIcon, color: AppTheme.onSurfaceVariantColor.withOpacity(0.4), size: 20),
          suffixIcon: isPassword ? Icon(Symbols.visibility, color: AppTheme.onSurfaceVariantColor.withOpacity(0.4), size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
