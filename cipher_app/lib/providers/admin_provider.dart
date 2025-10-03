import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cipher_app/services/admin_bulk_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminBulkService _bulkService = AdminBulkService();

  // State management
  bool _isImporting = false;
  String? _error;
  BulkImportResult? _lastImportResult;
  ValidationResult? _lastValidationResult;

  // Progress tracking
  int _currentProgress = 0;
  int _totalProgress = 0;
  String _currentStatus = '';

  // Getters
  bool get isImporting => _isImporting;
  String? get error => _error;
  BulkImportResult? get lastImportResult => _lastImportResult;
  ValidationResult? get lastValidationResult => _lastValidationResult;
  int get currentProgress => _currentProgress;
  int get totalProgress => _totalProgress;
  String get currentStatus => _currentStatus;
  double get progressPercentage =>
      _totalProgress > 0 ? _currentProgress / _totalProgress : 0.0;

  /// Validate JSON string before import
  Future<bool> validateJson(String jsonString) async {
    _error = null;
    _lastValidationResult = null;
    notifyListeners();

    try {
      // Parse JSON
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Validate structure
      _lastValidationResult = await _bulkService.validateImportJson(jsonData);
      notifyListeners();

      return _lastValidationResult!.isValid;
    } catch (e) {
      _error = 'Erro ao analisar JSON: $e';
      notifyListeners();
      return false;
    }
  }

  /// Import ciphers from JSON string
  Future<bool> importFromJson({
    required String jsonString,
    required bool uploadToCloud,
  }) async {
    if (_isImporting) return false;

    _isImporting = true;
    _error = null;
    _lastImportResult = null;
    _currentProgress = 0;
    _totalProgress = 0;
    _currentStatus = 'Preparando importação...';
    notifyListeners();

    try {
      // Parse JSON
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Import with progress tracking
      _lastImportResult = await _bulkService.importCiphersFromJson(
        jsonData: jsonData,
        uploadToCloud: uploadToCloud,
        onProgress: _updateProgress,
      );

      return !_lastImportResult!.hasAnyFailures;
    } catch (e) {
      _error = 'Erro durante importação: $e';
      if (kDebugMode) {
        print('Import error: $e');
      }
      return false;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  /// Update progress during import
  void _updateProgress(int current, int total, String status) {
    _currentProgress = current;
    _totalProgress = total;
    _currentStatus = status;
    notifyListeners();
  }

  /// Clear all state
  void clearState() {
    _error = null;
    _lastImportResult = null;
    _lastValidationResult = null;
    _currentProgress = 0;
    _totalProgress = 0;
    _currentStatus = '';
    notifyListeners();
  }

  /// Get sample JSON template
  String getSampleJsonTemplate() {
    final sample = AdminBulkService.getSampleTemplate();
    return const JsonEncoder.withIndent('  ').convert(sample);
  }

  /// Quick validation for UI feedback
  bool isValidJsonStructure(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      return data is Map<String, dynamic> && data.containsKey('ciphers');
    } catch (e) {
      return false;
    }
  }

  /// Count ciphers in JSON without full validation
  int countCiphersInJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      if (data is Map<String, dynamic> && data.containsKey('ciphers')) {
        final ciphers = data['ciphers'];
        if (ciphers is List) {
          return ciphers.length;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
