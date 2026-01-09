import 'package:cordis/models/domain/playlist/playlist_text_section.dart';
import 'package:cordis/repositories/text_section_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class TextSectionProvider extends ChangeNotifier {
  final TextSectionRepository _textSectionRepo = TextSectionRepository();

  TextSectionProvider();

  final Map<int, TextSection> _textSections = {};
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _error;

  // Getters
  Map<int, TextSection> get textSections => _textSections;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  String? get error => _error;

  // ===== READ =====
  // Load single textSection
  Future<void> _loadTextSection(
    int textSectionId, {
    bool forceReload = false,
  }) async {
    if (kDebugMode) {
      print(
        '===== Loading Text Section - $textSectionId - Forced Reload - $forceReload =====',
      );
    }
    // Check if already loaded (unless forcing reload)
    if (!forceReload && _textSections.containsKey(textSectionId)) {
      return;
    }

    _error = null;
    notifyListeners();

    try {
      final textSection = await _textSectionRepo.getTextSection(textSectionId);
      if (textSection != null) {
        _textSections[textSection.id!] = textSection;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<String?> getFirebaseIdByLocalId(int localId) async {
    // Check cache first
    if (_textSections.containsKey(localId)) {
      return _textSections[localId]!.firebaseId;
    }
    // Not in cache, query repository
    final textSection = await _textSectionRepo.getTextSection(localId);
    return textSection?.firebaseId;
  }

  Future<int?> getLocalIdByFirebaseId(String firebaseId) async {
    // Check cache first
    for (final entry in _textSections.entries) {
      if (entry.value.firebaseId == firebaseId) {
        return entry.key;
      }
    }
    // Not in cache, query repository
    final textSection = await _textSectionRepo.getTextSectionByFirebaseId(
      firebaseId,
    );
    return textSection?.id;
  }

  Future<TextSection?> getTextSectionById(int id) async {
    // Check cache first
    if (_textSections.containsKey(id)) {
      return _textSections[id];
    }
    // Not in cache, query repository
    final textSection = await _textSectionRepo.getTextSection(id);
    if (textSection != null) {
      _textSections[id] = textSection;
    }
    return textSection;
  }

  // ===== CREATE =====
  // Create a new TextSection from scratch
  Future<void> createTextSection(TextSection textSection) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      int id = await _textSectionRepo.createPlaylistText(
        textSection.playlistId,
        null,
        textSection.title,
        textSection.contentText,
        textSection.position,
      );
      await _loadTextSection(id, forceReload: true);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Upserts a Text Section (create or update)
  Future<void> upsertTextSection(TextSection textSection) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Check if exists
      final localId = await getLocalIdByFirebaseId(textSection.firebaseId);

      if (localId == null) {
        // Create new
        await _textSectionRepo.createPlaylistText(
          textSection.playlistId,
          textSection.firebaseId,
          textSection.title,
          textSection.contentText,
          textSection.position,
        );
      } else {
        // Update existing
        await _textSectionRepo.updatePlaylistText(
          localId,
          title: textSection.title,
          content: textSection.contentText,
          position: textSection.position,
        );
      }

      await _loadTextSection(textSection.id!, forceReload: true);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== UPDATE =====
  // Update a Text Section with new data (title/content)
  Future<void> updateTextSection(
    int id,
    String? title,
    String? content,
    int? position,
  ) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _textSectionRepo.updatePlaylistText(
        id,
        title: title,
        content: content,
        position: position,
      );

      // Force reload the updated text section to get fresh data
      await _loadTextSection(id, forceReload: true);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== DELETE =====
  // Delete a text section
  Future<void> deleteTextSection(int id) async {
    if (_isDeleting) return;

    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      await _textSectionRepo.deletePlaylistText(id);
      _textSections.remove(id); // Remove from local cache
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ===== UTILITY =====
  // Clear cached data and reset state
  void clearCache() {
    _textSections.clear();
    _error = null;
    _isLoading = false;
    _isSaving = false;
    _isDeleting = false;
    notifyListeners();
  }
}
