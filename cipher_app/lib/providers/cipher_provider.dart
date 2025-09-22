import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final CipherRepository _cipherRepository = CipherRepository();

  CipherProvider();

  List<Cipher> _ciphers = [];
  List<Cipher> _filteredCiphers = [];
  Cipher _currentCipher = Cipher.empty();
  Cipher? _expandedCipher;
  int? _expandedCipherId;
  bool _isLoading = false;
  bool _isLoadingExpandedCipher = false;
  bool _isSaving = false;
  String? _error;
  String _searchTerm = '';
  bool _useMemoryFiltering = true;
  bool _hasLoadedCiphers = false;

  // Add debouncing for rapid calls
  Timer? _loadTimer;

  // Getters
  List<Cipher> get ciphers => _filteredCiphers;
  Cipher get currentCipher => _currentCipher;
  Cipher? get expandedCipher => _expandedCipher;
  int? get expandedCipherId => _expandedCipherId;
  bool get isLoading => _isLoading;
  bool get isLoadingExpandedCipher => _isLoadingExpandedCipher;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get useMemoryFiltering => _useMemoryFiltering;
  bool get hasLoadedCiphers => _hasLoadedCiphers;

  /// ===== READ =====
  // Load all ciphers from local SQLite database into cache
  Future<void> loadCiphers() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _useMemoryFiltering = true;
      _ciphers = await _cipherRepository.getAllCiphersPruned();
      _filterCiphers();
      _hasLoadedCiphers = true;

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

  // Load single cipher into cache
  Future<void> loadCipher(int cipherId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCipher = (await _cipherRepository.getCipherById(cipherId))!;
    } catch (e) {
      _error = e.toString();
      _currentCipher = Cipher.empty();
      if (kDebugMode) {
        print('Error loading ciphers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load single cipher into cache by Version Id
  Future<void> loadCipherOfVersion(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCipher = (await _cipherRepository.getCipherWithVersionId(
        versionId,
      ))!;
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

  // Load expanded cipher for detailed view
  Future<void> loadExpandedCipher(int cipherId) async {
    if (_isLoadingExpandedCipher) return;

    // If this cipher is already expanded, don't load again
    if (_expandedCipherId == cipherId && _expandedCipher != null) return;

    _isLoadingExpandedCipher = true;
    _error = null;
    _expandedCipherId = cipherId; // Set the expanded cipher ID
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
      _isLoadingExpandedCipher = false;
      notifyListeners();
    }
  }

  // Collapse the currently expanded cipher
  void collapseExpandedCipher() {
    _expandedCipher = null;
    _expandedCipherId = null;
    notifyListeners();
  }

  // Check if a specific cipher is expanded
  bool isCipherExpanded(int cipherId) {
    return _expandedCipherId == cipherId;
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

  void clearSearch() {
    _filteredCiphers = List.from(_ciphers);
  }

  /// ===== CREATE =====
  Future<void> createCipher() async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Insert basic cipher info and tags
      final cipherId = await _cipherRepository.insertCipher(currentCipher);

      // Load the new ID into the current cipher cache
      _currentCipher = _currentCipher.copyWith(id: cipherId);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating cipher: $e');
      }
    } finally {
      _isSaving = false;
      updateCurrentCipherInList();
      notifyListeners();
    }
  }

  /// ===== UPDATE =====
  // Save current cipher changes to database
  Future<void> saveCipher() async {
    if (_isSaving) return;
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Update basic cipher info and tags
      await _cipherRepository.updateCipher(currentCipher);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error saving cipher: $e');
      }
    } finally {
      _isSaving = false;
      updateCurrentCipherInList();
      notifyListeners();
    }
  }

  // Update cache with non tag changes
  void cacheCipherUpdates(String field, String change) {
    if (kDebugMode) {
      print('Caching change for field $field: $change');
    }
    if (field == 'title') {
      _currentCipher = currentCipher.copyWith(title: change);
    } else if (field == 'author') {
      _currentCipher = currentCipher.copyWith(author: change);
    } else if (field == 'tempo') {
      _currentCipher = currentCipher.copyWith(tempo: change);
    } else if (field == 'musicKey') {
      _currentCipher = currentCipher.copyWith(musicKey: change);
    } else if (field == 'language') {
      _currentCipher = currentCipher.copyWith(language: change);
    }
  }

  // Update cache with tag changes
  void cacheCipherTagUpdates(String tags) {
    List<String> tagList = tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    _currentCipher = currentCipher.copyWith(tags: tagList);
  }

  /// ===== DELETE =====
  Future<void> deleteCipher(int cipherID) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.deleteCipher(cipherID);
      // Reload all ciphers to reflect the deletion
      await loadCiphers();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error deleting cipher: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// ===== UTILS =====
  /// Clear cached data and reset state for debugging
  void clearCache() {
    _ciphers.clear();
    _currentCipher = Cipher.empty();
    _filteredCiphers.clear();
    _isLoading = false;
    _isSaving = false;
    _error = null;
    _searchTerm = '';
    notifyListeners();
  }

  /// Clear current cipher to create a new cipher
  void clearCurrentCipher() {
    _currentCipher = Cipher.empty();
    notifyListeners();
  }

  /// On currentCipher database persistence update the _ciphers list to reflect changes
  void updateCurrentCipherInList() {
    if (_currentCipher.id == null) {
      if (kDebugMode) {
        print('Current cipher has no ID, cannot update in list');
      }
      return;
    }

    int index = _ciphers.indexWhere((c) => c.id == _currentCipher.id);
    if (index != -1) {
      _ciphers[index] = _currentCipher;
    } else {
      _ciphers.add(_currentCipher);
    }
    _filterCiphers();
  }

  /// Toggle expanded cipher for detailed view
  void toggleExpandCipher(int cipherId) {
    if (_expandedCipherId == cipherId) {
      collapseExpandedCipher();
    } else {
      loadExpandedCipher(cipherId);
    }
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
