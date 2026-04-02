import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0D631B);
  static const secondaryColor = Color(0xFF964900);
  static const tertiaryColor = Color(0xFF005A8C);
  static const errorColor = Color(0xFFBA1A1A);
  static const backgroundColor = Color(0xFFF4FAFF);
  static const surfaceColor = Color(0xFFF4FAFF);
  static const onSurfaceColor = Color(0xFF111D23);
  static const onSurfaceVariantColor = Color(0xFF40493D);
  static const outlineColor = Color(0xFF707A6C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF2E7D32),
      onPrimaryContainer: Color(0xFFCBFFC2),
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFC820C),
      onSecondaryContainer: Color(0xFF5E2C00),
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF0073B2),
      onTertiaryContainer: Color(0xFFE9F2FF),
      error: errorColor,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      background: backgroundColor,
      onBackground: Color(0xFF111D23),
      surface: surfaceColor,
      onSurface: Color(0xFF111D23),
      surfaceVariant: Color(0xFFD7E4EC),
      onSurfaceVariant: Color(0xFF40493D),
      outline: Color(0xFF707A6C),
      outlineVariant: Color(0xFFBFCABA),
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: onSurfaceColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: onSurfaceColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurfaceColor,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: onSurfaceColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurfaceColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurfaceColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: onSurfaceVariantColor,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );

  // Custom colors from tailwind
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFE9F6FD);
  static const surfaceContainer = Color(0xFFE3F0F8);
  static const surfaceContainerHigh = Color(0xFFDDEAF2);
  static const surfaceContainerHighest = Color(0xFFD7E4EC);
  static const primaryFixed = Color(0xFFA3F69C);
  static const onPrimaryFixed = Color(0xFF002204);
}
