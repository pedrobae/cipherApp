import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ParsingCipher {
  final String rawText;
  final ImportType importType;
  Map<String, dynamic> metadata = {};
  List<Map<String, dynamic>>
  lines; // {'lineNumber': int, 'text': String, 'avgWordLength': double,}
  // {'suggestedTitle': String, 'content': String, 'index': int, 'isDuplicate': bool}
  List<Map<String, dynamic>> labelSeparatedSections = [];
  List<Map<String, dynamic>> doubleLineSeparatedSections = [];
  Map<String, Section> parsedLabelSeparatedSections = {};
  Map<String, Section> parsedDoubleLineSeparatedSections = {};
  List<String> labelSeparatedSongStructure = [];
  List<String> doubleLineSeparatedSongStructure = [];

  ParsingCipher({
    required this.rawText,
    required this.importType,
    this.lines = const [],
    this.labelSeparatedSections = const [],
    this.doubleLineSeparatedSections = const [],
    this.parsedLabelSeparatedSections = const {},
    this.parsedDoubleLineSeparatedSections = const {},
    this.labelSeparatedSongStructure = const [],
    this.doubleLineSeparatedSongStructure = const [],
  });

  factory ParsingCipher.fromPdfLines(List<TextLine> textLines) {
    StringBuffer buffer = StringBuffer();
    List<Map<String, dynamic>> lines = [];

    int lineNumber = 0;
    for (var line in textLines) {
      buffer.writeln(line.text);
      lines.add({
        'text': line.text,
        'fontSize': line.fontSize,
        'isBold': line.fontStyle.first == PdfFontStyle.bold,
        'lineNumber': lineNumber++,
      });
    }

    return ParsingCipher(
      rawText: buffer.toString(),
      lines: lines,
      importType: ImportType.pdf,
    );
  }
}
