import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFFAF8F5);
  static const ink = Color(0xFF1F1D1B);
  static const textSecondary = Color(0xFF8E8880);
  static const border = Color(0xFFECE8E2);
  static const surfaceMuted = Color(0xFFF3F0EB);
  static const accent = Color(0xFFE5674F);
  static const success = Color(0xFF4E8F6B);
  static const warning = Color(0xFFC98A2B);
  static const info = Color(0xFF5B7FA6);

  static const accentBg = Color(0xFFFBE6E1);
  static const successBg = Color(0xFFE2EFE7);
  static const warningBg = Color(0xFFF8EEDD);
  static const infoBg = Color(0xFFE4ECF4);

  static const sand = Color(0xFFEADFD3);
  static const sage = Color(0xFFDCE5DC);
  static const lilac = Color(0xFFE6DDE8);
  static const butter = Color(0xFFF1E3C8);

  static const tiles = [sage, sand, lilac, butter];

  // Admin dashboard highlight
  static const forest = Color(0xFF2F4A3E);
  static const forestRaised = Color(0xFF3E5D4F);
  static const forestLine = Color(0xFF46655A);
  static const forestText = Color(0xFFB8CCC1);
}

ThemeData buildTheme() {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );

  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      error: AppColors.accent,
      surface: Colors.white,
      onSurface: AppColors.ink,
    ),
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.ink),
      errorBorder: border(AppColors.accent),
      focusedErrorBorder: border(AppColors.accent),
      errorStyle: const TextStyle(color: AppColors.accent, fontSize: 12),
      helperStyle:
          const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.surfaceMuted,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(88, 52),
        shape: shape,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size(88, 52),
        shape: shape,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
          color: on ? AppColors.ink : AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: on ? AppColors.ink : AppColors.textSecondary,
        );
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}
