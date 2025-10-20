import '../helpers/database.dart';
import '../models/domain/playlist/playlist.dart';
import '../models/domain/playlist/playlist_item.dart';

class PlaylistRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static int? _currentUserId;

  // Static method to set current user ID (for testing and app initialization)
  static void setCurrentUserId(int userId) {
    _currentUserId = userId;
  }

  // Static method to get current user ID
  static int? getCurrentUserId() {
    return _currentUserId;
  }

  // ===== PLAYLIST CRUD =====
  // Creates a new playlist, as well as the playlist_cipher, and user_playlist relational objects
  Future<int> createPlaylist(Playlist playlist) async {
    final db = await _databaseHelper.database;

    return await db.transaction((txn) async {
      // 1. Insert the playlist (basic info only)
      final playlistId = await txn.insert(
        'playlist',
        playlist.toDatabaseJson(),
      );

      // 2. Insert playlist items if any
      for (final item in playlist.items) {
        switch (item.type) {
          case 'cipher_version':
            await txn.insert('playlist_version', {
              'version_id': item.contentId,
              'playlist_id': playlistId,
              'includer_id': playlist.createdBy,
              'position': item.position,
              'included_at': DateTime.now().toIso8601String(),
            });
            break;
          case 'text_section':
            // Handle text sections if they exist
            // For now, just skip as we're removing text sections
            break;
        }
      }

      // 3. Insert collaborator relationships if any
      if (playlist.collaborators.isNotEmpty) {
        for (String collaboratorId in playlist.collaborators) {
          await txn.insert('user_playlist', {
            'user_id': int.parse(collaboratorId),
            'playlist_id': playlistId,
            'role': 'collaborator',
            'added_by': playlist.createdBy,
            'added_at': DateTime.now().toIso8601String(),
          });
        }
      }

      return playlistId;
    });
  }

  // Get all playlists stored in the database
  Future<List<Playlist>> getAllPlaylists() async {
    final db = await _databaseHelper.database;

    // Get playlists
    final playlistResults = await db.rawQuery('''
      SELECT p.* FROM playlist p
      ORDER BY p.updated_at DESC
    ''');

    List<Playlist> playlists = [];

    for (Map<String, dynamic> playlistData in playlistResults) {
      final playlist = await buildPlaylist(playlistData);
      playlists.add(playlist);
    }

    return playlists;
  }

  // Get single playlist by ID with all relationships
  Future<Playlist?> getPlaylistById(int playlistId) async {
    final db = await _databaseHelper.database;

    final playlistResults = await db.query(
      'playlist',
      where: 'id = ?',
      whereArgs: [playlistId],
    );

    if (playlistResults.isEmpty) return null;
    return await buildPlaylist(playlistResults.first);
  }

  // Update playlist, for name and description
  Future<void> updatePlaylist(
    int playlistId,
    Map<String, dynamic> changes,
  ) async {
    final db = await _databaseHelper.database;

    changes['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      'playlist',
      changes,
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  // Upsert playlist - Universal compatibility (works on all Android/iOS versions)
  Future<int> upsertPlaylist(Playlist playlist) async {
    final db = await _databaseHelper.database;

    // First, try to find existing playlist by firebase_id
    final existingResult = await db.query(
      'playlist',
      columns: ['id'],
      where: 'firebase_id = ?',
      whereArgs: [playlist.firebaseId],
    );

    if (existingResult.isNotEmpty) {
      // Update existing playlist
      final playlistId = existingResult.first['id'] as int;

      await db.update(
        'playlist',
        {
          'name': playlist.name,
          'description': playlist.description,
          'is_public': (playlist.isPublic ?? false) ? 1 : 0,
          'updated_at': playlist.updatedAt!.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [playlistId],
      );
      return playlistId;
    } else {
      // Insert new playlist
      final playlistId = await db.insert(
        'playlist',
        playlist.toDatabaseJson() as Map<String, Object?>,
      );
      return playlistId;
    }
  }

  // Delete playlist
  Future<void> deletePlaylist(int playlistId) async {
    final db = await _databaseHelper.database;

    await db.delete('playlist', where: 'id = ?', whereArgs: [playlistId]);
    await db.delete(
      'playlist_version',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    await db.delete(
      'user_playlist',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
  }

  // ===== VERSION MANAGEMENT =====
  Future<void> addVersionToPlaylist(
    int playlistId,
    int cipherMapId, {
    int? includerId,
  }) async {
    final db = await _databaseHelper.database;
    final effectiveIncluderId = includerId ?? _currentUserId ?? 1;

    await db.transaction((txn) async {
      // Get current max position
      final positionResult = await txn.rawQuery(
        '''
        SELECT COALESCE(MAX(position), -1) + 1 as next_position 
        FROM playlist_version 
        WHERE playlist_id = ?
      ''',
        [playlistId],
      );

      final nextPosition = positionResult.first['next_position'] as int;

      // Insert version relationship
      await txn.insert('playlist_version', {
        'version_id': cipherMapId,
        'playlist_id': playlistId,
        'includer_id': effectiveIncluderId,
        'position': nextPosition,
        'included_at': DateTime.now().toIso8601String(),
      });

      // Update playlist timestamp
      await txn.update(
        'playlist',
        {'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    });
  }

  /// Adds a version to a specific position in the playlist (used when importing)
  Future<void> addVersionToPlaylistAtPosition(
    int playlistId,
    int cipherMapId,
    int position, {
    int? includerId,
  }) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Insert version relationship at the desired position
      await txn.insert('playlist_version', {
        'version_id': cipherMapId,
        'playlist_id': playlistId,
        'includer_id': includerId,
        'position': position,
        'included_at': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Upserts a version's position in a playlist
  Future<void> updatePlaylistVersionPosition(
    int playlistVersionId,
    int newPosition,
  ) async {
    final db = await _databaseHelper.database;

    await db.update(
      'playlist_version',
      {'position': newPosition},
      where: 'id = ?',
      whereArgs: [playlistVersionId],
    );
  }

  Future<void> removeVersionFromPlaylist(int itemId, int playlistId) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Remove cipher map relationship
      await txn.delete(
        'playlist_version',
        where: 'id = ?',
        whereArgs: [itemId],
      );

      // Update playlist timestamp
      await txn.update(
        'playlist',
        {'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    });
  }

  // ===== COLLABORATOR MANAGEMENT =====
  /// Adds a collaborator to a playlist
  Future<void> addCollaborator(int playlistId, int userId, String role) async {
    final db = await _databaseHelper.database;
    final currentUserId = _currentUserId ?? 1; // Default to 1 if not set

    await db.insert('user_playlist', {
      'user_id': userId,
      'playlist_id': playlistId,
      'role': role,
      'added_by': currentUserId,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  /// Gets collaborators for a playlist
  Future<List<String>> getCollaborators(int playlistId) async {
    final db = await _databaseHelper.database;
    // Get collaborator IDs for this playlist
    final collaboratorResults = await db.rawQuery(
      '''
        SELECT user_id FROM user_playlist 
        WHERE playlist_id = ?
      ''',
      [playlistId],
    );

    return collaboratorResults.map((row) => row['user_id'].toString()).toList();
  }

  // ===== UNIFIED PLAYLIST ITEMS =====
  /// Saves playlist items from a list
  Future<void> savePlaylistOrder(
    int playlistId,
    List<PlaylistItem> items,
  ) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final tempPosition = -(i + 1000);
        if (item.isCipherVersion) {
          await txn.update(
            'playlist_version',
            {'position': tempPosition},
            where: 'playlist_id = ? AND version_id = ?',
            whereArgs: [playlistId, item.contentId],
          );
        } else if (item.isTextSection) {
          await txn.update(
            'playlist_text',
            {'position': tempPosition},
            where: 'id = ?',
            whereArgs: [item.contentId],
          );
        }
      }

      for (var item in items) {
        if (item.isCipherVersion) {
          await txn.update(
            'playlist_version',
            {'position': item.position},
            where: 'playlist_id = ? AND version_id = ?',
            whereArgs: [playlistId, item.contentId],
          );
        } else if (item.isTextSection) {
          await txn.update(
            'playlist_text',
            {'position': item.position},
            where: 'id = ?',
            whereArgs: [item.contentId],
          );
        }
      }
    });
  }

  /// Gets all items of a playlist in order
  Future<List<PlaylistItem>> getItemsOfPlaylist(int playlistId) async {
    final versionItems = await getVersionItemsOfPlaylist(playlistId);
    final textItems = await getTextItemsOfPlaylist(playlistId);

    // Combine and sort all items by position
    final allItemResults = [...versionItems, ...textItems]
      ..sort((a, b) => (a.position).compareTo(b.position));
    return allItemResults;
  }

  /// Gets text items of a playlist
  Future<List<PlaylistItem>> getTextItemsOfPlaylist(int playlistId) async {
    final db = await _databaseHelper.database;

    final textSectionResults = await db.rawQuery(
      '''
        SELECT id as content_id, position, 'text_section' as type, id
        FROM playlist_text 
        WHERE playlist_id = ? 
        ORDER BY position ASC
      ''',
      [playlistId],
    );

    return textSectionResults.map((row) {
      final id = row['id'] as int;
      final contentId = row['content_id'] as int;
      final position = row['position'] as int;

      return PlaylistItem.textSection(contentId, position, id);
    }).toList();
  }

  /// Gets version items of a playlist
  Future<List<PlaylistItem>> getVersionItemsOfPlaylist(int playlistId) async {
    final db = await _databaseHelper.database;

    final versionResults = await db.rawQuery(
      '''
        SELECT version_id as content_id, position, 'cipher_version' as type, id
        FROM playlist_version 
        WHERE playlist_id = ? 
        ORDER BY position ASC
      ''',
      [playlistId],
    );

    return versionResults.map((row) {
      final id = row['id'] as int;
      final contentId = row['content_id'] as int;
      final position = row['position'] as int;

      return PlaylistItem.cipherVersion(contentId, position, id);
    }).toList();
  }

  /// Gets version item ID in a playlist by playlist and version IDs
  Future<int?> getPlaylistVersionId(int playlistId, int versionId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'playlist_version',
      columns: ['id'],
      where: 'playlist_id = ? AND version_id = ?',
      whereArgs: [playlistId, versionId],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return null;
    }
  }

  /// Inserts or updates a text item in a playlist - Universal compatibility
  Future<void> upsertTextItem(
    int addedBy,
    String firebaseTextId,
    int playlistId,
    String title,
    String content,
    int position,
  ) async {
    final db = await _databaseHelper.database;

    // First, try to find existing text item by firebase_id
    final existingResult = await db.query(
      'playlist_text',
      columns: ['id'],
      where: 'firebase_id = ?',
      whereArgs: [firebaseTextId],
    );

    if (existingResult.isNotEmpty) {
      // Update existing text item
      await db.update(
        'playlist_text',
        {'title': title, 'content': content, 'position': position},
        where: 'firebase_id = ?',
        whereArgs: [firebaseTextId],
      );
    } else {
      // Insert new text item
      await db.insert('playlist_text', {
        'added_by': addedBy,
        'firebase_id': firebaseTextId,
        'playlist_id': playlistId,
        'title': title,
        'content': content,
        'position': position,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ===== UTILS =====
  /// Build playlist domain object from database row
  Future<Playlist> buildPlaylist(Map<String, dynamic> playlistRow) async {
    final items = await getItemsOfPlaylist(playlistRow['id'] as int);
    final collaborators = await getCollaborators(playlistRow['id'] as int);

    return Playlist(
      id: playlistRow['id'] as int,
      firebaseId: playlistRow['firebase_id'] as String?,
      isPublic: playlistRow['is_public'] == 1,
      name: playlistRow['name'] as String,
      description: playlistRow['description'] as String?,
      createdBy: playlistRow['author_id'] as int,
      createdAt: DateTime.parse(playlistRow['created_at'] as String),
      updatedAt: DateTime.parse(playlistRow['updated_at'] as String),
      collaborators: collaborators,
      items: items,
    );
  }
}
