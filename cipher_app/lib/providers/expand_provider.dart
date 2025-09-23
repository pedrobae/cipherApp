import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';

class ExpandProvider with ChangeNotifier {
  final CipherRepository _cipherRepository = CipherRepository();

  ExpandProvider();

  Cipher? _expandedCipher;
  int? _expandedCipherId;
  bool _isLoading = false;
  String? _error;

  Cipher? get expandedCipher => _expandedCipher;
  int? get expandedCipherId => _expandedCipherId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// ===== READ =====
  // Load single expanded cipher into cache
  Future<void> loadExpandedCipher(int cipherId) async {
    if (_isLoading) return;

    if (_expandedCipherId == cipherId) return;

    _isLoading = true;
    _error = null;
    _expandedCipherId = cipherId;
    notifyListeners();

    try {
      _expandedCipher = (await _cipherRepository.getCipherById(cipherId))!;
      if (kDebugMode) {
        print('Loaded expanded cipher: ${_expandedCipher?.title}');
      }
    } catch (e) {
      _error = e.toString();
      _expandedCipherId = null; // Reset on error
      if (kDebugMode) {
        print('Error loading expanded cipher: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ===== CLEAR =====
  // Clear the currently expanded cipher
  void clearCache() {
    _expandedCipher = null;
    _expandedCipherId = null;
    notifyListeners();
  }

  // Clear expanded cipher to trigger reload next time
  void clearExpandedCipher() {
    _expandedCipher = null;
  }

  /// ===== UTILS =====
  // Check if a specific cipher is expanded
  bool isCipherExpanded(int cipherId) {
    return _expandedCipherId == cipherId;
  }
}
