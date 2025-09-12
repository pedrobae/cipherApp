import '../helpers/database.dart';
import '../models/domain/collaborator.dart';
import '../models/domain/user.dart';

class CollaboratorRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Fetches all collaborators for a specific playlist, including basic user details
  Future<List<Collaborator>> getPlaylistCollaborators(int playlistId) async {
    final db = await _databaseHelper.database;

    // Join user_playlist with user to get user details
    final results = await db.rawQuery(
      '''
      SELECT up.*, u.username, u.mail, u.profile_photo
      FROM user_playlist up
      JOIN user u ON up.user_id = u.id
      WHERE up.playlist_id = ?
      ORDER BY 
        CASE 
          WHEN up.role = 'owner' THEN 1
          WHEN up.role = 'editor' THEN 2
          ELSE 3
        END,
        u.username
    ''',
      [playlistId],
    );

    return results.map((map) => Collaborator.fromJson(map)).toList();
  }

  /// Adds a new collaborator to a playlist
  Future<int> addCollaborator(
    int playlistId,
    int userId,
    String instrument,
    int addedBy,
  ) async {
    final db = await _databaseHelper.database;

    // Check if the user is already a collaborator
    final existingCollaborator = await db.query(
      'user_playlist',
      where: 'playlist_id = ? AND user_id = ?',
      whereArgs: [playlistId, userId],
    );

    if (existingCollaborator.isNotEmpty) {
      // Update the instrument if the user is already a collaborator
      return updateCollaboratorInstrument(playlistId, userId, instrument);
    } else {
      // Insert a new collaborator record
      return await db.insert('user_playlist', {
        'playlist_id': playlistId,
        'user_id': userId,
        'role': instrument, // Role field stores the instrument
        'added_by': addedBy,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Updates a collaborator's instrument
  Future<int> updateCollaboratorInstrument(
    int playlistId,
    int userId,
    String instrument,
  ) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'user_playlist',
      {'role': instrument}, // Role field stores the instrument
      where: 'playlist_id = ? AND user_id = ?',
      whereArgs: [playlistId, userId],
    );
  }

  /// Removes a collaborator from a playlist
  Future<int> removeCollaborator(int playlistId, int userId) async {
    final db = await _databaseHelper.database;

    return await db.delete(
      'user_playlist',
      where: 'playlist_id = ? AND user_id = ?',
      whereArgs: [playlistId, userId],
    );
  }

  /// Finds users by email or username for adding as collaborators
  Future<List<User>> findUsersByEmailOrUsername(String query) async {
    final db = await _databaseHelper.database;

    // Search for users by email or username
    final results = await db.query(
      'user',
      where: 'mail LIKE ? OR username LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: 10,
    );

    return results.map((map) => User.fromJson(map)).toList();
  }

  /// Check if a user is a collaborator in a playlist and get their role
  Future<String?> getUserRoleInPlaylist(int playlistId, int userId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'user_playlist',
      columns: ['role'],
      where: 'playlist_id = ? AND user_id = ?',
      whereArgs: [playlistId, userId],
    );

    if (result.isNotEmpty) {
      return result.first['role'] as String?;
    }

    return null;
  }
}
