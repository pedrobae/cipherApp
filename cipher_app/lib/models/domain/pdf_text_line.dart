/// Represents a text line with formatting metadata from PDF
class PdfTextLine {
  final String text;
  final double fontSize;
  final String fontName;
  final bool isBold;
  final int pageNumber;
  final int lineNumber;

  PdfTextLine({
    required this.text,
    required this.fontSize,
    required this.fontName,
    required this.isBold,
    required this.pageNumber,
    required this.lineNumber,
  });

  @override
  String toString() {
    return 'PdfTextLine(text: "$text", fontSize: $fontSize, bold: $isBold, page: $pageNumber, line: $lineNumber)';
  }
}
