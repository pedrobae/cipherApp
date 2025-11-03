import 'package:cipher_app/models/domain/playlist/playlist_text_section.dart';
import 'package:cipher_app/models/dtos/text_section_dto.dart';
import 'package:cipher_app/repositories/text_section_repository.dart';
import 'package:cipher_app/repositories/cloud_playlist_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class TextSectionProvider extends ChangeNotifier {
  final TextSectionRepository _textSectionRepo = TextSectionRepository();
  final CloudPlaylistRepository _cloudPlaylistRepository =
      CloudPlaylistRepository();

  TextSectionProvider();

  Map<int, TextSection> _textSections = {};
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isCloudSaving = false;
  bool _isDeleting = false;
  String? _error;

  // Getters
  Map<int, TextSection> get textSections => _textSections;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isCloudSaving => _isCloudSaving;
  bool get isDeleting => _isDeleting;
  String? get error => _error;

  // ===== READ =====
  // Load TextSections from local SQLite database
  Future<void> loadTextSections(List<int> textSectionsIds) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _textSections = await _textSectionRepo.getTextSections(textSectionsIds);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load single textSection
  Future<void> loadTextSection(
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
  Future<void> createTextSection(
    TextSection textSection, {
    VoidCallback? onPlaylistRefreshNeeded,
  }) async {
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
        textSection.includerId,
      );
      await loadTextSection(id, forceReload: true);

      // Notify that playlist needs refresh due to item adjustments
      onPlaylistRefreshNeeded?.call();
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
    int? position, {
    VoidCallback? onPlaylistRefreshNeeded,
  }) async {
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
      await loadTextSection(id, forceReload: true);

      // Notify that playlist needs refresh
      onPlaylistRefreshNeeded?.call();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateCloudTextSection(TextSectionDto textSectionDto) async {
    if (_isCloudSaving) return;

    _isCloudSaving = true;
    _error = null;

    try {
      await _cloudPlaylistRepository.updateTextSection(textSectionDto);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating cloud text section: $e');
      }
      _error = e.toString();
      rethrow;
    } finally {
      _isCloudSaving = false;
      notifyListeners();
    }
  }

  // ===== DELETE =====
  // Delete a text section
  Future<void> deleteTextSection(
    int id, {
    VoidCallback? onPlaylistRefreshNeeded,
  }) async {
    if (_isDeleting) return;

    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      await _textSectionRepo.deletePlaylistText(id);
      _textSections.remove(id); // Remove from local cache

      // Notify that playlist needs refresh due to position adjustments
      onPlaylistRefreshNeeded?.call();
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
