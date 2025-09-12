import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/domain/cipher.dart';
import '../repositories/cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  final CipherRepository _cipherRepository = CipherRepository();

  CipherProvider();

  List<Cipher> _ciphers = [];
  List<Cipher> _filteredCiphers = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String _searchTerm = '';
  bool _useMemoryFiltering = true;
  bool _hasInitialized = false;

  // Add debouncing for rapid calls
  Timer? _loadTimer;

  // Getters
  List<Cipher> get ciphers => _filteredCiphers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get useMemoryFiltering => _useMemoryFiltering;
  bool get hasInitialized => _hasInitialized;

  // Load ciphers from local SQLite database
  Future<void> loadCiphers() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _useMemoryFiltering = true;
      _ciphers = await _cipherRepository.getAllCiphers();
      _filterCiphers();
      _hasInitialized = true;

      if (kDebugMode) {
        print('Loaded ${_ciphers.length} ciphers from SQLite');
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
  }

  // Search functionality
  Future<void> searchCiphers(String term) async {
    _searchTerm = term.toLowerCase();
    if (_useMemoryFiltering) {
      // Instant memory filtering
      _filterCiphers();
    } else {
      // SQLite query with debouncing maybe implement later
    }
  }

  void _filterCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredCiphers = List.from(_ciphers);
    } else {
      _filteredCiphers = _ciphers
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
    notifyListeners();
  }

  void clearSearch() {
    _filteredCiphers = List.from(_ciphers);
  }

  Future<void> createCipher(Cipher cipher) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Insert basic cipher info and tags
      final cipherId = await _cipherRepository.insertCipher(cipher);

      // Insert cipher maps and their content
      await _createCipherVersionsAndSections(cipherId, cipher.maps);

      // Reload all ciphers to get the complete data with relationships
      await loadCiphers();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating cipher: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Handle creating cipher versions and their sections for a new cipher
  Future<void> _createCipherVersionsAndSections(
    int cipherId,
    List<CipherVersion> versions,
  ) async {
    for (final version in versions) {
      // Create Version with the correct cipher ID
      final versionWithCipherId = version.copyWith(cipherId: cipherId);
      final newVersionId = await _cipherRepository.insertCipherVersion(
        versionWithCipherId,
      );

      // Insert content for this map
      for (final section in version.sections!.entries) {
        if (section.key.isNotEmpty) {
          final sectionJson = section.value.toJson();
          await _cipherRepository.insertSection(
            newVersionId,
            sectionJson['content_type'],
            sectionJson['content_code'],
            sectionJson['content_text'],
            sectionJson['color'],
          );
        }
      }
    }
  }

  Future<void> updateCipher(Cipher cipher) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Update basic cipher info and tags
      await _cipherRepository.updateCipher(cipher);

      // Update cipher maps and their content
      await _updateCipherMapsAndContent(cipher);

      // Reload all ciphers to get the updated data with relationships
      await loadCiphers();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating cipher: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Handle updating cipher maps and their content
  Future<void> _updateCipherMapsAndContent(Cipher cipher) async {
    if (cipher.id == null || cipher.maps.isEmpty) return;

    // Get existing maps to determine which ones to update, create, or delete
    final existingMaps = await _cipherRepository.getCipherVersions(cipher.id!);
    final existingMapIds = existingMaps
        .map((m) => m.id)
        .where((id) => id != null)
        .toSet();
    final newMapIds = cipher.maps
        .map((m) => m.id)
        .where((id) => id != null)
        .toSet();

    // Delete maps that are no longer present
    for (final existingMap in existingMaps) {
      if (existingMap.id != null && !newMapIds.contains(existingMap.id)) {
        await _cipherRepository.deleteCipherVersion(existingMap.id!);
      }
    }

    // Update or create maps
    for (final map in cipher.maps) {
      final mapWithCipherId = map.copyWith(cipherId: cipher.id!);

      if (map.id != null && existingMapIds.contains(map.id)) {
        // Update existing map
        await _cipherRepository.updateCipherVersion(mapWithCipherId);
        await _updateVersionSection(map.id!, map.sections);
      } else {
        // Create new map
        final newMapId = await _cipherRepository.insertCipherVersion(
          mapWithCipherId,
        );
        await _updateVersionSection(newMapId, map.sections);
      }
    }
  }

  /// Handle updating map content
  Future<void> _updateVersionSection(
    int mapId,
    Map<String, Section>? newSection,
  ) async {
    if (newSection != null) {
      // Get existing content
      final existingContent = await _cipherRepository.getAllSections(mapId);

      // Delete content types that are no longer present
      for (final contentCode in existingContent.keys) {
        if (!newSection.containsKey(contentCode)) {
          // Note: We need a method to delete by mapId and contentType
          // For now, we'll delete all and recreate (simpler approach)
        }
      }
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

  Future<void> deleteCipher(int cipherID) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.deleteCipher(cipherID);
      // Reload all ciphers to reflect the deletion
      await loadCiphers();
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

  /// Clear cached data and reset state for debugging
  void clearCache() {
    _ciphers.clear();
    _filteredCiphers.clear();
    _isLoading = false;
    _isSaving = false;
    _error = null;
    _searchTerm = '';
    notifyListeners();
  }

  // === CIPHER VERSION SPECIFIC OPERATIONS ===

  /// Get cipher data from versionId
  Future<Cipher?> getCipherVersionById(int versionId) async {
    return await _cipherRepository.getCipherVersionWithId(versionId);
  }

  /// Add a new version (CipherMap) to an existing cipher
  Future<void> addCipherVersion(int cipherId, CipherVersion cipherMap) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Create map with the correct cipher ID
      final mapWithCipherId = cipherMap.copyWith(cipherId: cipherId);
      final newMapId = await _cipherRepository.insertCipherVersion(
        mapWithCipherId,
      );

      // Insert content for this map
      await _updateVersionSection(newMapId, cipherMap.sections);

      // Reload all ciphers to get the updated data
      await loadCiphers();
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

  /// Update a specific cipher version (CipherMap)
  Future<void> updateCipherVersion(CipherVersion cipherMap) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.updateCipherVersion(cipherMap);
      await _updateVersionSection(cipherMap.id!, cipherMap.sections);

      // Reload all ciphers to get the updated data
      await loadCiphers();
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

  /// Update the song structure of a specific cipher version
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

      // Reload all ciphers to get the updated data
      await loadCiphers();
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

  /// Delete a specific cipher version (CipherMap)
  Future<void> deleteCipherVersion(int mapId) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cipherRepository.deleteCipherVersion(mapId);

      // Reload all ciphers to get the updated data
      await loadCiphers();
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

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}
