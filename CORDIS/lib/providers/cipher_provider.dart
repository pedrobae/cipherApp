import 'dart:async';
import 'package:cordis/widgets/ciphers/editor/info_tab.dart';
import 'package:flutter/foundation.dart';
import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/repositories/local_cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();

  CipherProvider() {
    clearSearch();
  }

  Map<int, Cipher> _localCiphers = {};
  Map<int, Cipher> _filteredLocalCiphers = {};
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String _searchTerm = '';
  bool _hasLoadedCiphers = false;

  // Getters
  Map<int, Cipher> get localCiphers => _localCiphers;
  Map<int, Cipher> get filteredLocalCiphers => _filteredLocalCiphers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoadedCiphers => _hasLoadedCiphers;

  String? get error => _error;

  int get localCipherCount {
    if (_localCiphers[-1] != null) {
      return _localCiphers.length - 1;
    }
    return _localCiphers.length;
  }

  int get filteredLocalCipherCount {
    if (_filteredLocalCiphers[-1] != null) {
      return _filteredLocalCiphers.length - 1;
    }
    return _filteredLocalCiphers.length;
  }

  int? getLocalCipherIdByTitle(String title) {
    return _localCiphers.values
        .firstWhere(
          (cipher) => cipher.title == title,
          orElse: () => Cipher.empty(),
        )
        .id;
  }

  // ===== READ =====
  /// Load ciphers from local SQLite
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
          (cipher) => MapEntry(cipher.id, cipher),
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

  /// Load single cipher into cache by Version Id
  Future<void> loadCipherOfVersion(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cipher = (await _cipherRepository.getCipherWithVersionId(
        versionId,
      ))!;
      _localCiphers[cipher.id] = cipher;
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

  /// Search functionality
  Future<void> searchLocalCiphers(String term) async {
    _searchTerm = term.toLowerCase();
    _filterLocalCiphers();
    notifyListeners();
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
    notifyListeners();
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
      if (existingId != -1) {
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

  // ===== UPDATE =====
  /// Save current cipher changes to database
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

  /// Update cache with non tag changes
  void cacheCipherUpdates(int cipherId, InfoField field, String change) {
    if (kDebugMode) {
      print('Caching change for field $field: $change');
    }
    switch (field) {
      case InfoField.title:
        _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
          title: change,
        );
        break;
      case InfoField.author:
        _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
          author: change,
        );
        break;
      case InfoField.bpm:
        _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
          bpm: change,
        );
        break;
      case InfoField.musicKey:
        _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
          musicKey: change,
        );
        break;
      case InfoField.versionName:
        // Version name is not stored in Cipher, so no action here
        break;
      case InfoField.language:
        _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
          language: change,
        );
        break;
      case InfoField.duration:
        _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(
          duration: change,
        );
        break;
    }
    notifyListeners();
  }

  /// Update cache with tag changes
  void cacheCipherTagUpdates(int cipherId, String tags) {
    List<String> tagList = tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    _localCiphers[cipherId] = _localCiphers[cipherId]!.copyWith(tags: tagList);
  }

  // ===== DELETE =====
  /// Delete a cipher from the database
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

  // ===== UTILS =====
  /// Clear cached data and reset state for debugging
  void clearCache() {
    _localCiphers.clear();
    _filteredLocalCiphers.clear();
    _isLoading = false;
    _isSaving = false;
    _error = null;
    _searchTerm = '';
    notifyListeners();
  }

  // ===== CIPHER CACHING =====
  /// Get cipher from cache
  Cipher? getCipherById(int cipherId) {
    return _localCiphers[cipherId];
  }

  /// Check if a cipher is already cached
  bool cipherIsCached(int cipherId) {
    return _localCiphers.containsKey(cipherId);
  }

  /// Check if a cipher with given Firebase ID is cached
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
}
