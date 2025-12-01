import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:flutter/foundation.dart';

enum SeparatorType { doubleNewLine, bracket, parenthesis, hyphen }

class SectionParser {
  Future<void> parseSections(ParsingCipher cipher) async {
    // Identifies and separates the blocks of the lyrics from the imported text
    // Label sections that are identified (e.g., Verse, Chorus, Bridge)
    _separateSections(cipher);

    _checkDuplicates(cipher);

    _debugPrint(cipher);
  }

  void _separateSections(ParsingCipher cipher) {
    // Search text for section labels and separate sections accordingly
    _separateByLabels(cipher);

    // Separate raw text by double new lines
    _separateByDoubleNewLines(cipher);
  }

  void _separateByDoubleNewLines(ParsingCipher cipher) {
    List<String> rawSections = cipher.rawText.split('\n\n');

    cipher.doubleLineSeparatedSections = [];
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
        'suggestedTitle': 'Unlabeled Section',
      };

      cipher.doubleLineSeparatedSections.add(section);
    }
  }

  void _checkDuplicates(ParsingCipher cipher) {
    // Check for duplicate content and mark them
    for (int i = 0; i < SeparationType.values.length; i++) {
      List<Map<String, dynamic>> sections;
      if (i == 0) {
        sections = cipher.labelSeparatedSections;
      } else if (i == 1) {
        sections = cipher.doubleLineSeparatedSections;
      } else {
        sections = [];
      }
      Map<String, int> seenContentIndex = {};
      for (var section in sections) {
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
      for (var section in cipher.doubleLineSeparatedSections) {
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
  }

  void _debugPrint(ParsingCipher cipher) {
    if (kDebugMode) {
      print('--- Parsed Double Line Separated Sections ---');
      print('\tIndex\tisDuplicate\tNumLines\tTitle');
      for (var section in cipher.doubleLineSeparatedSections) {
        print(
          '\t${section['index']}\t${section['isDuplicate']}\t\t${section['numberOfLines']}\t"${section['suggestedTitle']}"',
        );
      }
      print('----------------------------------------------');
      print('--- Parsed Label Separated Sections ---');
      print('\tIndex\tisDuplicate\tNumLines\tTitle');
      for (var section in cipher.labelSeparatedSections) {
        print(
          '\t${section['index']}\t${section['isDuplicate']}\t\t${section['numberOfLines']}\t"${section['suggestedTitle']}"',
        );
      }
    }
  }

  void _separateByLabels(ParsingCipher cipher) {
    String rawText = cipher.rawText;
    List<Map<String, dynamic>> validMatches = [];
    // Search common label texts
    for (var label in commonSectionLabels) {
      for (var labelVariation in label.labelVariations) {
        RegExp regex = RegExp(labelVariation, caseSensitive: false);
        Iterable<RegExpMatch> matches = regex.allMatches(cipher.rawText);

        for (var match in matches) {
          final result = _validateLabel(cipher.rawText, match);

          // Possible Label found -  Validate
          if (result['isValid']) {
            validMatches.add({
              'label': match.group(0),
              'labelStart': result['labelStart'],
              'labelEnd': result['labelEnd'],
            });
          }
        }
      }
    }
    // Order valid matches by their position in the text
    validMatches.sort((a, b) => a['labelStart'].compareTo(b['labelStart']));

    for (int i = 0; i < validMatches.length; i++) {
      var match = validMatches[i];
      var nextMatch = (i + 1 < validMatches.length)
          ? validMatches[i + 1]
          : null;
      int sectionStart = match['labelEnd'];
      int sectionEnd = nextMatch != null
          ? nextMatch['labelStart']
          : rawText.length;

      cipher.labelSeparatedSections.add({
        'index': cipher.labelSeparatedSections.length,
        'content': rawText.substring(sectionStart, sectionEnd).trim(),
        'numberOfLines':
            '\n'
                .allMatches(rawText.substring(sectionStart, sectionEnd))
                .length +
            1,
        'suggestedTitle': rawText.substring(
          match['labelStart'],
          match['labelEnd'],
        ),
        'isDuplicate': false,
      });
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
  SectionLabels(
    labelVariations: ['chorus', 'coro', 'refrao', 'refrão'],
    officialLabel: 'Chorus',
  ),
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
