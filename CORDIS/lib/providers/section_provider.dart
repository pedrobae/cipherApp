import "package:cordis/models/domain/cipher/section.dart";
import "package:cordis/utils/section_constants.dart";
import "package:flutter/foundation.dart";
import 'package:cordis/repositories/local_cipher_repository.dart';
import "package:flutter/material.dart";

class SectionProvider extends ChangeNotifier {
  final LocalCipherRepository _cipherRepository = LocalCipherRepository();

  SectionProvider();

  Map<String, Section> _sections = {};
  int? _currentVersionId;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  Map<String, Section> get sections => _sections;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  // Set the current version ID (used when creating a new version / importing)
  void setCurrentVersionId(int versionId) {
    _currentVersionId = versionId;
  }

  // Set sections directly (used when importing)
  void setSections(Map<String, Section> sections) {
    _sections = sections;
    notifyListeners();
  }

  /// ===== CREATE =====
  // Add a new section
  void cacheAddSection(
    String contentCode, {
    Color? color,
    String? sectionType,
  }) {
    final newSection = Section(
      versionId: _currentVersionId!,
      contentCode: contentCode,
      contentColor: color ?? (defaultSectionColors[contentCode]!),
      contentType:
          sectionType ??
          commonSectionLabels
              .firstWhere((label) => label.code == contentCode)
              .officialLabel,
      contentText: '',
    );
    _sections[newSection.contentCode] = newSection;
    notifyListeners();
  }

  // ====== READ =====
  /// Load sections for a given version from the database
  Future<void> loadSections(int versionId) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _sections = await _cipherRepository.getSections(versionId);

      _currentVersionId = versionId;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('⚠️ Failed to load sections: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ===== UPDATE =====
  // Modify a section (content_text)
  void cacheUpdatedSection(
    String contentCode, {
    String? newContentCode,
    String? newContentType,
    String? newContentText,
    Color? newColor,
  }) {
    final newSection = Section(
      versionId: _currentVersionId ?? _sections[contentCode]!.versionId,
      contentCode: newContentCode ?? _sections[contentCode]!.contentCode,
      contentColor: newColor ?? _sections[contentCode]!.contentColor,
      contentType: newContentType ?? _sections[contentCode]!.contentType,
      contentText: newContentText ?? _sections[contentCode]!.contentText,
    );

    // Update the section in the sections map
    _sections.remove(contentCode);
    _sections[newSection.contentCode] = newSection;
    notifyListeners();
  }

  /// ===== DELETE =====
  // Remove all sections by its code
  void cacheDeleteSection(String sectionCode) {
    _sections.remove(sectionCode);
    notifyListeners();
  }

  /// ===== SAVE =====
  // Persist the data to the database
  Future<void> saveSections() async {
    if (_isSaving) return;

    _isSaving = true;
    notifyListeners();

    try {
      if (_currentVersionId == null) {
        throw Exception('No current version ID set.');
      }
      // For simplicity, delete all existing content and recreate
      // This could be optimized later to only update changed content
      await _cipherRepository.deleteAllVersionSections(_currentVersionId!);

      // Insert new content
      if (kDebugMode) {
        print(
          'Saving ${_sections.length} sections for version $_currentVersionId',
        );
      }
      for (final entry in _sections.entries) {
        if (entry.key.isNotEmpty) {
          final sectionId = await _cipherRepository.insertSection(
            entry.value.copyWith(versionId: _currentVersionId!),
          );

          if (kDebugMode) {
            print('Inserted section with code ${entry.key} and id $sectionId');
          }
        }
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('⚠️ Failed to save sections: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Clear all sections from cache
  void clearCache() {
    _sections = {};
    _currentVersionId = null;
    _isLoading = false;
    _isSaving = false;
    notifyListeners();
  }
}
