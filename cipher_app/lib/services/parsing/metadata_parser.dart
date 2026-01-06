import 'package:cipher_app/models/domain/parsing_cipher.dart';

class MetadataParser {
  Future<void> textParser(
    ImportVariant variant,
    ParsingStrategy strategy,
  ) async {
    // Iterates through sections
    for (var section in variant.parsingResults[strategy]!.rawSections) {
      // Simple heuristic: if the section is labeled it doesn't contain metadata
      if (section['suggestedTitle'] != 'Unlabeled Section') break;

      bool foundMetadata = false;
      // Look for colon-separated key-value pairs
      if (_checkForColons(variant, section)) foundMetadata = true;
      if (_checkForHyphens(variant, section)) foundMetadata = true;

      // Mark section as metadata if any metadata found
      if (foundMetadata) section['suggestedTitle'] = 'Metadata';
    }

    // If title is missing, checks the first couple lines looking at the number of words and average word length
    if (variant.metadata['title'] == null ||
        variant.metadata['title']!.isEmpty) {
      for (var line in variant.lines.take(5)) {
        if (line['wordCount'] <= 7 && line['avgWordLength'] >= 3.0) {
          variant.metadata['title'] = line['text'];
          variant.parsingResults[strategy]!.rawSections[0]['suggestedTitle'] =
              'Metadata';
          break;
        }
      }
    }
  }

  bool _checkForColons(ImportVariant variant, Map<String, dynamic> section) {
    final lines = section['content'].split('\n');

    bool foundMetadata = false;
    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();

          if (_checkKeyValue(key, value, variant)) {
            foundMetadata = true;
          }
        }
      }
    }
    return foundMetadata;
  }

  bool _checkForHyphens(ImportVariant variant, Map<String, dynamic> section) {
    final lines = section['content'].split('\n');

    bool foundMetadata = false;
    for (var line in lines) {
      if (line.contains('-')) {
        final parts = line.split('-');
        if (parts.length >= 2) {
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join('-').trim();

          if (_checkKeyValue(key, value, variant)) {
            foundMetadata = true;
          }
        }
      }
    }
    return foundMetadata;
  }

  bool _checkKeyValue(String key, String value, ImportVariant variant) {
    bool foundMetadata = false;
    if (['title', 'titulo'].contains(key)) {
      foundMetadata = true;
      variant.metadata['title'] = value;
    } else if (['artist', 'artista', 'autor', 'author'].contains(key)) {
      foundMetadata = true;
      variant.metadata['author'] = value;
    } else if (['key', 'tonality', 'tono', 'tom'].contains(key)) {
      foundMetadata = true;
      variant.metadata['key'] = value;
    } else if (['tempo', 'bpm'].contains(key)) {
      foundMetadata = true;
      variant.metadata['tempo'] = value;
    } else if (['cifra', 'cipher', 'versão', 'version'].contains(key)) {
      foundMetadata = true;
      variant.metadata['version'] = value;
    }
    return foundMetadata;
  }
}
