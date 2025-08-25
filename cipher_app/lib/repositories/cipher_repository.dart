import '../helpers/database_helper.dart';
import '../models/domain/cipher.dart';

class CipherRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // === CORE CIPHER OPERATIONS ===

  Future<List<Cipher>> getAllCiphers() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'cipher',
      where: 'is_deleted = 0',
      orderBy: 'created_at DESC',
    );

    return Future.wait(results.map((row) => _buildCipher(row)));
  }

  Future<Cipher?> getCipherById(int id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'cipher',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return _buildCipher(results.first);
  }

  Future<int> insertCipher(Cipher cipher) async {
    final db = await _databaseHelper.database;
    return await db.insert('cipher', cipher.toJson());
  }

  Future<void> updateCipher(Cipher cipher) async {
    final db = await _databaseHelper.database;
    await db.update(
      'cipher',
      cipher.toJson()..['updated_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [cipher.id],
    );
  }

  Future<void> deleteCipher(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'cipher',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // === CIPHER MAP OPERATIONS ===

  Future<List<CipherMap>> getCipherMaps(int cipherId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'cipher_map',
      where: 'cipher_id = ?',
      whereArgs: [cipherId],
      orderBy: 'id',
    );

    return Future.wait(results.map((row) => _buildCipherMap(row)));
  }

  Future<int> insertCipherMap(CipherMap map) async {
    final db = await _databaseHelper.database;
    return await db.insert('cipher_map', map.toJson());
  }

  Future<void> updateCipherMap(CipherMap map) async {
    final db = await _databaseHelper.database;
    await db.update(
      'cipher_map',
      map.toJson(),
      where: 'id = ?',
      whereArgs: [map.id],
    );
  }

  Future<void> deleteCipherMap(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('cipher_map', where: 'id = ?', whereArgs: [id]);
  }

  // === MAP CONTENT OPERATIONS ===

  Future<List<MapContent>> getMapContent(int mapId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'map_content',
      where: 'map_id = ?',
      whereArgs: [mapId],
      orderBy: 'content_type',
    );

    return results.map((row) => MapContent.fromJson(row)).toList();
  }

  Future<int> insertMapContent(MapContent content) async {
    final db = await _databaseHelper.database;
    return await db.insert('map_content', content.toJson());
  }

  Future<void> updateMapContent(MapContent content) async {
    final db = await _databaseHelper.database;
    await db.update(
      'map_content',
      content.toJson(),
      where: 'id = ?',
      whereArgs: [content.id],
    );
  }

  Future<void> deleteMapContent(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('map_content', where: 'id = ?', whereArgs: [id]);
  }

  // === PRIVATE HELPERS ===

  Future<Cipher> _buildCipher(Map<String, dynamic> row) async {
    final maps = await getCipherMaps(row['id']);
    return Cipher.fromJson(row).copyWith(maps: maps);
  }

  Future<CipherMap> _buildCipherMap(Map<String, dynamic> row) async {
    final content = await getMapContent(row['id']);
    return CipherMap.fromJson(row).copyWith(content: content);
  }
}
