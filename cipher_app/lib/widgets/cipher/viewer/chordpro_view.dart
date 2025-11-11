import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/helpers/chords/chord_parser.dart';
import 'package:cipher_app/helpers/chords/chord_song.dart';
import 'package:provider/provider.dart';
import 'line_view.dart';

class ChordProView extends StatelessWidget {
  final String? song;
  final double maxWidth;
  final int transpose;
  final bool centerChords;

  const ChordProView({
    super.key,
    this.song,
    required this.maxWidth,
    this.transpose = 0,
    this.centerChords = true,
  });

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LayoutSettingsProvider>();
    Song parsedSong = parseChordPro(song);

    List<Widget> sectionChildren = [];

    // CHECKS FILTERS - chords and lyrics
    if (ls.showChords && ls.showLyrics) {
      for (int i = 0; i < parsedSong.linesMap.length; i++) {
        if (parsedSong.linesMap[i] == null ||
            parsedSong.linesMap[i]!.trim().isEmpty) {
          List<Text> rowChildren = [];
          for (var chord in parsedSong.chordsMap[i]!) {
            rowChildren.add(Text(chord.name, style: ls.chordTextStyle));
          }
          sectionChildren.add(Row(spacing: 5, children: rowChildren));
        } else {
          sectionChildren.add(
            LineView(
              chords: parsedSong.chordsMap[i] ?? [],
              line: parsedSong.linesMap[i] ?? '',
              chordStyle: ls.chordTextStyle,
              lyricStyle: ls.lyricTextStyle,
            ),
          );
        }
      }
    } else if (ls.showLyrics) {
      for (int i = 0; i < parsedSong.linesMap.length; i++) {
        sectionChildren.add(
          Text(
            parsedSong.linesMap[i] ?? '',
            style: ls.lyricTextStyle.copyWith(height: 1.2),
          ),
        );
      }
    } else if (ls.showChords) {
      List<Text> rowChildren = [];
      for (int i = 0; i < parsedSong.chordsMap.length; i++) {
        for (var chord in parsedSong.chordsMap[i]!) {
          rowChildren.add(Text(chord.name, style: ls.chordTextStyle));
        }
      }
      sectionChildren.add(Row(spacing: 5, children: rowChildren));
    }

    return Column(
      spacing: ls.lyricTextStyle.fontSize! * 0.8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sectionChildren,
    );
  }
}
