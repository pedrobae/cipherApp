import 'package:flutter/material.dart';
import 'package:cipher_app/utils/palette.dart';

class AppTheme {
  static ThemeData getTheme(String color, bool isDark) {
    switch (color) {
      case 'green':
        return isDark ? _greenDarkTheme : _greenLightTheme;
      case 'orange':
        return isDark ? _orangeDarkTheme : _orangeLightTheme;
      case 'gold':
        return isDark ? _goldDarkTheme : _goldLightTheme;
      case 'burgundy':
        return isDark ? _burgundyDarkTheme : _burgundyLightTheme;
      default:
        return isDark ? _goldDarkTheme : _greenLightTheme;
    }
  }

  // Private color schemes
  static final ColorScheme _greenLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: BrandPalette.greenLight,
    onPrimary: BrandPalette.greenOnLight,
    primaryContainer: BrandPalette.greenContainerLight,
    onPrimaryContainer: BrandPalette.greenOnContainerLight,
    secondary: BrandPalette.greenAccent1Light,
    onSecondary: BrandPalette.greenOnAccent1Light,
    secondaryContainer: BrandPalette.greenAccent1ContainerLight,
    onSecondaryContainer: BrandPalette.greenOnAccent1ContainerLight,
    tertiary: BrandPalette.greenAccent2Light,
    onTertiary: BrandPalette.greenOnAccent2Light,
    tertiaryContainer: BrandPalette.greenAccent2ContainerLight,
    onTertiaryContainer: BrandPalette.greenOnAccent2ContainerLight,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceLight,
    surfaceContainerHighest: NeutralPalette.surface5Light,
    surfaceContainerHigh: NeutralPalette.surface4Light,
    surfaceContainer: NeutralPalette.surface3Light,
    surfaceContainerLow: NeutralPalette.surface2Light,
    surfaceContainerLowest: NeutralPalette.surface1Light,
    onSurface: NeutralPalette.surface5Dark,
    outline: NeutralPalette.outlineLight,
    shadow: NeutralPalette.shadowLight,
    scrim: NeutralPalette.scrimLight,
    inverseSurface: NeutralPalette.surface5Dark,
    onInverseSurface: NeutralPalette.surface1Light,
  );

  static final ColorScheme _greenDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: BrandPalette.greenDark,
    onPrimary: BrandPalette.greenOnDark,
    primaryContainer: BrandPalette.greenContainerDark,
    onPrimaryContainer: BrandPalette.greenOnContainerDark,
    secondary: BrandPalette.greenAccent1Dark,
    onSecondary: BrandPalette.greenOnAccent1Dark,
    secondaryContainer: BrandPalette.greenAccent1ContainerDark,
    onSecondaryContainer: BrandPalette.greenOnAccent1ContainerDark,
    tertiary: BrandPalette.greenAccent2Dark,
    onTertiary: BrandPalette.greenOnAccent2Dark,
    tertiaryContainer: BrandPalette.greenAccent2ContainerDark,
    onTertiaryContainer: BrandPalette.greenOnAccent2ContainerDark,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceDark,
    surfaceContainerHighest: NeutralPalette.surface1Dark,
    surfaceContainerHigh: NeutralPalette.surface2Dark,
    surfaceContainer: NeutralPalette.surface3Dark,
    surfaceContainerLow: NeutralPalette.surface4Dark,
    surfaceContainerLowest: NeutralPalette.surface5Dark,
    onSurface: NeutralPalette.surface5Light,
    outline: NeutralPalette.outlineDark,
    shadow: NeutralPalette.shadowDark,
    scrim: NeutralPalette.scrimDark,
    inverseSurface: NeutralPalette.surface5Light,
    onInverseSurface: NeutralPalette.surface1Dark,
  );

  static final ThemeData _greenLightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _greenLightColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _greenLightColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: NeutralPalette.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _greenLightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _greenLightColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _greenLightColorScheme.surface,
    ),
  );

  static final ThemeData _greenDarkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _greenDarkColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _greenDarkColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: NeutralPalette.shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _greenDarkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _greenDarkColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _greenDarkColorScheme.surface,
    ),
  );

  static final ColorScheme _orangeLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: BrandPalette.orangeLight,
    onPrimary: BrandPalette.orangeOnLight,
    primaryContainer: BrandPalette.orangeContainerLight,
    onPrimaryContainer: BrandPalette.orangeOnContainerLight,
    secondary: BrandPalette.orangeAccent1Light,
    onSecondary: BrandPalette.orangeOnAccent1Light,
    secondaryContainer: BrandPalette.orangeAccent1ContainerLight,
    onSecondaryContainer: BrandPalette.orangeOnAccent1ContainerLight,
    tertiary: BrandPalette.orangeAccent2Light,
    onTertiary: BrandPalette.orangeOnAccent2Light,
    tertiaryContainer: BrandPalette.orangeAccent2ContainerLight,
    onTertiaryContainer: BrandPalette.orangeOnAccent2ContainerLight,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceLight,
    surfaceContainerHighest: NeutralPalette.surface5Light,
    surfaceContainerHigh: NeutralPalette.surface4Light,
    surfaceContainer: NeutralPalette.surface3Light,
    surfaceContainerLow: NeutralPalette.surface2Light,
    surfaceContainerLowest: NeutralPalette.surface1Light,
    onSurface: NeutralPalette.surface5Dark,
    outline: NeutralPalette.outlineLight,
    shadow: NeutralPalette.shadowLight,
    scrim: NeutralPalette.scrimLight,
    inverseSurface: NeutralPalette.surface5Dark,
    onInverseSurface: NeutralPalette.surface1Light,
  );

  static final ColorScheme _orangeDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: BrandPalette.orangeDark,
    onPrimary: BrandPalette.orangeOnDark,
    primaryContainer: BrandPalette.orangeContainerDark,
    onPrimaryContainer: BrandPalette.orangeOnContainerDark,
    secondary: BrandPalette.orangeAccent1Dark,
    onSecondary: BrandPalette.orangeOnAccent1Dark,
    secondaryContainer: BrandPalette.orangeAccent1ContainerDark,
    onSecondaryContainer: BrandPalette.orangeOnAccent1ContainerDark,
    tertiary: BrandPalette.orangeAccent2Dark,
    onTertiary: BrandPalette.orangeOnAccent2Dark,
    tertiaryContainer: BrandPalette.orangeAccent2ContainerDark,
    onTertiaryContainer: BrandPalette.orangeOnAccent2ContainerDark,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceDark,
    surfaceContainerHighest: NeutralPalette.surface1Dark,
    surfaceContainerHigh: NeutralPalette.surface2Dark,
    surfaceContainer: NeutralPalette.surface3Dark,
    surfaceContainerLow: NeutralPalette.surface4Dark,
    surfaceContainerLowest: NeutralPalette.surface5Dark,
    onSurface: NeutralPalette.surface5Light,
    outline: NeutralPalette.outlineDark,
    shadow: NeutralPalette.shadowDark,
    scrim: NeutralPalette.scrimDark,
    inverseSurface: NeutralPalette.surface5Light,
    onInverseSurface: NeutralPalette.surface1Dark,
  );

  static final ThemeData _orangeLightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _orangeLightColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _orangeLightColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: NeutralPalette.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _orangeLightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _orangeLightColorScheme.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _orangeLightColorScheme.surface,
    ),
  );

  static final ThemeData _orangeDarkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _orangeDarkColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _orangeDarkColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: NeutralPalette.shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _orangeDarkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _orangeDarkColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _orangeDarkColorScheme.surface,
    ),
  );

  static final ColorScheme _goldLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: BrandPalette.goldLight,
    onPrimary: BrandPalette.goldOnLight,
    primaryContainer: BrandPalette.goldContainerLight,
    onPrimaryContainer: BrandPalette.goldOnContainerLight,
    secondary: BrandPalette.goldAccent1Light,
    onSecondary: BrandPalette.goldOnAccent1Light,
    secondaryContainer: BrandPalette.goldAccent1ContainerLight,
    onSecondaryContainer: BrandPalette.goldOnAccent1ContainerLight,
    tertiary: BrandPalette.goldAccent2Light,
    onTertiary: BrandPalette.goldOnAccent2Light,
    tertiaryContainer: BrandPalette.goldAccent2ContainerLight,
    onTertiaryContainer: BrandPalette.goldOnAccent2ContainerLight,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceLight,
    surfaceContainerHighest: NeutralPalette.surface5Light,
    surfaceContainerHigh: NeutralPalette.surface4Light,
    surfaceContainer: NeutralPalette.surface3Light,
    surfaceContainerLow: NeutralPalette.surface2Light,
    surfaceContainerLowest: NeutralPalette.surface1Light,
    onSurface: NeutralPalette.surface5Dark,
    outline: NeutralPalette.outlineLight,
    shadow: NeutralPalette.shadowLight,
    scrim: NeutralPalette.scrimLight,
    inverseSurface: NeutralPalette.surface5Dark,
    onInverseSurface: NeutralPalette.surface1Light,
  );

  static final ColorScheme _goldDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: BrandPalette.goldDark,
    onPrimary: BrandPalette.goldOnDark,
    primaryContainer: BrandPalette.goldContainerDark,
    onPrimaryContainer: BrandPalette.goldOnContainerDark,
    secondary: BrandPalette.goldAccent1Dark,
    onSecondary: BrandPalette.goldOnAccent1Dark,
    secondaryContainer: BrandPalette.goldAccent1ContainerDark,
    onSecondaryContainer: BrandPalette.goldOnAccent1ContainerDark,
    tertiary: BrandPalette.goldAccent2Dark,
    onTertiary: BrandPalette.goldOnAccent2Dark,
    tertiaryContainer: BrandPalette.goldAccent2ContainerDark,
    onTertiaryContainer: BrandPalette.goldOnAccent2ContainerDark,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceDark,
    surfaceContainerHighest: NeutralPalette.surface1Dark,
    surfaceContainerHigh: NeutralPalette.surface2Dark,
    surfaceContainer: NeutralPalette.surface3Dark,
    surfaceContainerLow: NeutralPalette.surface4Dark,
    surfaceContainerLowest: NeutralPalette.surface5Dark,
    onSurface: NeutralPalette.surface5Light,
    outline: NeutralPalette.outlineDark,
    shadow: NeutralPalette.shadowDark,
    scrim: NeutralPalette.scrimDark,
    inverseSurface: NeutralPalette.surface5Light,
    onInverseSurface: NeutralPalette.surface1Dark,
  );

  static final ThemeData _goldLightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _goldLightColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _goldLightColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: NeutralPalette.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _goldLightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _goldLightColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _goldLightColorScheme.surface,
    ),
  );

  static final ThemeData _goldDarkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _goldDarkColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _goldDarkColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: NeutralPalette.shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _goldDarkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _goldDarkColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _goldDarkColorScheme.surface,
    ),
  );

  static final ColorScheme _burgundyLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: BrandPalette.burgundyLight,
    onPrimary: BrandPalette.burgundyOnLight,
    primaryContainer: BrandPalette.burgundyContainerLight,
    onPrimaryContainer: BrandPalette.burgundyOnContainerLight,
    secondary: BrandPalette.burgundyAccent1Light,
    onSecondary: BrandPalette.burgundyOnAccent1Light,
    secondaryContainer: BrandPalette.burgundyAccent1ContainerLight,
    onSecondaryContainer: BrandPalette.burgundyOnAccent1ContainerLight,
    tertiary: BrandPalette.burgundyAccent2Light,
    onTertiary: BrandPalette.burgundyOnAccent2Light,
    tertiaryContainer: BrandPalette.burgundyAccent2ContainerLight,
    onTertiaryContainer: BrandPalette.burgundyOnAccent2ContainerLight,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceLight,
    surfaceContainerHighest: NeutralPalette.surface5Light,
    surfaceContainerHigh: NeutralPalette.surface4Light,
    surfaceContainer: NeutralPalette.surface3Light,
    surfaceContainerLow: NeutralPalette.surface2Light,
    surfaceContainerLowest: NeutralPalette.surface1Light,
    onSurface: NeutralPalette.surface5Dark,
    outline: NeutralPalette.outlineLight,
    shadow: NeutralPalette.shadowLight,
    scrim: NeutralPalette.scrimLight,
    inverseSurface: NeutralPalette.surface5Dark,
    onInverseSurface: NeutralPalette.surface1Light,
  );

  static final ColorScheme _burgundyDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: BrandPalette.burgundyDark,
    onPrimary: BrandPalette.burgundyOnDark,
    primaryContainer: BrandPalette.burgundyContainerDark,
    onPrimaryContainer: BrandPalette.burgundyOnContainerDark,
    secondary: BrandPalette.burgundyAccent1Dark,
    onSecondary: BrandPalette.burgundyOnAccent1Dark,
    secondaryContainer: BrandPalette.burgundyAccent1ContainerDark,
    onSecondaryContainer: BrandPalette.burgundyOnAccent1ContainerDark,
    tertiary: BrandPalette.burgundyAccent2Dark,
    onTertiary: BrandPalette.burgundyOnAccent2Dark,
    tertiaryContainer: BrandPalette.burgundyAccent2ContainerDark,
    onTertiaryContainer: BrandPalette.burgundyOnAccent2ContainerDark,
    error: NeutralPalette.error,
    onError: NeutralPalette.onError,
    surface: NeutralPalette.surfaceDark,
    surfaceContainerHighest: NeutralPalette.surface1Dark,
    surfaceContainerHigh: NeutralPalette.surface2Dark,
    surfaceContainer: NeutralPalette.surface3Dark,
    surfaceContainerLow: NeutralPalette.surface4Dark,
    surfaceContainerLowest: NeutralPalette.surface5Dark,
    onSurface: NeutralPalette.surface5Light,
    outline: NeutralPalette.outlineDark,
    shadow: NeutralPalette.shadowDark,
    scrim: NeutralPalette.scrimDark,
    inverseSurface: NeutralPalette.surface5Light,
    onInverseSurface: NeutralPalette.surface1Dark,
  );

  static final ThemeData _burgundyLightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _burgundyLightColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _burgundyLightColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: NeutralPalette.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _burgundyLightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _burgundyLightColorScheme.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _burgundyLightColorScheme.surface,
    ),
  );

  static final ThemeData _burgundyDarkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _burgundyDarkColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _burgundyDarkColorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: NeutralPalette.shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _burgundyDarkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _burgundyDarkColorScheme.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _burgundyDarkColorScheme.surface,
    ),
  );
}
