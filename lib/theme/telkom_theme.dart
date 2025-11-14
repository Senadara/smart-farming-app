import 'package:flutter/material.dart';

class TelkomColors {
  static const Color primary = Color(0xFFE60012); // Main red
  static const Color secondary = Color(0xFFFF5A5F); // Accent red-orange
  static const Color background = Color(0xFFFFFFFF); // App background
  static const Color card = Color(0xFFFFECEC); // Card & info panel
  static const Color textPrimary = Color(0xFF333333); // Primary text
  static const Color textSecondary = Color(0xFF666666); // Secondary text
  static const Color border = Color(0xFFE0E0E0); // Divider & outline
  static const Color inactive = Color(0xFFBDBDBD); // Unselected icons
  static const Color success = Color(0xFF00A676); // Success
  static const Color error = Color(0xFFFF3B30); // Error
}

class TelkomTheme {
  static ThemeData get themeData {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: TelkomColors.primary,
      onPrimary: Colors.white,
      secondary: TelkomColors.secondary,
      onSecondary: Colors.white,
      error: TelkomColors.error,
      onError: Colors.white,
      surface: TelkomColors.background,
      onSurface: TelkomColors.textPrimary,
      surfaceContainerHighest: TelkomColors.card,
      outline: TelkomColors.border,
      tertiary: TelkomColors.success,
      onTertiary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Onest',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TelkomColors.background,
      cardColor: TelkomColors.card,
      dividerColor: TelkomColors.border,
      appBarTheme: const AppBarTheme(
        backgroundColor: TelkomColors.background,
        foregroundColor: TelkomColors.textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: TelkomColors.textPrimary),
        displayMedium: TextStyle(color: TelkomColors.textPrimary),
        displaySmall: TextStyle(color: TelkomColors.textPrimary),
        headlineLarge: TextStyle(color: TelkomColors.textPrimary),
        headlineMedium: TextStyle(color: TelkomColors.textPrimary),
        headlineSmall: TextStyle(color: TelkomColors.textPrimary),
        titleLarge: TextStyle(color: TelkomColors.textPrimary),
        titleMedium: TextStyle(color: TelkomColors.textPrimary),
        titleSmall: TextStyle(color: TelkomColors.textSecondary),
        bodyLarge: TextStyle(color: TelkomColors.textPrimary),
        bodyMedium: TextStyle(color: TelkomColors.textPrimary),
        bodySmall: TextStyle(color: TelkomColors.textSecondary),
        labelLarge: TextStyle(color: TelkomColors.textPrimary),
        labelMedium: TextStyle(color: TelkomColors.textSecondary),
        labelSmall: TextStyle(color: TelkomColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TelkomColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TelkomColors.primary,
        ),
      ),
      iconTheme: const IconThemeData(color: TelkomColors.textPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TelkomColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TelkomColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TelkomColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TelkomColors.primary),
        ),
        hintStyle: const TextStyle(color: TelkomColors.textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: TelkomColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: TelkomColors.primary,
        unselectedItemColor: TelkomColors.inactive,
        backgroundColor: TelkomColors.background,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: TelkomColors.primary,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TelkomColors.primary;
          }
          return TelkomColors.inactive;
        }),
      ),
    );
  }

  // Opsi gelap (opsional)
  static ThemeData get darkTheme {
    const darkScheme = ColorScheme.dark(
      primary: TelkomColors.primary,
      secondary: TelkomColors.secondary,
      error: TelkomColors.error,
      surface: Color(0xFF121212),
      onSurface: Colors.white,
      outline: TelkomColors.border,
      tertiary: TelkomColors.success,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Onest',
      colorScheme: darkScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: TelkomColors.border,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white60),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: TelkomColors.primary,
        unselectedItemColor: TelkomColors.inactive,
        backgroundColor: Color(0xFF121212),
      ),
    );
  }
}
