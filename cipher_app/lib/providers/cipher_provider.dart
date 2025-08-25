import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/domain/cipher.dart';
import '../repositories/cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final CipherRepository _cipherRepository = CipherRepository();

  CipherProvider();

  List<Cipher> _ciphers = [];
  List<Cipher> _filteredCiphers = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String _searchTerm = '';
  bool _useMemoryFiltering = true;

  // Add debouncing for rapid calls
  Timer? _loadTimer;

  // Getters
  List<Cipher> get ciphers => _filteredCiphers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useMemoryFiltering => _useMemoryFiltering;

  // Load ciphers from local SQLite database
  Future<void> loadCiphers() async {
    print('------LoadCiphers_Provider-----------');
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _useMemoryFiltering = true;
      _ciphers = await _cipherRepository.getAllCiphers();
      _filterCiphers();

      if (kDebugMode) {
        print('Loaded ${_ciphers.length} ciphers from SQLite');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading ciphers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search functionality
  Future<void> searchCiphers(String term) async {
    _searchTerm = term.toLowerCase();

    if (_useMemoryFiltering) {
      // Instant memory filtering
      _filterCiphers();
    } else {
      // SQLite query with debouncing maybe implement later
    }
  }

  void _filterCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredCiphers = List.from(_ciphers);
    } else {
      _filteredCiphers = _ciphers
          .where(
            (cipher) =>
                cipher.title.toLowerCase().contains(_searchTerm) ||
                cipher.author.toLowerCase().contains(_searchTerm) ||
                cipher.tags.any(
                  (tag) => tag.toLowerCase().contains(_searchTerm),
                ),
          )
          .toList();
    }
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadCiphers();
  }

  Future<void> addCipher(Cipher cipher) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _cipherRepository.insertCipher(cipher);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isSaving = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
