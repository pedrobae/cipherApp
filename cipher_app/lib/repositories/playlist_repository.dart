import '../helpers/database_helper.dart';
import '../models/domain/playlist.dart';

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
      final playlistId = await txn.insert('playlist', playlist.toDatabaseJson());
      
      // 2. Insert cipher map relationships if any
      if (playlist.cipherMapIds.isNotEmpty) {
        for (int i = 0; i < playlist.cipherMapIds.length; i++) {
          await txn.insert('playlist_cipher_map', {
            'cipher_map_id': playlist.cipherMapIds[i],
            'playlist_id': playlistId,
            'includer_id': int.parse(playlist.createdBy), // Creator adds initial cipher maps
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
        // Get cipher map IDs for this playlist
        final cipherMapResults = await db.rawQuery('''
          SELECT cipher_map_id FROM playlist_cipher_map 
          WHERE playlist_id = ? 
          ORDER BY position
        ''', [playlistData['id']]);
        
        final cipherMapIds = cipherMapResults.map((row) => row['cipher_map_id'] as int).toList();
        
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
          cipherMapIds: cipherMapIds,
          collaborators: collaborators,
        );      playlists.add(playlist);
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
    
    // Get cipher map IDs
    final cipherMapResults = await db.rawQuery('''
      SELECT cipher_map_id FROM playlist_cipher_map 
      WHERE playlist_id = ? 
      ORDER BY position
    ''', [playlistId]);
    
    final cipherMapIds = cipherMapResults.map((row) => row['cipher_map_id'] as int).toList();
    
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
      cipherMapIds: cipherMapIds,
      collaborators: collaborators,
    );
  }

  // Update playlist, for name and description
  Future<void> updatePlaylist(int playlistId, {String? name, String? description}) async {
      final db = await _databaseHelper.database;
      
      Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      
      await db.update(
        'playlist',
        updates,
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    }

  // Delete playlist
  Future<void> deletePlaylist(int playlistId) async {
    final db = await _databaseHelper.database;
    
    await db.delete(
      'playlist',
      where: 'id = ?',
      whereArgs: [playlistId]
    );
  }

  // ===== CIPHER MAP MANAGEMENT =====
  Future<void> addCipherMapToPlaylist(int playlistId, int cipherMapId, {int? includerId}) async {
    final db = await _databaseHelper.database;
    final effectiveIncluderId = includerId ?? _currentUserId ?? 1;
    
    await db.transaction((txn) async {
      // Get current max position
      final positionResult = await txn.rawQuery('''
        SELECT COALESCE(MAX(position), -1) + 1 as next_position 
        FROM playlist_cipher_map 
        WHERE playlist_id = ?
      ''', [playlistId]);
      
      final nextPosition = positionResult.first['next_position'] as int;
      
      // Insert cipher map relationship
      await txn.insert('playlist_cipher_map', {
        'cipher_map_id': cipherMapId,
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

  Future<void> removeCipherMapFromPlaylist(int playlistId, int cipherMapId) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Remove cipher map relationship
      await txn.delete(
        'playlist_cipher_map',
        where: 'playlist_id = ? AND cipher_map_id = ?',
        whereArgs: [playlistId, cipherMapId],
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

  Future<void> reorderPlaylistCipherMaps(int playlistId, List<int> newCipherMapOrder) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // First, set all positions to negative values to avoid constraint conflicts
      await txn.rawUpdate('''
        UPDATE playlist_cipher_map 
        SET position = -position - 1000 
        WHERE playlist_id = ?
      ''', [playlistId]);
      
      // Now update positions for all cipher maps in order
      for (int i = 0; i < newCipherMapOrder.length; i++) {
        await txn.update(
          'playlist_cipher_map',
          {'position': i},
          where: 'playlist_id = ? AND cipher_map_id = ?',
          whereArgs: [playlistId, newCipherMapOrder[i]],
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
  Future<void> addCollaborator(int playlistId, int userId, {int? addedBy}) async {
    final db = await _databaseHelper.database;
    addedBy ?? _currentUserId;
    
    await db.insert('user_playlist', {
      'user_id': userId,
      'playlist_id': playlistId,
      'role': 'collaborator',
      'added_by': addedBy,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeCollaborator(int playlistId, int userId) async {
    final db = await _databaseHelper.database;
    
    await db.delete(
      'user_playlist',
      where: 'playlist_id = ? AND user_id = ?',
      whereArgs: [playlistId, userId],
    );
  }

  // Sets local user id
  void setLocalUser(int userId) {
    _currentUserId = userId;
  }
}