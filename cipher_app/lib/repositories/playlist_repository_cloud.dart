import 'package:cipher_app/services/firestore_service.dart';
import 'package:cipher_app/services/auth_service.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/dtos/playlist_dto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudPlaylistRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  CloudPlaylistRepository({
    this.cipherPublishGuard = CipherPublishGuard.adminOnly,
  });

  // Pluggable guard to control who can publish new ciphers to publicCiphers collection
  final CipherPublishGuard cipherPublishGuard;

  // ===== PERMISSION HELPERS =====
  Future<void> _requireAdmin() async {
    if (!(await _authService.isAdmin)) {
      throw Exception(
        'Acesso negado: operação requer privilégios de administrador',
      );
    }
  }

  Future<void> _requireAuth() async {
    if (!_authService.isAuthenticated) {
      throw Exception('Acesso negado: usuário deve estar autenticado');
    }
  }

  Future<void> _ensureCanModifyPlaylist(String playlistId) async {
    await _requireAuth();

    // Simple check: user must be owner or admin to modify playlists
    final uid = _authService.currentUser?.uid;
    final snap = await FirebaseFirestore.instance
        .collection('playlists')
        .doc(playlistId)
        .get();
    final ownerId = snap.data()?['ownerId'] as String?;

    if (ownerId != null && ownerId == uid) return; // Owner can always edit

    // Otherwise, must be admin
    await _requireAdmin();
  }

  Future<T> _withErrorHandling<T>(
    String action,
    Future<T> Function() fn,
  ) async {
    try {
      return await fn();
    } on FirebaseException catch (e) {
      throw Exception('Falha ao $action: ${_mapFirestoreError(e)}');
    } catch (e) {
      throw Exception('Falha ao $action: $e');
    }
  }

  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permissão negada';
      case 'not-found':
        return 'Documento não encontrado';
      case 'aborted':
        return 'Operação abortada';
      case 'unavailable':
        return 'Serviço indisponível. Tente novamente';
      case 'deadline-exceeded':
        return 'Tempo limite excedido';
      default:
        return 'Erro inesperado (${e.code})';
    }
  }

  // ===== CREATE =====
  /// Creates a new playlist in Firestore.
  Future<String> createPlaylist(Playlist playlist) async {
    await _requireAuth();

    final currentUser = _authService.currentUser;
    if (currentUser!.uid != playlist.createdBy) {
      throw Exception('Acesso negado: usuário não é o criador da playlist');
    }

    final docId = await _firestoreService.createDocument(
      collectionPath: 'playlists',
      data: playlist.toDto().toFirestore(),
    );

    await FirebaseAnalytics.instance.logEvent(
      name: 'created_playlist',
      parameters: {'playlistId': docId},
    );

    return docId;
  }

  // ===== CIPHER PUBLISHING (CONTROLLED BY GUARD) =====

  /// Check if current user can publish new ciphers based on the guard setting
  Future<void> _ensureCanPublishCiphers() async {
    await _requireAuth();
    switch (cipherPublishGuard) {
      case CipherPublishGuard.adminOnly:
        await _requireAdmin();
        return;
      case CipherPublishGuard.ownerOrAdmin:
        // For now, same as admin only - could be extended to allow verified users
        await _requireAdmin();
        return;
      case CipherPublishGuard.collaboratorsWithEdit:
        // More permissive - any authenticated user can publish
        // Could add additional checks here (e.g., account age, reputation)
        return;
    }
  }

  /// Publish a new cipher to the global publicCiphers collection
  /// This method delegates to CloudCipherRepository for proper domain separation
  Future<String> publishCipher(Map<String, dynamic> cipherData) async {
    return await _withErrorHandling('publicar cifra', () async {
      await _ensureCanPublishCiphers();

      // TODO: Replace with proper CloudCipherRepository call
      // Example: return await CloudCipherRepository().publishCipher(cipherData);
      throw UnimplementedError(
        'Use CloudCipherRepository.publishCipher() instead. '
        'This method exists only to demonstrate the permission guard.',
      );
    });
  }

  // ========= ITEM OPERATIONS =========
  /// Add items to a playlist. Performs lightweight preflight on cipher existence
  /// and converts unknown ciphers into placeholders instead of failing the whole write.
  Future<void> addPlaylistItems(
    String playlistId,
    List<PlaylistItemDto> items,
  ) async {
    await _withErrorHandling('adicionar itens à playlist', () async {
      await _ensureCanModifyPlaylist(playlistId);

      // Preflight: check distinct cipher existence once to avoid batch failures
      final cipherIds = <String>{};
      for (final it in items) {
        final ref = it.firebaseContentId; // expected format: cipherId:versionId
        if (it.type == 'cipher_version' && ref != null && ref.contains(':')) {
          cipherIds.add(ref.split(':').first);
        }
      }

      final known = await _checkExistingCiphers(cipherIds.toList());

      final itemsColl = FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .collection('items');

      // Determine next base position for append
      final last = await itemsColl
          .orderBy('position', descending: true)
          .limit(1)
          .get();
      var basePos =
          (last.docs.isNotEmpty
              ? (last.docs.first.data()['position'] as int? ?? -1)
              : -1) +
          1;

      final batch = FirebaseFirestore.instance.batch();
      var addedCount = 0;

      for (final raw in items) {
        var item = raw;
        if (item.position == null) {
          item = item.copyWith(position: basePos++);
        }

        // Convert to placeholder when cipher is unknown
        if (item.type == 'cipher_version') {
          final ref = item.firebaseContentId;
          final cipherId = (ref != null && ref.contains(':'))
              ? ref.split(':').first
              : null;
          if (cipherId == null || !known.contains(cipherId)) {
            item = item.copyWith(
              type: 'unknown_cipher',
              status: 'unknown',
              // keep original ref for potential recovery
              // store in displayFallback for lightweight UI rendering
              displayFallback: {
                'originalRef': ref,
                'title': 'Cifra indisponível',
              },
            );
          }
        }

        final ref = itemsColl.doc(item.id);
        batch.set(ref, item.toFirestore(playlistId));
        addedCount++;
      }

      await batch.commit();

      await FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .update({
            'updatedAt': FieldValue.serverTimestamp(),
            'itemCount': FieldValue.increment(addedCount),
          });

      await FirebaseAnalytics.instance.logEvent(
        name: 'playlist_items_added',
        parameters: {'playlistId': playlistId, 'count': addedCount},
      );
    });
  }

  /// Reorder items by updating only those with changed position.
  Future<void> reorderPlaylistItems(
    String playlistId,
    Map<String, int> newPositions,
  ) async {
    await _withErrorHandling('reordenar itens da playlist', () async {
      await _ensureCanModifyPlaylist(playlistId);

      final itemsColl = FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .collection('items');

      final snap = await itemsColl.get();
      final batch = FirebaseFirestore.instance.batch();
      var writes = 0;

      for (final d in snap.docs) {
        final id = d.id;
        final current = d.data()['position'] as int? ?? 0;
        final desired = newPositions[id];
        if (desired != null && desired != current) {
          batch.update(d.reference, {'position': desired});
          writes++;
        }
      }

      if (writes == 0) return;

      await batch.commit();
      await FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .update({'updatedAt': FieldValue.serverTimestamp()});

      await FirebaseAnalytics.instance.logEvent(
        name: 'playlist_items_reordered',
        parameters: {'playlistId': playlistId, 'writes': writes},
      );
    });
  }

  /// Remove items by IDs.
  Future<void> removePlaylistItems(
    String playlistId,
    List<String> itemIds,
  ) async {
    await _withErrorHandling('remover itens da playlist', () async {
      await _ensureCanModifyPlaylist(playlistId);

      final itemsColl = FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .collection('items');

      // Chunk deletes to respect batch limits
      const maxPerBatch = 450;
      for (var i = 0; i < itemIds.length; i += maxPerBatch) {
        final chunk = itemIds.sublist(
          i,
          (i + maxPerBatch).clamp(0, itemIds.length),
        );
        final batch = FirebaseFirestore.instance.batch();
        for (final id in chunk) {
          batch.delete(itemsColl.doc(id));
        }
        await batch.commit();
      }

      await FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .update({
            'updatedAt': FieldValue.serverTimestamp(),
            'itemCount': FieldValue.increment(-itemIds.length),
          });

      await FirebaseAnalytics.instance.logEvent(
        name: 'playlist_items_removed',
        parameters: {'playlistId': playlistId, 'count': itemIds.length},
      );
    });
  }

  /// Replace all items by diffing desired vs existing, minimizing writes.
  Future<void> setPlaylistItems(
    String playlistId,
    List<PlaylistItemDto> desiredItems,
  ) async {
    await _withErrorHandling('atualizar itens da playlist', () async {
      await _ensureCanModifyPlaylist(playlistId);

      final itemsColl = FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .collection('items');

      final existingSnap = await itemsColl.get();
      final existing = {
        for (final d in existingSnap.docs)
          d.id: PlaylistItemDto.fromFirestore(d.data(), d.id),
      };
      final desired = {for (final it in desiredItems) it.id: it};

      // Preflight: cipher existence for desired cipher_version items
      final cipherIds = <String>{};
      for (final it in desired.values) {
        final ref = it.firebaseContentId;
        if (it.type == 'cipher_version' && ref != null && ref.contains(':')) {
          cipherIds.add(ref.split(':').first);
        }
      }
      final known = await _checkExistingCiphers(cipherIds.toList());

      bool changed(PlaylistItemDto a, PlaylistItemDto b) {
        return a.type != b.type ||
            a.firebaseContentId != b.firebaseContentId ||
            a.position != b.position ||
            a.status != b.status;
      }

      final toAdd = <PlaylistItemDto>[];
      final toUpdate = <PlaylistItemDto>[];
      final toDelete = <String>[];

      // Build adds/updates
      for (final entry in desired.entries) {
        var item = entry.value;

        // Ensure placeholder for unknown cipher
        if (item.type == 'cipher_version') {
          final ref = item.firebaseContentId;
          final cipherId = (ref != null && ref.contains(':'))
              ? ref.split(':').first
              : null;
          if (cipherId == null || !known.contains(cipherId)) {
            item = item.copyWith(
              type: 'unknown_cipher',
              status: 'unknown',
              displayFallback: {
                'originalRef': ref,
                'title': 'Cifra indisponível',
              },
            );
          }
        }

        if (!existing.containsKey(entry.key)) {
          toAdd.add(item);
          continue;
        }
        final prev = existing[entry.key]!;
        if (changed(item, prev)) {
          toUpdate.add(item);
        }
      }

      // Build deletes
      for (final id in existing.keys) {
        if (!desired.containsKey(id)) toDelete.add(id);
      }

      // Commit in chunks
      const maxPerBatch = 450;
      final ops = <void Function(WriteBatch)>[];
      for (final it in toAdd) {
        final ref = itemsColl.doc(it.id);
        ops.add((b) => b.set(ref, it.toFirestore(playlistId)));
      }
      for (final it in toUpdate) {
        final ref = itemsColl.doc(it.id);
        ops.add(
          (b) =>
              b.set(ref, it.toFirestore(playlistId), SetOptions(merge: true)),
        );
      }
      for (final id in toDelete) {
        final ref = itemsColl.doc(id);
        ops.add((b) => b.delete(ref));
      }

      for (var i = 0; i < ops.length; i += maxPerBatch) {
        final chunk = ops.sublist(i, (i + maxPerBatch).clamp(0, ops.length));
        final batch = FirebaseFirestore.instance.batch();
        for (final op in chunk) {
          op(batch);
        }
        await batch.commit();
      }

      await FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .update({
            'updatedAt': FieldValue.serverTimestamp(),
            'itemCount': desiredItems.length,
          });

      await FirebaseAnalytics.instance.logEvent(
        name: 'playlist_items_updated',
        parameters: {
          'playlistId': playlistId,
          'adds': toAdd.length,
          'updates': toUpdate.length,
          'deletes': toDelete.length,
        },
      );
    });
  }

  // ========= HELPERS =========
  /// Returns the set of cipherIds that exist in publicCiphers collection.
  Future<Set<String>> _checkExistingCiphers(List<String> cipherIds) async {
    if (cipherIds.isEmpty) return <String>{};
    final firestore = FirebaseFirestore.instance;
    final results = <String>{};
    // Firestore supports up to 10 in 'whereIn'; do in chunks to avoid limits if needed later.
    // For now, read individually to keep it simple and explicit.
    for (final id in cipherIds.toSet()) {
      final doc = await firestore.collection('publicCiphers').doc(id).get();
      if (doc.exists) results.add(id);
    }
    return results;
  }
}

enum CipherPublishGuard { adminOnly, ownerOrAdmin, collaboratorsWithEdit }
