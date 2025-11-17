import 'package:flutter/painting.dart';

int _minimumGap = 4;

class Song {
  final Map<int, String> linesMap; // Line number -> Lyrics
  final Map<int, List<Chord>> chordsMap; // Line number -> List of Chords
  bool hasPrecedingChord = false;
  double? precedingChordOffset;

  Song(this.linesMap, this.chordsMap);

  Song copyWith({
    Map<int, String>? linesMap,
    Map<int, List<Chord>>? chordsMap,
    bool hasPrecedingChord = false,
    double? precedingChordOffset,
  }) {
    return Song(linesMap ?? this.linesMap, chordsMap ?? this.chordsMap);
  }

  void checkForPrecedingChord(TextStyle chordStyle) {
    double precedingOffset = 0.0;
    for (int i = 0; i < linesMap.length; i++) {
      if (linesMap[i]![0] == ' ') {
        // Found a line with space at the start, indicating preceding chord
        hasPrecedingChord = true;

        // Calculate offset of the preceding chords
        double totalWidth = 0.0;
        for (var chord in chordsMap[i]!) {
          if (chord.lyricsBefore.isEmpty) {
            totalWidth += (TextPainter(
              text: TextSpan(text: chord.name, style: chordStyle),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout(maxWidth: double.infinity, minWidth: 0)).width;

            totalWidth += _minimumGap;
          } else {
            break; // Stop at the first chord that has lyrics before it
          }
        }
        totalWidth -= _minimumGap; // Remove last gap

        if (totalWidth > precedingOffset) {
          precedingOffset = totalWidth;
        }
      }
    }

    if (hasPrecedingChord) {
      precedingChordOffset = precedingOffset;
    }
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

  (double, double, double, int) calculateOffsetForChord(
    TextStyle textStyle,
    TextStyle chordStyle,
    int previousLine,
    double lineWidth,
    double endOfPreviousChord,
  ) {
    final String sameLineLyricsBefore;
    final String wordBefore;
    int lineNumber;

    // Parse the lyrics before to determine line breaks
    (sameLineLyricsBefore, wordBefore, lineNumber) = _parseLine(
      textStyle,
      lineWidth,
    );

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
      text: TextSpan(text: name, style: chordStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    /// TEXT PAINTER FOR THE PREVIOUS WORD
    final previousWordPainter = TextPainter(
      text: TextSpan(text: wordBefore, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity, minWidth: 0);

    /// INITIAL X OFFSET BASED ON SAME LINE LYRICS BEFORE
    double xOffset = sameLineTextPainter.width;

    /// TEST EDGECASE - (previous chord caused line break, and the current chord didnt)
    /// CHECK IF PREVIOUS CHORD IS ON THE NEXT LINE
    if (previousLine > lineNumber) {
      // Previous chord caused a line break, adjust line number
      lineNumber = previousLine;
      xOffset = 0.0;
    }

    /// CHECK IF CHORD OVERLAPS PREVIOUS CHORD AND ADJUST
    if (endOfPreviousChord + _minimumGap > xOffset &&
        lineNumber == previousLine) {
      xOffset = endOfPreviousChord + _minimumGap;
    }

    /// CHECK FOR LINE BREAKS
    (lineNumber, xOffset, _) = _checkLineBreaks(
      chordWidth: chordPainter.width,
      endOfWordWidth: nextWordPainter.width,
      lineWidth: lineWidth,
      sameLineTextWidth: sameLineTextPainter.width,
      startOfWordWidth: previousWordPainter.width,
      lineNumber: lineNumber,
      xOffset: xOffset,
    );

    /// GET REMAINDER OFFSET IF CHORD OVERFLOWS
    xOffset = xOffset % lineWidth;

    double yOffset = lineHeight * (lineNumber + offset);
    double endOfChord = chordPainter.width + xOffset;

    return (xOffset, yOffset, endOfChord, lineNumber);
  }

  (int, double, bool) _checkLineBreaks({
    required double endOfWordWidth,
    required double lineWidth,
    required double sameLineTextWidth,
    required double chordWidth,
    required double startOfWordWidth,
    required int lineNumber,
    required double xOffset,
  }) {
    bool didLineBreak = false;

    /// LINE BREAKING TESTS
    /// First, checks if the next word fits in the current line
    if (endOfWordWidth > lineWidth - sameLineTextWidth) {
      didLineBreak = true;
      lineNumber++;
      xOffset = startOfWordWidth;

      /// If the next word fits, check if the chord fits
    } else if (chordWidth > lineWidth - xOffset) {
      didLineBreak = true;
      xOffset = 0;
      lineNumber++;
    }
    return (lineNumber, xOffset, didLineBreak);
  }

  /// GOES THROUGH EACH CHARACTER CHECKING THE LAST WORD FOR LINE BREAKS
  (String, String, int) _parseLine(TextStyle textStyle, double lineWidth) {
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
    // CHECK IF THE LAST WORD FITS IN THE LINE IF THERE IS A WORD BEFORE
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
      // If it fits, sameLineLyricsBefore already contains the last word do nothing
    }
    return (sameLineLyricsBefore, wordBefore, lineNumber);
  }
}
