import '../helpers/database.dart';
import '../models/domain/playlist/flow_item.dart';

class FlowItemRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ===== CREATE =====
  Future<int> createFlowItem(
    int playlistId,
    String? firebaseContentId,
    String title,
    String content,
    int position,
  ) async {
    final db = await _databaseHelper.database;

    return await db.insert('playlist_text', {
      'playlist_id': playlistId,
      'firebase_id': firebaseContentId,
      'title': title,
      'content': content,
      'position': position,
    });
  }

  // ===== READ =====
  Future<FlowItem?> getFlowItem(int id) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'playlist_text',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return FlowItem.fromFirestore(results.first);
    }
    return null;
  }

  Future<FlowItem?> getFlowItemByFirebaseId(String firebaseId) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'playlist_text',
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );

    if (results.isNotEmpty) {
      return FlowItem.fromFirestore(results.first);
    }
    return null;
  }

  Future<Map<int, FlowItem>> getFlowItemsByIds(List<int> ids) async {
    final db = await _databaseHelper.database;
    Map<int, FlowItem> flowItems = {};

    final placeholders = List.filled(ids.length, '?').join(',');
    final results = await db.query(
      'playlist_text',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );

    for (final row in results) {
      flowItems[row['id'] as int] = FlowItem.fromFirestore(row);
    }

    return flowItems;
  }

  Future<List<FlowItem>> getFlowItemsByPlaylistId(int playlistId) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'playlist_text',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'position ASC',
    );

    return results.map((row) => FlowItem.fromFirestore(row)).toList();
  }

  // ===== UPDATE =====
  Future<void> updateFlowItem(
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
          throw Exception(
            'Failed to update text section with id $id - no rows affected',
          );
        }
      }
    });
  }

  // ===== DELETE =====
  Future<void> deleteFlowItem(int id) async {
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
}
