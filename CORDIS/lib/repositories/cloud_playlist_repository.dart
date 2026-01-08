import 'package:cordis/helpers/guard.dart';
import 'package:cordis/models/dtos/playlist_dto.dart';
import 'package:cordis/models/dtos/text_section_dto.dart';
import 'package:cordis/services/firestore_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

// class PlaylistDto {
//   final String? firebaseId; // Cloud ID (Firebase)
//   final String name;
//   final String description;
//   final String ownerId; // User that created the playlist
//   final bool isPublic;
//   final DateTime updatedAt;
//   final DateTime createdAt;
//   final List<String> collaborators; // userIds
//   final List<PlaylistItemDto> items; // Array whose order matters

class CloudPlaylistRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final GuardHelper _guardHelper = GuardHelper();

  CloudPlaylistRepository();

  // ===== CREATE =====
  /// Publish a new playlist to Firestore
  Future<String> publishPlaylist(PlaylistDto playlistDto) async {
    return await _withErrorHandling('publish playlist', () async {
      await _guardHelper.requireAuth();
      await _guardHelper.requireOwnership(playlistDto.ownerId);

      final docId = await _firestoreService.createDocument(
        collectionPath: 'playlists',
        data: playlistDto.toFirestore(),
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'created_playlist',
        parameters: {'playlistId': docId},
      );

      return docId;
    });
  }

  // ===== READ =====
  /// Fetch playlists of a specific user ID
  Future<List<PlaylistDto>> fetchPlaylistsByUserId(String userId) async {
    return await _withErrorHandling('fetch playlists by user ID', () async {
      final querySnapshot = await _firestoreService
          .fetchDocumentsContainingValue(
            collectionPath: 'playlists',
            field: 'collaboratorIds',
            value: userId,
          );

      return querySnapshot
          .map(
            (doc) => PlaylistDto.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  /// Fetch a playlist by its ID
  Future<PlaylistDto?> fetchPlaylistById(String playlistId) async {
    return await _withErrorHandling('fetch playlist by ID', () async {
      final docSnapshot = await _firestoreService.fetchDocumentById(
        collectionPath: 'playlists',
        documentId: playlistId,
      );

      if (docSnapshot == null || !docSnapshot.exists) {
        return null;
      }

      return PlaylistDto.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    });
  }

  /// Fetches a playlist by its invite code
  Future<PlaylistDto?> fetchPlaylistByCode(String code) async {
    return await _withErrorHandling('fetch_playlist_by_invite_code', () async {
      final docSnapshot = await _firestoreService.fetchDocumentByField(
        collectionPath: 'playlists',
        fieldName: 'shareCode',
        fieldValue: code,
      );

      if (docSnapshot == null) {
        throw Exception('No playlist found with the provided invite code.');
      }

      return PlaylistDto.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    });
  }

  // ===== UPDATE =====
  /// Update an existing playlist in Firestore on the changes map
  Future<void> updatePlaylist(
    String firebaseId,
    String ownerId,
    Map<String, dynamic> changes,
  ) async {
    return await _withErrorHandling('update playlist', () async {
      await _guardHelper.requireAuth();
      await _guardHelper.requireOwnership(ownerId);

      await _firestoreService.updateDocument(
        collectionPath: 'playlists',
        documentId: firebaseId,
        data: changes,
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'updated_playlist',
        parameters: {'playlistId': firebaseId},
      );
    });
  }

  Future<void> updateTextSection(TextSectionDto textSectionDto) async {
    return await _withErrorHandling('update text section', () async {
      await _guardHelper.requireAuth();

      await _firestoreService.updateDocument(
        collectionPath: 'textSections',
        documentId: textSectionDto.firebaseId!,
        data: textSectionDto.toFirestore(),
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'updated_text_section',
        parameters: {'textSectionId': textSectionDto.firebaseId!},
      );
    });
  }

  Future<void> addCollaborator(
    String playlistId,
    String userId,
    String role,
  ) async {
    return await _withErrorHandling('add collaborator to playlist', () async {
      await _guardHelper.requireAuth();

      await _firestoreService.addToArrayField(
        collectionPath: 'playlists',
        documentId: playlistId,
        arrayField: 'collaboratorIds',
        value: userId,
      );

      await _firestoreService.addToArrayField(
        collectionPath: 'playlists',
        documentId: playlistId,
        arrayField: 'collaborators',
        value: {'id': userId, 'role': role},
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'added_collaborator',
        parameters: {'playlistId': playlistId, 'userId': userId},
      );
    });
  }

  // ===== DELETE =====
  /// Delete a playlist from Firestore
  Future<void> deletePlaylist(String firebaseId, String ownerId) async {
    return await _withErrorHandling('delete playlist', () async {
      await _guardHelper.requireAuth();
      await _guardHelper.requireOwnership(ownerId);

      await _firestoreService.deleteDocument(
        collectionPath: 'playlists',
        documentId: firebaseId,
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'deleted_playlist',
        parameters: {'playlistId': firebaseId},
      );
    });
  }

  // ===== ERROR HANDLING =====
  Future<T> _withErrorHandling<T>(
    String actionDescription,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } catch (e) {
      // Log error to analytics
      await FirebaseAnalytics.instance.logEvent(
        name: 'error_during_$actionDescription',
        parameters: {'error': e.toString()},
      );

      if (kDebugMode) {
        print('Error during $actionDescription: $e');
      }

      rethrow;
    }
  }
}
