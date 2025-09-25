import 'package:flutter/material.dart';

class AppTheme {
  // Five color palette
  static const Color _brandPrimary = Color(0xFFE6B428);
  static const Color _brandSecondary = Color(0xFFE66423);
  static const Color _brandTertiary = Color(0xFF145550);
  static const Color _brandQuaternary = Color(0xFF5A002D);
  static const Color _brandNeutral = Color(0xFFE1E1E6);

  static ColorScheme getLightColorScheme() => ColorScheme(
    brightness: Brightness.light,
    primary: _brandTertiary, // More professional primary
    onPrimary: Colors.white,
    primaryContainer: _brandTertiary.withValues(alpha: 0.1),
    onPrimaryContainer: _brandTertiary,
    secondary: _brandPrimary,
    onSecondary: Colors.black,
    secondaryContainer: _brandPrimary.withValues(alpha: 0.15),
    onSecondaryContainer: _brandQuaternary,
    tertiary: _brandSecondary,
    onTertiary: Colors.white,
    tertiaryContainer: _brandSecondary.withValues(alpha: 0.12),
    onTertiaryContainer: _brandQuaternary,
    error: const Color(0xFFD32F2F),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFEBEE),
    onErrorContainer: const Color(0xFFB71C1C),
    surface: Colors.white,
    onSurface: const Color(0xFF1C1B1F),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    outlineVariant: _brandNeutral,
    shadow: Colors.black.withValues(alpha: 0.15),
    scrim: Colors.black.withValues(alpha: 0.4),
    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF4),
    inversePrimary: _brandPrimary,
    surfaceTint: _brandTertiary,
    primaryFixed: _brandTertiary,
    primaryFixedDim: _brandTertiary.withValues(alpha: 0.8),
    onPrimaryFixed: Colors.white,
    onPrimaryFixedVariant: Colors.white,
    secondaryFixed: _brandPrimary,
    secondaryFixedDim: _brandPrimary.withValues(alpha: 0.8),
    onSecondaryFixed: Colors.black,
    onSecondaryFixedVariant: Colors.black,
    tertiaryFixed: _brandSecondary,
    tertiaryFixedDim: _brandSecondary.withValues(alpha: 0.8),
    onTertiaryFixed: Colors.white,
    onTertiaryFixedVariant: Colors.white,
    surfaceDim: const Color(0xFFF7F2FA),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFDF8FD),
    surfaceContainer: const Color(0xFFF7F2FA),
    surfaceContainerHigh: const Color(0xFFF1ECF4),
    surfaceContainerHighest: const Color(0xFFECE6F0),
  );

  static ColorScheme getDarkColorScheme() => ColorScheme(
    brightness: Brightness.dark,
    primary: _brandPrimary, // Gold stands out better in dark
    onPrimary: Colors.black,
    primaryContainer: _brandTertiary,
    onPrimaryContainer: _brandPrimary,
    secondary: _brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: _brandSecondary.withValues(alpha: 0.3),
    onSecondaryContainer: Colors.white,
    tertiary: _brandTertiary.withValues(alpha: 0.8),
    onTertiary: Colors.white,
    tertiaryContainer: _brandTertiary.withValues(alpha: 0.4),
    onTertiaryContainer: _brandPrimary,
    error: const Color(0xFFEF5350),
    onError: Colors.black,
    errorContainer: const Color(0xFFB71C1C),
    onErrorContainer: const Color(0xFFFFCDD2),
    surface: const Color(0xFF141218),
    onSurface: const Color(0xFFE6E1E5),
    onSurfaceVariant: const Color(0xFFCAC4D0),
    outline: const Color(0xFF938F99),
    outlineVariant: const Color(0xFF49454F),
    shadow: Colors.black.withValues(alpha: 0.6),
    scrim: Colors.black.withValues(alpha: 0.8),
    inverseSurface: const Color(0xFFE6E1E5),
    onInverseSurface: const Color(0xFF313033),
    inversePrimary: _brandTertiary,
    surfaceTint: _brandPrimary,
    primaryFixed: _brandPrimary,
    primaryFixedDim: _brandPrimary.withValues(alpha: 0.7),
    onPrimaryFixed: Colors.black,
    onPrimaryFixedVariant: Colors.black,
    secondaryFixed: _brandSecondary,
    secondaryFixedDim: _brandSecondary.withValues(alpha: 0.7),
    onSecondaryFixed: Colors.white,
    onSecondaryFixedVariant: Colors.white,
    tertiaryFixed: _brandTertiary,
    tertiaryFixedDim: _brandTertiary.withValues(alpha: 0.7),
    onTertiaryFixed: Colors.white,
    onTertiaryFixedVariant: Colors.white,
    surfaceDim: const Color(0xFF101014),
    surfaceBright: const Color(0xFF3A383E),
    surfaceContainerLowest: const Color(0xFF0B0B0F),
    surfaceContainerLow: const Color(0xFF1C1B1F),
    surfaceContainer: const Color(0xFF201F23),
    surfaceContainerHigh: const Color(0xFF2B2930),
    surfaceContainerHighest: const Color(0xFF36343B),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: getLightColorScheme(),
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: getLightColorScheme().onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: getLightColorScheme().outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: getLightColorScheme().primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: getLightColorScheme().surfaceContainerLow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: getDarkColorScheme(),
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: getDarkColorScheme().onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: getDarkColorScheme().outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: getDarkColorScheme().primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: getDarkColorScheme().surfaceContainerLow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );
}
