import 'dart:async';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:cordis/helpers/cloud_versions_cache.dart';
import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/repositories/cloud_version_repository.dart';
import 'package:cordis/repositories/local_cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();
  final CloudVersionRepository _cloudVersionRepository =
      CloudVersionRepository();

  final CloudVersionsCache _cloudCache = CloudVersionsCache();

  CipherProvider() {
    _initializeCloudCache();
    clearSearch();
  }

  Future<void> _initializeCloudCache() async {
    _lastCloudLoad = await _cloudCache.loadLastCloudLoad();
    _cloudVersions = await _cloudCache.loadCloudVersions();
    _filterCloudCiphers();
    notifyListeners();
  }

  List<Cipher> _localCiphers = [];
  List<VersionDto> _cloudVersions = [];
  List<Cipher> _filteredLocalCiphers = [];
  List<VersionDto> _filteredCloudVersions = [];
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
  List<Cipher> get localCiphers => _localCiphers;
  List<Cipher> get filteredLocalCiphers => _filteredLocalCiphers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoadedCiphers => _hasLoadedCiphers;

  List<VersionDto> get cloudVersions => _cloudVersions;
  List<VersionDto> get filteredCloudVersions => _filteredCloudVersions;
  bool get isLoadingCloud => _isLoadingCloud;

  String? get error => _error;

  int? getCachedCipherIdByTitle(String title) {
    return _localCiphers
        .firstWhere(
          (cipher) => cipher.title == title,
          orElse: () => Cipher.empty(),
        )
        .id;
  }

  /// ===== READ =====
  // Load all ciphers (local and cloud)
  Future<void> loadCiphers({bool forceReload = false}) async {
    await loadLocalCiphers(forceReload: forceReload);
    await loadCloudCiphers(forceReload: forceReload);
  }

  // Load ciphers from local SQLite
  Future<void> loadLocalCiphers({bool forceReload = false}) async {
    if (_hasLoadedCiphers && !forceReload) return;
    if (_isLoading) return;
    // Debounce rapid calls
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(milliseconds: 300), () async {
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
    });
  }

  // Load popular ciphers from cloud Firestore
  Future<void> loadCloudCiphers({bool forceReload = false}) async {
    final now = DateTime.now();
    if (_lastCloudLoad != null &&
        now.difference(_lastCloudLoad!).inDays < 7 &&
        _cloudVersions.isNotEmpty &&
        !forceReload) {
      return;
    }
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      _cloudVersions = await _cloudVersionRepository.getPublicVersions();
      _lastCloudLoad = now;
      await _cloudCache.saveCloudVersions(_cloudVersions);
      await _cloudCache.saveLastCloudLoad(now);
      _filterCloudCiphers();

      if (kDebugMode) {
        print(
          'LOADED ${_cloudVersions.length} PUBLIC CIPHERS FROM FIRESTORE - $_lastCloudLoad',
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
    notifyListeners();
  }

  Future<void> searchCachedCloudCiphers(String term) async {
    _searchTerm = term.toLowerCase();
    _filterCloudCiphers();
    notifyListeners();
  }

  void _filterCiphers() {
    _filterCloudCiphers();
    _filterLocalCiphers();
  }

  void _filterCloudCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredCloudVersions = List.from(cloudVersions);
    } else {
      _filteredCloudVersions = cloudVersions
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
    _filteredCloudVersions = List.from(cloudVersions);
    _filteredLocalCiphers = List.from(localCiphers);
  }

  /// ===== CREATE =====
  Future<int?> createCipher() async {
    if (_isSaving) return null;

    _isSaving = true;
    _error = null;
    notifyListeners();
    int? cipherId;

    try {
      // Insert basic cipher info and tags
      cipherId = await _cipherRepository.insertPrunedCipher(currentCipher);

      // Load the new ID into the cache
      _currentCipher = _currentCipher.copyWith(id: cipherId);
      updateCurrentCipherInList();
      if (kDebugMode) {
        print('Created a new cipher with id $cipherId');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating cipher: $e');
      }
    } finally {
      _isSaving = false;
      // Reload from database to ensure UI reflects all changes
      await loadLocalCiphers(forceReload: true);
      notifyListeners();
    }
    return cipherId;
  }

  // ===== UPSERT =====
  /// Upsert a cipher into the database used when syncing a playlist
  /// Returns the local cipher ID
  Future<void> upsertCipher(Cipher cipher) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Check if cipher exists on the cache
      final existingId = _localCiphers
          .firstWhere(
            (cachedCipher) =>
                (cachedCipher.title == cipher.title &&
                cachedCipher.author == cipher.author),
            orElse: () => Cipher.empty(),
          )
          .id;

      int cipherId;
      if (existingId != null) {
        await _cipherRepository.updateCipher(cipher.copyWith(id: existingId));
        cipherId = existingId;
      } else {
        cipherId = await _cipherRepository.insertPrunedCipher(cipher);
      }

      if (kDebugMode) {
        print(
          'Upserted cipher with Title ${cipher.title} - Existing Cipher ID: $existingId',
        );
      }

      // Load the upserted cipher into the cache
      await loadCipher(cipherId);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error upserting cipher: $e');
      }
    } finally {
      _isSaving = false;
      // Reload manually to ensure UI reflects all changes
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
      // Reload manually to ensure UI reflects all changes
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
      // Reload manually to ensure UI reflects all changes
      _localCiphers.removeWhere((c) => c.id == cipherID);
      notifyListeners();
    }
  }

  /// ===== UTILS =====
  /// Clear cached data and reset state for debugging
  void clearCache() {
    _localCiphers.clear();
    _cloudVersions.clear();
    _currentCipher = Cipher.empty();
    _filteredCloudVersions.clear();
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
    for (var cipher in _localCiphers) {
      if (cipher.id == cipherId) {
        return cipher;
      }
    }
    return null;
  }

  // Check if a cipher is already cached
  bool cipherIsCached(int cipherId) {
    return (localCiphers).any((cipher) => cipher.id == cipherId);
  }

  Future<int?> cipherWithFirebaseIdIsCached(String firebaseId) async {
    final result = await _cipherRepository.getCipherWithFirebaseId(firebaseId);

    if (kDebugMode) {
      print(
        'Checking if cipher with Firebase ID $firebaseId is cached: '
        '${result != null ? "Found" : "Not Found"}',
      );
    }
    if (result == null) {
      return null;
    }

    return result.id;
  }

  void setCurrentCipher(Cipher cipher) {
    _currentCipher = cipher;
    notifyListeners();
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
