import 'package:cipher_app/models/domain/parsing_cipher.dart';

class ChordLineParser {
  Future<void> parseChords(ParsingCipher cipher) async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Delay for UI testing purposes
    // TODO implementation for parsing chord lines
    // Identifies chords from text lines and associates them with lyrics,
    // Has to return a chordPro formatted string
  }
}
