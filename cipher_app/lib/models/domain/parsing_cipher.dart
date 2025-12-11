import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/dtos/pdf_dto.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

enum SeparationType { doubleNewLine, label }

class ParsingCipher {
  final String rawText;
  final ImportType importType;
  Map<String, dynamic> metadata = {};
  List<Map<String, dynamic>>
  lines; // {'lineNumber': int, 'text': String, 'avgWordLength': double,}
  // {'suggestedTitle': String, 'content': String, 'index': int, 'isDuplicate': bool}
  List<Map<String, dynamic>> labelSeparatedSections = [];
  Map<String, Section> parsedLabelSeparatedSections = {};
  List<String> labelSeparatedSongStructure = [];

  List<Map<String, dynamic>> doubleLineSeparatedSections = [];
  Map<String, Section> parsedDoubleLineSeparatedSections = {};
  List<String> doubleLineSeparatedSongStructure = [];

  List<Map<String, dynamic>> pdfSeparatedSections = [];
  Map<String, Section> parsedPdfSeparatedSections = {};
  List<String> pdfSeparatedSongStructure = [];

  Map<List<PdfFontStyle>, int> fontStyleCount = {};
  Map<List<PdfFontStyle>, Map<List<PdfFontStyle>, int>> followingStyleCounts =
      {};

  ParsingCipher({
    required this.rawText,
    required this.importType,
    this.lines = const [],
  });

  factory ParsingCipher.fromPdfLines(List<LineData> textLines) {
    StringBuffer buffer = StringBuffer();
    List<Map<String, dynamic>> lines = [];

    for (var line in textLines) {
      buffer.writeln(line.text);
      lines.add({'textLine': line});
    }

    return ParsingCipher(
      rawText: buffer.toString(),
      lines: lines,
      importType: ImportType.pdf,
    );
  }
}
