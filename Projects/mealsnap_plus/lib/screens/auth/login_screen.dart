import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDCC6).withOpacity(0.3),
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
                  // Brand Identity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Symbols.restaurant_menu, size: 40, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'MealSnap+',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Let's get cooking.",
                    style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),

                  // Login Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('EMAIL ADDRESS'),
                          _buildTextField(
                            hintText: 'chef@mealsnap.com',
                            prefixIcon: Symbols.mail,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('PASSWORD'),
                              Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          _buildTextField(
                            hintText: '••••••••',
                            prefixIcon: Symbols.lock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => context.go('/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                elevation: 4,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Symbols.arrow_forward, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Separator
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

                          // Google Login
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                backgroundColor: AppTheme.surfaceContainerLow,
                                foregroundColor: AppTheme.onSurfaceColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                      const Text("Don't have an account? ", style: TextStyle(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  // Heritage Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA5HvRb1o7Uu6wSGrUxYP3gZ0QdfVWaPvJwiOtjm7P_ac4102GVf8x0lGBtcQ_aI2qDHPVMO_xI4zkQ96PutpA2_PrwY_mP_mcc8-A9c8n_5v6-gEUNHtFI87ySl0u0cvIhSRSvBUwUjKCYxqTYeyAMJBEW2l7xPrDzhusIficEB0ILzTApuK2mh9pDPo1lkLMxIL8QepjaFbkDvfzzBFun9KXF29xpBxCTxcTrZYj2QA4xM_3WZeD6_2JVa_uAF1391zWKaaqtvIC4'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CULINARILY CURATED',
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, letterSpacing: 1.2),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Join 50,000+ home chefs tracking their nutrition journey with local flavors.',
                                style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor),
                              ),
                            ],
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.only(bottom: 8.0),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppTheme.outlineColor.withOpacity(0.6)),
          prefixIcon: Icon(prefixIcon, color: AppTheme.outlineColor, size: 20),
          suffixIcon: isPassword ? const Icon(Symbols.visibility, color: AppTheme.outlineColor, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
