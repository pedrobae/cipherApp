import '../helpers/database.dart';
import '../models/domain/info_item.dart';

class InfoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<InfoItem>> getAllInfo() async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'app_info',
      orderBy: 'published_at DESC, priority DESC',
    );

    return results.map((row) => InfoItem.fromJson(row)).toList();
  }

  Future<List<InfoItem>> getInfoByType(String type) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'app_info',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'published_at DESC, priority DESC',
    );

    return results.map((row) => InfoItem.fromJson(row)).toList();
  }

  Future<List<InfoItem>> getRecentInfo({int limit = 5}) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'app_info',
      orderBy: 'published_at DESC',
      limit: limit,
    );

    return results.map((row) => InfoItem.fromJson(row)).toList();
  }

  Future<InfoItem?> getInfoById(String remoteId) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'app_info',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    return InfoItem.fromJson(results.first);
  }

  Future<int> createInfo(InfoItem infoItem) async {
    final db = await _databaseHelper.database;

    return await db.insert('app_info', infoItem.toJson());
  }

  Future<void> updateInfo(InfoItem infoItem) async {
    final db = await _databaseHelper.database;

    await db.update(
      'app_info',
      infoItem.toJson(),
      where: 'remote_id = ?',
      whereArgs: [infoItem.id],
    );
  }

  Future<void> deleteInfo(String remoteId) async {
    final db = await _databaseHelper.database;

    await db.delete('app_info', where: 'remote_id = ?', whereArgs: [remoteId]);
  }

  Future<List<InfoItem>> searchInfo(String query) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'app_info',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'published_at DESC, priority DESC',
    );

    return results.map((row) => InfoItem.fromJson(row)).toList();
  }

  Future<void> markAsStale(String remoteId) async {
    final db = await _databaseHelper.database;

    await db.update(
      'app_info',
      {'is_stale': 1},
      where: 'remote_id = ?',
      whereArgs: [remoteId],
    );
  }

  Future<void> clearExpiredInfo() async {
    final db = await _databaseHelper.database;

    await db.delete(
      'app_info',
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }
}
