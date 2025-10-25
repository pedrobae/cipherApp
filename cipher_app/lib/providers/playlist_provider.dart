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
  Playlist? _currentPlaylist;
  PlaylistDto? _currentCloudPlaylist;
  bool _isLoading = false;
  bool _isCloudLoading = false;
  bool _isSaving = false;
  bool _isCloudSaving = false;
  bool _isDeleting = false;
  String? _error;

  // Track changes per playlist for efficient cloud syncing
  // Map<playlistId, changeMap>
  final Map<int, Map<String, dynamic>> _pendingChanges = {};

  // Getters
  List<Playlist> get playlists => _playlists;
  List<PlaylistDto> get cloudPlaylists => _cloudPlaylists;
  Playlist? get currentPlaylist => _currentPlaylist;
  PlaylistDto? get currentCloudPlaylist => _currentCloudPlaylist;
  bool get isLoading => _isLoading;
  bool get isCloudLoading => _isCloudLoading;
  bool get isSaving => _isSaving;
  bool get isCloudSaving => _isCloudSaving;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  Playlist? getPlaylistByFirebaseId(String firebaseId) {
    for (var p in _playlists) {
      if (p.firebaseId == firebaseId) {
        return p;
      }
    }
    return null;
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
  Future<void> loadPlaylist(int id) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Playlist playlist = (await _playlistRepository.getPlaylistById(
        id,
      ))!;
      _currentPlaylist = playlist;

      /// Upsert the playlist on the _playlists list
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
  Future<void> loadCloudPlaylist(String firebaseId) async {
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

      _currentCloudPlaylist = cloudDto;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isCloudLoading = false;
      notifyListeners();
    }
  }

  /// Load Single Playlist by Share Code
  Future<void> loadCloudPlaylistByCode(String code) async {
    try {
      final playlistDto = await _cloudPlaylistRepository.fetchPlaylistByCode(
        code,
      );

      if (playlistDto == null) {
        throw Exception('Playlist not found with code $code.');
      }

      _currentCloudPlaylist = playlistDto;
    } catch (e) {
      throw Exception('Error loading playlist by code: $e');
    }
  }

  Future<TextSectionDto> downloadTextItemByFirebaseId(
    String firebaseTextId,
  ) async {
    try {
      final textItemDto = await _cloudPlaylistRepository.fetchTextSectionById(
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

  Future<void> uploadPlaylist(PlaylistDto playlist) async {
    if (_isCloudSaving) return;

    _isCloudSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cloudPlaylistRepository.publishPlaylist(playlist);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error Uploading Playlist: $e');
      }
    } finally {
      _isCloudLoading = false;
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
    trackChange('metadata', playlistId: id);

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

  /// Add a collaborator to a cloud playlist
  Future<void> addCollaboratorToPlaylist(
    String playlistId,
    String userId,
    String role,
  ) async {
    await _cloudPlaylistRepository.addCollaborator(playlistId, userId, role);
  }

  // Update a Playlist with a version
  Future<void> addVersionToPlaylist(int playlistId, int versionId) async {
    await _playlistRepository.addVersionToPlaylist(playlistId, versionId);

    // Track added version
    trackChange('versions', playlistId: playlistId);

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
        includerId: addedBy,
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
      trackChange('itemsReordered', playlistId: playlist.id);
    } catch (e) {
      _rollbackItemOrders(playlist, originalItems);
      notifyListeners();
      _error = 'Erro ao reordenar itens: $e';
      rethrow;
    }
  }

  Future<void> duplicateVersion(int playlistId, int versionId) async {
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
      trackChange('versions', playlistId: playlistId);
    }

    await loadPlaylist(playlistId);
  }

  /// Calculate which items need to be pruned before syncing
  /// Returns (textItemsToPrune, versionItemsToPrune)
  (List<int>, List<int>) calculateItemsToPrune(
    int playlistId,
    List<Map<String, dynamic>> versionSectionItems,
    List<Map<String, dynamic>> textSectionItems,
  ) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);

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
        await loadPlaylist(existingPlaylist.id);

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
  void trackChange(String changeType, {int? playlistId}) {
    playlistId ??= _currentPlaylist!.id;

    _pendingChanges.putIfAbsent(playlistId, () => {});

    _pendingChanges[playlistId]![changeType] = true;

    if (kDebugMode) {
      print('Tracked change for playlist $playlistId: $changeType');
    }
  }

  /// Upload pending changes for a specific playlist to Firebase
  Future<void> uploadChanges(
    int playlistLocalId,
    PlaylistDto playlistDto,
  ) async {
    if (!hasPendingChanges(playlistLocalId)) {
      if (kDebugMode) {
        print('No pending changes for playlist $playlistLocalId');
      }
      return;
    }

    final changes = _pendingChanges[playlistLocalId]!;

    if (_isSaving) return;

    try {
      _isSaving = true;
      notifyListeners();

      // Build update payload
      Map<String, dynamic> updatePayload = {'updatedAt': DateTime.now()};

      // Add metadata changes
      if (changes.containsKey('metadata')) {
        updatePayload.addAll({
          'name': playlistDto.name,
          'description': playlistDto.description,
          'shareCode': playlistDto.shareCode,
          'isPublic': playlistDto.isPublic,
        });
      }

      // Add items if reordered or changed versions or text sections
      if (changes.containsKey('itemsReordered') ||
          changes.containsKey('versions') ||
          changes.containsKey('textSections')) {
        // Get current playlist items and convert to DTOs
        updatePayload['items'] = [
          for (final item in playlistDto.items) ...[item.toFirestore()],
        ];
      }

      // Add collaborators if changed
      if (changes.containsKey('collaborators')) {
        updatePayload['collaborators'] = playlistDto.collaborators;
        updatePayload['collaboratorIds'] = playlistDto.collaborators
            .map((c) => c['id'])
            .toList();
      }

      // Upload to Firebase
      if (playlistDto.firebaseId != null) {
        await _cloudPlaylistRepository.updatePlaylist(
          playlistDto.firebaseId!,
          playlistDto.ownerId,
          updatePayload,
        );

        // Clear pending changes for this playlist
        _pendingChanges.remove(playlistLocalId);

        if (kDebugMode) {
          print('Successfully uploaded changes for playlist $playlistLocalId');
        }
      } else {
        if (kDebugMode) {
          print(
            'Playlist $playlistDto has no firebaseId, cannot upload changes',
          );
        }
      }
    } catch (e) {
      _error = 'Erro ao fazer upload das alterações: $e';
      if (kDebugMode) {
        print('Error uploading changes for playlist $playlistLocalId: $e');
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
