import 'package:cordis/helpers/cloud_versions_cache.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/repositories/cloud_version_repository.dart';
import 'package:cordis/repositories/local_cipher_repository.dart';
import 'package:flutter/foundation.dart';

class VersionProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();
  final CloudVersionRepository _cloudVersionRepository =
      CloudVersionRepository();

  final CloudVersionsCache _cloudCache = CloudVersionsCache();

  VersionProvider() {
    _initializeCloudCache();
  }

  Map<int, Version> _versions = {}; // Cached versions localID -> Version
  Map<String, VersionDto> _cloudVersions =
      {}; // Cached cloud versions firebaseID -> Version
  Map<String, VersionDto> _filteredCloudVersions = {};
  bool _isLoading = false;
  bool _isSaving = false;

  bool _isLoadingCloud = false;
  bool _isSavingCloud = false;
  DateTime? _lastCloudLoad;

  String _searchTerm = '';

  String? _error;

  // Getters
  Map<dynamic, Version> get versions => _versions;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Map<String, VersionDto> get cloudVersions => _cloudVersions;
  Map<String, VersionDto> get filteredCloudVersions => _filteredCloudVersions;
  bool get isLoadingCloud => _isLoadingCloud;
  bool get isSavingCloud => _isSavingCloud;

  String? get error => _error;

  List<String> getSongStructure(dynamic versionKey) =>
      versions[versionKey]?.songStructure ?? [];

  /// Checks if a version exists locally by its Firebase ID
  /// Returns the local id if found, otherwise null
  Future<int?> getLocalIdByFirebaseId(String firebaseId) async {
    for (var v in _versions.values) {
      if (v.firebaseId == firebaseId && v.id != null) {
        return v.id;
      }
    }
    // Not in cache, query repository
    final version = await _cipherRepository.getVersionWithFirebaseId(
      firebaseId,
    );

    return version?.id;
  }

  Future<String?> getFirebaseIdByLocalId(int localId) async {
    final id = _versions[localId]?.firebaseId;
    if (id != null) {
      return id;
    }
    // Not in cache, query repository
    final version = await _cipherRepository.getVersionWithId(localId);
    return version?.firebaseId;
  }

  // ===== CREATE =====
  /// Creates a new version to an existing cipher =====
  Future<int?> createVersion(int cipherId) async {
    if (_isSaving) return null;

    _isSaving = true;
    _error = null;
    notifyListeners();

    int? versionId;
    try {
      if (!_versions.containsKey(-1)) {
        throw Exception('No version cached to create a new version from.');
      }
      // Create version with the correct cipher ID
      final versionWithCipherId = _versions[-1]!.copyWith(cipherId: cipherId);

      versionId = await _cipherRepository.insertVersion(versionWithCipherId);

      _versions[versionId] = versionWithCipherId.copyWith(id: versionId);

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

  void setNewVersionInCache(Version version) {
    _versions[-1] = version;
    notifyListeners();
  }

  /// ===== READ - Load version from versionId =====
  Future<void> loadCurrentVersion(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _versions[versionId] = (await _cipherRepository.getVersionWithId(
        versionId,
      ))!;
      if (kDebugMode) {
        print(
          '===== Loaded the version: ${_versions[versionId]?.versionName} into cache =====',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error adding cipher version: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load public versions from Firestore
  Future<void> loadCloudVersions({bool forceReload = false}) async {
    final now = DateTime.now();
    if (_lastCloudLoad != null &&
        now.difference(_lastCloudLoad!).inDays < 7 &&
        _versions.keys.any((key) => key is String) &&
        !forceReload) {
      return;
    }
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      final cloudVersions = await _cloudVersionRepository.getPublicVersions();

      for (final version in cloudVersions) {
        _cloudVersions[version.firebaseId!] = version;
      }

      await _cloudCache.saveCloudVersions(cloudVersions);
      await _cloudCache.saveLastCloudLoad(now);
      _filterCloudVersions();

      if (kDebugMode) {
        print(
          'LOADED ${cloudVersions.length} PUBLIC CIPHERS FROM FIRESTORE - $_lastCloudLoad',
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

  // Load all versions of a cipher into cache, used for version selector and cipher expansion
  Future<void> loadVersionsOfCipher(int cipherId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final versionList = await _cipherRepository.getVersions(cipherId);
      for (final version in versionList) {
        _versions[version.id!] = version;
      }
      if (kDebugMode) {
        print('Loaded ${_versions.length} versions of cipher $cipherId');
      }
    } catch (e) {
      _error = e.toString();
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

      _versions[versionId] = version;
      if (kDebugMode) {
        print(
          'Loaded the version: ${_versions[versionId]?.versionName} into cache',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading cipher version by id: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search cached cloud versions
  Future<void> searchCachedCloudVersions(String term) async {
    _searchTerm = term.toLowerCase();
    _filterCloudVersions();
    notifyListeners();
  }

  void _filterCloudVersions() {
    if (_searchTerm.isEmpty) {
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
        final newVersionId = await _cipherRepository.insertVersion(version);
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
      loadVersionById(version.id!);

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
      _versions[versionId] = _versions[versionId]!.copyWith(
        songStructure: songStructure,
      );

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
  void cacheUpdatedVersion(
    dynamic versionId, {
    String? newVersionName,
    String? newTransposedKey,
  }) {
    if (versionId is int) {
      if (newVersionName != null) {
        _versions[versionId] = _versions[versionId]!.copyWith(
          versionName: newVersionName,
        );
      }
      if (newTransposedKey != null) {
        _versions[versionId] = _versions[versionId]!.copyWith(
          transposedKey: newTransposedKey,
        );
      }
    } else {
      if (newVersionName != null) {
        _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
          versionName: newVersionName,
        );
      }
      if (newTransposedKey != null) {
        _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
          transposedKey: newTransposedKey,
        );
      }
    }
    notifyListeners();
  }

  // Cache a version's song structure =====
  void cacheUpdatedSongStructure(
    dynamic versionId,
    List<String> songStructure,
  ) {
    if (versionId is int) {
      _versions[versionId] = _versions[versionId]!.copyWith(
        songStructure: songStructure,
      );
      notifyListeners();
      return;
    } else {
      _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
        songStructure: songStructure.join(','),
      );
      notifyListeners();
      return;
    }
  }

  // Reorder and cache a new structure
  void cacheReorderedStructure(dynamic versionId, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;

    if (versionId is int) {
      final item = _versions[versionId]!.songStructure.removeAt(oldIndex);
      _versions[versionId]!.songStructure.insert(newIndex, item);
      notifyListeners();
      return;
    } else {
      final item = _cloudVersions[versionId]!.songStructure
          .split(',')
          .removeAt(oldIndex);
      final structure = _cloudVersions[versionId]!.songStructure.split(',');
      structure.insert(newIndex, item);
      _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
        songStructure: structure.join(','),
      );
      notifyListeners();
      return;
    }
  }

  /// ===== DELETE - cipher version =====
  Future<void> deleteCipherVersion(int versionId) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.deleteVersion(versionId);
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
  Future<void> saveVersion({dynamic versionId}) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (versionId == null) {
        throw Exception(
          'No versionId provided to save the version, create the version first.',
        );
      }

      if (versionId is int) {
        await _cipherRepository.updateVersion(_versions[versionId]!);
      } else {
        // Cloud version saving not implemented
        throw Exception('Saving cloud versions is not supported yet.');
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
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _versions = Map.fromEntries(
        (await _cipherRepository.getVersionsByIds(
          versionIds,
        )).map((version) => MapEntry(version.id!, version)),
      );
      if (kDebugMode) {
        print('Loaded ${_versions.length} versions for playlist');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading versions for playlist: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get cached version by ID (returns null if not in cache)
  Version? getVersionById(int versionId) {
    return _versions[versionId];
  }

  // Check if a version is already cached
  bool isVersionCached(int versionId) {
    return _versions.containsKey(versionId);
  }

  /// ===== SONG STRUCTURE =====
  /// ===== CREATE =====
  // Add a new section
  void addSectionToStruct(dynamic versionId, String contentCode) {
    if (versionId is int) {
      _versions[versionId]!.songStructure.add(contentCode);
      notifyListeners();
      return;
    } else {
      _cloudVersions[versionId]!.songStructure.split(',').add(contentCode);
      notifyListeners();
      return;
    }
  }

  // ===== UPDATE =====
  /// Update a section code in the song structure
  void updateSectionCodeInStruct(
    dynamic versionId, {
    required String oldCode,
    required String newCode,
  }) {
    if (versionId is int) {
      for (int i = 0; i < _versions[versionId]!.songStructure.length; i++) {
        if (_versions[versionId]!.songStructure[i] == oldCode) {
          _versions[versionId]!.songStructure[i] = newCode;
        }
      }
    } else {
      List<String> structure = _cloudVersions[versionId]!.songStructure.split(
        ',',
      );
      String newStructure = '';
      for (int i = 0; i < structure.length; i++) {
        if (structure[i] == oldCode) {
          newStructure += newCode;
        } else {
          newStructure += structure[i];
        }
        if (i < structure.length - 1) {
          newStructure += ',';
        }
      }
      _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
        songStructure: newStructure,
      );
      return;
    }

    notifyListeners();
  }

  /// ===== DELETE =====
  // Remove a section from cache
  void removeSectionFromStruct(dynamic versionId, int index) {
    if (versionId is int) {
      _versions[versionId]!.songStructure.removeAt(index);
    } else {
      List<String> structure = _cloudVersions[versionId]!.songStructure.split(
        ',',
      );
      structure.removeAt(index);
      _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
        songStructure: structure.join(','),
      );
    }
    notifyListeners();
  }

  void removeSectionFromStructByCode(dynamic versionId, String contentCode) {
    if (versionId is int) {
      _versions[versionId]!.songStructure.removeWhere(
        (code) => code == contentCode,
      );
    } else {
      List<String> structure = _cloudVersions[versionId]!.songStructure.split(
        ',',
      );
      structure.removeWhere((code) => code == contentCode);
      _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
        songStructure: structure.join(','),
      );
    }
    notifyListeners();
  }

  Future<void> _initializeCloudCache() async {
    _lastCloudLoad = await _cloudCache.loadLastCloudLoad();
    _cloudVersions = Map.fromEntries(
      (await _cloudCache.loadCloudVersions()).map(
        (version) => MapEntry(version.firebaseId!, version),
      ),
    );
    _filterCloudVersions();
    notifyListeners();
  }

  void clearCache() {
    _versions.clear();
    _cloudVersions.clear();
    _filteredCloudVersions.clear();
    notifyListeners();
  }
}
