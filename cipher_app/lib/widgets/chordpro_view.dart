import 'package:flutter/material.dart';
import 'package:cipher_app/helpers/chords/chord_parser.dart';
import 'package:cipher_app/helpers/chords/chord_song.dart';
import 'line_view.dart';

 class ChordProView extends StatelessWidget {
  final String song;
  final double maxWidth;
  final TextStyle? lyricStyle;
  final TextStyle? chordStyle;
  final int transpose;
  final bool centerChords;

  const ChordProView({
    super.key,
    required this.song,
    required this.maxWidth,
    this.lyricStyle,
    this.chordStyle,
    this.transpose = 0,
    this.centerChords = true,
  });

  @override
  Widget build(BuildContext context) {
    Song parsedSong = parseChordPro(song);
    parsedSong.calculateOffsets(maxWidth, lyricStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < parsedSong.linesMap.length; i++) LineView(
          chords: parsedSong.chordsMap[i] ?? [],
          line: parsedSong.linesMap[i] ?? '',
          lyricStyle: lyricStyle,
          chordStyle: chordStyle,
        ),
      ],
    );
  }
}