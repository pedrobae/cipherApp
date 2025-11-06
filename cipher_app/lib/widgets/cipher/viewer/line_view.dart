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

  const LineView({
    super.key,
    required this.chords,
    required this.line,
    required this.lyricStyle,
    required this.chordStyle,
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
        double carryOver = 0.0;
        double previousCarryOver = 0.0;
        double endOfPreviousChord = 0.0;
        double endOfChord = 0.0;

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
              (xOffset, yOffset, carryOver, endOfChord) = chord
                  .calculateOffsetForChord(
                    lyricStyle,
                    constraints.maxWidth,
                    previousCarryOver,
                    endOfPreviousChord,
                  );
              previousCarryOver = carryOver;
              endOfPreviousChord = endOfChord;
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
