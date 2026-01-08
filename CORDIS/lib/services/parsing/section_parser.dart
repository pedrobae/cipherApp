import 'package:cordis/models/domain/parsing_cipher.dart';
import 'package:cordis/models/dtos/pdf_dto.dart';
import 'package:cordis/utils/section_constants.dart';

enum SeparatorType { doubleNewLine, bracket, parenthesis, hyphen }

class SectionParser {
  void parseByDoubleNewLine(ImportVariant variant) {
    List<String> rawSections = variant.rawText.split('\n\n');

    ParsingResult result =
        variant.parsingResults[ParsingStrategy.doubleNewLine]!;
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

      result.rawSections.add(section);
    }
  }

  void parseBySectionLabels(ImportVariant variant) {
    ParsingResult result =
        variant.parsingResults[ParsingStrategy.sectionLabels]!;
    String rawText = variant.rawText;
    List<Map<String, dynamic>> validMatches = [];
    // Search common label texts
    for (var label in commonSectionLabels) {
      for (var labelVariation in label.labelVariations) {
        RegExp regex = RegExp(labelVariation, caseSensitive: false);
        Iterable<RegExpMatch> matches = regex.allMatches(variant.rawText);

        for (var match in matches) {
          final labelData = _validateLabel(variant.rawText, match);

          // Possible Label found -  Validate
          if (labelData['isValid']) {
            validMatches.add({
              'label': match.group(0),
              'labelStart': labelData['labelStart'],
              'labelEnd': labelData['labelEnd'],
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

      result.rawSections.add({
        'index': result.rawSections.length,
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
    _checkDuplicates(result);
  }

  void parseByPdfFormatting(ImportVariant variant) {
    ParsingResult result =
        variant.parsingResults[ParsingStrategy.pdfFormatting]!;

    /// Identifies section break based on line spacing greater than the mean line spacing
    double totalLineSpacing = 0.0;
    int relativeSpacingCount = 0;
    for (int i = 0; i < variant.lines.length - 1; i++) {
      final textLine = variant.lines[i]['textLine'] as LineData;
      final nextLine = variant.lines[i + 1]['textLine'] as LineData;
      final spacing = nextLine.bounds.top - textLine.bounds.bottom;
      if (spacing > 0) {
        totalLineSpacing += spacing;
        relativeSpacingCount++;
      }
    }
    double meanLineSpacing = totalLineSpacing / relativeSpacingCount;
    int previousBreakIndex = 0;
    for (int i = 0; i < variant.lines.length - 1; i++) {
      final textLine = variant.lines[i]['textLine'] as LineData;
      final nextLine = variant.lines[i + 1]['textLine'] as LineData;
      double lineSpacing = nextLine.bounds.top - textLine.bounds.bottom;
      // Line spacing greater than mean indicates a section break (negative spacing implies column change)
      if (lineSpacing > meanLineSpacing || lineSpacing < 0) {
        // Section break found
        int sectionStart = previousBreakIndex;
        int sectionEnd = i + 1;

        List<LineData> sectionLines = variant.lines
            .sublist(sectionStart, sectionEnd)
            .map((lineMap) {
              return lineMap['textLine'] as LineData;
            })
            .toList();

        _mapSectionFromLinesData(result, sectionLines);

        previousBreakIndex = sectionEnd;
      }
    }
    // Handle last section if any lines remain
    if (previousBreakIndex < variant.lines.length) {
      List<LineData> sectionLines = variant.lines
          .sublist(previousBreakIndex)
          .map((lineMap) {
            return lineMap['textLine'] as LineData;
          })
          .toList();

      _mapSectionFromLinesData(result, sectionLines);
    }

    _checkDuplicates(result);
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
      if (lineStart != 0) {
        // No newline was found after the match
        // And the text is not single line
        return {'isValid': false};
      }
      matchLine = rawText;
    } else {
      matchLine = rawText.substring(lineStart, lineEnd);
    }

    // Search for colon after the label
    RegExp colonRegex = RegExp(r':');
    if (colonRegex.hasMatch(matchLine)) {
      final labelEnd = colonRegex.firstMatch(matchLine)!.end;
      return {
        'isValid': true,
        'labelStart': lineStart,
        'labelEnd': lineStart + labelEnd,
        'labelWithColon': true,
      };
    }

    // Check preceding and following characters, examining equally spaced characters
    if (start - lineStart > lineEnd - end) {
      // More preceding characters than following characters ---> ASSUMING THIS ISNT A VALID LABEL
      if (lineEnd != -1) {
        return {'isValid': false};
      }
    }
    int j = 0;
    for (int i = start - 1; i >= lineStart; i--, j++) {
      String precedingChar = rawText[i];
      String followingChar = rawText[end + j];

      if (precedingChar != followingChar &&
          !_areMirrored(precedingChar, followingChar)) {
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

  bool _areMirrored(String char1, String char2) {
    const Map<String, String> mirroredPairs = {
      '(': ')',
      '[': ']',
      '{': '}',
      '<': '>',
      '-': '-',
    };

    return mirroredPairs[char1] == char2;
  }

  void _checkDuplicates(ParsingResult result) {
    // Check for duplicate content and mark them
    List<Map<String, dynamic>> sections = result.rawSections;
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
    for (var section in sections) {
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

  void _mapSectionFromLinesData(
    ParsingResult result,
    List<LineData> linesData,
  ) {
    if (linesData.isEmpty) {
      return; // No lines to process
    }
    // Check first line for label
    bool firstLineHasLabel;
    RegExpMatch? match;
    String officialLabel;
    String label = 'Unlabeled Section';
    (firstLineHasLabel, match, officialLabel) = _containsLabel(
      linesData[0].text,
    );

    if (firstLineHasLabel) {
      final labelData = _validateLabel(linesData[0].text, match!);

      if (labelData['isValid']) {
        // Save extracted label
        label = linesData[0].text
            .substring(labelData['labelStart'], labelData['labelEnd'])
            .trim();

        if (labelData['labelWithColon'] == true) {
          label = label.substring(0, label.length - 1).trim();
        }

        // Remove label from LineData
        linesData[0].text = linesData[0].text
            .substring(labelData['labelEnd'])
            .trimLeft();

        if (linesData[0].text.isEmpty) {
          // If the line is now empty, remove it from linesData
          linesData.removeAt(0);
        }
      }
    }
    StringBuffer buffer = StringBuffer();
    for (var line in linesData) {
      buffer.writeln(line.text);
    }
    String sectionContent = buffer.toString().trim();

    if (sectionContent.isEmpty) {
      return; // Skip empty sections
    }

    Map<String, dynamic> section = {
      'index': result.rawSections.length,
      'content': sectionContent,
      'numberOfLines': linesData.length,
      'isDuplicate': false,
      'suggestedTitle': label,
      'linesData': linesData,
      'officialLabel': officialLabel,
    };

    result.rawSections.add(section);
  }

  (bool, RegExpMatch?, String) _containsLabel(String text) {
    for (var label in commonSectionLabels) {
      for (var labelVariation in label.labelVariations) {
        RegExp regex = RegExp(labelVariation, caseSensitive: false);
        if (regex.hasMatch(text)) {
          return (true, regex.firstMatch(text)!, label.officialLabel);
        }
      }
    }
    return (false, null, 'Unlabeled Section');
  }
}

bool _isNumber(String char) {
  return int.tryParse(char) != null;
}
