import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFF1C1C2E);
  static const Color surfaceColor = Color(0xFF25253E);
  static const Color primaryColor = Color(0xFF00D09E);
  static const Color secondaryColor = Color(0xFF2C2C4E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0A0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      cardColor: surfaceColor,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
