class ContentToken {
  final String text;
  final TokenType type;
  final int? position;

  ContentToken({
    required this.text,
    required this.type,
    required this.position,
  });
}

enum TokenType {
  chord, // [Am], [F#m7]
  lyric, // Regular character
  space, // Whitespace
  newline, // Line break
}
