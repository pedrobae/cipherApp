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
    // Check the raw text for section separators (e.g., double newlines, brackets, parentheses, etc.)
    int doubleNewLineCount = '\n\n'.allMatches(cipher.rawText).length;
    int bracketCount = RegExp(r'\[.*?\]').allMatches(cipher.rawText).length;
    int parenthesisCount = RegExp(r'\(.*?\)').allMatches(cipher.rawText).length;
    int hyphenCount = RegExp(r'-{2,}').allMatches(cipher.rawText).length;

    // Prefer brackets if they exist in reasonable counts
    SeparatorType? selectedSeparator;

    if (bracketCount >= 2 && bracketCount <= 30) {
      selectedSeparator = SeparatorType.bracket;
    } else if (doubleNewLineCount >= 2 && doubleNewLineCount <= 30) {
      selectedSeparator = SeparatorType.doubleNewLine;
    } else if (parenthesisCount >= 2 && parenthesisCount <= 30) {
      selectedSeparator = SeparatorType.parenthesis;
    } else if (hyphenCount >= 2 && hyphenCount <= 30) {
      selectedSeparator = SeparatorType.hyphen;
    }

    if (selectedSeparator == null) {
      throw Exception('No suitable section separator found in text.');
    }

    if (kDebugMode) {
      print('Selected separator: $selectedSeparator');
    }

    switch (selectedSeparator) {
      case SeparatorType.doubleNewLine:
        _separateDoubleNewLines(cipher);
        break;
      case SeparatorType.bracket:
        _separateBrackets(cipher);
        break;
      case SeparatorType.parenthesis:
        _separateParentheses(cipher);
        break;
      case SeparatorType.hyphen:
        _separateHyphens(cipher);
        break;
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

  /// Separates sections based on double new lines as delimiters
  ///
  /// Finds new lines, then after trimming, finds empty lines as section separators
  void _separateDoubleNewLines(ParsingCipher cipher) {
    List<Map<String, dynamic>> sections = [];
    // Iterate through lines trim whitespace, and find empty lines as section separators
    int index = 0;
    Map<String, dynamic> currentSection = {
      'content': '',
      'index': index++,
      'numberOfLines': 0,
    };
    for (var line in cipher.rawText.split('\n')) {
      if (line.trim().isEmpty) {
        if (currentSection['content'].toString().trim().isNotEmpty) {
          sections.add(currentSection);
          currentSection = {
            'content': '',
            'index': index++,
            'numberOfLines': 0,
          };
        }
      } else {
        currentSection['content'] = '${currentSection['content']}$line\n';
        currentSection['numberOfLines'] = (currentSection['numberOfLines']) + 1;
      }
    }
    // Add the last section if not empty
    if (currentSection['content'].toString().trim().isNotEmpty) {
      sections.add(currentSection);
    }
    cipher.sections = sections;
  }

  void _separateBrackets(ParsingCipher cipher) {
    List<Map<String, dynamic>> sections = [];
    RegExp bracketRegex = RegExp(r'\[.*?\]');
    String rawText = cipher.rawText;
    Iterable<RegExpMatch> matches = bracketRegex.allMatches(rawText);

    int lastEnd = 0;
    int index = 0;
    String label = '';

    for (var match in matches) {
      // Content before the bracket
      if (match.start > lastEnd) {
        String content = rawText.substring(lastEnd, match.start).trim();
        if (content.isNotEmpty) {
          sections.add({
            'content': content,
            'index': index++,
            'suggestedTitle': label.isNotEmpty ? label : 'Unlabeled Section',
            'numberOfLines': content.split('\n').length,
          });
        }
      }

      // Content inside the bracket
      label = match.group(0)!.substring(1, match.group(0)!.length - 1).trim();
      lastEnd = match.end;
    }

    // Content after the last bracket
    if (lastEnd < rawText.length) {
      String content = rawText.substring(lastEnd).trim();
      if (content.isNotEmpty) {
        sections.add({
          'content': content,
          'index': index++,
          'suggestedTitle': label.isNotEmpty ? label : 'Unlabeled Section',
          'numberOfLines': content.split('\n').length,
        });
      }
    }

    cipher.sections = sections;
  }

  void _separateParentheses(ParsingCipher cipher) {
    List<Map<String, dynamic>> sections = [];
    RegExp parenthesesRegex = RegExp(r'\(.*?\)');
    String rawText = cipher.rawText;
    Iterable<RegExpMatch> matches = parenthesesRegex.allMatches(rawText);

    int lastEnd = 0;
    int index = 0;
    String label = '';

    for (var match in matches) {
      if (match.start > lastEnd) {
        String content = rawText.substring(lastEnd, match.start).trim();
        if (content.isNotEmpty) {
          sections.add({
            'content': content,
            'index': index++,
            'suggestedTitle': label.isNotEmpty ? label : 'Unlabeled Section',
            'numberOfLines': content.split('\n').length,
          });
        }
      }

      label = match.group(0)!.trim();
      lastEnd = match.end;
    }

    if (lastEnd < rawText.length) {
      String content = rawText.substring(lastEnd).trim();
      if (content.isNotEmpty) {
        sections.add({
          'content': content,
          'index': index++,
          'suggestedTitle': label.isNotEmpty ? label : 'Unlabeled Section',
          'numberOfLines': content.split('\n').length,
        });
      }
    }

    cipher.sections = sections;
  }

  void _separateHyphens(ParsingCipher cipher) {
    List<Map<String, dynamic>> sections = [];
    RegExp hyphenRegex = RegExp(r'-{2,}');
    String rawText = cipher.rawText;
    Iterable<RegExpMatch> matches = hyphenRegex.allMatches(rawText);

    int lastEnd = 0;
    int index = 0;

    for (var match in matches) {
      if (match.start > lastEnd) {
        String content = rawText.substring(lastEnd, match.start).trim();
        if (content.isNotEmpty) {
          sections.add({
            'content': content,
            'index': index++,
            'numberOfLines': content.split('\n').length,
          });
        }
      }

      lastEnd = match.end;
    }

    if (lastEnd < rawText.length) {
      String content = rawText.substring(lastEnd).trim();
      if (content.isNotEmpty) {
        sections.add({
          'content': content,
          'index': index++,
          'numberOfLines': content.split('\n').length,
        });
      }
    }

    cipher.sections = sections;
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
}
