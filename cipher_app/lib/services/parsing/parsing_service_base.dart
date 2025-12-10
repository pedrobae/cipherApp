import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/models/dtos/pdf_dto.dart';
import 'package:cipher_app/services/parsing/chord_line_parser.dart';
import 'package:cipher_app/services/parsing/metadata_parser.dart';
import 'package:cipher_app/services/parsing/section_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ParsingServiceBase {
  final MetadataParser metadataParser = MetadataParser();
  final ChordLineParser chordLineParser = ChordLineParser();
  final SectionParser sectionParser = SectionParser();

  Future<void> parseMetadata(ParsingCipher cipher) async {
    await metadataParser.parseMetadata(cipher);
  }

  Future<void> parseSections(ParsingCipher cipher) async {
    await sectionParser.parseSections(cipher);
    separateSectionLines(cipher);
    for (var section
        in cipher.doubleLineSeparatedSections + cipher.labelSeparatedSections) {
      calculateLines(section['lines']);
    }
  }

  Future<void> parsePdfLines(ParsingCipher cipher) async {
    // USE PDF FORMATTING DATA TO PARSE EACH LINE
    // Calculate font style distribution, to see if the pdf uses different styles

    /// PRE-PROCESSING STEPS
    /// - Identify different font styles used in the document
    /// - Calculate average space between words for each line
    Map<List<PdfFontStyle>, int> fontStyleCount = {};
    Map<List<PdfFontStyle>, Map<List<PdfFontStyle>, int>> followingStyleCounts =
        {};
    for (int i = 0; i < cipher.lines.length; i++) {
      final textLine = cipher.lines[i]['textLine'] as LineData;
      final followingLine = (i + 1 < cipher.lines.length)
          ? cipher.lines[i + 1]['textLine'] as LineData
          : null;

      // Keep count offont styles
      final fontStyles = textLine.fontStyle ?? [];
      fontStyleCount[fontStyles] = (fontStyleCount[fontStyles] ?? 0) + 1;

      // Keep count of adjacent font styles
      if (followingStyleCounts[fontStyles] == null) {
        followingStyleCounts[fontStyles] = {};
      }
      if (followingLine != null) {
        followingStyleCounts[fontStyles]![followingLine.fontStyle ?? []] =
            (followingStyleCounts[fontStyles]![followingLine.fontStyle ?? []] ??
                0) +
            1;
      }

      // Calculate average space between words
      final words = textLine.wordList;
      if (words.length > 1) {
        int totalSpace = 0;
        for (int i = 0; i < words.length - 1; i++) {
          totalSpace +=
              words[i + 1].bounds.left.toInt() - words[i].bounds.right.toInt();
        }
        textLine.avgSpaceBetweenWords = totalSpace ~/ (words.length - 1);
      } else {
        textLine.avgSpaceBetweenWords = 0;
      }
    }

    /// - Identify Chord Style
    ///     - Heuristic: at least 30% of lines use this style
    ///     - Heuristic: at least 70% of chord lines have the same following style (lyrics style)
    ///     - Heuristic: chord lines have higher average space between words
    final int totalLines = cipher.lines.length;
    List<List<PdfFontStyle>> possibleChordStyles = [];
    for (var entry in fontStyleCount.entries) {
      final style = entry.key;
      final count = entry.value;
      // Check style usage threshold
      if (count / totalLines >= 0.3) {
        // Check following styles
        if (followingStyleCounts[style]!.values.any((s) => s > count * 0.7)) {
          // Potential chord style found
          possibleChordStyles.add(style);
        }
      }
    }
    // From possible chord styles, select the one with highest average space between words
    List<PdfFontStyle> chordStyle;
    int highestAvgSpace = -1;
    for (var style in possibleChordStyles) {
      int totalSpace = 0;
      for (var lineMap in cipher.lines) {
        final textLine = lineMap['textLine'] as LineData;
        if ((textLine.fontStyle ?? []) == style) {
          totalSpace += textLine.avgSpaceBetweenWords!;
        }
      }
      int avgSpace = totalSpace ~/ fontStyleCount[style]!;
      if (avgSpace > highestAvgSpace) {
        highestAvgSpace = avgSpace;
        chordStyle = style;
      }
    }
  }

  Future<void> parseChords(ParsingCipher cipher) async {
    await chordLineParser.parseChords(cipher);
  }

  void separateSectionLines(ParsingCipher cipher) {
    for (var section
        in cipher.doubleLineSeparatedSections + cipher.labelSeparatedSections) {
      List<Map<String, dynamic>> lines = [];
      section['content']
          .split('\n')
          .map((line) => lines.add({'text': line}))
          .toList();
      section['lines'] = lines;
    }
  }

  void separateLines(ParsingCipher cipher) {
    List<Map<String, dynamic>> lines = [];
    int lineNumber = 0;
    cipher.rawText
        .split('\n')
        .map((line) => lines.add({'text': line, 'lineNumber': lineNumber++}))
        .toList();
    cipher.lines = lines;
  }

  void calculateLines(List<Map<String, dynamic>> lines) {
    for (var line in lines) {
      // Split line text into words using whitespace as delimiter
      List<String> words = line['text'].split(RegExp(r'\s+')).toList();

      line['wordCount'] = words.length;

      // Calculate average word length
      double avgWordLength = words.isNotEmpty
          ? words.map((w) => w.length).reduce((a, b) => a + b) / words.length
          : 0.0;

      line['avgWordLength'] = avgWordLength;
    }
  }

  void debugPrintCalcs(ParsingCipher cipher) {
    if (kDebugMode) {
      print(
        '--- Line Calculations ---\n\tLine Number\tWord Count\tAvg Word Length',
      );
      for (var line in cipher.lines) {
        print(
          '\t${line['lineNumber']}\t\t${line['wordCount']}\t\t${line['avgWordLength'].toStringAsFixed(2)}',
        );
      }
    }
  }
}
