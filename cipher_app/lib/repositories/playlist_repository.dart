import '../helpers/database_helper.dart';
import '../models/domain/playlist.dart';

class PlaylistRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ===== PLAYLIST CRUD =====
  Future<int> createPlaylist(Playlist playlist) async {
    final db = await _databaseHelper.database;
    
    return await db.transaction((txn) async {
      // 1. Insert the playlist (basic info only)
      final playlistId = await txn.insert('playlist', playlist.toDatabaseJson());
      
      // 2. Insert cipher relationships if any
      if (playlist.cipherIds.isNotEmpty) {
        for (int i = 0; i < playlist.cipherIds.length; i++) {
          await txn.insert('playlist_cipher', {
            'cipher_id': playlist.cipherIds[i],
            'playlist_id': playlistId,
            'includer_id': int.parse(playlist.createdBy), // Creator adds initial ciphers
            'position': i,
            'included_at': DateTime.now().toIso8601String(),
          });
        }
      }
      
      // 3. Insert collaborator relationships if any
      if (playlist.collaborators.isNotEmpty) {
        for (String collaboratorId in playlist.collaborators) {
          await txn.insert('user_playlist', {
            'user_id': int.parse(collaboratorId),
            'playlist_id': playlistId,
            'role': 'collaborator',
            'added_by': int.parse(playlist.createdBy),
            'added_at': DateTime.now().toIso8601String(),
          });
        }
      }
      
      return playlistId;
    });
  }

  // Get all playlists for a user (owned + collaborated)
  Future<List<Playlist>> getUserPlaylists(int userId) async {
    final db = await _databaseHelper.database;
    
    // Get playlists where user is owner or collaborator
    final playlistResults = await db.rawQuery('''
      SELECT DISTINCT p.* FROM playlist p
      LEFT JOIN user_playlist up ON p.id = up.playlist_id
      WHERE p.author_id = ? OR up.user_id = ?
      ORDER BY p.updated_at DESC
    ''', [userId, userId]);
    
    List<Playlist> playlists = [];
    
    for (Map<String, dynamic> playlistData in playlistResults) {
      // Get cipher IDs for this playlist
      final cipherResults = await db.rawQuery('''
        SELECT cipher_id FROM playlist_cipher 
        WHERE playlist_id = ? 
        ORDER BY position
      ''', [playlistData['id']]);
      
      final cipherIds = cipherResults.map((row) => row['cipher_id'] as int).toList();
      
      // Get collaborator IDs for this playlist
      final collaboratorResults = await db.rawQuery('''
        SELECT user_id FROM user_playlist 
        WHERE playlist_id = ?
      ''', [playlistData['id']]);
      
      final collaborators = collaboratorResults.map((row) => row['user_id'].toString()).toList();
      
      // Build complete playlist object
      final playlist = Playlist(
        id: playlistData['id'] as int,
        name: playlistData['name'] as String,
        description: playlistData['description'] as String?,
        createdBy: playlistData['author_id'].toString(),
        createdAt: DateTime.parse(playlistData['created_at'] as String),
        updatedAt: DateTime.parse(playlistData['updated_at'] as String),
        cipherIds: cipherIds,
        collaborators: collaborators,
      );
      
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
    
    final playlistData = playlistResults.first;
    
    // Get cipher IDs
    final cipherResults = await db.rawQuery('''
      SELECT cipher_id FROM playlist_cipher 
      WHERE playlist_id = ? 
      ORDER BY position
    ''', [playlistId]);
    
    final cipherIds = cipherResults.map((row) => row['cipher_id'] as int).toList();
    
    // Get collaborators
    final collaboratorResults = await db.rawQuery('''
      SELECT user_id FROM user_playlist 
      WHERE playlist_id = ?
    ''', [playlistId]);
    
    final collaborators = collaboratorResults.map((row) => row['user_id'].toString()).toList();
    
    return Playlist(
      id: playlistData['id'] as int,
      name: playlistData['name'] as String,
      description: playlistData['description'] as String?,
      createdBy: playlistData['author_id'].toString(),
      createdAt: DateTime.parse(playlistData['created_at'] as String),
      updatedAt: DateTime.parse(playlistData['updated_at'] as String),
      cipherIds: cipherIds,
      collaborators: collaborators,
    );
  }

  // ===== CIPHER MANAGEMENT =====
  Future<void> addCipherToPlaylist(int playlistId, int cipherId, int includerId) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Get current max position
      final positionResult = await txn.rawQuery('''
        SELECT COALESCE(MAX(position), -1) + 1 as next_position 
        FROM playlist_cipher 
        WHERE playlist_id = ?
      ''', [playlistId]);
      
      final nextPosition = positionResult.first['next_position'] as int;
      
      // Insert cipher relationship
      await txn.insert('playlist_cipher', {
        'cipher_id': cipherId,
        'playlist_id': playlistId,
        'includer_id': includerId,
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

  Future<void> removeCipherFromPlaylist(int playlistId, int cipherId) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Remove cipher relationship
      await txn.delete(
        'playlist_cipher',
        where: 'playlist_id = ? AND cipher_id = ?',
        whereArgs: [playlistId, cipherId],
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

  Future<void> reorderPlaylistCiphers(int playlistId, List<int> newCipherOrder) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Update positions for all ciphers
      for (int i = 0; i < newCipherOrder.length; i++) {
        await txn.update(
          'playlist_cipher',
          {'position': i},
          where: 'playlist_id = ? AND cipher_id = ?',
          whereArgs: [playlistId, newCipherOrder[i]],
        );
      }
      
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
  Future<void> addCollaboratorToPlaylist(int playlistId, int userId, int addedBy) async {
    final db = await _databaseHelper.database;
    
    await db.insert('user_playlist', {
      'user_id': userId,
      'playlist_id': playlistId,
      'role': 'collaborator',
      'added_by': addedBy,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeCollaboratorFromPlaylist(int playlistId, int userId) async {
    final db = await _databaseHelper.database;
    
    await db.delete(
      'user_playlist',
      where: 'playlist_id = ? AND user_id = ?',
      whereArgs: [playlistId, userId],
    );
  }
}