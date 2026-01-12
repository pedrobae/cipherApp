import 'package:cloud_functions/cloud_functions.dart';
import 'package:cordis/helpers/guard.dart';
import 'package:cordis/models/dtos/playlist_dto.dart';
import 'package:cordis/models/dtos/version_dto.dart';
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
  /// Returns the generated document ID
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
  /// Used when fetching playlists for a user
  Future<List<PlaylistDto>> fetchPlaylistsByUserId(String userId) async {
    return await _withErrorHandling('fetch playlists by user ID', () async {
      final querySnapshot = await _firestoreService
          .fetchDocumentsContainingValue(
            collectionPath: 'playlists',
            field: 'collaboratorIds',
            orderField: 'updatedAt',
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

  /// Fetch a playlist's versions by its ID
  Future<List<VersionDto>> fetchPlaylistVersions(String playlistId) async {
    return await _withErrorHandling('fetch playlist by ID', () async {
      final docSnapshot = await _firestoreService.fetchSubCollectionDocuments(
        parentCollectionPath: 'playlists',
        parentDocumentId: playlistId,
        subCollectionPath: 'versions',
      );

      return docSnapshot
          .map(
            (doc) => VersionDto.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  /// Fetches a playlist by its ID
  /// Returns null if not found
  /// Used after successfully inserting a share code
  Future<PlaylistDto?> fetchPlaylistById(String playlistId) async {
    return await _withErrorHandling('fetch_playlist_by_id', () async {
      final docSnapshot = await _firestoreService.fetchDocumentById(
        collectionPath: 'playlists',
        documentId: playlistId,
      );

      if (docSnapshot == null) {
        throw Exception('No playlist found with the provided playlist ID.');
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

  /// Enter Playlist via Share Code by adding the user as a collaborator
  Future<String> enterPlaylist(String shareCode) async {
    return await _withErrorHandling('enter playlist via share code', () async {
      await _guardHelper.requireAuth();

      final functions = FirebaseFunctions.instance;

      final result = await functions.httpsCallable('joinPlaylistWithCode').call(
        <String, dynamic>{'shareCode': shareCode},
      );

      // After successfully joining load the playlist
      if (result.data['success'] == true) {
        final String playlistId = result.data['playlistId'];
        return playlistId;
      } else {
        throw Exception(
          'Failed to join playlist with the provided share code.',
        );
      }
    });
  }

  Future<void> updatePlaylistVersion(
    String playlistId,
    String versionId,
    Map<String, dynamic> changes,
  ) async {
    return await _withErrorHandling('update playlist version', () async {
      await _guardHelper.requireAuth();

      await _firestoreService.updateSubCollectionDocument(
        parentCollectionPath: 'playlists',
        parentDocumentId: playlistId,
        subCollectionPath: 'versions',
        documentId: versionId,
        data: changes,
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'updated_playlist_version',
        parameters: {'playlistId': playlistId, 'versionId': versionId},
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

  /// Delete a specific version of a playlist
  Future<void> deletePlaylistVersion(
    String playlistId,
    String versionId,
  ) async {
    return await _withErrorHandling('delete playlist version', () async {
      await _guardHelper.requireAuth();

      await _firestoreService.deleteSubCollectionDocument(
        parentCollectionPath: 'playlists',
        parentDocumentId: playlistId,
        subCollectionPath: 'versions',
        documentId: versionId,
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'deleted_playlist_version',
        parameters: {'playlistId': playlistId, 'versionId': versionId},
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
