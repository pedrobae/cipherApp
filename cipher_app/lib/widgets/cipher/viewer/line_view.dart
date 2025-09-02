import 'package:flutter/material.dart';
import 'package:cipher_app/helpers/chords/chord_song.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate offsets with the actual available width
        for (var chord in chords) {
          chord.saveOffsetForChord(lyricStyle, constraints.maxWidth);
        }
        // Calculate yOffset dynamically based on chordStyle
        final textPainter = TextPainter(
          text: TextSpan(text: 'A', style: chordStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final double yOffset = -textPainter.height /2 ;

        return Stack(
          children: [
            Text(
              line,
              style: lyricStyle,
            ),
            Positioned.fill(
              child: Stack(
                clipBehavior: Clip.none,
                children: chords.map((chord) {
                  return Positioned(
                    left: chord.xOffset,
                    top: yOffset,
                    child: Text(
                      chord.name,
                      style: chordStyle,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}