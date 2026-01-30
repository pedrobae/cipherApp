import 'package:cordis/helpers/cloud_versions_cache.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/repositories/cloud_version_repository.dart';
import 'package:cordis/repositories/local_cipher_repository.dart';
import 'package:cordis/widgets/ciphers/editor/metadata_tab.dart';
import 'package:flutter/foundation.dart';

class VersionProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();
  final CloudVersionRepository _cloudVersionRepository =
      CloudVersionRepository();

  final CloudVersionsCache _cloudCache = CloudVersionsCache();

  VersionProvider() {
    _initializeCloudCache();
  }

  Map<int, Version> _localVersions = {}; // Cached versions localID -> Version
  Map<String, VersionDto> _cloudVersions =
      {}; // Cached cloud versions firebaseID -> Version
  bool _isLoading = false;
  bool _isSaving = false;

  bool _isLoadingCloud = false;
  DateTime? _lastCloudLoad;

  String _searchTerm = '';

  String? _error;

  // Getters
  Map<int, Version> get localVersions => _localVersions;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Map<String, VersionDto> get cloudVersions => _cloudVersions;
  List<String> get filteredCloudVersions {
    if (_searchTerm.isEmpty) {
      return _cloudVersions.keys.toList();
    } else {
      final List<String> tempList = [];
      for (var entry in _cloudVersions.entries) {
        if (entry.value.title.toLowerCase().contains(_searchTerm) ||
            entry.value.author.toLowerCase().contains(_searchTerm) ||
            entry.value.tags.any(
              (tag) => tag.toLowerCase().contains(_searchTerm),
            )) {
          tempList.add(entry.key);
        }
      }
      return tempList;
    }
  }

  bool get isLoadingCloud => _isLoadingCloud;

  String? get error => _error;

  int get localVersionCount {
    if (_localVersions[-1] != null) {
      return _localVersions.length - 1;
    }
    return _localVersions.length;
  }

  List<String> getSongStructure(dynamic versionKey) => versionKey is int
      ? _localVersions[versionKey]?.songStructure ?? []
      : _cloudVersions[versionKey]?.songStructure ?? [];

  /// Checks if a version exists locally by its Firebase ID
  /// Returns the local id if found, otherwise null
  Future<int?> getLocalIdByFirebaseId(String firebaseId) async {
    for (var v in _localVersions.values) {
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
    final id = _localVersions[localId]?.firebaseId;
    if (id != null) {
      return id;
    }
    // Not in cache, query repository
    final version = await _cipherRepository.getVersionWithId(localId);
    return version?.firebaseId;
  }

  // === Versions of a cipher ===
  List<int> getVersionsByCipherId(int cipherId) {
    return _localVersions.values
        .where((version) => version.cipherId == cipherId)
        .map((version) => version.id!)
        .toList();
  }

  int getVersionsOfCipherCount(int cipherId) {
    return _localVersions.values
        .where((version) => version.cipherId == cipherId)
        .length;
  }

  int? getIdOfOldestVersionOfCipher(int cipherId) {
    final versions = _localVersions.values
        .where((version) => version.cipherId == cipherId)
        .toList();
    versions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return versions.isNotEmpty ? versions.first.id : null;
  }

  // ===== CREATE =====
  /// Creates a new version from the local cache to an existing cipher
  /// If no cipherId is provided, the version will use the cached cipherID or throw an error
  Future<int?> createVersion(int? cipherId) async {
    if (_isSaving) return null;

    _isSaving = true;
    _error = null;
    notifyListeners();

    int? versionId;
    try {
      if (!_localVersions.containsKey(-1)) {
        throw Exception('No version cached to create a new version from.');
      }
      // Create version with the correct cipher ID
      final versionWithCipherId = _localVersions[-1]!.copyWith(
        cipherId: cipherId ?? _localVersions[-1]!.cipherId,
      );

      if (versionWithCipherId.cipherId == -1) {
        throw Exception(
          'Cannot create version: no cipherId provided and cached version has no cipherId.',
        );
      }

      versionId = await _cipherRepository.insertVersion(versionWithCipherId);

      _localVersions[versionId] = versionWithCipherId.copyWith(id: versionId);

      if (kDebugMode) {
        print(
          'Created a new version with id $versionId, for cipher ${cipherId ?? versionWithCipherId.cipherId}',
        );
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

  /// Initialize cloud cache from domain object, with ID -1
  void setNewVersionInCache(Version version) {
    _localVersions[-1] = version;
    notifyListeners();
  }

  /// Inserts a new version into the local database and cache
  Future<int> insertVersion(Version version) async {
    int versionId = -1;
    if (_isSaving) return versionId;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      versionId = await _cipherRepository.insertVersion(version);
      _localVersions[versionId] = version.copyWith(id: versionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return versionId;
  }

  /// Load public versions from Firestore
  Future<void> loadCloudVersions({bool forceReload = false}) async {
    final now = DateTime.now();
    if ((_lastCloudLoad != null &&
            now.difference(_lastCloudLoad!).inDays < 7) &&
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

      _lastCloudLoad = now;

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

  Future<void> ensureCloudVersionIsLoaded(String firebaseId) async {
    if (_cloudVersions.containsKey(firebaseId)) {
      return;
    }

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      final version = await _cloudVersionRepository.getUserVersionById(
        firebaseId,
      );
      if (version != null) {
        _cloudVersions[firebaseId] = version;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring cloud version in cache: $e');
      }
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
        _localVersions[version.id!] = version;
      }
      if (kDebugMode) {
        print('Loaded ${_localVersions.length} versions of cipher $cipherId');
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

  /// Load a version into cache by its Firebase ID
  Future<void> loadCloudUserVersionByFirebaseId(String firebaseId) async {
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      final version = await _cloudVersionRepository.getUserVersionById(
        firebaseId,
      );
      if (version == null) {
        throw Exception('Version with id $firebaseId not found in cloud');
      }

      _cloudVersions[firebaseId] = version;
      if (kDebugMode) {
        print(
          'Loaded the cloud version: ${_cloudVersions[firebaseId]?.versionName} into cache',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading cloud cipher version by id: $e');
      }
    } finally {
      _isLoadingCloud = false;
      notifyListeners();
    }
  }

  /// Load a version into cache by its local ID
  Future<void> loadLocalVersion(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final version = await _cipherRepository.getVersionWithId(versionId);
      if (version == null) {
        throw Exception('Version with id $versionId not found locally');
      }

      _localVersions[versionId] = version;
      _localVersions[versionId] = version;
      if (kDebugMode) {
        print(
          'Loaded the version: ${_localVersions[versionId]?.versionName} into cache',
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
  Future<void> setSearchTerm(String term) async {
    _searchTerm = term.toLowerCase();
    notifyListeners();
  }

  // ===== UPSERT =====
  /// Upsert a version into local db (add or update)
  Future<int> upsertVersion(Version version) async {
    int versionId = -1;
    if (_isSaving) return versionId;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Check if version exists by its firebaseId
      final versionId = await getLocalIdByFirebaseId(version.firebaseId!);

      if (versionId != null) {
        // Update existing version
        await _cipherRepository.updateVersion(version.copyWith(id: versionId));
        for (final section in version.sections!.values) {
          await _cipherRepository.updateSection(
            section.copyWith(versionId: versionId),
          );
        }
        if (kDebugMode) {
          print('Updated existing version with id: $versionId');
        }
      } else {
        // Insert new version
        final versionId = await _cipherRepository.insertVersion(version);
        for (final section in version.sections!.values) {
          await _cipherRepository.insertSection(
            section.copyWith(versionId: versionId),
          );
        }
        if (kDebugMode) {
          print('Inserted new version with id: $versionId');
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
    return versionId;
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
      loadLocalVersion(version.id!);

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
      _localVersions[versionId] = _localVersions[versionId]!.copyWith(
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
        _localVersions[versionId] = _localVersions[versionId]!.copyWith(
          versionName: newVersionName,
        );
      }
      if (newTransposedKey != null) {
        _localVersions[versionId] = _localVersions[versionId]!.copyWith(
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
      _localVersions[versionId] = _localVersions[versionId]!.copyWith(
        songStructure: songStructure,
      );
      notifyListeners();
      return;
    } else {
      _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
        songStructure: songStructure,
      );
      notifyListeners();
      return;
    }
  }

  // Reorder and cache a new structure
  void cacheReorderedStructure(dynamic versionId, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;

    if (versionId is int) {
      final item = _localVersions[versionId]!.songStructure.removeAt(oldIndex);
      _localVersions[versionId]!.songStructure.insert(newIndex, item);
      notifyListeners();
      return;
    } else {
      final item = _cloudVersions[versionId]!.songStructure.removeAt(oldIndex);
      _cloudVersions[versionId]!.songStructure.insert(newIndex, item);
      notifyListeners();
      return;
    }
  }

  /// Cache a change to the cloud version metadata
  void cacheCloudMetadataUpdate(
    String versionFirebaseId,
    InfoField field,
    String newValue,
  ) {
    if (!_cloudVersions.containsKey(versionFirebaseId)) {
      if (kDebugMode) {
        print(
          'Cannot cache update for cloud version $versionFirebaseId: not in cache',
        );
      }
      return;
    }

    switch (field) {
      case InfoField.title:
        _cloudVersions[versionFirebaseId] = _cloudVersions[versionFirebaseId]!
            .copyWith(title: newValue);
        break;
      case InfoField.author:
        _cloudVersions[versionFirebaseId] = _cloudVersions[versionFirebaseId]!
            .copyWith(author: newValue);
        break;
      case InfoField.bpm:
        _cloudVersions[versionFirebaseId] = _cloudVersions[versionFirebaseId]!
            .copyWith(bpm: int.tryParse(newValue) ?? 0);
        break;
      case InfoField.duration:
        final minuteSecond = newValue.split(':');
        final duration = Duration(
          minutes: int.tryParse(minuteSecond[0]) ?? 0,
          seconds: minuteSecond.length > 1
              ? int.tryParse(minuteSecond[1]) ?? 0
              : 0,
        );
        _cloudVersions[versionFirebaseId] = _cloudVersions[versionFirebaseId]!
            .copyWith(duration: duration.inSeconds);
        break;
      case InfoField.versionName:
        _cloudVersions[versionFirebaseId] = _cloudVersions[versionFirebaseId]!
            .copyWith(versionName: newValue);
        break;
      case InfoField.key:
        _cloudVersions[versionFirebaseId] = _cloudVersions[versionFirebaseId]!
            .copyWith(transposedKey: newValue);
        break;
      case InfoField.language:
        _cloudVersions[versionFirebaseId] = _cloudVersions[versionFirebaseId]!
            .copyWith(language: newValue);
        break;
      case InfoField.tags:
        // Tags are handled separately
        break;
    }
    notifyListeners();
  }

  void addTagToCloudCache(String versionFirebaseId, String newTag) {
    final currentTags = _cloudVersions[versionFirebaseId]!.tags;
    if (!currentTags.contains(newTag)) {
      currentTags.add(newTag);
    }
    notifyListeners();
  }

  void cacheDuration(dynamic versionId, Duration newDuration) {
    if (versionId is int) {
      _localVersions[versionId] = _localVersions[versionId]!.copyWith(
        duration: newDuration,
      );
    } else {
      _cloudVersions[versionId] = _cloudVersions[versionId]!.copyWith(
        duration: newDuration.inSeconds,
      );
    }
    notifyListeners();
  }

  /// ===== DELETE - Version =====
  Future<void> deleteVersion(int versionId) async {
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

  void clearVersionsOfCipher(int cipherId) {
    _localVersions.removeWhere((id, version) => version.cipherId == cipherId);
    notifyListeners();
  }

  // ===== SAVE =====
  /// Persist the cache of an ID to the database
  Future<void> saveVersion({dynamic versionID}) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (versionID == null) {
        throw Exception(
          'No versionId provided to save the version, create the version first.',
        );
      }

      if (versionID is int) {
        await _cipherRepository.updateVersion(_localVersions[versionID]!);
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
      _localVersions = Map.fromEntries(
        (await _cipherRepository.getVersionsByIds(
          versionIds,
        )).map((version) => MapEntry(version.id!, version)),
      );
      if (kDebugMode) {
        print('Loaded ${_localVersions.length} versions for playlist');
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

  dynamic getVersionById(dynamic versionId) {
    if (versionId.runtimeType == int) {
      return _localVersions[versionId];
    } else if (versionId.runtimeType == String) {
      return _cloudVersions[versionId];
    }
    return null;
  }

  int getCipherIdOfLocalVersion(int versionId) {
    return _localVersions[versionId]?.cipherId ?? -1;
  }

  // Get cached version by ID (returns null if not in cache)
  Version? getLocalVersionById(int versionId) {
    return _localVersions[versionId];
  }

  String? getMusicKeyOfVersion(dynamic versionId) {
    if (versionId is int) {
      return _localVersions[versionId]!.transposedKey;
    } else if (versionId is String) {
      return _cloudVersions[versionId]!.transposedKey ??
          _cloudVersions[versionId]!.originalKey;
    }
    return null;
  }

  VersionDto? getCloudVersionByFirebaseId(String firebaseId) {
    return _cloudVersions[firebaseId];
  }

  // Check if a version is already cached
  bool isVersionCached(dynamic versionId) {
    if (versionId is String) {
      return _cloudVersions.containsKey(versionId);
    }
    return _localVersions.containsKey(versionId);
  }

  /// ===== SONG STRUCTURE =====
  /// ===== CREATE =====
  // Add a new section
  void addSectionToStruct(dynamic versionId, String contentCode) {
    if (versionId is int) {
      _localVersions[versionId]!.songStructure.add(contentCode);
      notifyListeners();
      return;
    } else {
      _cloudVersions[versionId]!.songStructure.add(contentCode);
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
    final songStructure = getSongStructure(versionId);

    // Iterate through the song structure and update the section code
    for (int i = 0; i < _localVersions[versionId]!.songStructure.length; i++) {
      if (songStructure[i] == oldCode) {
        songStructure[i] = newCode;
      }
    }

    notifyListeners();
  }

  /// ===== DELETE =====
  // Remove a section from cache
  void removeSectionFromStruct(dynamic versionId, int index) {
    if (versionId is int) {
      _localVersions[versionId]!.songStructure.removeAt(index);
    } else {
      _cloudVersions[versionId]!.songStructure.removeAt(index);
    }
    notifyListeners();
  }

  void removeSectionFromStructByCode(dynamic versionId, String contentCode) {
    if (versionId is int) {
      _localVersions[versionId]!.songStructure.removeWhere(
        (code) => code == contentCode,
      );
    } else {
      _cloudVersions[versionId]!.songStructure.removeWhere(
        (code) => code == contentCode,
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
    notifyListeners();
  }

  void clearCache() {
    _localVersions.clear();
    _cloudVersions.clear();
    _searchTerm = '';
    notifyListeners();
  }
}
