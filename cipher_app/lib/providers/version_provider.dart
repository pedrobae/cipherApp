import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';
import 'package:flutter/foundation.dart';

class VersionProvider extends ChangeNotifier {
  final CipherRepository _cipherRepository = CipherRepository();

  VersionProvider();

  Version? _version;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Getters
  Version? get version => _version;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  /// ===== CREATE - new version to an existing cipher =====
  Future<void> createNewVersion(int cipherId, Version version) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Create version with the correct cipher ID
      final versionWithCipherId = version.copyWith(cipherId: cipherId);
      final newVersionId = await _cipherRepository.insertVersionToCipher(
        versionWithCipherId,
      );

      // Insert content for this map
      await _saveSections();

      // Reload version to get the updated data
      await loadVersionById(newVersionId);
      if (kDebugMode) {
        print('Created a new version with id $newVersionId');
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
      _version = await _cipherRepository.getCipherVersionWithId(versionId);
      if (kDebugMode) {
        print('===== Loaded the version: ${_version!.versionName} ');
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

  /// ===== UPDATE - update cipher version =====
  // Saves a new structure of a version
  Future<void> saveUpdatedSongStructure(
    int versionId,
    List<String> songStructure,
  ) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      String songStruct = songStructure.toString();
      songStruct = songStruct.substring(1, songStruct.length - 1);
      _cipherRepository.updateFieldOfCipherVersion(versionId, {
        'song_structure': songStruct,
      });

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
    _version = _version!.copyWith(
      versionName: newVersionName,
      transposedKey: newTransposedKey,
    );
    notifyListeners();
  }

  // Cache a version's song structure =====
  void cacheUpdatedSongStructure(List<String> songStructure) {
    _version = _version!.copyWith(songStructure: songStructure);
    notifyListeners();
  }

  // Reorder and cache a new structure
  void cacheReorderedStructure(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = version!.songStructure.removeAt(oldIndex);
    version!.songStructure.insert(newIndex, item);
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
      await _cipherRepository.updateCipherVersion(version!);
      // Insert content for this map
      await _saveSections();

      // Reload version to get the updated data
      if (kDebugMode) {
        print('Saved version with id ${version!.id}');
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
    _version = null;
  }

  /// ===== SECTION MANAGEMENT =====
  /// ===== CREATE =====
  // Add a new section
  void cacheAddSection(Section newSection) {
    _version!.sections![newSection.contentCode] = newSection;

    _version!.songStructure.add(newSection.contentCode);

    notifyListeners();
  }

  /// ===== UPDATE =====
  // Modify a section (content_text)
  void cacheUpdatedSection(String contentCode, String newContentText) {
    _version!.sections![contentCode]!.contentText = newContentText;
    notifyListeners();
  }

  /// ===== DELETE =====
  // Remove a section from cache
  void cacheRemoveSection(int index) {
    final sectionCode = version!.songStructure.removeAt(index);

    if (!version!.songStructure.contains(sectionCode)) {
      _version!.sections!.remove(sectionCode);
    }
    notifyListeners();
  }

  /// ===== SAVE =====
  // Persist the data to the database
  Future<void> _saveSections() async {
    if (version!.sections != null) {
      // For simplicity, delete all existing content and recreate
      // This could be optimized later to only update changed content
      await _cipherRepository.deleteAllVersionSections(version!.id!);

      // Insert new content
      for (final entry in version!.sections!.entries) {
        if (entry.key.isNotEmpty) {
          final sectionJson = entry.value.toJson();
          await _cipherRepository.insertSection(
            version!.id!,
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
