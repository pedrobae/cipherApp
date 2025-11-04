import 'package:flutter/material.dart';
import 'package:cipher_app/services/import/import_service_base.dart';

class ImportProvider extends ChangeNotifier {
  final ImportServiceBase _importService = ImportServiceBase();

  String? _importText;
  bool _isImporting = false;
  String? _error;

  String? get importText => _importText;
  bool get isImporting => _isImporting;
  String? get error => _error;

  /// Initiates the import process from the provided text.
  Future<void> importFromText(String text) async {
    if (text.isEmpty) {
      _error = 'Texto de importação vazio';
      notifyListeners();
      return;
    }

    if (isImporting) {
      _error = 'Já está em processo de importação';
      notifyListeners();
      return;
    }

    _isImporting = true;
    _error = null;
    notifyListeners();

    try {
      await _importService.importCipherFromText(text);
    } catch (e) {
      _error = 'Falha ao importar: $e';
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  /// Clears the import error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
