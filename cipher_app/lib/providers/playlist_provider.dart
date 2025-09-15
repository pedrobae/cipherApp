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
      await _loadPlaylist(id);
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

  // Update a Playlist with a new Cipher Map
  Future<void> addCipherMap(int playlistId, int cipherMapId) async {
    await _playlistRepository.addCipherMapToPlaylist(playlistId, cipherMapId);
    await _loadPlaylist(playlistId);
  }

  // Update a Playlist with a new Order, but same cipher maps
  Future<void> reorderPlaylistCipherMaps(
    int playlistId,
    List<int> newOrder,
  ) async {
    await _playlistRepository.reorderPlaylistCipherMaps(playlistId, newOrder);
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
  Future<void> removeCipherMapFromPlaylist(
    int playlistId,
    int cipherMapId,
  ) async {
    await _playlistRepository.removeVersionFromPlaylist(
      playlistId,
      cipherMapId,
    );
    await _loadPlaylist(playlistId);
    notifyListeners();
  }

  // ===== UTILITY =====
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
