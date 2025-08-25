import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import '../models/domain/cipher.dart';

class CipherRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get all ciphers
  Future<List<Cipher>> getAllCiphers() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'cipher',
      orderBy: 'created_at DESC',
    );

    List<Cipher> ciphers = [];
    for (var map in maps) {
      final cipher = await _buildCipherFromMap(map);
      ciphers.add(cipher);
    }

    return ciphers;
  }

  // Get cipher by ID
  Future<Cipher?> getCipherById(int id) async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'cipher',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return await _buildCipherFromMap(maps.first);
    }
    return null;
  }

  // Insert a new cipher
  Future<int> insertCipher(Cipher cipher) async {
    final db = await _databaseHelper.database;

    return await db.transaction((txn) async {
      // Insert cipher
      final cipherId = await txn.insert('cipher', {
        'title': cipher.title,
        'author': cipher.author,
        'tempo': cipher.tempo,
        'music_key': cipher.musicKey,
        'language': cipher.language,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Insert tags
      for (String tag in cipher.tags) {
        await _insertOrGetTagId(txn, tag, cipherId);
      }

      // Insert map
      // for (CipherMap map in cipher.maps) {
      //   await _insertOrGetMapId(txn, map, cipherId);
      // }

      return cipherId;
    });
  }

  // Update cipher
  Future<int> updateCipher(Cipher cipher) async {
    final db = await _databaseHelper.database;

    return await db.transaction((txn) async {
      // Update cipher
      final result = await txn.update(
        'cipher',
        {
          'title': cipher.title,
          'author': cipher.author,
          'tempo': cipher.tempo,
          'music_key': cipher.musicKey,
          'language': cipher.language,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [cipher.id],
      );

      // Delete existing tags
      await txn.delete(
        'cipher_tags',
        where: 'cipher_id = ?',
        whereArgs: [cipher.id],
      );

      // Insert new tags
      for (String tag in cipher.tags) {
        await _insertOrGetTagId(txn, tag, cipher.id!);
      }

      return result;
    });
  }

  // Delete cipher
  Future<int> deleteCipher(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('cipher', where: 'id = ?', whereArgs: [id]);
  }

  // Helper method to build Cipher object from database map
  Future<Cipher> _buildCipherFromMap(Map<String, dynamic> map) async {
    final db = await _databaseHelper.database;

    // Get tags for this cipher
    final tagMaps = await db.rawQuery(
      '''
      SELECT t.title FROM tag t
      INNER JOIN cipher_tags ct ON t.id = ct.tag_id
      WHERE ct.cipher_id = ?
    ''',
      [map['id']],
    );

    final tags = tagMaps.map((tagMap) => tagMap['title'] as String).toList();

    return Cipher(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      tempo: map['tempo'],
      musicKey: map['music_key'],
      language: map['language'],
      tags: tags,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isLocal: true, // Since it's from local database
      maps: [], // Empty for now, you can populate this later
      // You'll need to add musicMaps loading here when you implement the content system
      // maps: await _getMapsForCipher(map['id']),
    );
  }

  // Helper method to insert or get existing tag
  Future<void> _insertOrGetTagId(
    Transaction txn,
    String tagTitle,
    int cipherId,
  ) async {
    // Check if tag exists
    final existingTags = await txn.query(
      'tag',
      where: 'title = ?',
      whereArgs: [tagTitle],
    );

    int tagId;
    if (existingTags.isNotEmpty) {
      tagId = existingTags.first['id'] as int;
    } else {
      // Insert new tag
      tagId = await txn.insert('tag', {
        'title': tagTitle,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Link tag to cipher
    await txn.insert('cipher_tags', {
      'tag_id': tagId,
      'cipher_id': cipherId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
