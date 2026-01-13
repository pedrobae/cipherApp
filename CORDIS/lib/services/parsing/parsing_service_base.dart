import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/domain/parsing_cipher.dart';
import 'package:cordis/models/dtos/pdf_dto.dart';
import 'package:cordis/services/parsing/chord_line_parser.dart';
import 'package:cordis/services/parsing/metadata_parser.dart';
import 'package:cordis/services/parsing/section_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ParsingServiceBase {
  final MetadataParser metadataParser = MetadataParser();
  final ChordLineParser chordLineParser = ChordLineParser();
  final SectionParser sectionParser = SectionParser();

  void parse(ImportVariant variant) {
    for (var strategy in variant.parsingResults.keys) {
      parseSections(variant, strategy);
      parseMetadata(variant, strategy);
      parseChords(variant, strategy);
    }
  }

  void parseSections(ImportVariant variant, ParsingStrategy strategy) {
    switch (strategy) {
      case ParsingStrategy.doubleNewLine:
        sectionParser.parseByDoubleNewLine(variant);
        break;
      case ParsingStrategy.sectionLabels:
        sectionParser.parseBySectionLabels(variant);
        break;
      case ParsingStrategy.pdfFormatting:
        sectionParser.parseByPdfFormatting(variant);
        break;
    }
  }

  void parseMetadata(ImportVariant variant, ParsingStrategy strategy) {
    switch (strategy) {
      case ParsingStrategy.doubleNewLine:
      case ParsingStrategy.sectionLabels:
        metadataParser.parseBySimpleText(variant, strategy);
        break;
      case ParsingStrategy.pdfFormatting:
        break;
    }
  }

  void parseChords(ImportVariant variant, ParsingStrategy strategy) {
    switch (strategy) {
      case ParsingStrategy.doubleNewLine:
      case ParsingStrategy.sectionLabels:
        chordLineParser.parseBySimpleText(
          variant,
          variant.parsingResults[strategy]!,
        );
        break;
      case ParsingStrategy.pdfFormatting:
        chordLineParser.parseByPdfFormatting(
          variant,
          variant.parsingResults[strategy]!,
        );
        break;
    }
  }

  /// ----- PRE-PROCESSING HELPERS ------
  void preProcessPdf(ImportVariant variant) {
    /// PRE-PROCESSING STEPS
    /// - Initialize the PDF-specific parsing result
    /// - Identify different font styles used in the document
    /// - Calculate average space between words for each line
    ParsingResult result = ParsingResult(
      strategy: ParsingStrategy.pdfFormatting,
    );

    for (int i = 0; i < variant.lines.length; i++) {
      final textLine = variant.lines[i]['textLine'] as LineData;
      final followingLine = (i + 1 < variant.lines.length)
          ? variant.lines[i + 1]['textLine'] as LineData
          : null;

      // Keep count of font styles
      final fontStyles = textLine.fontStyle ?? [];
      result.fontStyleCount[(fontStyles)] =
          (result.fontStyleCount[(fontStyles)] ?? 0) + 1;

      // Keep count of adjacent font styles
      if (result.followingStyleCounts[(fontStyles)] == null) {
        result.followingStyleCounts[(fontStyles)] = {};
      }
      if (followingLine != null) {
        result.followingStyleCounts[(fontStyles)]![(followingLine.fontStyle ??
                [])] =
            (result.followingStyleCounts[(fontStyles)]![(followingLine
                        .fontStyle ??
                    [])] ??
                0) +
            1;
      }

      // Calculate average space between words and average word length
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

    // - Identify Chord Style
    //     - Heuristic: at least 30% of lines use this style
    //     - Heuristic: at least 70% of chord lines have the same following style (lyrics style)
    //     - Heuristic: chord lines have higher average space between words
    final int totalLines = variant.lines.length;
    List<List<PdfFontStyle>> possibleChordStyles = [];
    for (var entry in result.fontStyleCount.entries) {
      final style = entry.key;
      final count = entry.value;
      // Check style usage threshold
      if (count / totalLines >= 0.3) {
        // Check following styles
        if (result.followingStyleCounts[style]!.values.any(
          (s) => s > count * 0.7,
        )) {
          // Potential chord style found
          possibleChordStyles.add(style);
        }
      }
    }
    // From possible chord styles, select the one with highest average space between words
    int highestAvgSpace = -1;
    for (var style in possibleChordStyles) {
      int totalSpace = 0;
      for (var lineMap in variant.lines) {
        final textLine = lineMap['textLine'] as LineData;
        if ((textLine.fontStyle ?? []) == style) {
          totalSpace += textLine.avgSpaceBetweenWords!;
        }
      }
      int avgSpace = totalSpace ~/ result.fontStyleCount[style]!;
      if (avgSpace > highestAvgSpace) {
        highestAvgSpace = avgSpace;
        result.dominantChordStyle = style;
      }
    }

    variant.parsingResults[ParsingStrategy.pdfFormatting] = result;
  }

  void preProcessText(ImportVariant variant) {
    /// PRE-PROCESSING STEPS
    /// - Initialize empty parsing results for text strategies
    variant.parsingResults[ParsingStrategy.doubleNewLine] = ParsingResult(
      strategy: ParsingStrategy.doubleNewLine,
    );
    variant.parsingResults[ParsingStrategy.sectionLabels] = ParsingResult(
      strategy: ParsingStrategy.sectionLabels,
    );
  }

  void calculateLines(ImportVariant variant) {
    for (var line in variant.lines) {
      // Split line text into words using whitespace as delimiter
      List<String> words = line['text'].split(RegExp(r'\s+')).toList();

      variant.metadata['wordCount'] = words.length;

      // Calculate average word length
      double avgWordLength = words.isNotEmpty
          ? words.map((w) => w.length).reduce((a, b) => a + b) / words.length
          : 0.0;

      variant.metadata['avgWordLength'] = avgWordLength;
    }
  }

  void debugPrintCalcs(ImportVariant variant) {
    if (kDebugMode) {
      print('--- PDF Pre-Processing Results for ${variant.variation.name} ---');
      print(
        '--- Line Calculations ---\n\tLine Number\tWord Count\tAvg Word Length',
      );
      for (var line in variant.lines) {
        print(
          '\t${line['lineNumber']}\t\t${variant.metadata['wordCount']}\t\t${variant.metadata['avgWordLength'].toStringAsFixed(2)}',
        );
      }
    }
  }

  Cipher buildCipherFromParsedImportVariant(
    ParsingResult result,
    ImportVariant variant,
  ) {
    return Cipher(
      versions: [
        Version(
          sections: result.parsedSections,
          songStructure: result.songStructure,
          versionName: 'Imported',
          cipherId: -1,
          createdAt: DateTime.now(),
        ),
      ],
      title: variant.metadata['title'] ?? 'Unknown Title',
      author: variant.metadata['artist'] ?? 'Unknown Artist',
      tempo: variant.metadata['tempo'] ?? '',
      musicKey: variant.metadata['key'] ?? '',
      language: variant.metadata['language'] ?? '',
      isLocal: true,
    );
  }
}
