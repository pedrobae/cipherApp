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
  final String lyricsBefore; // Lyrics before the chord

  Chord(this.name, this.lyricsBefore, [this.xOffset = 0.0, this.yOffset = 0.0]);

  (double, double) calculateOffsetForChord(
    TextStyle textStyle,
    double lineWidth,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: lyricsBefore, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    if (textPainter.width > lineWidth) {
      return (textPainter.width % lineWidth, textPainter.height * 0.5);
    }

    return (textPainter.width, -textPainter.height * 0.5);
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
