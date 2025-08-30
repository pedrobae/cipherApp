import 'package:flutter/painting.dart';

class Song {
  final Map<int, String> linesMap; // Line number -> Lyrics
  final Map<int, List<Chord>> chordsMap; // Line number -> List of Chords

  Song(this.linesMap, this.chordsMap);

  void calculateOffsets(double lineWidth, TextStyle? textStyle) {
    chordsMap.forEach((lineNumber, chords) {
      double accumulatedOffset = 0;
      for (var chord in chords) {
        double offset = chord.calculateOffsetForChord(textStyle, lineWidth, accumulatedOffset);
        chord.xOffset = offset;
        accumulatedOffset += offset;
      }
    });
  }
}

class Chord {
  final String name; // e.g., "C", "Am"
  double xOffset; // X-axis offset for alignment
  final String lyricsBefore; // Lyrics before the chord

  Chord(this.name, this.lyricsBefore, [this.xOffset = 0.0]);

  double calculateOffsetForChord(TextStyle? textStyle, double lineWidth, double accumulatedOffset) {
    final textPainter = TextPainter(
      text: TextSpan(text: lyricsBefore, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: lineWidth);
    return textPainter.width + accumulatedOffset;
  }
}