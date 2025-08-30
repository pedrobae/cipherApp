import 'package:flutter/material.dart';


abstract class ChordProView extends StatelessWidget {
  final String data;
  final double maxWidth;
  final TextStyle? lyricStyle;
  final TextStyle? chordStyle;
  final int transpose;
  final bool centerChords;

  const ChordProView({
    super.key,
    required this.data,
    required this.maxWidth,
    this.lyricStyle,
    this.chordStyle,
    this.transpose = 0,
    this.centerChords = true,
  });
}