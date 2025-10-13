import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/domain/playlist/playlist.dart';
import '../repositories/playlist_repository.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _playlistRepository = PlaylistRepository();

  PlaylistProvider();

  List<Playlist> _playlists = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _error;

  // Getters
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  String? get error => _error;

  // ===== READ =====
  // Load Playlists from local SQLite database
  Future<void> loadPlaylists() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playlists = await _playlistRepository.getAllPlaylists();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Single Playlist by ID
  Future<void> _loadPlaylist(int id) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Playlist playlist = (await _playlistRepository.getPlaylistById(
        id,
      ))!;
      int existingIndex = _playlists.indexWhere((p) => p.id == playlist.id);

      if (existingIndex != -1) {
        _playlists[existingIndex] = playlist;
      } else {
        _playlists.add(playlist);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== CREATE =====
  // Create a new playlist from scratch
  Future<void> createPlaylist(Playlist playlist) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      int id = await _playlistRepository.createPlaylist(playlist);

      // Add the created playlist directly to cache
      _playlists.add(playlist.copyWith(id: id));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== UPDATE =====
  // Update a Playlist with new data (name/description)
  Future<void> updatePlaylistInfo(
    int id,
    String? name,
    String? description,
  ) async {
    await _playlistRepository.updatePlaylist(
      id,
      name: name,
      description: description,
    );
    await _loadPlaylist(id); // Reload just this playlist
  }

  // Update a Playlist with a version
  Future<void> addVersion(int playlistId, int version) async {
    await _playlistRepository.addVersionToPlaylist(playlistId, version);
    await _loadPlaylist(playlistId);
  }

  // Reorder playlist items with optimistic updates
  Future<void> reorderItems(
    int oldIndex,
    int newIndex,
    Playlist playlist,
  ) async {
    final originalItems = playlist.items
        .map(
          (item) => PlaylistItem(
            id: item.id,
            type: item.type,
            contentId: item.contentId,
            position: item.position,
          ),
        )
        .toList();

    try {
      _updateItemOrdersOptimistically(playlist, oldIndex, newIndex);
      notifyListeners();

      List<PlaylistItem> changedList = _getChangedItems(
        originalItems,
        playlist.items,
      );
      await _playlistRepository.savePlaylistOrder(playlist.id, changedList);
    } catch (e) {
      _rollbackItemOrders(playlist, originalItems);
      notifyListeners();
      _error = 'Erro ao reordenar itens: $e';
      rethrow;
    }
  }

  Future<void> duplicateVersion(int playlistId, int versionId) async {
    await _playlistRepository.addVersionToPlaylist(playlistId, versionId);
    await _loadPlaylist(playlistId);
  }

  // ===== DELETE =====
  // Delete a playlist
  Future<void> deletePlaylist(int playlistId) async {
    if (_isSaving) return;

    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      await _playlistRepository.deletePlaylist(playlistId);
      int i = _playlists.indexWhere((p) => p.id == playlistId);
      _playlists.removeAt(i);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // Remove a Cipher Map from a Playlist
  Future<void> removeCipherMapFromPlaylist(int itemId, int playlistId) async {
    await _playlistRepository.removeVersionFromPlaylist(itemId, playlistId);
    await _loadPlaylist(playlistId);
  }

  // ===== UTILITY =====
  void _updateItemOrdersOptimistically(
    Playlist playlist,
    int oldIndex,
    int newIndex,
  ) {
    final items = playlist.items;

    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);

    for (int i = 0; i < items.length; i++) {
      items[i].position = i;
    }
  }

  // Helper method to get items that changed order
  List<PlaylistItem> _getChangedItems(
    List<PlaylistItem> original,
    List<PlaylistItem> updated,
  ) {
    List<PlaylistItem> changed = [];

    for (int i = 0; i < updated.length; i++) {
      final updatedItem = updated[i];
      final originalItem = original.firstWhere(
        (item) =>
            item.contentId == updatedItem.contentId &&
            item.type == updatedItem.type,
      );

      if (originalItem.position != updatedItem.position) {
        changed.add(updatedItem);
      }
    }

    return changed;
  }

  void _rollbackItemOrders(
    Playlist playlist,
    List<PlaylistItem> originalItems,
  ) {
    for (int i = 0; i < playlist.items.length; i++) {
      final currentItem = playlist.items[i];
      final originalItem = originalItems.firstWhere(
        (item) =>
            item.contentId == currentItem.contentId &&
            item.type == currentItem.type,
      );
      currentItem.position = originalItem.position;
    }
    playlist.items.sort((a, b) => a.position.compareTo(b.position));
  }

  // Clear cached data and reset state
  void clearCache() {
    _playlists.clear();
    _error = null;
    _isLoading = false;
    _isSaving = false;
    _isDeleting = false;
    notifyListeners();
  }
}
