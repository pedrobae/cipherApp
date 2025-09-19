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
  static double offset = -0.45;

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
    /// GOES THROUGH EACH CHARACTER CHECKING THE LAST WORD FOR LINE BREAKS
    /// SAVES THE SAME LINE LYRICS BEFORE
    String sameLineLyricsBefore = '';
    String wordBefore = '';
    int lineNumber = 0;
    for (int i = 0; i < lyricsBefore.length; i++) {
      String character = lyricsBefore[i];
      if (character == ' ') {
        final previousPiece = TextPainter(
          text: TextSpan(text: sameLineLyricsBefore, style: textStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: double.infinity, minWidth: 0);

        if (previousPiece.width > lineWidth) {
          sameLineLyricsBefore = '$wordBefore ';
          lineNumber++;
        } else {
          sameLineLyricsBefore = '$sameLineLyricsBefore$character';
        }
        wordBefore = '';
      } else {
        wordBefore = '$wordBefore$character';
        sameLineLyricsBefore = '$sameLineLyricsBefore$character';
      }
    }

    /// TEXT PAINTER FOR THE SAME LINE LYRICS BEFORE
    final sameLineTextPainter = TextPainter(
      text: TextSpan(text: sameLineLyricsBefore, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    final TextPainter nextWordPainter = TextPainter(
      text: TextSpan(text: wordAfter, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity, minWidth: 0);
    final double lineHeight = nextWordPainter.height;

    double xOffset = sameLineTextPainter.width % lineWidth;

    /// CHECK IF NEXT WORD LINE BREAKS
    if (nextWordPainter.width > lineWidth - sameLineTextPainter.width) {
      xOffset = 0;
      lineNumber++;
    }

    double yOffset = lineHeight * (lineNumber + offset);

    return (xOffset, yOffset);
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
