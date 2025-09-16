import '../helpers/database.dart';
import '../models/domain/playlist/playlist_text_section.dart';

class TextSectionRepository {
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

  // ===== CRUD =====
  Future<int> createPlaylistText(
    int playlistId,
    String title,
    String content,
    int position,
    int? includerId,
  ) async {
    final db = await _databaseHelper.database;
    final effectiveIncluderId = includerId ?? _currentUserId ?? 1;

    return await db.insert('playlist_text', {
      'playlist_id': playlistId,
      'title': title,
      'content': content,
      'position': position,
      'added_by': effectiveIncluderId,
    });
  }

  Future<void> updatePlaylistText(
    int id, {
    String? title,
    String? content,
    int? position,
  }) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (position != null) updates['position'] = position;

      if (updates.isNotEmpty) {
        
        final result = await txn.update(
          'playlist_text',
          updates,
          where: 'id = ?',
          whereArgs: [id],
        );
        
        if (result == 0) {
          throw Exception('Failed to update text section with id $id - no rows affected');
        }
      }
    });
  }

  Future<void> deletePlaylistText(int id) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // First, get the position and playlist_id of the item being deleted
      final result = await txn.query(
        'playlist_text',
        columns: ['position', 'playlist_id'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        final deletedPosition = result.first['position'] as int;
        final playlistId = result.first['playlist_id'] as int;

        // Delete the text section
        await txn.delete('playlist_text', where: 'id = ?', whereArgs: [id]);

        // Adjust positions of items that come after the deleted item
        await txn.rawUpdate(
          'UPDATE playlist_text SET position = position - 1 WHERE playlist_id = ? AND position > ?',
          [playlistId, deletedPosition],
        );

        // Also adjust positions in playlist_version table for the same playlist
        await txn.rawUpdate(
          'UPDATE playlist_version SET position = position - 1 WHERE playlist_id = ? AND position > ?',
          [playlistId, deletedPosition],
        );
      }
    });
  }

  Future<TextSection?> getTextSection(int id) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'playlist_text',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return TextSection.fromJson(results.first);
    }
    return null;
  }

  Future<Map<int, TextSection>> getTextSections(List<int> ids) async {
    final db = await _databaseHelper.database;
    Map<int, TextSection> textSections = {};

    final placeholders = List.filled(ids.length, '?').join(',');
    final results = await db.query(
      'playlist_text',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );

    for (final row in results) {
      textSections[row['id'] as int] = TextSection.fromJson(row);
    }

    return textSections;
  }
}
