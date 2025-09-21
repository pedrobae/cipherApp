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
      await _insertVersionSections(newVersionId, version.sections);

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
      _isSaving = false;
      notifyListeners();
    }
  }

  /// ===== UPDATE - update cipher version =====
  Future<void> updateCipherVersion(Version version) async {
    if (version.id == null) {
      createNewVersion(version.cipherId, version);
    }
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.updateCipherVersion(version);
      await _insertVersionSections(version.id!, version.sections);

      // Reload version to get the updated data
      await loadVersionById(version.id!);
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

  /// ===== UPDATE - version's song structure =====
  Future<void> updateVersionSongStructure(
    int versionId,
    String songStructure,
  ) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.updateFieldOfCipherVersion(versionId, {
        'song_structure': songStructure,
      });

      // Reload version to get the updated data
      await loadVersionById(versionId);
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

  /// ===== DELETE - cipher version =====
  Future<void> deleteCipherVersion(int versionId) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.deleteCipherVersion(versionId);

      // Reload version to get the updated data
      await loadVersionById(versionId);
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

  /// Handle updating / creating version section
  Future<void> _insertVersionSections(
    int mapId,
    Map<String, Section>? newSection,
  ) async {
    if (newSection != null) {
      // For simplicity, delete all existing content and recreate
      // This could be optimized later to only update changed content
      await _cipherRepository.deleteAllVersionSections(mapId);

      // Insert new content
      for (final entry in newSection.entries) {
        if (entry.key.isNotEmpty) {
          final sectionJson = entry.value.toJson();
          await _cipherRepository.insertSection(
            mapId,
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
