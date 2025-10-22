import 'dart:async';
import 'package:cipher_app/models/domain/cipher/version.dart';
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
  bool _isSavingToCloud = false;
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

  List<CipherDto> get cloudCiphers => _cloudCiphers;
  List<CipherDto> get filteredCloudCiphers => _filteredCloudCiphers;
  bool get isLoadingCloud => _isLoadingCloud;
  bool get isSavingToCloud => _isSavingToCloud;

  String? get error => _error;

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
    notifyListeners();
  }

  Future<void> searchCachedCloudCiphers(String term) async {
    _searchTerm = term.toLowerCase();
    _filterCloudCiphers();
    notifyListeners();
  }

  Future<void> searchCloudCiphers(String term) async {
    if (term == '') {
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

      if (queriedCiphers.isEmpty) {
        _error = 'Nenhuma cifra encontrada na nuvem para "$term"';
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
  }

  void _filterCloudCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredCloudCiphers = List.from(cloudCiphers);
    } else {
      _filteredCloudCiphers = cloudCiphers
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
      final cipherId = await _cipherRepository.insertPrunedCipher(
        currentCipher,
      );

      // Load the new ID into the cache
      _currentCipher = _currentCipher.copyWith(id: cipherId);
      updateCurrentCipherInList();
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
  }

  /// Creates a new cipher in the cloud
  Future<void> createCipherInCloud() async {
    if (_isSavingToCloud) return;

    _isSavingToCloud = true;
    _error = null;
    notifyListeners();

    try {
      final firebaseId = await _cloudCipherRepository.publishCipher(
        currentCipher,
      );

      List<Version> updatedVersions = [];
      for (var ver in currentCipher.versions) {
        final version = ver.copyWith(firebaseCipherId: firebaseId);
        await _cloudCipherRepository.createVersionForCipher(version);
        updatedVersions.add(version);
      }
      _currentCipher = _currentCipher.copyWith(
        firebaseId: firebaseId,
        versions: updatedVersions,
      );
      updateCurrentCipherInList();

      if (kDebugMode) {
        print('Created cipher in cloud with ID: $firebaseId');
      }

      await _cipherRepository.updateCipher(_currentCipher);
    } catch (e) {
      _error = 'Creating cipher in cloud: ${e.toString()}';
      if (kDebugMode) {
        print('Error creating cipher in cloud: $e');
      }
    } finally {
      _isSavingToCloud = false;
      notifyListeners();
    }
  }

  /// Downloads cipher from cloud and inserts into local database
  Future<void> downloadFullCipher(CipherDto cipherDTO) async {
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
      final versionDTOs = await _cloudCipherRepository.getVersionsOfCipher(
        cipherDTO.firebaseId!,
      );
      if (versionDTOs.isEmpty) {
        throw Exception('Cipher versions not found in cloud');
      }

      List<Version> versions = [];
      for (var versionDTO in versionDTOs) {
        versions.add(versionDTO.toDomain());
      }

      final cipher = cipherDTO.toDomain(versions);

      final cipherLocalId = await _cipherRepository.insertWholeCipher(cipher);

      // Load the new ID into the cache
      await loadCipher(cipherLocalId);
      updateCurrentCipherInList();
    } catch (e) {
      _error = 'Downloading and inserting cipher: ${e.toString()}';
      if (kDebugMode) {
        print('Error downloading and inserting cipher: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Downloads only cipher metadata from cloud and inserts into local database
  Future<int?> downloadCipherMetadata(String cipherId) async {
    if (_isSaving) {
      _error = 'Já está salvando uma cifra, aguarde...';
      if (kDebugMode) {
        print('Already saving a cipher, aborting download.');
      }
      return null;
    }

    _isSaving = true;
    _error = null;
    int? result;
    notifyListeners();

    try {
      final cipherDto = await _cloudCipherRepository.getCipherById(cipherId);

      result = await _cipherRepository.insertPrunedCipher(
        cipherDto.toDomain([]),
      );

      // Load the new ID into the cache
      await loadCipher(result);
      updateCurrentCipherInList();
      if (kDebugMode) {
        print('Downloaded and inserted cipher metadata with local ID: $result');
      }
    } catch (e) {
      _error = 'Downloading and inserting cipher metadata: ${e.toString()}';
      if (kDebugMode) {
        result = null;
        print('Error downloading and inserting cipher metadata: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return result;
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

  /// Save current cipher changes to cloud
  Future<void> saveCipherInCloud() async {
    if (_isSavingToCloud) return;

    _isSavingToCloud = true;
    _error = null;
    notifyListeners();

    try {
      if (currentCipher.firebaseId == null) {
        throw Exception('Cipher has no firebaseId, cannot update in cloud');
      }
      await _cloudCipherRepository.updatePublicCipher(currentCipher);
      await saveCipher();
    } catch (e) {
      _error = 'Saving cipher to cloud: ${e.toString()}';
      if (kDebugMode) {
        print('Error saving cipher to cloud: $e');
      }
    } finally {
      _isSavingToCloud = false;
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

  /// Identify if the cipher exists in the cloud (return wether the cipher isNew on cloud)
  Future<bool> mergeCipherInCloud() async {
    if (currentCipher.firebaseId == null) {
      if (kDebugMode) {
        print("Cipher doesn't exist in cloud, creating new entry.");
      }
      await createCipherInCloud();
      return true;
    }
    await saveCipherInCloud();
    return false;
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
    return result;
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
