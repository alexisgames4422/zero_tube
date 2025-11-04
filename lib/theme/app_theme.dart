import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F1722);
  static const Color surface = Color(0xFF192330);
  static const Color surfaceVariant = Color(0xFF233242);
  static const Color mint = Color(0xFF7FE1C5);
  static const Color ice = Color(0xFF8EC5FF);
  static const Color textPrimary = Color(0xFFE6F1F5);
  static const Color textSecondary = Color(0xFFB5C8D4);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.mint,
        secondary: AppColors.ice,
        surface: AppColors.surface,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(base),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mint,
        linearTrackColor: AppColors.surfaceVariant,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.mint,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        indicatorColor: AppColors.mint,
        labelColor: AppColors.mint,
        unselectedLabelColor: AppColors.textSecondary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }

  static InputDecorationThemeData _inputDecorationTheme(ThemeData base) {
    return base.inputDecorationTheme.copyWith(
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.surfaceVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.mint, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
