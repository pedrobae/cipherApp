import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:cipher_app/helpers/cloud_cipher_cache.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/repositories/cloud_cipher_repository.dart';
import 'package:cipher_app/repositories/local_cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();
  final CloudCipherRepository _cloudCipherRepository = CloudCipherRepository();

  final CloudCipherCache _cloudCache = CloudCipherCache();

  CipherProvider() {
    _initializeCloudCache();
    clearSearch();
  }

  Future<void> _initializeCloudCache() async {
    _lastCloudLoad = await _cloudCache.loadLastCloudLoad();
    _cloudCiphers = await _cloudCache.loadCloudCiphers();
    _filterCloudCiphers();
    notifyListeners();
  }

  List<Cipher> _localCiphers = [];
  List<CipherDto> _cloudCiphers = [];
  List<Cipher> _filteredLocalCiphers = [];
  List<CipherDto> _filteredCloudCiphers = [];
  Cipher _currentCipher = Cipher.empty();
  bool _isLoading = false;
  bool _isLoadingCloud = false;
  bool _isSaving = false;
  String? _error;
  String _searchTerm = '';
  bool _hasLoadedCiphers = false;
  DateTime? _lastCloudLoad;

  // Add debouncing for rapid calls
  Timer? _loadTimer;

  // Getters
  Cipher get currentCipher => _currentCipher;
  List<Cipher> get filteredLocalCiphers => _filteredLocalCiphers;
  List<CipherDto> get filteredCloudCiphers => _filteredCloudCiphers;
  List<Cipher> get localCiphers => _localCiphers;
  List<CipherDto> get cloudCiphers => _cloudCiphers;
  bool get isLoading => _isLoading;
  bool get isLoadingCloud => _isLoadingCloud;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get hasLoadedCiphers => _hasLoadedCiphers;

  /// ===== READ =====
  // Load all ciphers (local and cloud)
  Future<void> loadCiphers({bool forceReload = false}) async {
    // Debounce rapid calls
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(milliseconds: 300), () async {
      await loadLocalCiphers();
      await loadCloudCiphers();
    });
  }

  // Load ciphers from local SQLite
  Future<void> loadLocalCiphers({bool forceReload = false}) async {
    if (_hasLoadedCiphers && !forceReload) return;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _localCiphers = await _cipherRepository.getAllCiphersPruned();
      _filterLocalCiphers();

      _hasLoadedCiphers = true;

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
  Future<void> loadCloudCiphers({bool forceReload = false}) async {
    final now = DateTime.now();
    if (_lastCloudLoad != null &&
        now.difference(_lastCloudLoad!).inHours < 24 &&
        _cloudCiphers.isNotEmpty &&
        !forceReload) {
      return;
    }
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      _cloudCiphers = await _cloudCipherRepository.getPopularCiphers();
      _lastCloudLoad = now;
      await _cloudCache.saveCloudCiphers(_cloudCiphers);
      await _cloudCache.saveLastCloudLoad(now);
      _filterCloudCiphers();

      if (kDebugMode) {
        print(
          'LOADED ${_cloudCiphers.length} POPULAR CIPHERS FROM FIRESTORE - $_lastCloudLoad',
        );
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

  /// Load single cipher by ID into cache (_current_cipher)
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
  Future<void> searchLocalCiphers(String term) async {
    _searchTerm = term.toLowerCase();
    _filterLocalCiphers();
  }

  Future<void> searchCloudCiphers(String term) async {
    if (term.isEmpty) {
      _filteredCloudCiphers = List.from(cloudCiphers);
      notifyListeners();
      return;
    }

    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      final queriedCiphers =
          (await _cloudCipherRepository.searchCiphers(term)) ?? [];

      for (var cipher in queriedCiphers) {
        if (!_cloudCiphers.any((c) => c.firebaseId == cipher.firebaseId)) {
          _cloudCiphers.add(cipher);
        }
      }
      _filterCloudCiphers();

      if (kDebugMode) {
        print('QUERIED CLOUD CIPHERS FOR "$term" - ${queriedCiphers.length}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error searching cloud ciphers: $e');
      }
    } finally {
      _isLoadingCloud = false;
      notifyListeners();
    }
  }

  void _filterCiphers() {
    _filterCloudCiphers();
    _filterLocalCiphers();
    notifyListeners();
  }

  void _filterCloudCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredCloudCiphers = List.from(cloudCiphers);
    } else {
      _filteredCloudCiphers = cloudCiphers
          .where(
            (cipher) =>
                cipher.searchTerm.toLowerCase().contains(_searchTerm) ||
                cipher.author.toLowerCase().contains(_searchTerm) ||
                cipher.tags.any(
                  (tag) => tag.toLowerCase().contains(_searchTerm),
                ),
          )
          .toList();
    }
  }

  void _filterLocalCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredLocalCiphers = List.from(localCiphers);
    } else {
      _filteredLocalCiphers = localCiphers
          .where(
            (cipher) =>
                cipher.title.toLowerCase().contains(_searchTerm) ||
                cipher.author.toLowerCase().contains(_searchTerm) ||
                cipher.tags.any(
                  (tag) => tag.toLowerCase().contains(_searchTerm),
                ),
          )
          .toList()
          .cast<Cipher>();
    }
  }

  void clearSearch() {
    _searchTerm = '';
    _filteredCloudCiphers = List.from(cloudCiphers);
    _filteredLocalCiphers = List.from(localCiphers);
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

  /// Downloads cipher from cloud and inserts into local database
  Future<void> downloadAndInsertCipher(String cipherFirebaseId) async {
    if (_isSaving) {
      _error = 'Já está salvando uma cifra, aguarde...';
      if (kDebugMode) {
        print('Already saving a cipher, aborting download.');
      }
      return;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final cipher = await _cloudCipherRepository.downloadCompleteCipher(
        cipherFirebaseId,
      );
      if (cipher == null) {
        throw Exception('Cipher not found in cloud');
      }

      final cipherId = await _cipherRepository.insertWholeCipher(cipher);

      // Load the new ID into the current cipher cache
      loadCipher(cipherId);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error downloading and inserting cipher: $e');
      }
    } finally {
      _isSaving = false;
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
    _filteredCloudCiphers.clear();
    _filteredLocalCiphers.clear();
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
