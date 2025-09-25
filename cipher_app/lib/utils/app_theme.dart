import 'package:flutter/material.dart';

class AppTheme {
  // Five color palette
  static const Color _brandPrimary = Color(0xFFE6B428); // amarelo ouro
  static const Color _brandSecondary = Color(0xFFE66423); // laranja queimado
  static const Color _brandTertiary = Color(0xFF145550); // verde escuro
  static const Color _brandQuaternary = Color(0xFF5A002D); // vinho escuro
  static const Color _brandNeutral = Color(0xFFE1E1E6); // cinza claro

  static ColorScheme getLightColorScheme() => ColorScheme(
    brightness: Brightness.light,
    primary: _brandPrimary,
    onPrimary: Colors.black,
    primaryContainer: _brandPrimary.withValues(alpha: 46), // ~0.18*255
    onPrimaryContainer: Colors.black,
    secondary: _brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: _brandSecondary.withValues(alpha: 38), // ~0.15*255
    onSecondaryContainer: Colors.black,
    tertiary: _brandTertiary,
    onTertiary: Colors.white,
    tertiaryContainer: _brandTertiary.withValues(alpha: 38), // ~0.15*255
    onTertiaryContainer: Colors.white,
    error: Colors.red.shade700,
    onError: Colors.white,
    errorContainer: Colors.red.shade100,
    onErrorContainer: Colors.red.shade900,
    surface: Colors.white,
    onSurface: Colors.black,
    onSurfaceVariant: Colors.black,
    outline: _brandQuaternary.withValues(alpha: 128), // 0.5*255
    outlineVariant: _brandQuaternary.withValues(alpha: 38), // ~0.15*255
    shadow: Colors.black.withValues(alpha: 51), // 0.2*255
    scrim: Colors.black.withValues(alpha: 76), // 0.3*255
    inverseSurface: _brandQuaternary,
    onInverseSurface: Colors.white,
    inversePrimary: _brandSecondary,
    surfaceTint: _brandPrimary,
    primaryFixed: _brandPrimary,
    primaryFixedDim: _brandPrimary.withValues(alpha: 179), // 0.7*255
    onPrimaryFixed: Colors.black,
    onPrimaryFixedVariant: Colors.black,
    secondaryFixed: _brandSecondary,
    secondaryFixedDim: _brandSecondary.withValues(alpha: 179),
    onSecondaryFixed: Colors.white,
    onSecondaryFixedVariant: Colors.white,
    tertiaryFixed: _brandTertiary,
    tertiaryFixedDim: _brandTertiary.withValues(alpha: 179),
    onTertiaryFixed: Colors.white,
    onTertiaryFixedVariant: Colors.white,
    surfaceDim: _brandNeutral.withValues(alpha: 204), // 0.8*255
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: _brandNeutral.withValues(alpha: 179), // 0.7*255
    surfaceContainer: _brandNeutral.withValues(alpha: 230), // 0.9*255
    surfaceContainerHigh: _brandNeutral,
    surfaceContainerHighest: _brandNeutral,
  );

  static ColorScheme getDarkColorScheme() => ColorScheme(
    brightness: Brightness.dark,
    primary: _brandPrimary,
    onPrimary: Colors.black,
    primaryContainer: _brandPrimary.withValues(alpha: 64), // 0.25*255
    onPrimaryContainer: Colors.black,
    secondary: _brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: _brandSecondary.withValues(alpha: 64),
    onSecondaryContainer: Colors.white,
    tertiary: _brandTertiary,
    onTertiary: Colors.white,
    tertiaryContainer: _brandTertiary.withValues(alpha: 64),
    onTertiaryContainer: Colors.white,
    error: Colors.red.shade200,
    onError: Colors.black,
    errorContainer: Colors.red.shade900,
    onErrorContainer: Colors.red.shade100,
    surface: Color(0xFF232323),
    onSurface: Colors.white,
    onSurfaceVariant: Colors.white,
    outline: _brandQuaternary.withValues(alpha: 128),
    outlineVariant: _brandQuaternary.withValues(alpha: 38),
    shadow: Colors.black.withValues(alpha: 102), // 0.4*255
    scrim: Colors.black.withValues(alpha: 128), // 0.5*255
    inverseSurface: _brandNeutral,
    onInverseSurface: Colors.black,
    inversePrimary: _brandSecondary,
    surfaceTint: _brandPrimary,
    primaryFixed: _brandPrimary,
    primaryFixedDim: _brandPrimary.withValues(alpha: 179),
    onPrimaryFixed: Colors.black,
    onPrimaryFixedVariant: Colors.black,
    secondaryFixed: _brandSecondary,
    secondaryFixedDim: _brandSecondary.withValues(alpha: 179),
    onSecondaryFixed: Colors.white,
    onSecondaryFixedVariant: Colors.white,
    tertiaryFixed: _brandTertiary,
    tertiaryFixedDim: _brandTertiary.withValues(alpha: 179),
    onTertiaryFixed: Colors.white,
    onTertiaryFixedVariant: Colors.white,
    surfaceDim: Color(0xFF181A1B),
    surfaceBright: Color(0xFF232323),
    surfaceContainerLowest: Color(0xFF0F1113),
    surfaceContainerLow: Color(0xFF181A1B),
    surfaceContainer: Color(0xFF232323),
    surfaceContainerHigh: Color(0xFF2C2C2C),
    surfaceContainerHighest: Color(0xFF353535),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: getLightColorScheme(),
    fontFamily: 'OpenSans',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: getDarkColorScheme(),
    fontFamily: 'OpenSans',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}
