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
              return Row(
                children: chords.map((chord) {
                  return Transform.translate(
                    offset: Offset(chord.xOffset, 0),
                    child: Text(
                      chord.name,
                      style: chordStyle ??
                        const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                    ),
                  )
                }).toList()
              )
            })
        )
      ]
    );
  }
}