import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:flutter/foundation.dart';

enum SeparatorType { doubleNewLine, bracket, parenthesis, hyphen }

class SectionParser {
  Future<void> parseSections(ParsingCipher cipher) async {
    // Identifies and separates the blocks of the lyrics from the imported text
    // Label sections that are identified (e.g., Verse, Chorus, Bridge)

    _separateSections(cipher);

    _labelSections(cipher);

    _checkDuplicates(cipher);

    _debugPrint(cipher);
  }

  void _separateSections(ParsingCipher cipher) {
    // Search text for section labels and separate sections accordingly
    _separateByLabels(cipher);

    // Check the raw text for section separators (e.g., double newlines, brackets, parentheses, etc.)
    int doubleNewLineCount = '\n\n'.allMatches(cipher.rawText).length;

    // Prefer brackets if they exist in reasonable counts
    SeparatorType? selectedSeparator;
    if (doubleNewLineCount >= 2 && doubleNewLineCount <= 30) {
      selectedSeparator = SeparatorType.doubleNewLine;
    }

    if (selectedSeparator == null) {
      if (kDebugMode) {
        print('No suitable section separator found in text.');
      }
      selectedSeparator = SeparatorType.doubleNewLine; // Default fallback
    }

    if (kDebugMode) {
      print('Selected separator: $selectedSeparator');
    }

    switch (selectedSeparator) {
      case SeparatorType.doubleNewLine:
        _separateDoubleNewLines(cipher);
      default:
    }
  }

  void _separateDoubleNewLines(ParsingCipher cipher) {
    List<String> rawSections = cipher.rawText.split('\n\n');

    cipher.sections = [];
    for (int i = 0; i < rawSections.length; i++) {
      String sectionContent = rawSections[i].trim();
      if (sectionContent.isEmpty) {
        continue; // Skip empty sections
      }

      Map<String, dynamic> section = {
        'index': i,
        'content': sectionContent,
        'numberOfLines': '\n'.allMatches(sectionContent).length + 1,
        'isDuplicate': false,
      };

      cipher.sections.add(section);
    }
  }

  void _labelSections(ParsingCipher cipher) {
    for (var section in cipher.sections) {
      if (section.containsKey('suggestedTitle') &&
          section['suggestedTitle'] != 'Unlabeled Section') {
        continue; // Already labeled
      }

      String content = section['content'].trim();
      String suggestedTitle = 'Unlabeled Section';
      // Simple heuristic to suggest titles based on keywords
      for (var label in commonSectionLabels) {
        for (var possibleLabel in label.labelVariations) {
          RegExp regex = RegExp(
            r'\b' + possibleLabel + r'\b',
            caseSensitive: false,
          );
          if (regex.hasMatch(content)) {
            suggestedTitle = label.officialLabel;
            break;
          }
        }
        if (suggestedTitle != 'Unlabeled Section') {
          break;
        }
      }

      section['suggestedTitle'] = suggestedTitle;
    }
  }

  void _checkDuplicates(ParsingCipher cipher) {
    // Check for duplicate content and mark them
    Map<String, int> seenContentIndex = {};
    for (var section in cipher.sections) {
      String content = section['content'];

      if (seenContentIndex.containsKey(content)) {
        section['duplicatedSectionIndex'] =
            seenContentIndex[content]; // Mark as duplicate, with a reference
      } else {
        seenContentIndex[content] = section['index'];
      }
    }

    // Check for duplicate titles and mark them, except 'verse' and 'unlabeled section'
    Map<String, int> seenTitleIndex = {};
    for (var section in cipher.sections) {
      String title = section['suggestedTitle'].toString().toLowerCase();

      if (section['suggestedTitle'] == 'Unlabeled Section' ||
          section['suggestedTitle'] == 'Verse') {
        continue;
      }

      if (seenTitleIndex.containsKey(title)) {
        section['duplicatedSectionIndex'] =
            seenTitleIndex[title]; // Mark as duplicate, with a reference
      } else {
        seenTitleIndex[title] = section['index'];
      }
    }
  }

  void _debugPrint(ParsingCipher cipher) {
    if (kDebugMode) {
      print('--- Parsed Sections ---');
      print('\tIndex\tisDuplicate\tNumLines\tTitle');
      for (var section in cipher.sections) {
        print(
          '\t${section['index']}\t${section['isDuplicate']}\t\t${section['numberOfLines']}\t"${section['suggestedTitle']}"',
        );
      }
    }
  }

  void _separateByLabels(ParsingCipher cipher) {
    String rawText = cipher.rawText;
    // Search common label texts
    for (var label in commonSectionLabels) {
      for (var labelVariation in label.labelVariations) {
        RegExp regex = RegExp(labelVariation, caseSensitive: false);
        Iterable<RegExpMatch> matches = regex.allMatches(cipher.rawText);

        for (var match in matches) {
          // Possible Label found - check if preceding and following characters are equal
          int start = match.start;
          int end = match.end;

          if (cipher.rawText[start - 1] == cipher.rawText[end]) {
            // Valid label - separate section

            if (start > 0) {
              // Find Last Line Break before the label
              int precedingLineBreakIndex = rawText.lastIndexOf(
                '\n',
                start - 1,
              );
              if (precedingLineBreakIndex == -1) continue;

              // Find first Line Break after the label
              int followingLineBreakIndex = rawText.indexOf('\n', end);
              if (followingLineBreakIndex == -1) continue;

              int sectionEndLineBreak = rawText.indexOf(
                '\n\n',
                followingLineBreakIndex + 1,
              );
              if (sectionEndLineBreak == -1) {
                sectionEndLineBreak = rawText.length;
              }

              // Validate sectionEndLineBreak
              // If
            }
          }
        }
      }
    }
  }
}

final List<SectionLabels> commonSectionLabels = [
  SectionLabels(
    labelVariations: ['verse', 'verso', r'parte\s*\d+'],
    officialLabel: 'Verse',
  ),
  SectionLabels(labelVariations: ['chorus', 'coro'], officialLabel: 'Chorus'),
  SectionLabels(labelVariations: ['bridge', 'ponte'], officialLabel: 'Bridge'),
  SectionLabels(labelVariations: ['intro'], officialLabel: 'Intro'),
  SectionLabels(labelVariations: ['outro'], officialLabel: 'Outro'),
];

class SectionLabels {
  List<String> labelVariations;
  String officialLabel;

  SectionLabels({required this.labelVariations, required this.officialLabel});
}
