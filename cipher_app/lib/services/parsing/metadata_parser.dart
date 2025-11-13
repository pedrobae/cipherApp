import 'package:cipher_app/models/domain/parsing_cipher.dart';

class MetadataParser {
  Future<void> parseMetadata(ParsingCipher cipher) async {
    // Iterates through sections
    for (var section in cipher.sections) {
      // Simple heuristic: if the section is labeled it doesn't contain metadata
      if (section['suggestedTitle'] != 'Unlabeled Section') break;

      bool foundMetadata = false;
      // Look for colon-separated key-value pairs
      if (_checkForColons(cipher, section)) foundMetadata = true;
      if (_checkForHyphens(cipher, section)) foundMetadata = true;

      // Mark section as metadata if any metadata found
      if (foundMetadata) section['suggestedTitle'] = 'Metadata';
    }

    // If title is missing, checks the first couple lines looking at the number of words and average word length
    if (cipher.metadata['title'] == null || cipher.metadata['title']!.isEmpty) {
      for (var line in cipher.lines.take(5)) {
        if (line['wordCount'] <= 7 && line['avgWordLength'] >= 3.0) {
          cipher.metadata['title'] = line['text'];
          cipher.sections[0]['suggestedTitle'] = 'Metadata';
          break;
        }
      }
    }
  }

  bool _checkForColons(ParsingCipher cipher, Map<String, dynamic> section) {
    final lines = section['content'].split('\n');

    bool foundMetadata = false;
    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();

          if (_checkKeyValue(key, value, cipher)) {
            foundMetadata = true;
          }
        }
      }
    }
    return foundMetadata;
  }

  bool _checkForHyphens(ParsingCipher cipher, Map<String, dynamic> section) {
    final lines = section['content'].split('\n');

    bool foundMetadata = false;
    for (var line in lines) {
      if (line.contains('-')) {
        final parts = line.split('-');
        if (parts.length >= 2) {
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join('-').trim();

          if (_checkKeyValue(key, value, cipher)) {
            foundMetadata = true;
          }
        }
      }
    }
    return foundMetadata;
  }

  bool _checkKeyValue(String key, String value, ParsingCipher cipher) {
    bool foundMetadata = false;
    if (['title', 'titulo'].contains(key)) {
      foundMetadata = true;
      cipher.metadata['title'] = value;
    } else if (['artist', 'artista', 'autor', 'author'].contains(key)) {
      foundMetadata = true;
      cipher.metadata['author'] = value;
    } else if (['key', 'tonality', 'tono', 'tom'].contains(key)) {
      foundMetadata = true;
      cipher.metadata['key'] = value;
    } else if (['tempo', 'bpm'].contains(key)) {
      foundMetadata = true;
      cipher.metadata['tempo'] = value;
    } else if (['cifra', 'cipher', 'versão', 'version'].contains(key)) {
      foundMetadata = true;
      cipher.metadata['version'] = value;
    }
    return foundMetadata;
  }
}
