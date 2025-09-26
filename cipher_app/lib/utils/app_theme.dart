import 'package:flutter/material.dart';

class AppTheme {
  // Five color palette
  static const Color _brandPrimary = Color(0xFF145550);
  static const Color _brandSecondary = Color(0xFFE66423);
  static const Color _brandTertiary = Color(0xFFE6B428);
  static const Color _brandQuaternary = Color(0xFF5A002D);
  static const Color _brandNeutral = Color(0xFFE1E1E6);

  /// Lighten a color by [amount] (0.0 to 1.0)
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  /// Darken a color by [amount] (0.0 to 1.0)
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // Precomputed color variations for performance (light theme)
  static final Color _brandPrimaryLight = lighten(_brandPrimary, 0.1);
  static final Color _brandPrimaryDark = darken(_brandPrimary, 0.2);
  static final Color _brandSecondaryLight = lighten(_brandSecondary, 0.5);
  static final Color _brandSecondaryDark = darken(_brandSecondary, 0.2);
  static final Color _brandTertiaryLight = lighten(_brandTertiary, 0.5);
  static final Color _brandTertiaryDark = darken(_brandTertiary, 0.2);
  static final Color _brandNeutralLight = lighten(_brandNeutral, 0.1);
  static final Color _brandNeutralLow = lighten(_brandNeutral, 0.05);
  static final Color _brandNeutralContainer = lighten(_brandNeutral, 0.02);
  static final Color _brandNeutralHigh = darken(_brandNeutral, 0.05);
  static final Color _brandNeutralHighest = darken(_brandNeutral, 0.1);
  static final Color _brandNeutralOutline = darken(_brandNeutral, 0.15);
  static final Color _shadowLight = darken(Colors.black, 0.1);
  static final Color _scrimLight = darken(Colors.black, 0.3);
  static final Color _errorContainerLight = lighten(
    const Color(0xFFD32F2F),
    0.7,
  );

  // Precomputed color variations for performance (dark theme)
  static final Color _brandTertiary80 = lighten(
    _brandTertiary,
    0.3,
  ); // lighter gold
  static final Color _brandTertiary40 = darken(
    _brandTertiary,
    0.2,
  ); // darker gold
  static final Color _brandTertiary70 = lighten(
    _brandTertiary,
    0.15,
  ); // mid-light gold
  static final Color _brandSecondary30 = darken(
    _brandSecondary,
    0.2,
  ); // darker orange
  static final Color _brandSecondary70 = lighten(
    _brandSecondary,
    0.2,
  ); // lighter orange
  static final Color _brandPrimary70 = lighten(
    _brandTertiary,
    0.15,
  ); // mid-light gold for primaryFixedDim
  static final Color _shadowDark = lighten(Colors.black, 0.6);
  static final Color _scrimDark = lighten(Colors.black, 0.8);

  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _brandPrimary,
    onPrimary: Colors.black,
    primaryContainer: _brandPrimaryLight,
    onPrimaryContainer: _brandPrimaryDark,
    secondary: _brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: _brandSecondaryLight,
    onSecondaryContainer: _brandQuaternary,
    tertiary: _brandTertiary,
    onTertiary: Colors.white,
    tertiaryContainer: _brandTertiaryLight,
    onTertiaryContainer: _brandQuaternary,
    error: const Color(0xFFD32F2F),
    onError: Colors.white,
    errorContainer: _errorContainerLight,
    onErrorContainer: const Color(0xFFB71C1C),
    surface: _brandNeutral,
    onSurface: const Color(0xFF1C1B1F),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    outlineVariant: _brandNeutralOutline,
    shadow: _shadowLight,
    scrim: _scrimLight,
    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF4),
    inversePrimary: _brandPrimary,
    surfaceTint: _brandTertiary,
    primaryFixed: _brandTertiary,
    primaryFixedDim: _brandTertiaryDark,
    onPrimaryFixed: Colors.white,
    onPrimaryFixedVariant: Colors.white,
    secondaryFixed: _brandPrimary,
    secondaryFixedDim: _brandPrimaryDark,
    onSecondaryFixed: Colors.black,
    onSecondaryFixedVariant: Colors.black,
    tertiaryFixed: _brandSecondary,
    tertiaryFixedDim: _brandSecondaryDark,
    onTertiaryFixed: Colors.white,
    onTertiaryFixedVariant: Colors.white,
    surfaceDim: _brandNeutralLight,
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: _brandNeutralLow,
    surfaceContainer: _brandNeutralContainer,
    surfaceContainerHigh: _brandNeutralHigh,
    surfaceContainerHighest: _brandNeutralHighest,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _brandTertiary, // Gold stands out better in dark
    onPrimary: Colors.black,
    primaryContainer: _brandTertiary,
    onPrimaryContainer: _brandTertiary,
    secondary: _brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: _brandSecondary30,
    onSecondaryContainer: Colors.white,
    tertiary: _brandTertiary80,
    onTertiary: Colors.white,
    tertiaryContainer: _brandTertiary40,
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
    shadow: _shadowDark,
    scrim: _scrimDark,
    inverseSurface: const Color(0xFFE6E1E5),
    onInverseSurface: const Color(0xFF313033),
    inversePrimary: _brandTertiary,
    surfaceTint: _brandTertiary,
    primaryFixed: _brandTertiary,
    primaryFixedDim: _brandPrimary70,
    onPrimaryFixed: Colors.black,
    onPrimaryFixedVariant: Colors.black,
    secondaryFixed: _brandSecondary,
    secondaryFixedDim: _brandSecondary70,
    onSecondaryFixed: Colors.white,
    onSecondaryFixedVariant: Colors.white,
    tertiaryFixed: _brandTertiary,
    tertiaryFixedDim: _brandTertiary70,
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

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: lightColorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: _shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: lightColorScheme.surfaceContainerLow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shadowColor: _shadowLight,
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

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    fontFamily: 'OpenSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: darkColorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: _shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: darkColorScheme.surfaceContainerLow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shadowColor: _shadowDark,
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
