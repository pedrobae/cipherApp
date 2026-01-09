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
    _cloudVersions = Map.fromEntries(
      (await _cloudCache.loadCloudVersions()).map(
        (version) => MapEntry(version.firebaseId!, version),
      ),
    );
    _filterCloudCiphers();
    notifyListeners();
  }

  Map<int, Cipher> _localCiphers = {};
  Map<int, Cipher> _filteredLocalCiphers = {};

  Map<String, VersionDto> _cloudVersions = {};
  Map<String, VersionDto> _filteredCloudVersions = {};
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
  Map<int, Cipher> get localCiphers => _localCiphers;
  Map<int, Cipher> get filteredLocalCiphers => _filteredLocalCiphers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoadedCiphers => _hasLoadedCiphers;

  Map<String, VersionDto> get cloudVersions => _cloudVersions;
  Map<String, VersionDto> get filteredCloudVersions => _filteredCloudVersions;
  bool get isLoadingCloud => _isLoadingCloud;

  String? get error => _error;

  int? getLocalCipherIdByTitle(String title) {
    return _localCiphers.values
        .firstWhere(
          (cipher) => cipher.title == title,
          orElse: () => Cipher.empty(),
        )
        .id;
  }

  VersionDto? getCloudVersionByFirebaseId(String firebaseId) {
    return _cloudVersions[firebaseId];
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _localCiphers = Map.fromEntries(
        (await _cipherRepository.getAllCiphersPruned()).map(
          (cipher) => MapEntry(cipher.id!, cipher),
        ),
      );
      _filterLocalCiphers();

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
      _hasLoadedCiphers = true;
      notifyListeners();
    }
  }

  // Load public versions from Firestore
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
      _cloudVersions = Map.fromEntries(
        (await _cloudVersionRepository.getPublicVersions()).map(
          (version) => MapEntry(version.firebaseId!, version),
        ),
      );
      _lastCloudLoad = now;
      await _cloudCache.saveCloudVersions(
        _cloudVersions.values.map((v) => v).toList(),
      );
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
      _localCiphers[cipherId] = (await _cipherRepository.getCipherById(
        cipherId,
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

  // Load single cipher into cache by Version Id
  Future<void> loadCipherOfVersion(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cipher = (await _cipherRepository.getCipherWithVersionId(
        versionId,
      ))!;
      _localCiphers[cipher.id!] = cipher;
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

  void _filterCloudCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredCloudVersions = _cloudVersions;
    } else {
      _filteredCloudVersions = Map.fromEntries(
        _cloudVersions.entries
            .where(
              (e) =>
                  e.value.title.toLowerCase().contains(_searchTerm) ||
                  e.value.author.toLowerCase().contains(_searchTerm) ||
                  e.value.tags.any(
                    (tag) => tag.toLowerCase().contains(_searchTerm),
                  ),
            )
            .toList(),
      );
    }
  }

  void _filterLocalCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredLocalCiphers = _localCiphers;
    } else {
      _filteredLocalCiphers = Map.fromEntries(
        _localCiphers.entries
            .where(
              (e) =>
                  e.value.title.toLowerCase().contains(_searchTerm) ||
                  e.value.author.toLowerCase().contains(_searchTerm) ||
                  e.value.tags.any(
                    (tag) => tag.toLowerCase().contains(_searchTerm),
                  ),
            )
            .toList(),
      );
    }
  }

  void clearSearch() {
    _searchTerm = '';
    _filteredCloudVersions = _cloudVersions;
    _filteredLocalCiphers = _localCiphers;
  }

  /// ===== CREATE =====
  Future<int?> createCipher() async {
    if (_isSaving) return null;
    if (_localCiphers[-1] == null) {
      if (kDebugMode) {
        print('No new cipher to create in local cache');
      }
      return null;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();
    int? cipherId;

    try {
      // Insert basic cipher info and tags
      cipherId = await _cipherRepository.insertPrunedCipher(_localCiphers[-1]!);

      // Load the new ID into the cache
      _localCiphers[cipherId] = _localCiphers[-1]!.copyWith(id: cipherId);
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

  void setNewCipherInCache(Cipher cipher) {
    _localCiphers[-1] = cipher;
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
      final existingId = _localCiphers.values
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
      notifyListeners();
    }
  }

  /// ===== UPDATE =====
  // Save current cipher changes to database
  Future<void> saveCipher(int cipherId) async {
    if (_isSaving) return;
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Update basic cipher info and tags
      await _cipherRepository.updateCipher(_localCiphers[cipherId]!);
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
  void cacheCipherUpdates(int cipherId, String field, String change) {
    if (kDebugMode) {
      print('Caching change for field $field: $change');
    }
    if (field == 'title') {
      _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
        title: change,
      );
    } else if (field == 'author') {
      _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
        author: change,
      );
    } else if (field == 'tempo') {
      _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
        tempo: change,
      );
    } else if (field == 'musicKey') {
      _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
        musicKey: change,
      );
    } else if (field == 'language') {
      _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
        language: change,
      );
    }
  }

  // Update cache with tag changes
  void cacheCipherTagUpdates(int cipherId, String tags) {
    List<String> tagList = tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(tags: tagList);
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
      _localCiphers.remove(cipherID);
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
    _cloudVersions.clear();
    _filteredCloudVersions.clear();
    _filteredLocalCiphers.clear();
    _isLoading = false;
    _isSaving = false;
    _error = null;
    _searchTerm = '';
    notifyListeners();
  }

  /// ===== CIPHER CACHING =====
  Cipher? getCipherFromCache(int cipherId) {
    return _localCiphers[cipherId];
  }

  // Check if a cipher is already cached
  bool cipherIsCached(int cipherId) {
    return _localCiphers.containsKey(cipherId);
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

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
