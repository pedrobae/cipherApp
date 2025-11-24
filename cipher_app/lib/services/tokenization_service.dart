import 'package:cipher_app/models/ui/content_token.dart';

class TokenizationService {
  List<ContentToken> tokenize(String content) {
    if (content.isEmpty) {
      return [];
    }

    final List<ContentToken> tokens = [];

    for (int index = 0; index < content.length; index++) {
      final char = content[index];
      if (char == '\n') {
        tokens.add(
          ContentToken(
            type: TokenType.newline,
            text: char,
            position: tokens.length,
          ),
        );
      } else if (char == ' ' || char == '\t') {
        tokens.add(
          ContentToken(
            type: TokenType.space,
            text: char,
            position: tokens.length,
          ),
        );
      } else if (char == '[') {
        index++; // Move past the '['
        String chordText = '';
        while (index < content.length && content[index] != ']') {
          chordText += content[index];
          index++;
        }
        tokens.add(
          ContentToken(
            type: TokenType.chord,
            text: chordText,
            position: tokens.length,
          ),
        );
      } else {
        tokens.add(
          ContentToken(
            type: TokenType.lyric,
            text: char,
            position: tokens.length,
          ),
        );
      }
    }
    if (tokens.last.type == TokenType.newline) {
      tokens.removeLast();
    }
    return tokens;
  }

  String reconstructContent(List<ContentToken> tokens) {
    return tokens.map((token) {
      switch (token.type) {
        case TokenType.chord:
          return '[${token.text}]';
        case TokenType.lyric:
        case TokenType.space:
        case TokenType.newline:
          return token.text;
      }
    }).join();
  }
}
