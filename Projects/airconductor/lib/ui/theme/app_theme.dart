import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Colors.tealAccent,
        secondary: Colors.cyanAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: ThemeData.dark().textTheme,
    );
  }
}
