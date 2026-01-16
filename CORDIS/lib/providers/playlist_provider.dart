import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/models/dtos/playlist_dto.dart';
import 'package:cordis/repositories/local_playlist_repository.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _playlistRepository = PlaylistRepository();

  PlaylistProvider();

  final Map<int, Playlist> _localPlaylists = {};
  Map<int, Playlist> _filteredPlaylists = {};

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  String? _error;

  // Track changes per playlist for efficient cloud syncing
  // Map<playlistId, changeMap>
  final Map<int, Map<String, dynamic>> _pendingChanges = {};

  // Getters
  Map<int, Playlist> get localPlaylists => _localPlaylists;
  Map<int, Playlist> get filteredPlaylists => _filteredPlaylists;

  String _searchTerm = '';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;

  String? get error => _error;

  Playlist? getLocalPlaylistByFirebaseId(String firebaseId) {
    for (var p in _localPlaylists.values) {
      if (p.firebaseId == firebaseId) {
        return p;
      }
    }
    return null;
  }

  Playlist? getLocalPlaylistById(int id) {
    return _localPlaylists[id];
  }

  // Check if a playlist has pending changes to upload
  bool hasPendingChanges(int playlistId) {
    return _pendingChanges.containsKey(playlistId) &&
        _pendingChanges[playlistId]!.isNotEmpty;
  }

  // Get pending changes for a playlist
  Map<String, dynamic>? getPendingChanges(int playlistId) {
    return _pendingChanges[playlistId];
  }

  // ===== CREATE =====
  // Create a new playlist from local cache
  Future<void> createPlaylist(Playlist playlist) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (_localPlaylists[-1] == null) {
        throw Exception('No playlist found to create.');
      }
      int id = await _playlistRepository.insertPlaylist(playlist);

      // Add the created playlist with new ID directly to cache
      _localPlaylists[id] = _localPlaylists[id]!.copyWith(id: id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== READ =====
  // Load Playlists from local SQLite database
  Future<void> loadLocalPlaylists() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final playlist = await _playlistRepository.getAllPlaylists();
      for (var p in playlist) {
        _localPlaylists[p.id] = p;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Single Playlist by ID
  Future<void> loadPlaylist(int id) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Playlist playlist = (await _playlistRepository.getPlaylistById(
        id,
      ))!;
      _localPlaylists[playlist.id] = playlist;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== UPDATE =====
  // Update a Playlist with new data (name/description)
  Future<void> updateMetadata(int id, String? name, String? description) async {
    await _playlistRepository.updatePlaylist(id, {
      'name': name,
      'description': description,
    });

    // Track metadata changes
    trackChange('metadata', id);

    await loadPlaylist(id); // Reload just this playlist
  }

  Future<int> upsertPlaylist(Playlist playlist) async {
    final playlistId = await _playlistRepository.upsertPlaylist(playlist);
    await loadPlaylist(playlistId);

    return playlistId;
  }

  /// Sync entire playlist with all its items in a single transaction
  /// This prevents database locking issues during bulk sync operations
  Future<int> syncPlaylistWithTransaction(
    Playlist playlist,
    List<Map<String, dynamic>> versionSectionItems,
    List<Map<String, dynamic>> textSectionItems,
    List<int> textItemsToPrune,
    List<int> versionItemsToPrune,
  ) async {
    final playlistId = await _playlistRepository.syncPlaylistWithTransaction(
      playlist,
      versionSectionItems,
      textSectionItems,
      textItemsToPrune,
      versionItemsToPrune,
    );

    // Reload the playlist in the provider's cache
    await loadPlaylist(playlistId);

    return playlistId;
  }

  // Update a Playlist with a version
  Future<void> addVersionToPlaylist(int playlistId, int versionId) async {
    await _playlistRepository.addVersionToPlaylist(playlistId, versionId);

    // Track added version
    trackChange('versions', playlistId);

    await loadPlaylist(playlistId);
  }

  Future<void> upsertVersionOnPlaylist(
    int playlistId,
    int versionId,
    int position,
    int? addedBy,
  ) async {
    // Check if the version already exists in the playlist
    final playlistVersionId = await _playlistRepository.getPlaylistVersionId(
      playlistId,
      versionId,
    );

    if (playlistVersionId == null) {
      // Version isn't in the playlist, add it
      await _playlistRepository.addVersionToPlaylistAtPosition(
        playlistId,
        versionId,
        position,
      );
    } else {
      // Version exists, just update its position
      await _playlistRepository.updatePlaylistVersionPosition(
        playlistVersionId,
        position,
      );
    }

    await loadPlaylist(playlistId);
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

      // Track item reordering
      trackChange('itemsReordered', playlist.id);
    } catch (e) {
      _rollbackItemOrders(playlist, originalItems);
      notifyListeners();
      _error = 'Erro ao reordenar itens: $e';
      rethrow;
    }
  }

  Future<void> duplicateVersion(
    int playlistId,
    int versionId,
    int currentUserId,
  ) async {
    await _playlistRepository.addVersionToPlaylist(playlistId, versionId);
    await loadPlaylist(playlistId);
  }

  Future<void> upsertTextItem({
    required int addedBy,
    required int playlistId,
    required String firebaseTextId,
    required String title,
    required String content,
    required int position,
  }) async {
    await _playlistRepository.upsertTextItem(
      addedBy,
      firebaseTextId,
      playlistId,
      title,
      content,
      position,
    );

    await loadPlaylist(playlistId);
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
      _localPlaylists.remove(playlistId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // Remove a Cipher Map from a Playlist
  Future<void> removeVersionFromPlaylist(int itemId, int playlistId) async {
    await _playlistRepository.removeVersionFromPlaylist(itemId, playlistId);

    // Track removed version
    trackChange('versions', playlistId);

    await loadPlaylist(playlistId);
  }

  /// Calculate which items need to be pruned before syncing
  /// Returns (textItemsToPrune, versionItemsToPrune)
  (List<int>, List<int>) calculateItemsToPrune(
    int playlistId,
    List<Map<String, dynamic>> versionSectionItems,
    List<Map<String, dynamic>> textSectionItems,
  ) {
    final playlist = _localPlaylists[playlistId]!;

    List<int> textItemsToPrune = [];
    List<int> versionItemsToPrune = [];

    for (final item in playlist.items) {
      if (item.type == 'text_section') {
        if (!textSectionItems.any(
          (textItem) =>
              (textItem['firebaseContentId'] == item.firebaseContentId),
        )) {
          textItemsToPrune.add(item.id!);
        }
      } else if (item.type == 'cipher_version') {
        if (!versionSectionItems.any(
          (versionItem) => (versionItem['contentId'] == item.contentId),
        )) {
          versionItemsToPrune.add(item.id!);
        }
      }
    }

    return (textItemsToPrune, versionItemsToPrune);
  }

  /// Prune playlist items to insert the items from the cloud version
  Future<void> prunePlaylistItems(
    int playlistId,
    List<Map<String, dynamic>> versionSectionItems,
    List<Map<String, dynamic>> textSectionItems,
  ) async {
    final (textItemsToPrune, versionItemsToPrune) = calculateItemsToPrune(
      playlistId,
      versionSectionItems,
      textSectionItems,
    );

    _playlistRepository.prunePlaylistItems(
      playlistId,
      textItemsToPrune,
      versionItemsToPrune,
    );
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
    _localPlaylists.clear();
    _error = null;
    _isLoading = false;
    _isSaving = false;
    _isDeleting = false;
    notifyListeners();
  }

  // ===== CHANGE TRACKING & CLOUD SYNC =====
  /// Track a change for later upload to cloud
  void trackChange(String changeType, int playlistId) {
    _pendingChanges[playlistId]![changeType] = true;

    if (kDebugMode) {
      print('Tracked change for playlist $playlistId: $changeType');
    }
  }

  /// Build map of changes to upload to cloud for a playlist
  Map<String, dynamic> buildUpdatePayload(
    int playlistLocalId,
    PlaylistDto playlistDto,
  ) {
    Map<String, dynamic> updatePayload = {};
    final changes = _pendingChanges[playlistLocalId];

    if (changes == null) return updatePayload; // No changes to upload

    // Build update payload based on pennding changes
    // Add metadata changes
    if (changes.containsKey('metadata')) {
      updatePayload.addAll({
        'updatedAt': DateTime.now(),
        'name': playlistDto.name,
      });
    }

    // Add items if reordered or changed versions or text sections
    if (changes.containsKey('itemsReordered')) {
      updatePayload['itemOrder'] = playlistDto.itemOrder;
    }

    if (changes.containsKey('versions')) {
      updatePayload['versions'] = [
        for (final version in playlistDto.versions) ...[version.toFirestore()],
      ];
      updatePayload['duration'] = playlistDto.duration;
    }
    return updatePayload;
  }

  /// Clear pending changes for a playlist (without uploading)
  void clearPendingChanges(int playlistId) {
    _pendingChanges.remove(playlistId);
    notifyListeners();
  }

  /// Clear all pending changes (without uploading)
  void clearAllPendingChanges() {
    _pendingChanges.clear();
    notifyListeners();
  }

  // ===== SEARCH =====
  void setSearchTerm(String searchTerm) {
    _searchTerm = searchTerm.toLowerCase();
    _filterLocalPlaylists();
  }

  void _filterLocalPlaylists() {
    if (_searchTerm.isEmpty) {
      _filteredPlaylists = _localPlaylists;
    } else {
      Map<int, Playlist> tempFiltered = {};
      for (var entry in _localPlaylists.entries) {
        final playlist = entry.value;
        if (playlist.name.toLowerCase().contains(_searchTerm)) {
          tempFiltered[entry.key] = playlist;
        }
      }
      _filteredPlaylists = tempFiltered;
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchTerm = '';
    _filteredPlaylists = _localPlaylists;
    notifyListeners();
  }
}
