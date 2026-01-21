import 'package:cordis/models/domain/parsing_cipher.dart';

class MetadataParser {
  void parseBySimpleText(ParsingResult result) {
    // Iterates through sections
    for (var section in result.rawSections) {
      // Simple heuristic: if the section is labeled it doesn't contain metadata
      if (section.suggestedLabel != 'Unlabeled Section') break;

      bool foundMetadata = false;
      // Look for colon-separated key-value pairs
      if (_checkForColons(result, section)) foundMetadata = true;
      if (_checkForHyphens(result, section)) foundMetadata = true;

      // Mark section as metadata if any metadata found
      if (foundMetadata) section.suggestedLabel = 'Metadata';
    }

    // If title is missing, checks the first section's lines looking at the number of words and average word length
    if (result.metadata['title'] == null || result.metadata['title']!.isEmpty) {
      for (var line in result.lines.take(result.rawSections[0].numberOfLines)) {
        // Maybe the map is wrong
        if (line.wordCount! <= 7 && line.avgWordLength! >= 3.0) {
          result.metadata['title'] = line.text;
          result.rawSections[0].suggestedLabel = 'Metadata';
          break;
        }
      }
    }
  }

  void parseByPdfFormatting(ParsingResult result) {
    // Analizes the first section
    final firstSection = result.rawSections[0];
    bool foundMetadata = false;

    if (firstSection.suggestedLabel == 'Unlabeled Section') {
      // Look for colon-separated key-value pairs
      if (_checkForColons(result, firstSection)) foundMetadata = true;
      if (_checkForHyphens(result, firstSection)) foundMetadata = true;

      // Mark section as metadata if any metadata found
      if (foundMetadata) firstSection.suggestedLabel = 'Metadata';
    }
  }

  bool _checkForColons(ParsingResult result, RawSection section) {
    final lines = section.content.split('\n');

    bool foundMetadata = false;
    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();

          if (_checkKeyValue(key, value, result)) {
            foundMetadata = true;
          }
        }
      }
    }
    return foundMetadata;
  }

  bool _checkForHyphens(ParsingResult result, RawSection section) {
    final lines = section.content.split('\n');

    bool foundMetadata = false;
    for (var line in lines) {
      if (line.contains('-')) {
        final parts = line.split('-');
        if (parts.length >= 2) {
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join('-').trim();

          if (_checkKeyValue(key, value, result)) {
            foundMetadata = true;
          }
        }
      }
    }
    return foundMetadata;
  }

  bool _checkKeyValue(String key, String value, ParsingResult result) {
    bool foundMetadata = false;
    if (['title', 'titulo'].contains(key)) {
      foundMetadata = true;
      result.metadata['title'] = value;
    } else if (['artist', 'artista', 'autor', 'author'].contains(key)) {
      foundMetadata = true;
      result.metadata['author'] = value;
    } else if (['key', 'tonality', 'tono', 'tom'].contains(key)) {
      foundMetadata = true;
      result.metadata['key'] = value;
    } else if (['tempo', 'bpm'].contains(key)) {
      foundMetadata = true;
      result.metadata['tempo'] = value;
    } else if (['cifra', 'cipher', 'versão', 'version'].contains(key)) {
      foundMetadata = true;
      result.metadata['version'] = value;
    }
    return foundMetadata;
  }
}
