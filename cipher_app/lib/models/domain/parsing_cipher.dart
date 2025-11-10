import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/pdf_text_line.dart';
import 'package:cipher_app/providers/import_provider.dart';

class ParsingCipher {
  final String rawText;
  final ImportType importType;
  Map<String, dynamic> metadata = {};
  List<Map<String, dynamic>>
  lines; // {'lineNumber': int, 'text': String, 'avgWordLength': double,}
  List<Map<String, dynamic>>
  sections; // {'suggestedTitle': String, 'content': String, 'index': int, 'isDuplicate': bool}
  List<Section> parsedSections = [];
  List<String> songStructure = [];

  ParsingCipher({
    required this.rawText,
    required this.importType,
    this.lines = const [],
    this.sections = const [],
    this.parsedSections = const [],
    this.songStructure = const [],
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

    return ParsingCipher(
      rawText: buffer.toString(),
      lines: lines,
      importType: ImportType.pdf,
    );
  }
}
