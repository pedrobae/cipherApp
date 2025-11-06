import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class Song {
  final Map<int, String> linesMap; // Line number -> Lyrics
  final Map<int, List<Chord>> chordsMap; // Line number -> List of Chords

  Song(this.linesMap, this.chordsMap);
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

  (double, double, double, double) calculateOffsetForChord(
    TextStyle textStyle,
    double lineWidth,
    double previousCarryOver,
    double endOfPreviousChord,
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
          // Word doesn't fit, start new line
          sameLineLyricsBefore = '$wordBefore$character';
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

    // Handle the last word if there's no trailing space
    if (wordBefore.isNotEmpty) {
      final testWithLastWord = TextPainter(
        text: TextSpan(text: sameLineLyricsBefore, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: double.infinity, minWidth: 0);

      if (testWithLastWord.width > lineWidth) {
        // Last word doesn't fit, start new line
        sameLineLyricsBefore = wordBefore;
        lineNumber++;
      }
      // If it fits, sameLineLyricsBefore already contains the last word
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

    double xOffset = sameLineTextPainter.width;

    /// CHECK IF CARRYOVER IS LARGER THAN THE DIFFERENCE OF xOFFSETs
    if ((previousCarryOver + endOfPreviousChord) > (xOffset)) {
      xOffset += previousCarryOver;
      carryOver += previousCarryOver;
    }

    // /// CHECK IF CHORD LINE BREAKS
    // if (chordPainter.width > lineWidth - xOffset) {
    //   xOffset = 0;
    //   lineNumber++;
    // }

    /// CHECK IF NEXT WORD LINE BREAKS
    if (nextWordPainter.width > lineWidth - sameLineTextPainter.width) {
      lineNumber++;
      xOffset = 0;
      // CHECK IF THE CHORD IS AT THE START OF A WORD
      if (previousWordPainter.width != 0) {
        xOffset += previousWordPainter.width;
      }
    }

    /// CHECK IF CHORD IS LARGER THAN THE NEXT WORD TO PUSH THE NEXT CHORD RIGHT
    if (nextWordPainter.width < chordPainter.width) {
      carryOver += chordPainter.width - nextWordPainter.width + 4;
    }

    double yOffset = lineHeight * (lineNumber + offset);
    double endOfChord = chordPainter.width + xOffset;
    if (kDebugMode) {
      // Debug print to trace offsets
      print(
        '''Chord: $name\txOffset: ${xOffset.truncate()}\tcarryOver: ${carryOver.truncate()}\tLyrics: "$lyricsBefore"''',
      );
    }

    return (xOffset, yOffset, carryOver, endOfChord);
  }
}
