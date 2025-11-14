import 'package:flutter/material.dart';

class OriginalColors {
  static const Color green1 = Color(0xFF00623A);
  static const Color green2 = Color(0xFF3B9C0B);
  static const Color green3 = Color(0xFFEEE3D4);
  static const Color green4 = Color(0xFFDBE4D6);

  static const Color yellow = Color(0xFFFF9306);
  static const Color yellow1 = Color(0xFFEEE3D4);
  static const Color yellow2 = Color(0xFFFAC96C);
  static const Color grey = Color(0xFFD9D9D9);

  static const Color dark1 = Color(0xFF494953);
  static const Color dark2 = Color(0xFF4A4A4A);
  static const Color dark3 = Color(0xFF999798);
  static const Color dark4 = Color(0xFFEDEDED);

  static const Color blue1 = Color(0xFF37B7FF);
  static const Color blue2 = Color(0xFF177BFF);
  static const Color blue3 = Color(0xFFE0E1EE);
  static const Color blue4 = Color(0xFF2E8BFF);

  static const Color red = Color(0xFFE84140);
  static const Color red2 = Color(0xFFEEDFDF);
  static const Color purple = Color(0xFF87027B);
  static const Color white = Colors.white;
}

class OriginalTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Onest',
      colorScheme: ColorScheme.fromSeed(
        seedColor: OriginalColors.green2,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black87),
        titleSmall: TextStyle(color: Colors.black87),
      ),
      dividerColor: OriginalColors.dark4,
      cardColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OriginalColors.green2,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OriginalColors.dark4,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: OriginalColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: OriginalColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: OriginalColors.green2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: OriginalColors.green2,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: OriginalColors.green2,
        unselectedItemColor: OriginalColors.dark3,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
