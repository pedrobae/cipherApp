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
          // Possible Label found -  Validate
          if (_validateLabel(cipher.rawText, match)['isValid']) {
            // FOR NOW DEBUG PRINT ONLY
            if (kDebugMode) {
              print(
                'Valid section label found: "${match.group(0)}" at positions ${match.start}-${match.end}',
              );
            }
            // TODO: Implement section separation logic based on validated labels
          }
        }
      }
    }
  }

  /// Validates if a found label is indeed a section label,
  /// returns true if valid, false otherwise, {'isValid': bool, ...}
  /// and additional info for extracting the section {... , 'labelStart': int, 'labelEnd': int}, if valid
  Map<String, dynamic> _validateLabel(String rawText, RegExpMatch match) {
    /// Validation strategy - check surrounding characters
    /// Examples to correctly validade:
    /// "\nChorus\n"  -> valid
    /// "[Chorus]"    -> valid
    /// "(Chorus)"    -> valid
    /// "- Chorus -"  -> valid
    /// "Chorus:"      -> valid
    /// "Intro: C E F" -> valid -> Correctly identify the label at the start of the line
    /// "Verse 1"      -> valid
    /// "[Intro] A2  B2  C#m7  G#m7(11)" -> valid

    /// Invalid examples:
    /// "Cantaremos como um coro de anjos" -> invalid
    /// "This is the chorus of the song"   -> invalid
    /// "Chorus is a great part"            -> invalid

    int start = match.start;
    int end = match.end;

    // Extract the full line containing the match
    String matchLine = '';
    int lineStart = rawText.lastIndexOf('\n', start) + 1;
    int lineEnd = rawText.indexOf('\n', end);
    if (lineEnd == -1) {
      // No newline was found after the match, invalid label
      return {'isValid': false};
    }
    matchLine = rawText.substring(lineStart, lineEnd);

    // Search for colon after the label
    RegExp colonRegex = RegExp(r':');
    if (colonRegex.hasMatch(matchLine)) {
      final labelEnd = colonRegex.firstMatch(matchLine)!.end;
      return {
        'isValid': true,
        'labelStart': lineStart,
        'labelEnd': lineStart + labelEnd,
      };
    }

    // Check preceding and following characters, examining equally spaced characters
    if (start - lineStart > lineEnd - end) {
      // More preceding characters than following characters ---> ASSUMING THIS ISNT A VALID LABEL
      return {'isValid': false};
    }
    int j = 0;
    for (int i = start - 1; i >= lineStart; i--, j++) {
      String precedingChar = rawText[i];
      String followingChar = rawText[end + j];

      if (precedingChar != followingChar) {
        // Mismatched characters, check for label suffixes, e.g. numbered verses ("Verse 1")
        if (followingChar.trim().isEmpty && _isNumber(rawText[end + j + 1])) {
          // The matched label is followed by a space and number,
          // Adjust indexes and continue checking
          i--;
          j += 2; // Skip space and number
          continue;
        } else {
          // Invalid label
          return {'isValid': false};
        }
      }
    }
    // All preceding and following characters matched
    return {'isValid': true, 'labelStart': lineStart, 'labelEnd': end + j};
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

bool _isNumber(String char) {
  return int.tryParse(char) != null;
}
