import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

const double newLineThreshold = 2.0; // Tolerance for y-position differences
const double spaceThreshold = 1.0; // Threshold to detect spaces between words

class DocumentData {
  final Map<int, List<LineData>> pageLines;

  DocumentData({required this.pageLines});

  factory DocumentData.fromGlyphMap(Map<int, List<TextGlyph>> pageGlyphs) {
    Map<int, List<LineData>> pages = {};
    for (var pageGlyph in pageGlyphs.entries) {
      int currentLineIndex = -1;
      double lastY = -1.0;
      Map<int, List<TextGlyph>> lineGlyphMap = {};
      for (var glyph in pageGlyph.value) {
        // Check if glyph starts a new line
        if ((lastY - glyph.bounds.top).abs() > newLineThreshold ||
            lastY == -1.0) {
          currentLineIndex++;
          lastY = glyph.bounds.top;
        }

        // Add glyph to the current line, on the correct position (x-axis)
        if (lineGlyphMap[currentLineIndex] == null) {
          lineGlyphMap[currentLineIndex] = [glyph];
        } else {
          final lineGlyph = lineGlyphMap[currentLineIndex]!;
          bool inserted = false;
          for (int i = 0; i < lineGlyph.length; i++) {
            if (glyph.bounds.left < lineGlyph[i].bounds.left) {
              inserted = true;
              lineGlyph.insert(i, glyph);
              break;
            }
          }
          if (!inserted) {
            lineGlyph.add(glyph);
          }
        }
      }

      List<LineData> lines = [];
      for (var entry in lineGlyphMap.entries) {
        if (entry.value.any((g) => g.text.trim().isNotEmpty)) {
          lines.add(LineData.fromGlyphArray(entry.key, entry.value));
        }
      }
      pages[pageGlyph.key] = lines;
    }

    return DocumentData(pageLines: pages);
  }
}

class LineData {
  final String text;
  final double? fontSize;
  final Rect bounds;
  final List<PdfFontStyle>? fontStyle;
  final int lineIndex;
  final List<WordData> wordList;

  LineData({
    required this.text,
    required this.fontSize,
    required this.bounds,
    required this.fontStyle,
    required this.lineIndex,
    required this.wordList,
  });

  int get wordCount => wordList.length;

  factory LineData.fromGlyphArray(int lineIndex, List<TextGlyph> glyphs) {
    Map<int, List<TextGlyph>> wordGlyphMap = {};
    int currentWordIndex = -1;
    double lastRightBound = 0.0;
    for (var glyph in glyphs) {
      // Check if glyph is a space
      if (glyph.text.trim().isEmpty) {
        continue; // Trim spaces
      }
      if ((glyph.bounds.left - lastRightBound) > spaceThreshold ||
          currentWordIndex == -1) {
        currentWordIndex++;
      }
      // Add glyph to the current word
      if (wordGlyphMap[currentWordIndex] == null) {
        wordGlyphMap[currentWordIndex] = [glyph];
      } else {
        wordGlyphMap[currentWordIndex]!.add(glyph);
      }
      lastRightBound = glyph.bounds.right;
    }

    // Create WordData list
    List<WordData> words = [];
    for (var entry in wordGlyphMap.entries) {
      words.add(WordData.fromGlyphArray(entry.key, entry.value));
    }

    double? fontSize;
    List<PdfFontStyle>? fontStyle;
    (fontSize, fontStyle) = _getFontAttributes(words);

    return LineData(
      lineIndex: lineIndex,
      text: glyphs.map((g) => g.text).join(),
      fontSize: fontSize,
      fontStyle: fontStyle,
      bounds: _calculateBounds(glyphs),
      wordList: words,
    );
  }
}

class WordData {
  final String text;
  final double? fontSize;
  final Rect bounds;
  final List<PdfFontStyle>? fontStyle;
  final int wordIndex;
  final List<GlyphData> glyphList;

  WordData({
    required this.text,
    required this.fontSize,
    required this.bounds,
    required this.fontStyle,
    required this.glyphList,
    required this.wordIndex,
  });

  factory WordData.fromGlyphArray(int wordIndex, List<TextGlyph> glyphs) {
    double? fontSize;
    List<PdfFontStyle>? fontStyle;

    final glyphData = glyphs
        .asMap()
        .entries
        .map((e) => GlyphData.fromGlyph(e.key, e.value))
        .toList();

    (fontSize, fontStyle) = _getFontAttributes(glyphData);

    return WordData(
      wordIndex: wordIndex,
      text: glyphs.map((g) => g.text).join(),
      bounds: _calculateBounds(glyphs),
      fontSize: fontSize,
      fontStyle: fontStyle,
      glyphList: glyphData,
    );
  }
}

class GlyphData {
  final String text;
  final double fontSize;
  final Rect bounds;
  final List<PdfFontStyle> fontStyle;
  final int glyphIndex;

  GlyphData({
    required this.text,
    required this.fontSize,
    required this.bounds,
    required this.fontStyle,
    required this.glyphIndex,
  });

  factory GlyphData.fromGlyph(int glyphIndex, TextGlyph glyph) {
    return GlyphData(
      glyphIndex: glyphIndex,
      text: glyph.text,
      fontSize: glyph.fontSize,
      bounds: glyph.bounds,
      fontStyle: glyph.fontStyle,
    );
  }
}

Rect _calculateBounds(List<TextGlyph> glyphs) {
  if (glyphs.isEmpty) {
    return Rect.zero;
  }
  double left = glyphs.first.bounds.left;
  double top = glyphs.first.bounds.top;
  double right = glyphs.first.bounds.right;
  double bottom = glyphs.first.bounds.bottom;

  for (var glyph in glyphs) {
    if (glyph.bounds.left < left) {
      left = glyph.bounds.left;
    }
    if (glyph.bounds.top < top) {
      top = glyph.bounds.top;
    }
    if (glyph.bounds.right > right) {
      right = glyph.bounds.right;
    }
    if (glyph.bounds.bottom > bottom) {
      bottom = glyph.bounds.bottom;
    }
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

(double?, List<PdfFontStyle>?) _getFontAttributes(List<dynamic> children) {
  if (children.isEmpty) {
    return (null, null);
  }

  bool allSameSize = children.every(
    (child) => child.fontSize == children.first.fontSize,
  );
  bool allSameStyle = children.every((child) {
    List<PdfFontStyle> fontStyles = child.fontStyle;

    for (var style in fontStyles) {
      if (!children.every((c) => c.fontStyle.contains(style))) {
        return false;
      }
    }
    return true;
  });

  return (
    allSameSize ? children.first.fontSize : null,
    allSameStyle ? children.first.fontStyle : null,
  );
}
