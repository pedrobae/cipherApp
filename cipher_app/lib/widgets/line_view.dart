import 'package:flutter/material.dart';
import 'package:cipher_app/helpers/chords/chord_song.dart';

class LineView extends StatelessWidget {
  final List<Chord> chords;
  final String line;
  final TextStyle? lyricStyle;
  final TextStyle? chordStyle;

  const LineView({
    super.key,
    required this.chords,
    required this.line,
    this.lyricStyle,
    this.chordStyle,
  });

  @override
  Widget build(BuildContext context) {
    double cumulativeOffset = 0;
    return Stack(
      children: [
        // Lyrics
        Text(
          line,
          style: lyricStyle ?? const TextStyle(fontSize: 16),
        ),
        // Chords
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: chords.map((chord) {
                  

                  // Ensure xOffset respects the available width
                  final chordOffset = chord.xOffset + cumulativeOffset;

                  cumulativeOffset += (TextPainter(
                                        text: TextSpan(text: chord.name, style: chordStyle),
                                        textDirection: TextDirection.ltr,
                                      )..layout()).width;
                  return Positioned(
                    left: chordOffset,
                    top: -8, // Adjust the vertical position of chords
                    child: Text(
                      chord.name,
                      style: chordStyle ??
                          const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}