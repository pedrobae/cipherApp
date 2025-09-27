import 'dart:async';
import 'package:cipher_app/repositories/cloud_cipher_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/repositories/local_cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();
  final CloudCipherRepository _cloudCipherRepository = CloudCipherRepository();

  CipherProvider();

  List<Cipher> _localCiphers = [];
  List<Cipher> _cloudCiphers = [];
  List<Cipher> _filteredCiphers = [];
  Cipher _currentCipher = Cipher.empty();
  bool _isLoading = false;
  bool _isLoadingCloud = false;
  bool _isSaving = false;
  String? _error;
  String _searchTerm = '';
  bool _useMemoryFiltering = true;
  bool _hasLoadedCiphers = false;

  // Add debouncing for rapid calls
  Timer? _loadTimer;

  // Getters
  Cipher get currentCipher => _currentCipher;
  List<Cipher> get filteredCiphers => _filteredCiphers;
  List<Cipher> get localCiphers => _localCiphers;
  List<Cipher> get cloudCiphers => _cloudCiphers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get useMemoryFiltering => _useMemoryFiltering;
  bool get hasLoadedCiphers => _hasLoadedCiphers;

  /// ===== READ =====
  // Load all ciphers (local and cloud)
  Future<void> loadCiphers({bool forceReload = false}) async {
    if (_hasLoadedCiphers && !forceReload) return;

    // Debounce rapid calls
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(milliseconds: 300), () async {
      await _loadLocalCiphers();
      await loadCloudCiphers();
    });
    _hasLoadedCiphers = true;
  }

  // Load ciphers from local SQLite
  Future<void> _loadLocalCiphers() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _useMemoryFiltering = true;
      _localCiphers = await _cipherRepository.getAllCiphersPruned();
      _filterCiphers();

      if (kDebugMode) {
        print('Loaded ${_localCiphers.length} ciphers from SQLite');
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

  // Load popular ciphers from cloud Firestore
  Future<void> loadCloudCiphers() async {
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      _cloudCiphers = await _cloudCipherRepository.getPopularCiphers();
      _filterCiphers();

      if (kDebugMode) {
        print('Loaded ${_cloudCiphers.length} popular ciphers from Firestore');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading cloud ciphers: $e');
      }
    } finally {
      _isLoadingCloud = false;
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
      _filteredCiphers = cloudCiphers + localCiphers;
    } else {
      _filteredCiphers = (cloudCiphers + localCiphers)
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
    _filteredCiphers = List.from(cloudCiphers + localCiphers);
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
      _localCiphers.removeWhere((c) => c.id == cipherID);
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
    _localCiphers.clear();
    _cloudCiphers.clear();
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

    int index = _localCiphers.indexWhere((c) => c.id == _currentCipher.id);
    if (index != -1) {
      _localCiphers[index] = _currentCipher;
    } else {
      _localCiphers.add(_currentCipher);
    }
    _filterCiphers();
  }

  /// ===== CIPHER CACHING =====
  // Get cached cipher by ID (returns null if not in cache)
  Cipher? getCachedCipher(int cipherId) {
    try {
      return _localCiphers.firstWhere((cipher) => cipher.id == cipherId);
    } catch (e) {
      return null;
    }
  }

  // Check if a cipher is already cached
  bool isCipherCached(int cipherId) {
    return (localCiphers).any((cipher) => cipher.id == cipherId);
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
