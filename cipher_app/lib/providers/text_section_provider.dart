import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/domain/playlist/playlist_text_section.dart';
import '../repositories/text_section_repository.dart';

class TextSectionProvider extends ChangeNotifier {
  final TextSectionRepository _textSectionRepo = TextSectionRepository();

  TextSectionProvider();

  List<TextSection> _textSections = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _error;

  // Getters
  List<TextSection> get textSections => _textSections;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
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
  Future<void> loadTextSection(int textSectionsId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final textSection = await _textSectionRepo.getTextSection(textSectionsId);
      if (textSection != null) {
        // Update cache
        int existingIndex = _textSections.indexWhere(
          (p) => p.id == textSection.id,
        );

        if (existingIndex != -1) {
          _textSections[existingIndex] = textSection;
        } else {
          _textSections.add(textSection);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== CREATE =====
  // Create a new TextSection from scratch
  Future<void> createTextSection(TextSection textSection) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      int? id = await _textSectionRepo.createPlaylistText(
        textSection.playlistId,
        textSection.title,
        textSection.contentText,
        textSection.position,
        textSection.includerId,
      );
      if (id != null) await loadTextSection(id);
    } catch (e) {
      _error = e.toString();
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
    await _textSectionRepo.updatePlaylistText(
      id,
      title: title,
      content: content,
      position: position,
    );
    await loadTextSection(id); // Reload just this playlist
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
