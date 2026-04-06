import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D631B);
  static const Color primaryContainer = Color(0xFF2E7D32);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF964900);
  static const Color secondaryContainer = Color(0xFFFC820C);
  static const Color tertiary = Color(0xFF005A8C);
  static const Color tertiaryContainer = Color(0xFF0073B2);
  static const Color background = Color(0xFFF4FAFF);
  static const Color surface = Color(0xFFF4FAFF);
  static const Color surfaceContainer = Color(0xFFE3F0F8);
  static const Color surfaceContainerHigh = Color(0xFFDDEAF2);
  static const Color surfaceContainerHighest = Color(0xFFD7E4EC);
  static const Color surfaceContainerLow = Color(0xFFE9F6FD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111D23);
  static const Color outline = Color(0xFF707A6C);
  static const Color error = Color(0xFFBA1A1A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        background: background,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
