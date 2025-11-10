import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/services/parsing/chord_line_parser.dart';
import 'package:cipher_app/services/parsing/metadata_parser.dart';
import 'package:cipher_app/services/parsing/section_parser.dart';
import 'package:flutter/foundation.dart';

class ParsingServiceBase {
  final MetadataParser metadataParser = MetadataParser();
  final ChordLineParser chordLineParser = ChordLineParser();
  final SectionParser sectionParser = SectionParser();

  void _separateLines(ParsingCipher cipher) {
    List<Map<String, dynamic>> lines = [];
    int lineNumber = 0;
    cipher.rawText
        .split('\n')
        .map((line) => lines.add({'text': line, 'lineNumber': lineNumber++}))
        .toList();
    cipher.lines = lines;
  }

  void calculateLines(ParsingCipher cipher) {
    _separateLines(cipher);

    for (var line in cipher.lines) {
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

  Future<void> parseMetadata(ParsingCipher cipher) async {
    await metadataParser.parseMetadata(cipher);
  }

  Future<void> parseSections(ParsingCipher cipher) async {
    await sectionParser.parseSections(cipher);
  }

  Future<void> parseChords(ParsingCipher cipher) async {
    await chordLineParser.parseChords(cipher);
  }
}
