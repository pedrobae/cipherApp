import 'package:flutter/material.dart';
import 'package:cipher_app/services/import/import_service_base.dart';

class ImportProvider extends ChangeNotifier {
  final ImportServiceBase _importService = ImportServiceBase();

  String? _importText;
  bool _isImporting = false;

  String? get importText => _importText;
  bool get isImporting => _isImporting;

  void setImportText(String text) {
    _importText = text;
    notifyListeners();
  }
}
