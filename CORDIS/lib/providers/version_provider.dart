import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/repositories/cloud_cipher_repository.dart';
import 'package:cordis/repositories/local_cipher_repository.dart';
import 'package:flutter/foundation.dart';

class VersionProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();
  final CloudCipherRepository _cloudCipherRepository = CloudCipherRepository();

  VersionProvider();

  int _expandedCipherId = -1;
  List<Version> _versions = [];
  Version _currentVersion = Version.empty();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Getters
  int get expandedCipherId => _expandedCipherId;
  List<Version> get versions => _versions;
  Version get currentVersion => _currentVersion;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  /// Checks if a version exists locally by its Firebase ID
  /// Returns the local id if found, otherwise null
  Future<int?> getLocalIdByFirebaseId(String firebaseId) async {
    for (var v in _versions) {
      if (v.firebaseId == firebaseId) {
        return v.id;
      }
    }
    // Not in cache, query repository
    return await _cipherRepository.getVersionWithFirebaseId(firebaseId);
  }

  Future<String?> getFirebaseIdByLocalId(int localId) async {
    // cipherFirebaseId:versionFirebaseId
    for (var v in _versions) {
      if (v.id == localId) {
        return '${v.firebaseCipherId}:${v.firebaseId}';
      }
    }
    // Not in cache, query repository
    final version = await _cipherRepository.getVersionWithId(localId);
    return '${version?.firebaseCipherId}:${version?.firebaseId}';
  }

  /// ===== CREATE - new version to an existing cipher =====
  Future<int?> createVersion(int cipherId) async {
    if (_isSaving) return null;

    _isSaving = true;
    _error = null;
    notifyListeners();

    int? versionId;
    try {
      // Create version with the correct cipher ID
      final versionWithCipherId = _currentVersion.copyWith(cipherId: cipherId);
      versionId = await _cipherRepository.insertVersionToCipher(
        versionWithCipherId,
      );
      // Load the new ID into the version cache
      _currentVersion = versionWithCipherId.copyWith(id: versionId);

      if (kDebugMode) {
        print('Created a new version with id $versionId, for cipher $cipherId');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating cipher version: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return versionId;
  }

  /// Create version from version domaing object - used when importing from cloud
  Future<int?> creatVersionFromDomain(Version version) async {
    if (_isSaving) return null;

    _isSaving = true;
    _error = null;
    notifyListeners();
    int? versionId;

    try {
      // Create version with the correct cipher ID
      versionId = await _cipherRepository.insertVersionToCipher(version);

      if (kDebugMode) {
        print('Created a new version with id $versionId from domain object');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating cipher version from domain object: $e');
      }
      versionId = null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return versionId;
  }

  /// ===== READ - Load version from versionId =====
  Future<void> loadCurrentVersion(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentVersion = (await _cipherRepository.getVersionWithId(versionId))!;
      if (kDebugMode) {
        print(
          '===== Loaded the version: ${_currentVersion.versionName} into cache =====',
        );
      }
    } catch (e) {
      _error = e.toString();
      _currentVersion = Version.empty();
      if (kDebugMode) {
        print('Error adding cipher version: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all versions of a cipher into cache, used for version selector and cipher expansion
  Future<void> loadVersionsOfCipher(int cipherId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _expandedCipherId = cipherId; // Set the expanded cipher ID immediately
    notifyListeners();

    try {
      _versions = await _cipherRepository.getVersions(cipherId);
      if (kDebugMode) {
        print('Loaded ${_versions.length} versions of cipher $cipherId');
      }
    } catch (e) {
      _error = e.toString();
      _versions = [];
      if (kDebugMode) {
        print('Error loading versions of cipher: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a version into cache by its local ID
  Future<void> loadVersionById(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final version = await _cipherRepository.getVersionWithId(versionId);
      if (version == null) {
        throw Exception('Version with id $versionId not found locally');
      }

      _versions.add(version);
      if (kDebugMode) {
        print('Loaded the version: ${_versions.last.versionName} into cache');
      }
    } catch (e) {
      _error = e.toString();
      _currentVersion = Version.empty();
      if (kDebugMode) {
        print('Error loading cipher version by id: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== UPSERT =====
  /// Upsert a version into local db (add or update)
  Future<void> upsertVersion(Version version) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Check if version exists by its firebaseId
      final existingVersionId = await getLocalIdByFirebaseId(
        version.firebaseId!,
      );

      if (existingVersionId != null) {
        // Update existing version
        await _cipherRepository.updateVersion(
          version.copyWith(id: existingVersionId),
        );
        for (final section in version.sections!.values) {
          await _cipherRepository.updateSection(
            section.copyWith(versionId: existingVersionId),
          );
        }
        if (kDebugMode) {
          print('Updated existing version with id: $existingVersionId');
        }
      } else {
        // Insert new version
        final newVersionId = await _cipherRepository.insertVersionToCipher(
          version,
        );
        for (final section in version.sections!.values) {
          await _cipherRepository.insertSection(
            section.copyWith(versionId: newVersionId),
          );
        }
        if (kDebugMode) {
          print('Inserted new version with id: $newVersionId');
        }
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error upserting cipher version: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== UPDATE - update cipher version =====
  /// Updates a version in the local database (nothing to do with cache)
  Future<void> updateVersion(Version version) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.updateVersion(version);

      // Update cached version if it exists
      final cachedVersionIndex = _versions.indexWhere(
        (v) => v.id == version.id,
      );
      if (cachedVersionIndex != -1) {
        _versions[cachedVersionIndex] = version;
      }

      // Update version on the sqlLite
      await _cipherRepository.updateVersion(version);

      if (kDebugMode) {
        print('Updated version with id: ${version.id}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating cipher version: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Saves a new structure of a version (playlist reordering)
  Future<void> saveUpdatedSongStructure(
    int versionId,
    List<String> songStructure,
  ) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _cipherRepository.updateFieldOfVersion(versionId, {
        'song_structure': songStructure.join(','),
      });

      // Update cached version if it exists
      final cachedVersionIndex = _versions.indexWhere((v) => v.id == versionId);
      if (cachedVersionIndex != -1) {
        _versions[cachedVersionIndex] = _versions[cachedVersionIndex].copyWith(
          songStructure: songStructure,
        );
      }

      if (kDebugMode) {
        print('Updated the songStructure of version: $versionId');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating cipher version song structure: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Cache changes to the version data (Version Name / Transposed Key)
  void cacheUpdatedVersion({String? newVersionName, String? newTransposedKey}) {
    _currentVersion = _currentVersion.copyWith(
      versionName: newVersionName,
      transposedKey: newTransposedKey,
    );
    notifyListeners();
  }

  // Cache a version's song structure =====
  void cacheUpdatedSongStructure(List<String> songStructure) {
    _currentVersion = _currentVersion.copyWith(songStructure: songStructure);
    notifyListeners();
  }

  // Reorder and cache a new structure
  void cacheReorderedStructure(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = currentVersion.songStructure.removeAt(oldIndex);
    currentVersion.songStructure.insert(newIndex, item);
  }

  /// ===== DELETE - cipher version =====
  Future<void> deleteCipherVersion(int versionId) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.deleteVersion(versionId);
      clearCache();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error deleting cipher version: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// ===== SAVE =====
  // Persist the cache to the database
  Future<void> saveVersion() async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.updateVersion(currentVersion);

      // Check if the version exists in the versions list, if so update it
      final index = _versions.indexWhere(
        (version) => version.id == currentVersion.id,
      );
      if (index != -1) {
        _versions[index] = currentVersion;
      }

      if (kDebugMode) {
        print('Saved version with id ${currentVersion.id}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating cipher version: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveVersionInCloud() async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cloudCipherRepository.updateVersionOfCipher(currentVersion);

      if (kDebugMode) {
        print('Saved cloud version with id ${currentVersion.firebaseId}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating cloud cipher version: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// ===== UTILS =====
  // Clear Cache to create a new version
  void clearCache() {
    _currentVersion = Version.empty();
  }

  // Clear current expanded cipher
  void clearVersions() {
    _expandedCipherId = -1;
    _versions = [];
  }

  /// ===== PLAYLIST SUPPORT =====
  // Load versions for playlist using PlaylistItems
  Future<void> loadVersionsForPlaylist(List<PlaylistItem> playlistItems) async {
    if (_isLoading) return;

    // Extract cipher version IDs from playlist items
    final versionIds = playlistItems
        .where((item) => item.isCipherVersion)
        .map((item) => item.contentId)
        .toList();

    if (versionIds.isEmpty) {
      _versions = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _versions = await _cipherRepository.getVersionsByIds(versionIds);
      if (kDebugMode) {
        print('Loaded ${_versions.length} versions for playlist');
      }
    } catch (e) {
      _error = e.toString();
      _versions = [];
      if (kDebugMode) {
        print('Error loading versions for playlist: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentVersion(Version version) {
    _currentVersion = version;
    notifyListeners();
  }

  // Get cached version by ID (returns null if not in cache)
  Version? getCachedVersion(int versionId) {
    for (var version in _versions) {
      if (version.id == versionId) {
        return version;
      }
    }
    return null;
  }

  // Check if a version is already cached
  bool isVersionCached(int versionId) {
    return _versions.any((version) => version.id == versionId);
  }

  /// ===== SONG STRUCTURE =====
  /// ===== CREATE =====
  // Add a new section
  void addSectionToStruct(String contentCode) {
    _currentVersion.songStructure.add(contentCode);
    notifyListeners();
  }

  // ===== UPDATE =====
  /// Update a section code in the song structure
  void updateSectionCodeInStruct({
    required String oldCode,
    required String newCode,
  }) {
    for (int i = 0; i < _currentVersion.songStructure.length; i++) {
      if (_currentVersion.songStructure[i] == oldCode) {
        _currentVersion.songStructure[i] = newCode;
      }
    }
    notifyListeners();
  }

  /// ===== DELETE =====
  // Remove a section from cache
  void removeSectionFromStruct(int index) {
    _currentVersion.songStructure.removeAt(index);
    notifyListeners();
  }

  void removeSectionFromStructByCode(String contentCode) {
    _currentVersion.songStructure.removeWhere((code) => code == contentCode);
    notifyListeners();
  }
}
