import 'package:flutter/painting.dart';

class Song {
  final Map<int, String> linesMap; // Line number -> Lyrics
  final Map<int, List<Chord>> chordsMap; // Line number -> List of Chords

  Song(this.linesMap, this.chordsMap);

  void calculateOffsets(double lineWidth, TextStyle textStyle) {
    chordsMap.forEach((lineNumber, chords) {
      for (var chord in chords) {
        chord.saveOffsetForChord(textStyle, lineWidth);
      }
    });
  }
}

class Chord {
  final String name; // e.g., "C", "Am"
  double xOffset;
  double yOffset;
  final String lyricsBefore;
  final String wordAfter;
  static double offset = -0.4;

  Chord(
    this.name,
    this.lyricsBefore,
    this.wordAfter, [
    this.xOffset = 0.0,
    this.yOffset = 0.0,
  ]);

  (double, double) calculateOffsetForChord(
    TextStyle textStyle,
    double lineWidth,
  ) {
    final previousTextPainter = TextPainter(
      text: TextSpan(text: lyricsBefore, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    final nextTextPainter = TextPainter(
      text: TextSpan(text: wordAfter, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    final double lineHeight = nextTextPainter.height;

    return (
      previousTextPainter.width % lineWidth,
      lineHeight * offset +
          lineHeight * (previousTextPainter.width ~/ lineWidth),
    );
  }

  void saveOffsetForChord(TextStyle textStyle, double lineWidth) {
    final (newXOffset, newYOffset) = calculateOffsetForChord(
      textStyle,
      lineWidth,
    );
    xOffset = newXOffset;
    yOffset = newYOffset;
  }
}
