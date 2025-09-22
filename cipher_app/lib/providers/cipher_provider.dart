import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final CipherRepository _cipherRepository = CipherRepository();

  CipherProvider();

  List<Cipher> _ciphers = [];
  List<Cipher> _filteredCiphers = [];
  Cipher? _currentCipher;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String _searchTerm = '';
  bool _useMemoryFiltering = true;
  bool _hasInitialized = false;

  // Add debouncing for rapid calls
  Timer? _loadTimer;

  // Getters
  List<Cipher> get ciphers => _filteredCiphers;
  Cipher? get currentCipher => _currentCipher;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get useMemoryFiltering => _useMemoryFiltering;
  bool get hasInitialized => _hasInitialized;

  /// ===== READ =====
  // Load all ciphers from local SQLite database into cache
  Future<void> loadCiphers() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _useMemoryFiltering = true;
      _ciphers = await _cipherRepository.getAllCiphers();
      _filterCiphers();
      _hasInitialized = true;

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
      _currentCipher = await _cipherRepository.getCipherById(cipherId);
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

  // Load single cipher into cache by Version Id
  Future<void> loadCipherOfVersion(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCipher = await _cipherRepository.getCipherWithVersionId(
        versionId,
      );
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

  void clearSearch() {
    _filteredCiphers = List.from(_ciphers);
  }

  /// ===== CREATE =====
  Future<void> createCipher(Cipher cipher) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Insert basic cipher info and tags
      final cipherId = await _cipherRepository.insertCipher(cipher);

      // Insert cipher maps and their content
      await _createCipherVersionsAndSections(cipherId, cipher.versions);

      // Reload all ciphers to get the complete data with relationships
      await loadCiphers();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating cipher: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Handle creating cipher versions and their sections for a new cipher
  Future<void> _createCipherVersionsAndSections(
    int cipherId,
    List<Version> versions,
  ) async {
    for (final version in versions) {
      // Create Version with the correct cipher ID
      final versionWithCipherId = version.copyWith(cipherId: cipherId);
      final newVersionId = await _cipherRepository.insertVersionToCipher(
        versionWithCipherId,
      );

      // Insert content for this map
      for (final section in version.sections!.entries) {
        if (section.key.isNotEmpty) {
          final sectionJson = section.value.toJson();
          await _cipherRepository.insertSection(
            newVersionId,
            sectionJson['content_type'],
            sectionJson['content_code'],
            sectionJson['content_text'],
            sectionJson['color'],
          );
        }
      }
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
      await _cipherRepository.updateCipher(currentCipher!);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error saving cipher: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Update cache with non tag changes
  void cacheCipherUpdates(String field, String change) {
    if (kDebugMode) {
      print('Caching change for field $field: $change');
    }
    if (field == 'title') {
      _currentCipher = currentCipher!.copyWith(title: change);
    } else if (field == 'author') {
      _currentCipher = currentCipher!.copyWith(author: change);
    } else if (field == 'tempo') {
      _currentCipher = currentCipher!.copyWith(tempo: change);
    } else if (field == 'musicKey') {
      _currentCipher = currentCipher!.copyWith(musicKey: change);
    } else if (field == 'language') {
      _currentCipher = currentCipher!.copyWith(language: change);
    }
  }

  // Update cache with tag changes
  void cacheCipherTagUpdates(String tags) {
    List<String> tagList = tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    _currentCipher = currentCipher!.copyWith(tags: tagList);
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
    _currentCipher = null;
    _filteredCiphers.clear();
    _isLoading = false;
    _isSaving = false;
    _error = null;
    _searchTerm = '';
    notifyListeners();
  }

  /// Clear current cipher to create a new cipher
  void clearCurrentCipher() {
    _currentCipher = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
