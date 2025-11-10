import 'package:cipher_app/models/domain/parsing_cipher.dart';

class MetadataParser {
  Future<void> parseMetadata(ParsingCipher cipher) async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Delay for UI testing purposes

    // TODO: Implement metadata parsing

    //
    cipher.metadata = {
      'title': 'Sample Title',
      'artist': 'Sample Artist',
      'album': 'Sample Album',
    };
  }
}
