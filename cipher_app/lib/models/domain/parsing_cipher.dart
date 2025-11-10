import 'package:cipher_app/helpers/chords/chord_song.dart';
import 'package:cipher_app/models/domain/pdf_text_line.dart';

class ParsingCipher {
  final String rawText;
  Map<String, dynamic> metadata;
  List<Map<String, dynamic>>
  lines; // {'lineNumber': int, 'text': String, 'avgWordLength': double,}
  List<Map<String, dynamic>>
  sections; // {'suggestedTitle': String, 'content': String}
  List<Chord> chords;
  String chordProText;

  ParsingCipher({
    required this.rawText,
    this.metadata = const {},
    this.lines = const [],
    this.chords = const [],
    this.sections = const [],
    this.chordProText = '',
  });

  factory ParsingCipher.fromPdfLines(List<PdfTextLine> pdfLines) {
    StringBuffer buffer = StringBuffer();
    List<Map<String, dynamic>> lines = [];

    for (var line in pdfLines) {
      buffer.writeln(line.text);
      lines.add({
        'text': line.text,
        'fontSize': line.fontSize,
        'isBold': line.isBold,
        'lineNumber': line.lineNumber,
      });
    }

    return ParsingCipher(rawText: buffer.toString(), lines: lines);
  }
}
