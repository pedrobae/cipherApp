import 'package:cipher_app/repositories/collaborator_repository.dart';
import 'package:flutter/material.dart';
import '../models/domain/collaborator.dart';
import '../repositories/local_playlist_repository.dart';

class CollaboratorProvider extends ChangeNotifier {
  final CollaboratorRepository _collaboratorRepository =
      CollaboratorRepository();

  CollaboratorProvider();

  // Collaborators by playlist ID
  final Map<int, List<Collaborator>> _collaboratorsByPlaylist = {};

  // State variables
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get collaborators for a specific playlist
  List<Collaborator> getCollaboratorsForPlaylist(int playlistId) {
    return _collaboratorsByPlaylist[playlistId] ?? [];
  }

  // Load collaborators for a playlist
  Future<void> loadCollaborators(int playlistId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final collaborators = await _collaboratorRepository
          .getPlaylistCollaborators(playlistId);

      _collaboratorsByPlaylist[playlistId] = collaborators;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add collaborator to a playlist
  Future<void> addCollaborator(int playlistId, int userId, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the current user ID for the 'added by' field
      final currentUserId = PlaylistRepository.getCurrentUserId() ?? 1;

      await _collaboratorRepository.addCollaborator(
        playlistId,
        userId,
        role,
        currentUserId,
      );

      // Reload collaborators to refresh the list
      await loadCollaborators(playlistId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a collaborator's instrument
  Future<void> updateCollaboratorInstrument(
    int playlistId,
    int userId,
    String instrument,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _collaboratorRepository.updateCollaboratorRole(
        playlistId,
        userId,
        instrument,
      );

      // Update the local state
      final playlistCollaborators = _collaboratorsByPlaylist[playlistId];
      if (playlistCollaborators != null) {
        final index = playlistCollaborators.indexWhere(
          (c) => c.userId == userId,
        );
        if (index != -1) {
          final updatedCollaborator = playlistCollaborators[index].copyWith(
            instrument: instrument,
          );
          playlistCollaborators[index] = updatedCollaborator;
          _collaboratorsByPlaylist[playlistId] = playlistCollaborators;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove a collaborator from a playlist
  Future<void> removeCollaborator(int playlistId, int userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _collaboratorRepository.removeCollaborator(playlistId, userId);

      // Update the local state
      final playlistCollaborators = _collaboratorsByPlaylist[playlistId];

      if (playlistCollaborators != null) {
        playlistCollaborators.removeWhere((c) => c.userId == userId);
        _collaboratorsByPlaylist[playlistId] = playlistCollaborators;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get common instruments for dropdown options
  List<String> getCommonInstruments() {
    return [
      'Vocalista',
      'Guitarrista',
      'Baixista',
      'Baterista',
      'Tecladista',
      'Pianista',
      'Violão',
      'Percussão',
      'Saxofone',
      'Violino',
      'Viola',
      'Violoncelo',
      'Flauta',
      'Dirigente',
    ];
  }
}
