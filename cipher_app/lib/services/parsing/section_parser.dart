import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:flutter/foundation.dart';

class SectionParser {
  Future<void> parseSections(ParsingCipher cipher) async {
    // Identifies and separates the blocks of the lyrics from the imported text
    // Label sections that are identified (e.g., Verse, Chorus, Bridge)
    // Offer suggestions for unidentified sections based on common patterns

    _separateSections(cipher);

    _labelSections(cipher);

    _checkDuplicates(cipher);

    _debugPrint(cipher);
  }

  void _separateSections(ParsingCipher cipher) {
    List<Map<String, dynamic>> sections = [];
    List<String> rawSections = cipher.rawText.split('\n\n');
    int index = 0;
    for (var rawSection in rawSections) {
      sections.add({'content': rawSection.trim(), 'index': index++});
    }
    cipher.sections = sections;
  }

  void _labelSections(ParsingCipher cipher) {
    String suggestedTitle = 'Unlabeled Section';
    for (var section in cipher.sections) {
      String content = section['content'].trim();

      // Simple heuristic to suggest titles based on keywords
      for (var keyword in ['verse', 'verso']) {
        if (content.toLowerCase().contains(keyword)) {
          suggestedTitle = 'Verse';
        }
      }

      for (var keyword in ['chorus', 'coro']) {
        if (content.toLowerCase().contains(keyword)) {
          suggestedTitle = 'Chorus';
        }
      }

      for (var keyword in ['bridge', 'ponte']) {
        if (content.toLowerCase().contains(keyword)) {
          suggestedTitle = 'Bridge';
        }
      }

      for (var keyword in ['intro']) {
        if (content.toLowerCase().contains(keyword)) {
          suggestedTitle = 'Intro';
        }
      }

      for (var keyword in ['outro']) {
        if (content.toLowerCase().contains(keyword)) {
          suggestedTitle = 'Outro';
        }
      }

      section['suggestedTitle'] = suggestedTitle;
    }
  }

  void _checkDuplicates(ParsingCipher cipher) {
    // Check for duplicate content and mark them
    Set<String> seenContents = {};
    for (var section in cipher.sections) {
      String content = section['content'];
      if (seenContents.contains(content)) {
        section['isDuplicate'] = true;
      } else {
        section['isDuplicate'] = false;
        seenContents.add(content);
      }
    }

    // Check for duplicate titles and mark them, except 'verse' and 'unlabeled section'
    for (var section in cipher.sections) {
      bool isDuplicate = false;
      String title = section['suggestedTitle'].toString().toLowerCase();

      if (section['suggestedTitle'] == 'Unlabeled Section' ||
          section['suggestedTitle'] == 'Verse') {
        section['isDuplicate'] = false;
        continue;
      }

      for (var otherSection in cipher.sections) {
        if (section == otherSection) continue;
        if (title == otherSection['suggestedTitle'].toString().toLowerCase()) {
          isDuplicate = true;
          break;
        }
      }

      section['isDuplicate'] = isDuplicate;
    }
  }

  void _debugPrint(ParsingCipher cipher) {
    if (kDebugMode) {
      print('--- Parsed Sections ---');
      print('\tIndex\tTitle\t\tDuplicate\tContent');
      for (var section in cipher.sections) {
        print(
          '\t${section['index']}\t\t"${section['suggestedTitle']}"\t\t${section['isDuplicate']}\t\t\n${section['content']}\n',
        );
      }
    }
  }
}
