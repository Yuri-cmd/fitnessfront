import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';

const _interFamily = 'Inter';

TextStyle _inter({
  required double fontSize,
  required FontWeight fontWeight,
  Color? color,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: _interFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

class AppTheme {
  static TextTheme _textTheme(TextTheme base, Color title, Color body) {
    return base.apply(fontFamily: _interFamily).copyWith(
      displayLarge: _inter(fontSize: 40, fontWeight: FontWeight.w800, color: title, letterSpacing: -0.5),
      displayMedium: _inter(fontSize: 34, fontWeight: FontWeight.w800, color: title, letterSpacing: -0.5),
      displaySmall: _inter(fontSize: 28, fontWeight: FontWeight.w700, color: title),
      headlineLarge: _inter(fontSize: 26, fontWeight: FontWeight.w700, color: title),
      headlineMedium: _inter(fontSize: 22, fontWeight: FontWeight.w700, color: title),
      headlineSmall: _inter(fontSize: 20, fontWeight: FontWeight.w700, color: title),
      titleLarge: _inter(fontSize: 20, fontWeight: FontWeight.w700, color: title, letterSpacing: 0.2),
      titleMedium: _inter(fontSize: 16, fontWeight: FontWeight.w700, color: title, letterSpacing: 0.1),
      titleSmall: _inter(fontSize: 14, fontWeight: FontWeight.w600, color: title),
      bodyLarge: _inter(fontSize: 16, fontWeight: FontWeight.w400, color: body),
      bodyMedium: _inter(fontSize: 14, fontWeight: FontWeight.w400, color: body),
      bodySmall: _inter(fontSize: 12, fontWeight: FontWeight.w400, color: body),
      labelLarge: _inter(fontSize: 14, fontWeight: FontWeight.w700, color: title, letterSpacing: 0.5),
      labelMedium: _inter(fontSize: 12, fontWeight: FontWeight.w700, color: body, letterSpacing: 0.8),
      labelSmall: _inter(fontSize: 11, fontWeight: FontWeight.w700, color: body, letterSpacing: 1.2),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _textTheme(ThemeData.light().textTheme, AppColors.textTitle, AppColors.textBody);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: _interFamily,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ).copyWith(onSurfaceVariant: AppColors.textMutedLight),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textTitle),
        titleTextStyle: _inter(
          color: AppColors.textTitle,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        prefixIconColor: AppColors.textBody,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary, // negro cálido — ratio 11.7:1
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: _inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textTitle,
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: _inter(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textTitle,
        contentTextStyle: _inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        selectedColor: AppColors.primary,
        labelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textTitle),
        secondaryLabelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMutedLight,
        labelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      dividerColor: const Color(0xFFE0E0E0),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);
    const darkCard = Color(0xFF242424);
    const darkInput = Color(0xFF2A2A2A);

    final textTheme = _textTheme(ThemeData.dark().textTheme, Colors.white, AppColors.textMutedDark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: _interFamily,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: darkSurface,
        error: AppColors.error,
      ).copyWith(
        onPrimary: Colors.black,
        surface: darkSurface,
        surfaceContainerLowest: const Color(0xFF0D0D0D),
        surfaceContainerLow: const Color(0xFF161616),
        surfaceContainer: const Color(0xFF1E1E1E),
        surfaceContainerHigh: const Color(0xFF252525),
        surfaceContainerHighest: const Color(0xFF2E2E2E),
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.textMutedDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: _inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white30),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        prefixIconColor: Colors.white54,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: _inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: _inter(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2E2E2E),
        contentTextStyle: _inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withValues(alpha: 0.16),
        selectedColor: AppColors.primary,
        labelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        secondaryLabelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMutedDark,
        labelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: _inter(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      dividerColor: Colors.white12,
    );
  }
}
