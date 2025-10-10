import 'package:flutter/painting.dart';

class Song {
  final Map<int, String> linesMap; // Line number -> Lyrics
  final Map<int, List<Chord>> chordsMap; // Line number -> List of Chords

  Song(this.linesMap, this.chordsMap);

  void calculateOffsets(double lineWidth, TextStyle textStyle) {
    chordsMap.forEach((lineNumber, chords) {
      for (var chord in chords) {
        chord.saveOffsetForChord(textStyle, lineWidth, 0.0);
      }
    });
  }
}

class Chord {
  final String name; // e.g., "C", "Am"
  double xOffset;
  double yOffset;
  double carryOver;
  final String lyricsBefore;
  final String nextWord;
  static double offset = -0.45;

  Chord(
    this.name,
    this.lyricsBefore,
    this.nextWord, [
    this.xOffset = 0.0,
    this.yOffset = 0.0,
    this.carryOver = 0.0,
  ]);

  (double, double, double) calculateOffsetForChord(
    TextStyle textStyle,
    double lineWidth,
    double previousCarryOver,
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

    /// TEXT PAINTER FOR THE NEXT WORD
    final nextWordPainter = TextPainter(
      text: TextSpan(text: nextWord, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity, minWidth: 0);
    final double lineHeight = nextWordPainter.height;

    /// TEXT PAINTER FOR THE CHORD
    final chordPainter = TextPainter(
      text: TextSpan(text: name, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    /// TEXT PAINTER FOR THE PREVIOUS WORD
    final previousWordPainter = TextPainter(
      text: TextSpan(text: wordBefore, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    double xOffset =
        (sameLineTextPainter.width + previousCarryOver) % lineWidth;

    /// CHECK IF NEXT WORD LINE BREAKS
    if (nextWordPainter.width + previousWordPainter.width >
        lineWidth - sameLineTextPainter.width) {
      lineNumber++;
      // CHECK IF THE CHORD IS AT THE START OF A WORD
      if (previousWordPainter.width == 0) {
        xOffset = 0;
      } else {
        xOffset = previousWordPainter.width;
      }
    }

    /// CHECK IF CHORD LINE BREAKS
    if (chordPainter.width > lineWidth - xOffset) {
      xOffset = 0;
      lineNumber++;
    }

    /// CHECK IF CHORD IS LARGER THAN THE NEXT WORD TO PUSH THE NEXT CHORD RIGHT
    if (nextWordPainter.width < chordPainter.width || nextWord.isEmpty) {
      carryOver = chordPainter.width - nextWordPainter.width;
    }

    double yOffset = lineHeight * (lineNumber + offset);

    return (xOffset, yOffset, carryOver);
  }

  void saveOffsetForChord(
    TextStyle textStyle,
    double lineWidth,
    double previousCarryOver,
  ) {
    final (newXOffset, newYOffset, newCarryOver) = calculateOffsetForChord(
      textStyle,
      lineWidth,
      previousCarryOver,
    );
    xOffset = newXOffset;
    yOffset = newYOffset;
    carryOver = newCarryOver;
  }
}
