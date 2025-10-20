import 'dart:async';
import 'package:cipher_app/models/dtos/playlist_item_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/models/dtos/playlist_dto.dart';
import 'package:cipher_app/repositories/local_playlist_repository.dart';
import 'package:cipher_app/repositories/cloud_playlist_repository.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _playlistRepository = PlaylistRepository();
  final CloudPlaylistRepository _cloudPlaylistRepository =
      CloudPlaylistRepository();

  PlaylistProvider();

  List<Playlist> _playlists = [];
  List<PlaylistDto> _cloudPlaylists = [];
  bool _isLoading = false;
  bool _isCloudLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _error;

  // Track changes per playlist for efficient cloud syncing
  // Map<playlistId, changeMap>
  final Map<int, Map<String, dynamic>> _pendingChanges = {};

  // Getters
  List<Playlist> get playlists => _playlists;
  List<PlaylistDto> get cloudPlaylists => _cloudPlaylists;
  bool get isLoading => _isLoading;
  bool get isCloudLoading => _isCloudLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  String? get error => _error;

  // Check if a playlist has pending changes to upload
  bool hasPendingChanges(int playlistId) {
    return _pendingChanges.containsKey(playlistId) &&
        _pendingChanges[playlistId]!.isNotEmpty;
  }

  // Get pending changes for a playlist
  Map<String, dynamic>? getPendingChanges(int playlistId) {
    return _pendingChanges[playlistId];
  }

  // ===== READ =====
  // Load Playlists from local SQLite database
  Future<void> loadLocalPlaylists() async {
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

  // Load all cloud playlists of a specific user
  Future<void> loadCloudPlaylists(String userId) async {
    if (_isCloudLoading) return;

    _isCloudLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cloudPlaylists = await _cloudPlaylistRepository
          .fetchPlaylistsByUserId(userId);

      _cloudPlaylists = cloudPlaylists;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isCloudLoading = false;
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

  // Load Single Playlist by Firebase ID
  Future<void> loadPlaylistByFirebaseId(String firebaseId) async {
    if (_isCloudLoading) return;

    _isCloudLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cloudDto = await _cloudPlaylistRepository.fetchPlaylistById(
        firebaseId,
      );

      if (cloudDto == null) {
        _error = 'Playlist não encontrada na nuvem.';
        return;
      }

      _cloudPlaylists.add(cloudDto);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isCloudLoading = false;
      notifyListeners();
    }
  }

  Future<TextItemDto> downloadTextItemByFirebaseId(
    String firebaseTextId,
  ) async {
    try {
      final textItemDto = await _cloudPlaylistRepository.fetchTextItemById(
        firebaseTextId,
      );
      if (textItemDto == null) {
        throw Exception('Item de texto não encontrado');
      }
      return textItemDto;
    } catch (e) {
      throw Exception('Erro ao buscar item de texto: $e');
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
    await _playlistRepository.updatePlaylist(id, {
      'name': name,
      'description': description,
    });

    // Track metadata changes
    _trackChange(id, 'metadata', {'name': name, 'description': description});

    await _loadPlaylist(id); // Reload just this playlist
  }

  Future<int> upsertPlaylist(Playlist playlist) async {
    return await _playlistRepository.upsertPlaylist(playlist);
  }

  // Update a Playlist with a version
  Future<void> addVersionToPlaylist(int playlistId, int versionId) async {
    await _playlistRepository.addVersionToPlaylist(playlistId, versionId);

    // Track added version
    _trackChange(playlistId, 'addedVersions', versionId);

    await _loadPlaylist(playlistId);
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
        includerId: addedBy,
      );
    } else {
      // Version exists, just update its position
      await _playlistRepository.updatePlaylistVersionPosition(
        playlistVersionId,
        position,
      );
    }

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

      // Track item reordering
      _trackChange(playlist.id, 'itemsReordered', true);
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
  Future<void> removeVersionFromPlaylist(int itemId, int playlistId) async {
    // Get the version ID before removing (for change tracking)
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    final item = playlist.items.firstWhere((i) => i.id == itemId);
    final versionId = item.contentId;

    await _playlistRepository.removeVersionFromPlaylist(itemId, playlistId);

    // Track removed version
    if (versionId != null) {
      _trackChange(playlistId, 'removedVersions', versionId);
    }

    await _loadPlaylist(playlistId);
  }

  // ===== UTILITY =====
  // Sync playlist from cloud with existing local playlist
  // Assumes users and versions have already been synced/loaded beforehand
  Future<void> syncPlaylist(PlaylistDto cloudDto, int ownerLocalId) async {
    // Merge cloud playlists with local ones, avoiding duplicates
    final existingIndex = _playlists.indexWhere(
      (p) => p.firebaseId == cloudDto.firebaseId,
    );

    final existingPlaylist = existingIndex != -1
        ? _playlists[existingIndex]
        : null;

    if (existingPlaylist != null) {
      // Update existing playlist with cloud data
      // Compare timestamps? - only update if cloud is newer?
      try {
        // Update playlist metadata (name, description, timestamps)
        await _playlistRepository.updatePlaylist(existingPlaylist.id, {
          'name': cloudDto.name,
          'description': cloudDto.description,
          'updated_at': cloudDto.updatedAt.toIso8601String(),
          'is_public': cloudDto.isPublic ? 1 : 0,
        });

        // Reload playlist to update cache
        await _loadPlaylist(existingPlaylist.id);

        if (kDebugMode) {
          print('Successfully merged playlist: ${cloudDto.name}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error merging playlist from cloud: $e');
        }
        rethrow;
      }
    } else {
      // Save new cloud playlist locally
      List<PlaylistItem> items = [];
      for (var index = 0; index < cloudDto.items.length; index++) {
        items.add(cloudDto.items[index].toDomain(index));
      }

      await _playlistRepository.createPlaylist(
        cloudDto.toDomain(items, ownerLocalId),
      );
    }
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

  // ===== CHANGE TRACKING & CLOUD SYNC =====
  /// Track a change for later upload to cloud
  void _trackChange(int playlistId, String changeType, dynamic value) {
    _pendingChanges.putIfAbsent(playlistId, () => {});

    switch (changeType) {
      case 'metadata':
        // Merge metadata changes
        if (_pendingChanges[playlistId]!.containsKey('metadata')) {
          final existingMetadata =
              _pendingChanges[playlistId]!['metadata'] as Map<String, dynamic>;
          _pendingChanges[playlistId]!['metadata'] = {
            ...existingMetadata,
            ...(value as Map<String, dynamic>),
          };
        } else {
          _pendingChanges[playlistId]!['metadata'] = value;
        }
        break;

      case 'addedVersions':
        // Accumulate added versions
        _pendingChanges[playlistId]!['addedVersions'] ??= <int>[];
        (_pendingChanges[playlistId]!['addedVersions'] as List<int>).add(value);
        break;

      case 'removedVersions':
        // Accumulate removed versions
        _pendingChanges[playlistId]!['removedVersions'] ??= <int>[];
        (_pendingChanges[playlistId]!['removedVersions'] as List<int>).add(
          value,
        );
        break;

      case 'itemsReordered':
        _pendingChanges[playlistId]!['itemsReordered'] = true;
        break;

      default:
        _pendingChanges[playlistId]![changeType] = value;
    }

    if (kDebugMode) {
      print('Tracked change for playlist $playlistId: $changeType');
    }
  }

  /// Upload pending changes for a specific playlist to Firebase
  Future<void> uploadChanges(int playlistId, String ownerFirebaseId) async {
    if (!hasPendingChanges(playlistId)) {
      if (kDebugMode) {
        print('No pending changes for playlist $playlistId');
      }
      return;
    }

    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    final changes = _pendingChanges[playlistId]!;

    try {
      _isSaving = true;
      notifyListeners();

      // Build update payload
      Map<String, dynamic> updatePayload = {'updatedAt': DateTime.now()};

      // Add metadata changes
      if (changes.containsKey('metadata')) {
        updatePayload.addAll(changes['metadata']);
      }

      // Add items if reordered or added/removed
      if (changes.containsKey('itemsReordered') ||
          changes.containsKey('addedVersions') ||
          changes.containsKey('removedVersions')) {
        // Get current playlist items and convert to DTOs
        // This ensures we upload the current state
        updatePayload['items'] = playlist.items
            .map(
              (item) => {
                'type': item.type,
                'firebaseContentId': item.firebaseContentId,
                'position': item.position,
              },
            )
            .toList();
      }

      // Upload to Firebase
      if (playlist.firebaseId != null) {
        await _cloudPlaylistRepository.updatePlaylist(
          playlist.firebaseId!,
          ownerFirebaseId,
          updatePayload,
        );

        // Clear pending changes for this playlist
        _pendingChanges.remove(playlistId);

        if (kDebugMode) {
          print('Successfully uploaded changes for playlist $playlistId');
        }
      } else {
        if (kDebugMode) {
          print(
            'Playlist $playlistId has no firebaseId, cannot upload changes',
          );
        }
      }
    } catch (e) {
      _error = 'Erro ao fazer upload das alterações: $e';
      if (kDebugMode) {
        print('Error uploading changes for playlist $playlistId: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearCloudPlaylists() {
    _cloudPlaylists.clear();
    notifyListeners();
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
}
