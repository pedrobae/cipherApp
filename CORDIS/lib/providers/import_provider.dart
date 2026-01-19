import 'package:cordis/models/domain/parsing_cipher.dart';
import 'package:flutter/foundation.dart';
import 'package:cordis/services/import/image_import_service.dart';
import 'package:cordis/services/import/pdf_import_service.dart';

enum ImportType { text, pdf, image }

class ImportProvider extends ChangeNotifier {
  final PDFImportService _pdfService = PDFImportService();
  final ImageImportService _imageService = ImageImportService();

  /// Single ParsingCipher object that may contain multiple import variants
  ParsingCipher? _importedCipher;
  bool _isImporting = false;
  String? _selectedFile;
  String? _selectedFileName;
  String? _error;
  ImportType? _importType;

  ParsingCipher? get importedCipher => _importedCipher;
  String? get selectedFile => _selectedFile;
  String? get selectedFileName => _selectedFileName;
  bool get isImporting => _isImporting;
  String? get error => _error;

  /// Sets the import type (text, pdf, image).
  void setImportType(ImportType type) {
    _importType = type;
  }

  /// Gets a string representation of the import type.
  String getImportType() {
    switch (_importType) {
      case ImportType.text:
        return 'Text';
      case ImportType.pdf:
        return 'PDF';
      case ImportType.image:
        return 'Image';
      default:
        return 'Error';
    }
  }

  /// Imports text based on the selected import type.
  /// For PDFs: creates multiple import variants (with/without columns) in a single ParsingCipher
  /// For text/images: creates a single import variant
  Future<void> importText({String? data}) async {
    if (_isImporting) return;

    _isImporting = true;
    _error = null;
    notifyListeners();

    try {
      switch (_importType) {
        case ImportType.text:
          // Text import: single import variant (textDirect)
          final lines = (data ?? '').split('\n');
          _importedCipher = ParsingCipher(importType: ImportType.text);

          final variant = ImportVariant(
            variation: ImportVariation.textDirect,
            rawText: data ?? '',
            lines: lines
                .asMap()
                .entries
                .map((entry) => {'lineNumber': entry.key, 'text': entry.value})
                .toList(),
          );
          _importedCipher!.addImportVariant(
            ImportVariation.textDirect.name,
            variant,
          );
          break;

        case ImportType.pdf:
          // PDF import: multiple import variants (with/without columns)
          final pdfDocument = await _pdfService.extractTextWithFormatting(
            selectedFile!,
          );

          _importedCipher = ParsingCipher(importType: ImportType.pdf);

          // Variant 1: PDF without column detection
          // TODO: Handle multi-page PDFs - currently only processes page 0
          final noColumnsVariant = ImportVariant.fromPdfLines(
            pdfDocument.pageLines[0]!,
            strategy: ImportVariation.pdfNoColumns,
          );
          _importedCipher!.addImportVariant(
            ImportVariation.pdfNoColumns.name,
            noColumnsVariant,
          );

          // Variant 2: PDF with column detection (if columns detected)
          if (pdfDocument.hasColumns[0] == true) {
            final hasColumnsVariant = ImportVariant.fromPdfLines(
              pdfDocument.pageLinesWithColumns[0]!,
              strategy: ImportVariation.pdfWithColumns,
            );
            _importedCipher!.addImportVariant(
              ImportVariation.pdfWithColumns.name,
              hasColumnsVariant,
            );
          }

          // Store metadata in all variants
          for (var variant in _importedCipher!.importVariants.values) {
            variant.metadata['hasColumns'] = pdfDocument.hasColumns[0];
            variant.metadata['pageCount'] = pdfDocument.pageLines.length;
          }
          break;

        case ImportType.image:
          // TODO: Implement image import logic
          await _imageService.extractText(selectedFile!);
          break;

        default:
          throw Exception('Import type not set');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  /// Sets the selected file name.
  void setSelectedFile(String fileName) {
    _selectedFile = fileName;
    notifyListeners();
  }

  /// Sets the selected file name.
  void setSelectedFileName(String fileName) {
    _selectedFileName = fileName;
    notifyListeners();
  }

  /// Clears the selected file name.
  void clearSelectedFile() {
    _selectedFile = null;
    notifyListeners();
  }

  /// Clears the selected file name.
  void clearSelectedFileName() {
    _selectedFileName = null;
    notifyListeners();
  }

  /// Clears any existing error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
