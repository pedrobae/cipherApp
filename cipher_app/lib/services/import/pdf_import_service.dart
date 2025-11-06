import 'dart:io';
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
