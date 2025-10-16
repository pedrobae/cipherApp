import 'package:cipher_app/helpers/guard.dart';
import 'package:cipher_app/models/dtos/playlist_dto.dart';
import 'package:cipher_app/services/firestore_service.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class CloudPlaylistRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final GuardHelper _guardHelper = GuardHelper();

  CloudPlaylistRepository();

  // ===== CREATE =====
  /// Publish a new playlist to Firestore
  Future<String> publishPlaylist(Playlist playlist) async {
    return await _withErrorHandling('publish playlist', () async {
      await _guardHelper.requireAuth();
      await _guardHelper.requireOwnership(playlist.createdBy);

      final docId = await _firestoreService.createDocument(
        collectionPath: 'playlists',
        data: playlist.toDto().toFirestore(),
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'created_playlist',
        parameters: {'playlistId': docId},
      );

      return docId;
    });
  }

  /// Publishes a new text section to Firestore
  Future<String> publishTextSection(
    String title,
    String content,
    String createdBy,
  ) async {
    return await _withErrorHandling('publish text section', () async {
      await _guardHelper.requireAuth();
      await _guardHelper.requireOwnership(createdBy);

      final docId = await _firestoreService.createDocument(
        collectionPath: 'text_sections',
        data: {
          'title': title,
          'content': content,
          'createdBy': createdBy,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'created_text_section',
        parameters: {'textSectionId': docId},
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
            field: 'collaborators',
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

  // ===== UPDATE =====
  /// Update an existing playlist adding new version
  Future<void> addVersionToPlaylist(Playlist playlist, String versionId) async {
    return await _withErrorHandling('update playlist', () async {
      await _guardHelper.requireAuth();
      await _guardHelper.requireOwnership(playlist.createdBy);

      await _firestoreService.updateDocument(
        collectionPath: 'playlists',
        documentId: playlist.firebaseId!,
        data: {
          'versions': FieldValue.arrayUnion([versionId]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await FirebaseAnalytics.instance.logEvent(
        name: 'updated_playlist',
        parameters: {'playlistId': playlist.id},
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

      // Rethrow with user-friendly message
      throw Exception(
        'Erro ao $actionDescription. Tente novamente mais tarde.',
      );
    }
  }
}
