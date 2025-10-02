import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/utils/color.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/database.dart';
import '../models/domain/cipher/cipher.dart';

class LocalCipherRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // === CORE CIPHER OPERATIONS ===
  Future<List<Cipher>> getAllCiphersPruned() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'cipher',
      where: 'is_deleted = 0',
      orderBy: 'created_at DESC',
    );

    return Future.wait(results.map((row) => _buildPrunedCipher(row)));
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
          await _addTagInTransaction(txn, cipherId, tagTitle);
        }
      }
      return cipherId;
    });
  }

  Future<int> insertWholeCipher(Cipher cipher) async {
    final db = await _databaseHelper.database;

    return await db.transaction((txn) async {
      // Insert the cipher
      final cipherId = await txn.insert('cipher', cipher.toJson());

      // Insert tags if any
      if (cipher.tags.isNotEmpty) {
        for (final tagTitle in cipher.tags) {
          await _addTagInTransaction(txn, cipherId, tagTitle);
        }
      }

      // Insert versions and their sections
      for (final version in cipher.versions) {
        final versionId = await _insertVersionInTransaction(
          txn,
          cipherId,
          version,
        );

        for (final section in version.sections!.values) {
          await _insertSectionInTransaction(txn, versionId, section);
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
          await _addTagInTransaction(txn, cipher.id!, tagTitle);
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

  // === VERSION OPERATIONS ===
  Future<List<Version>> getVersions(int cipherId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'version',
      where: 'cipher_id = ?',
      whereArgs: [cipherId],
      orderBy: 'id',
    );

    return Future.wait(results.map((row) => _buildCipherVersion(row)));
  }

  Future<Version?> getVersionWithId(int versionId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'version',
      where: 'id = ?',
      whereArgs: [versionId],
    );

    Version version = await (_buildCipherVersion(result[0]));

    return version;
  }

  Future<Cipher?> getCipherWithVersionId(int versionId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'version',
      where: 'id = ?',
      whereArgs: [versionId],
    );
    return getCipherById(result[0]['cipher_id'] as int);
  }

  Future<List<Version>> getVersionsByIds(List<int> versionIds) async {
    if (versionIds.isEmpty) return [];

    final db = await _databaseHelper.database;
    final placeholders = versionIds.map((_) => '?').join(',');
    final results = await db.query(
      'version',
      where: 'id IN ($placeholders)',
      whereArgs: versionIds,
      orderBy: 'id',
    );

    return Future.wait(results.map((row) => _buildCipherVersion(row)));
  }

  Future<int> insertVersionToCipher(Version map) async {
    final db = await _databaseHelper.database;
    return await db.insert('version', map.toJson());
  }

  Future<void> updateVersion(Version version) async {
    final db = await _databaseHelper.database;
    await db.update(
      'version',
      version.toJson(),
      where: 'id = ?',
      whereArgs: [version.id],
    );
  }

  Future<void> updateFieldOfVersion(
    int versionId,
    Map<String, dynamic> field,
  ) async {
    final db = await _databaseHelper.database;
    await db.update('version', field, where: 'id = ?', whereArgs: [versionId]);
  }

  Future<void> deleteVersion(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('version', where: 'id = ?', whereArgs: [id]);
  }

  // === SECTION OPERATIONS ===
  Future<Map<String, Section>> getAllSections(int mapId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'section',
      where: 'version_id = ?',
      whereArgs: [mapId],
      orderBy: 'content_code',
    );

    final sections = <String, Section>{};
    for (var row in results) {
      sections[row['content_code'] as String] = Section.fromJson({
        'id': row['id'] as int,
        'version_id': mapId,
        'content_type': row['content_type'] as String,
        'content_code': row['content_code'] as String,
        'content_text': row['content_text'] as String,
        'content_color': row['content_color'] as String,
      });
    }
    return sections;
  }

  Future<int> insertSection(
    int mapId,
    String contentType,
    String contentCode,
    String contentText,
    String hexColor,
  ) async {
    final db = await _databaseHelper.database;
    return await db.insert('section', {
      'version_id': mapId,
      'content_type': contentType,
      'content_code': contentCode,
      'content_text': contentText,
      'content_color': hexColor,
    });
  }

  Future<void> updateSection(
    int mapId,
    String contentType,
    String contentCode,
    String contentText,
    String hexColor,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'section',
      {
        'content_type': contentType,
        'content_code': contentCode,
        'content_text': contentText,
        'content_color': hexColor,
      },
      where: 'version_id = ? AND content_code = ?',
      whereArgs: [mapId, contentCode],
    );
  }

  Future<void> deleteSection(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('section', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllVersionSections(int mapId) async {
    final db = await _databaseHelper.database;
    await db.delete('section', where: 'version_id = ?', whereArgs: [mapId]);
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
    final version = await getVersions(row['id']);
    final tags = await getCipherTags(row['id']);

    return Cipher.fromJson(row).copyWith(versions: version, tags: tags);
  }

  Future<Cipher> _buildPrunedCipher(Map<String, dynamic> row) async {
    final tags = await getCipherTags(row['id']);

    return Cipher.fromJson(row).copyWith(tags: tags);
  }

  Future<Version> _buildCipherVersion(Map<String, dynamic> row) async {
    final section = await getAllSections(row['id']);
    return Version.fromRow(row).copyWith(content: section);
  }

  // Helper method to add tags within a transaction
  Future<void> _addTagInTransaction(
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

  /// Insert version of cipher within a transaction
  Future<int> _insertVersionInTransaction(
    Transaction txn,
    int cipherId,
    Version version,
  ) async {
    final versionId = await txn.insert(
      'version',
      version.toJson()..['cipher_id'] = cipherId,
    );
    return versionId;
  }

  /// Insert section of version of cipher within a transaction
  Future<void> _insertSectionInTransaction(
    Transaction txn,
    int versionId,
    Section section,
  ) async {
    await txn.insert('section', {
      'version_id': versionId,
      'content_type': section.contentType,
      'content_code': section.contentCode,
      'content_text': section.contentText,
      'content_color': colorToHex(section.contentColor),
    });
  }
}
