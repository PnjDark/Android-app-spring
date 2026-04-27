import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/router.dart';
import 'firebase_config.dart';
import 'seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.init();
  if (kDebugMode) seedDatabase().catchError((_) {});
  runApp(const MealSnapApp());
}

class MealSnapApp extends StatelessWidget {
  const MealSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MealSnap+',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: AppRouter.router,
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
