import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/helpers/chords/chord_song.dart';
import 'package:cipher_app/helpers/chords/chord_transposer.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';

class LineView extends StatelessWidget {
  final List<Chord> chords;
  final String line;
  final TextStyle lyricStyle;
  final TextStyle chordStyle;
  final bool hasPrecedingChord;
  final double? precedingChordOffset;

  const LineView({
    super.key,
    required this.chords,
    required this.line,
    required this.lyricStyle,
    required this.chordStyle,
    required this.hasPrecedingChord,
    required this.precedingChordOffset,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<LayoutSettingsProvider>(context);
    final transposer = ChordTransposer(
      originalKey: settings.originalKey,
      transposeValue: settings.transposeAmount,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        double xOffset;
        double yOffset;
        double endOfChord = 0.0;
        int lineNumber = 0;

        bool foundPrecedingSeparator = false;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: Text(
                line,
                style: lyricStyle,
                textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: false,
                ),
              ),
            ),
            ...chords.map((chord) {
              final String chordToShow = settings.transposeAmount != 0
                  ? transposer.transpose(chord.name)
                  : chord.name;
              (xOffset, yOffset, endOfChord, lineNumber) = chord
                  .calculateOffsetForChord(
                    lyricStyle,
                    chordStyle,
                    lineNumber,
                    constraints.maxWidth - (precedingChordOffset ?? 0),
                    endOfChord,
                  );
              if (!hasPrecedingChord || foundPrecedingSeparator) {
                return Positioned(
                  left: xOffset + (precedingChordOffset ?? 0),
                  top: yOffset,
                  child: Text(chordToShow, style: chordStyle),
                );
              }

              if (chord.lyricsBefore != '') {
                foundPrecedingSeparator = true;
                return Positioned(
                  left: xOffset + (precedingChordOffset ?? 0),
                  top: yOffset,
                  child: Text(chordToShow, style: chordStyle),
                );
              }

              // Preceding Chord
              return Positioned(
                left: xOffset,
                top: yOffset,
                child: Text(chordToShow, style: chordStyle),
              );
            }),
          ],
        );
      },
    );
  }
}
