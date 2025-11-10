import 'dart:io';
import 'package:cipher_app/models/domain/pdf_text_line.dart';
import 'package:cipher_app/services/import/import_service_base.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFImportService extends ImportService {
  /// Extracts text content from a PDF file
  ///
  /// [path] - Absolute file path to the PDF
  /// Returns extracted text as a String
  /// Throws [FileSystemException] if file doesn't exist
  /// Throws [Exception] if PDF parsing fails
  @override
  Future<String> extractText(String path) async {
    try {
      // Read PDF file as bytes
      final file = File(path);
      final bytes = await file.readAsBytes();

      // Load PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Extract text using Syncfusion's text extractor
      final String text = PdfTextExtractor(document).extractText();

      // Clean up resources
      document.dispose();

      return text;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Extracts text with detailed formatting information for better parsing
  ///
  /// Returns a list of text lines with font size, boldness, and position metadata
  Future<List<PdfTextLine>> extractTextWithFormatting(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      final List<PdfTextLine> lines = [];

      // Extract text from each page with layout information
      final textExtractor = PdfTextExtractor(document);

      for (int i = 0; i < document.pages.count; i++) {
        // Extract text with layout information for this page
        final List<TextLine> textLines = textExtractor.extractTextLines(
          startPageIndex: i,
          endPageIndex: i,
        );

        for (final textLine in textLines) {
          // Get font information from the text line
          final fontSize = textLine.fontSize;
          final fontName = textLine.fontName;
          final isBold = _isBoldFont(fontName);

          lines.add(
            PdfTextLine(
              text: textLine.text.trim(),
              fontSize: fontSize,
              fontName: fontName,
              isBold: isBold,
              pageNumber: i + 1,
              lineNumber: lines.length,
            ),
          );
        }
      }

      document.dispose();

      return lines;
    } catch (e) {
      throw Exception('Failed to extract formatted text from PDF: $e');
    }
  }

  /// Determines if a font is bold based on its name
  bool _isBoldFont(String fontName) {
    final lowerName = fontName.toLowerCase();
    return lowerName.contains('bold') ||
        lowerName.contains('black') ||
        lowerName.contains('heavy') ||
        lowerName.contains('semibold');
  }

  /// Validates that the PDF file exists and has .pdf extension
  @override
  Future<bool> validate(String path) async {
    if (!path.toLowerCase().endsWith('.pdf')) {
      return false;
    }

    final file = File(path);
    return await file.exists();
  }
}
