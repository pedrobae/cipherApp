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
  Future<void> createPlaylistText(
    int playlistId,
    String title,
    String content,
    int position,
    int? includerId,
  ) async {
    final db = await _databaseHelper.database;
    final effectiveIncluderId = includerId ?? _currentUserId ?? 1;

    await db.transaction((txn) async {
      final playlistTextId = txn.insert('playlist_text', {
        'playlist_id': playlistId,
        'title': title,
        'content': content,
        'position': position,
        'added_by': effectiveIncluderId,
      });
      return playlistTextId;
    });
  }

  Future<void> updatePlaylistText(
    int id,
    String? title,
    String? content,
    int? position,
  ) async {
    final db = await _databaseHelper.database;

    Map<String, dynamic> updates = {};

    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;
    if (position != null) updates['position'] = position;

    if (updates.isNotEmpty) {
      await db.update(
        'playlist_text',
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deletePlaylistText(int id) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      txn.delete('playlist_text', where: 'id = ?', whereArgs: [id]);
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

  Future<List<TextSection>> getTextSections(List<int> ids) async {
    final db = await _databaseHelper.database;

    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(',');
    final results = await db.query(
      'playlist_text',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );

    return results.map((row) => TextSection.fromJson(row)).toList();
  }
}
