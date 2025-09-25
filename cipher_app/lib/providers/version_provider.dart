import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';
import 'package:flutter/foundation.dart';

class VersionProvider extends ChangeNotifier {
  final CipherRepository _cipherRepository = CipherRepository();

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

  /// ===== CREATE - new version to an existing cipher =====
  Future<void> createVersion(int cipherId) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Create version with the correct cipher ID
      final versionWithCipherId = _currentVersion.copyWith(cipherId: cipherId);
      final versionId = await _cipherRepository.insertVersionToCipher(
        versionWithCipherId,
      );
      // Load the new ID into the version cache
      _currentVersion = versionWithCipherId.copyWith(id: versionId);

      // Insert content for this map
      await _saveSections();

      if (kDebugMode) {
        print('Created a new version with id $versionId');
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
  }

  /// ===== READ - Load version from versionId =====
  Future<void> loadVersionById(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentVersion = (await _cipherRepository.getCipherVersionWithId(
        versionId,
      ))!;
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
      _versions = await _cipherRepository.getCipherVersions(cipherId);
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

  /// ===== UPDATE - update cipher version =====
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
      _cipherRepository.updateFieldOfCipherVersion(versionId, {
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
      await _cipherRepository.deleteCipherVersion(versionId);
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
      await _cipherRepository.updateCipherVersion(currentVersion);
      // Insert content for this map
      await _saveSections();

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

  /// ===== UTILS =====
  // Clear Cache to create a new version
  void clearCache() {
    _currentVersion = Version.empty();
  }

  // Clear current expanded cipher
  void clearVersions() {
    _expandedCipherId = -1;
    _versions = [];
    notifyListeners();
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

  // Get cached version by ID (returns null if not in cache)
  Version? getCachedVersion(int versionId) {
    try {
      return _versions.firstWhere((version) => version.id == versionId);
    } catch (e) {
      return null;
    }
  }

  // Check if a version is already cached
  bool isVersionCached(int versionId) {
    return _versions.any((version) => version.id == versionId);
  }

  /// ===== SECTION MANAGEMENT =====
  /// ===== CREATE =====
  // Add a new section
  void cacheAddSection(Section newSection) {
    _currentVersion.sections![newSection.contentCode] = newSection;

    _currentVersion.songStructure.add(newSection.contentCode);

    notifyListeners();
  }

  /// ===== UPDATE =====
  // Modify a section (content_text)
  void cacheUpdatedSection(String contentCode, String newContentText) {
    _currentVersion.sections![contentCode]!.contentText = newContentText;
    notifyListeners();
  }

  /// ===== DELETE =====
  // Remove a section from cache
  void cacheRemoveSection(int index) {
    final sectionCode = _currentVersion.songStructure.removeAt(index);

    if (!_currentVersion.songStructure.contains(sectionCode)) {
      _currentVersion.sections!.remove(sectionCode);
    }
    notifyListeners();
  }

  /// ===== SAVE =====
  // Persist the data to the database
  Future<void> _saveSections() async {
    if (currentVersion.sections != null) {
      // For simplicity, delete all existing content and recreate
      // This could be optimized later to only update changed content
      await _cipherRepository.deleteAllVersionSections(currentVersion.id!);

      // Insert new content
      for (final entry in currentVersion.sections!.entries) {
        if (entry.key.isNotEmpty) {
          final sectionJson = entry.value.toJson();
          await _cipherRepository.insertSection(
            currentVersion.id!,
            sectionJson['content_type'],
            sectionJson['content_code'],
            sectionJson['content_text'],
            sectionJson['color'],
          );
        }
      }
    }
  }
}
