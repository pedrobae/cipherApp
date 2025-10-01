import 'package:flutter/material.dart';

class Palette {
  // Five color palette
  // PALETTE
  static const Color _green = Color(0xFF145550); // Green
  static const Color _orange = Color(0xFFE66423); // Orange
  static const Color _gold = Color(0xFFE6B428); // Gold
  static const Color _burgundy = Color(0xFF5A002D); // Burgundy
  static const Color _neutral = Color(0xFFE1E1E6); // Neutral
  static const Color _darkNeutral = Color(0xFF121214); // Dark Neutral

  /// Lighten a color by [amount] (0.0 to 1.0)
  static Color lighten(Color color, [double amount = .08]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  /// Darken a color by [amount] (0.0 to 1.0)
  static Color darken(Color color, [double amount = .08]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class BrandPalette extends Palette {
  // ===== PRECOMPUTED COLORS ======

  // GREEN THEME
  // PRIMARIES (Green)
  static Color get greenLight => Palette._green;
  static Color get greenDark => Palette._green;
  static Color get greenOnLight => Palette._neutral;
  static Color get greenOnDark => Palette._neutral;
  static Color get greenContainerLight => Palette.lighten(Palette._green, 0.18);
  static Color get greenContainerDark => Palette.darken(Palette._green, 0.12);
  static Color get greenOnContainerLight => Palette._darkNeutral;
  static Color get greenOnContainerDark => Palette._neutral;

  // ACCENT 1 (Green + Orange)
  static Color get greenAccent1 => Color.alphaBlend(
    Palette._orange.withAlpha(0x40), // 25% blend
    Palette._green,
  );
  static Color get greenAccent1Light => greenAccent1;
  static Color get greenAccent1Dark => Palette.darken(greenAccent1, 0.1);
  static Color get greenOnAccent1Light => Palette._darkNeutral;
  static Color get greenOnAccent1Dark => Palette._neutral;
  static Color get greenAccent1ContainerLight =>
      Palette.lighten(greenAccent1, 0.2);
  static Color get greenAccent1ContainerDark =>
      Palette.darken(greenAccent1, 0.17);
  static Color get greenOnAccent1ContainerLight => Palette._darkNeutral;
  static Color get greenOnAccent1ContainerDark => Palette._neutral;

  // ACCENT 2 (Green + Gold)
  static Color get greenAccent2 => Color.alphaBlend(
    Palette._gold.withAlpha(0x38), // 22% blend
    Palette._green,
  );
  static Color get greenAccent2Light => Palette.lighten(greenAccent2, 0.15);
  static Color get greenAccent2Dark => Palette.darken(greenAccent2, 0.09);
  static Color get greenOnAccent2Light => Palette._darkNeutral;
  static Color get greenOnAccent2Dark => Palette._neutral;
  static Color get greenAccent2ContainerLight =>
      Palette.lighten(greenAccent2, 0.25);
  static Color get greenAccent2ContainerDark =>
      Palette.darken(greenAccent2, 0.22);
  static Color get greenOnAccent2ContainerLight => Palette._darkNeutral;
  static Color get greenOnAccent2ContainerDark => Palette._neutral;

  // =============================================================================
  // ORANGE THEME
  // PRIMARIES (Orange)
  static Color get orangeLight => Palette._orange;
  static Color get orangeDark => Palette.darken(Palette._orange, 0.15);
  static Color get orangeOnLight => Palette._darkNeutral;
  static Color get orangeOnDark => Palette._neutral;
  static Color get orangeContainerLight =>
      Palette.lighten(Palette._orange, 0.18);
  static Color get orangeContainerDark => Palette.darken(Palette._orange, 0.25);
  static Color get orangeOnContainerLight => Palette._darkNeutral;
  static Color get orangeOnContainerDark => Palette._neutral;

  // ACCENT 1 (Orange + Green)
  static Color get orangeAccent1 => Color.alphaBlend(
    Palette._green.withAlpha(0x40), // 25% blend
    Palette._orange,
  );
  static Color get orangeAccent1Light => orangeAccent1;
  static Color get orangeAccent1Dark => Palette.darken(orangeAccent1, 0.1);
  static Color get orangeOnAccent1Light => Palette._darkNeutral;
  static Color get orangeOnAccent1Dark => Palette._neutral;
  static Color get orangeAccent1ContainerLight =>
      Palette.lighten(orangeAccent1, 0.2);
  static Color get orangeAccent1ContainerDark =>
      Palette.darken(orangeAccent1, 0.17);
  static Color get orangeOnAccent1ContainerLight => Palette._darkNeutral;
  static Color get orangeOnAccent1ContainerDark => Palette._neutral;

  // ACCENT 2 (Orange + Gold)
  static Color get orangeAccent2 => Color.alphaBlend(
    Palette._gold.withAlpha(0x38), // 22% blend
    Palette._orange,
  );
  static Color get orangeAccent2Light => Palette.lighten(orangeAccent2, 0.15);
  static Color get orangeAccent2Dark => Palette.darken(orangeAccent2, 0.09);
  static Color get orangeOnAccent2Light => Palette._darkNeutral;
  static Color get orangeOnAccent2Dark => Palette._neutral;
  static Color get orangeAccent2ContainerLight =>
      Palette.lighten(orangeAccent2, 0.25);
  static Color get orangeAccent2ContainerDark =>
      Palette.darken(orangeAccent2, 0.22);
  static Color get orangeOnAccent2ContainerLight => Palette._darkNeutral;
  static Color get orangeOnAccent2ContainerDark => Palette._neutral;

  // =============================================================================
  // GOLD THEME
  // PRIMARIES (Gold)
  static Color get goldLight => Palette._gold;
  static Color get goldDark => Palette._gold;
  static Color get goldOnLight => Palette._darkNeutral;
  static Color get goldOnDark => Palette._darkNeutral;
  static Color get goldContainerLight => Palette.lighten(Palette._gold, 0.12);
  static Color get goldContainerDark => Palette.darken(Palette._gold, 0.17);
  static Color get goldOnContainerLight => Palette._darkNeutral;
  static Color get goldOnContainerDark => Palette._darkNeutral;

  // ACCENT 1 (Gold + Orange)
  static Color get goldAccent1 =>
      Color.alphaBlend(Palette._gold.withAlpha(0x70), Palette._orange);
  static Color get goldAccent1Light => goldAccent1;
  static Color get goldAccent1Dark => Palette.darken(goldAccent1, 0.06);
  static Color get goldOnAccent1Light => Palette._darkNeutral;
  static Color get goldOnAccent1Dark => Palette._darkNeutral;
  static Color get goldAccent1ContainerLight =>
      Palette.lighten(goldAccent1, 0.12);
  static Color get goldAccent1ContainerDark =>
      Palette.darken(goldAccent1, 0.16);
  static Color get goldOnAccent1ContainerLight => Palette._darkNeutral;
  static Color get goldOnAccent1ContainerDark => Palette._neutral;

  // ACCENT 2 (Gold + Burgundy)
  static Color get goldAccent2 =>
      Color.alphaBlend(Palette._gold.withAlpha(0x50), Palette._burgundy);
  static Color get goldAccent2Light => Palette.lighten(goldAccent2, 0.08);
  static Color get goldAccent2Dark => Palette.darken(goldAccent2, 0.01);
  static Color get goldOnAccent2Light => Palette._darkNeutral;
  static Color get goldOnAccent2Dark => Palette._neutral;
  static Color get goldAccent2ContainerLight =>
      Palette.lighten(goldAccent2, 0.15);
  static Color get goldAccent2ContainerDark =>
      Palette.darken(goldAccent2, 0.14);
  static Color get goldOnAccent2ContainerLight => Palette._darkNeutral;
  static Color get goldOnAccent2ContainerDark => Palette._neutral;

  // =============================================================================
  // BURGUNDY THEME
  // PRIMARIES (Burgundy)
  static Color get burgundyLight => Palette._burgundy;
  static Color get burgundyDark => Palette.darken(Palette._burgundy, 0.03);
  static Color get burgundyOnLight => Palette._neutral;
  static Color get burgundyOnDark => Palette._neutral;
  static Color get burgundyContainerLight =>
      Palette.lighten(Palette._burgundy, 0.07);
  static Color get burgundyContainerDark =>
      Palette.darken(Palette._burgundy, 0.11);
  static Color get burgundyOnContainerLight => Palette._neutral;
  static Color get burgundyOnContainerDark => Palette._neutral;

  // ACCENT 1 (Burgundy + Gold)
  static Color get burgundyAccent1 => Color.alphaBlend(
    Palette._gold.withAlpha(0x40), // 25% blend
    Palette._burgundy,
  );
  static Color get burgundyAccent1Light => burgundyAccent1;
  static Color get burgundyAccent1Dark => Palette.darken(burgundyAccent1, 0.1);
  static Color get burgundyOnAccent1Light => Palette._neutral;
  static Color get burgundyOnAccent1Dark => Palette._neutral;
  static Color get burgundyAccent1ContainerLight =>
      Palette.lighten(burgundyAccent1, 0.1);
  static Color get burgundyAccent1ContainerDark =>
      Palette.darken(burgundyAccent1, 0.19);
  static Color get burgundyOnAccent1ContainerLight => Palette._neutral;
  static Color get burgundyOnAccent1ContainerDark => Palette._neutral;

  // ACCENT 2 (Burgundy + Green)
  static Color get burgundyAccent2 => Color.alphaBlend(
    Palette._green.withAlpha(0x38), // 22% blend
    Palette._burgundy,
  );
  static Color get burgundyAccent2Light =>
      Palette.lighten(burgundyAccent2, 0.15);
  static Color get burgundyAccent2Dark => Palette.darken(burgundyAccent2, 0.01);
  static Color get burgundyOnAccent2Light => Palette._neutral;
  static Color get burgundyOnAccent2Dark => Palette._neutral;
  static Color get burgundyAccent2ContainerLight =>
      Palette.lighten(burgundyAccent2, 0.22);
  static Color get burgundyAccent2ContainerDark =>
      Palette.darken(burgundyAccent2, 0.06);
  static Color get burgundyOnAccent2ContainerLight => Palette._neutral;
  static Color get burgundyOnAccent2ContainerDark => Palette._neutral;
}

class NeutralPalette extends Palette {
  // Neutral colors for surfaces calculated using Palette methods
  static Color get surface1Light => Palette.darken(Palette._neutral, 0.25);
  static Color get surface2Light => Palette.darken(Palette._neutral, 0.2);
  static Color get surface3Light => Palette.darken(Palette._neutral, 0.15);
  static Color get surface4Light => Palette.darken(Palette._neutral, 0.1);
  static Color get surface5Light => Palette.darken(Palette._neutral, 0.05);
  static Color get surfaceLight => Palette._neutral;

  static Color get surface1Dark => Palette.lighten(Palette._darkNeutral, 0.25);
  static Color get surface2Dark => Palette.lighten(Palette._darkNeutral, 0.2);
  static Color get surface3Dark => Palette.lighten(Palette._darkNeutral, 0.15);
  static Color get surface4Dark => Palette.lighten(Palette._darkNeutral, 0.1);
  static Color get surface5Dark => Palette.lighten(Palette._darkNeutral, 0.05);
  static Color get surfaceDark => Palette._darkNeutral;

  // Neutral elements calculated using Palette methods
  static Color get outlineLight =>
      Palette.darken(Palette._neutral, 0.5); // Light outline
  static Color get outlineDark =>
      Palette.lighten(Palette._darkNeutral, 0.5); // Dark outline

  static Color get shadowLight => Color.fromARGB(127, 0, 0, 0); // Light shadow
  static Color get shadowDark =>
      Color.fromARGB(127, 168, 168, 168); // Dark shadow
  static Color get scrimLight => Color(0x0D000000); // Light scrim (5% opacity)
  static Color get scrimDark => Color(0x1A000000); // Dark scrim (10% opacity)

  static const Color error = Color(0xFFD32F2F); // Standard error red
  static const Color onError = Color(0xFFFFFFFF); // White text for contrast
}
