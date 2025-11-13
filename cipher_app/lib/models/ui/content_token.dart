class ContentToken {
  final String text;
  final TokenType type;

  ContentToken({required this.text, required this.type});
}

enum TokenType {
  chord, // [Am], [F#m7]
  lyric, // Regular character
  space, // Whitespace
  newline, // Line break
}
