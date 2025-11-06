import 'package:flutter/foundation.dart';
import 'package:cipher_app/services/import/image_import_service.dart';
import 'package:cipher_app/services/import/pdf_import_service.dart';

enum ImportType { text, pdf, image }

class ImportProvider extends ChangeNotifier {
  final PDFImportService _pdfService = PDFImportService();
  final ImageImportService _imageService = ImageImportService();

  String? _importedText;
  bool _isImporting = false;
  String? _selectedFile;
  String? _error;
  ImportType? _importType;

  String? get importedText => _importedText;
  String? get selectedFile => _selectedFile;
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
  Future<void> importText({String? data}) async {
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
          _importedText = await _pdfService.extractText(selectedFile!);
          break;
        case ImportType.image:
          _importedText = await _imageService.extractText(selectedFile!);
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

  /// Clears the selected file name.
  void clearSelectedFile() {
    _selectedFile = null;
    notifyListeners();
  }

  /// Clears any existing error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
