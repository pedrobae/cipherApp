import 'package:sqflite/sqflite.dart';
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

    return await db.transaction((txn) async {
      // Insert the cipher
      final cipherId = await txn.insert('cipher', cipher.toJson());

      // Insert tags if any
      if (cipher.tags.isNotEmpty) {
        for (final tagTitle in cipher.tags) {
          await _addTagToCipherInTransaction(txn, cipherId, tagTitle);
        }
      }

      return cipherId;
    });
  }

  Future<void> updateCipher(Cipher cipher) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Update the cipher
      await txn.update(
        'cipher',
        cipher.toJson()..['updated_at'] = DateTime.now().toIso8601String(),
        where: 'id = ?',
        whereArgs: [cipher.id],
      );

      // Clear existing tags
      await txn.delete(
        'cipher_tags',
        where: 'cipher_id = ?',
        whereArgs: [cipher.id],
      );

      // Insert new tags
      if (cipher.tags.isNotEmpty) {
        for (final tagTitle in cipher.tags) {
          await _addTagToCipherInTransaction(txn, cipher.id!, tagTitle);
        }
      }
    });
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

  Future<Map<String, String>> getMapContent(int mapId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'map_content',
      where: 'map_id = ?',
      whereArgs: [mapId],
      orderBy: 'content_type',
    );

    final contentMap = <String, String>{};
    for (var row in results) {
      contentMap[row['content_type'] as String] = row['content_text'] as String;
    }
    return contentMap;
  }

  Future<int> insertMapContent(
    int mapId,
    String contentType,
    String contentText,
  ) async {
    final db = await _databaseHelper.database;
    return await db.insert('map_content', {
      'map_id': mapId,
      'content_type': contentType,
      'content_text': contentText,
    });
  }

  Future<void> updateMapContent(
    int mapId,
    String contentType,
    String contentText,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'map_content',
      {'content_type': contentType, 'content_text': contentText},
      where: 'map_id = ? AND content_type = ?',
      whereArgs: [mapId, contentType],
    );
  }

  Future<void> deleteMapContent(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('map_content', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllMapContent(int mapId) async {
    final db = await _databaseHelper.database;
    await db.delete('map_content', where: 'map_id = ?', whereArgs: [mapId]);
  }

  // === TAG OPERATIONS ===

  Future<List<String>> getCipherTags(int cipherId) async {
    final db = await _databaseHelper.database;
    final results = await db.rawQuery(
      '''
      SELECT t.title 
      FROM tag t
      JOIN cipher_tags ct ON t.id = ct.tag_id
      WHERE ct.cipher_id = ?
    ''',
      [cipherId],
    );

    return results.map((row) => row['title'] as String).toList();
  }

  Future<void> addTagToCipher(int cipherId, String tagTitle) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Get or create tag
      var tags = await txn.query(
        'tag',
        where: 'title = ?',
        whereArgs: [tagTitle],
      );

      int tagId;
      if (tags.isEmpty) {
        tagId = await txn.insert('tag', {
          'title': tagTitle,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        tagId = tags.first['id'] as int;
      }

      // Link to cipher (ignore if already exists)
      await txn.insert('cipher_tags', {
        'tag_id': tagId,
        'cipher_id': cipherId,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    });
  }

  Future<void> removeTagFromCipher(int cipherId, String tagTitle) async {
    final db = await _databaseHelper.database;

    await db.rawDelete(
      '''
      DELETE FROM cipher_tags 
      WHERE cipher_id = ? AND tag_id = (
        SELECT id FROM tag WHERE title = ?
      )
    ''',
      [cipherId, tagTitle],
    );
  }

  Future<List<String>> getAllTags() async {
    final db = await _databaseHelper.database;
    final results = await db.query('tag', orderBy: 'title');
    return results.map((row) => row['title'] as String).toList();
  }

  // === PRIVATE HELPERS ===

  Future<Cipher> _buildCipher(Map<String, dynamic> row) async {
    final maps = await getCipherMaps(row['id']);
    final tags = await getCipherTags(row['id']);

    return Cipher.fromJson(row).copyWith(maps: maps, tags: tags);
  }

  Future<CipherMap> _buildCipherMap(Map<String, dynamic> row) async {
    final content = await getMapContent(row['id']);
    return CipherMap.fromJson(row).copyWith(content: content);
  }

  // Helper method to add tags within a transaction
  Future<void> _addTagToCipherInTransaction(
    Transaction txn,
    int cipherId,
    String tagTitle,
  ) async {
    // Get or create tag
    var tags = await txn.query(
      'tag',
      where: 'title = ?',
      whereArgs: [tagTitle],
    );

    int tagId;
    if (tags.isEmpty) {
      tagId = await txn.insert('tag', {
        'title': tagTitle,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      tagId = tags.first['id'] as int;
    }

    // Link to cipher (ignore if already exists)
    await txn.insert('cipher_tags', {
      'tag_id': tagId,
      'cipher_id': cipherId,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
