import 'package:flutter/material.dart';
import 'package:cipher_app/services/import/image_import_service.dart';
import 'package:cipher_app/services/import/pdf_import_service.dart';

enum ImportType { text, pdf, image }

class ImportProvider extends ChangeNotifier {
  final PDFImportService _pdfService = PDFImportService();
  final ImageImportService _imageService = ImageImportService();

  String? _importedText;
  bool _isImporting = false;
  String? _error;
  ImportType? _importType;

  String? get importedText => _importedText;
  bool get isImporting => _isImporting;
  String? get error => _error;

  /// Sets the import type (text, pdf, image).
  void setImportType(ImportType type) {
    _importType = type;
  }

  /// Imports text based on the selected import type.
  Future<void> importText(String data) async {
    if (_isImporting) return;

    _isImporting = true;
    _error = null;
    notifyListeners();

    try {
      switch (_importType) {
        case ImportType.text:
          _importedText = data;
          break;
        case ImportType.pdf:
          _importedText = await _pdfService.extractText(data);
          break;
        case ImportType.image:
          _importedText = await _imageService.extractText(data);
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

  /// Clears any existing error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
