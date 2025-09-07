import 'package:flutter_test/flutter_test.dart';
import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/helpers/database_factory.dart';

void main() {
  // Initialize database factory for tests
  setUpAll(() {
    DatabaseFactoryHelper.initializeForTesting();
  });

  group('DatabaseHelper Tests', () {
    test('should create database and tables', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Check if database was created
      expect(db, isNotNull);

      // Check if tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      final tableNames = tables.map((t) => t['name']).toList();

      expect(tableNames, contains('cipher'));
      expect(tableNames, contains('cipher_map'));
      expect(tableNames, contains('map_content'));
      expect(tableNames, contains('tag'));
      expect(tableNames, contains('cipher_tags'));
      expect(tableNames, contains('user'));
      expect(tableNames, contains('playlist'));
      expect(tableNames, contains('playlist_cipher_map'));
      expect(tableNames, contains('app_info'));

      // Clean up this test
      await dbHelper.resetDatabase();
    });

    test('should have correct cipher table schema', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      final schema = await db.rawQuery('PRAGMA table_info(cipher)');
      final columnNames = schema.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('title'));
      expect(columnNames, contains('author'));
      expect(columnNames, contains('tempo'));
      expect(columnNames, contains('music_key'));
      expect(columnNames, contains('language'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));

      // Clean up this test
      await dbHelper.resetDatabase();
    });

    test('debug reset functionality', () async {
      final dbHelper = DatabaseHelper();

      // Step 1: Create database and add data
      var db = await dbHelper.database;

      await db.insert('cipher', {
        'title': 'Debug Song',
        'author': 'Debug Author',
        'tempo': 'Medium',
        'music_key': 'C',
        'language': 'en',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Step 2: Reset database
      await dbHelper.resetDatabase();

      // Step 3: Get new database instance - make sure to reset any cached state
      var db1 = await dbHelper.database;

      // Step 4: Check data
      var afterReset = await db1.query('cipher');

      expect(
        afterReset.length,
        4,
        reason: 'Database should have only seed data after reset',
      );

      // Cleanup
      await dbHelper.resetDatabase();
    });

    test('should handle multiple database operations', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Insert multiple records
      await db.insert('cipher', {
        'title': 'Song 1',
        'author': 'Author 1',
        'tempo': 'Fast',
        'music_key': 'G',
        'language': 'en',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await db.insert('cipher', {
        'title': 'Song 2',
        'author': 'Author 2',
        'tempo': 'Slow',
        'music_key': 'Am',
        'language': 'pt',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Query and verify
      final ciphers = await db.query('cipher');
      expect(ciphers.length, 6);

      // Test specific queries
      final fastSongs = await db.query(
        'cipher',
        where: 'tempo = ?',
        whereArgs: ['Fast'],
      );
      expect(fastSongs.length, 1);
      expect(fastSongs.first['title'], 'Song 1');

      // Clean up this test
      await dbHelper.resetDatabase();
    });
  });

  group('Cipher Map Seed Data Tests', () {
    test('should seed cipher_map table with correct data', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Check if cipher_map records were seeded
      final cipherMaps = await db.query('cipher_map');
      expect(cipherMaps.length, 3, reason: 'Should have 5 cipher maps seeded');

      // Verify Amazing Grace maps
      final amazingGraceMaps = await db.query(
        'cipher_map',
        where: 'cipher_id = (SELECT id FROM cipher WHERE title = ?)',
        whereArgs: ['Amazing Grace'],
      );
      expect(
        amazingGraceMaps.length,
        2,
        reason: 'Amazing Grace should have 2 maps',
      );

      // Check original version
      final originalMap = amazingGraceMaps.firstWhere(
        (map) => map['version_name'] == 'Original',
      );
      expect(originalMap['song_structure'], 'V1,V2,V3,V4');
      expect(originalMap['transposed_key'], null);

      // Check transposed version
      final transposedMap = amazingGraceMaps.firstWhere(
        (map) => map['version_name'] == 'Short Version (Key of D)',
      );
      expect(transposedMap['song_structure'], 'V1,V3,V4');
      expect(transposedMap['transposed_key'], 'D');

      // Verify How Great Thou Art map
      final howGreatMaps = await db.query(
        'cipher_map',
        where: 'cipher_id = (SELECT id FROM cipher WHERE title = ?)',
        whereArgs: ['How Great Thou Art'],
      );
      expect(
        howGreatMaps.length,
        1,
        reason: 'How Great Thou Art should have 1 map',
      );
      expect(howGreatMaps.first['song_structure'], 'V1,C,V2,C,V3,C,V4,C');
      expect(howGreatMaps.first['version_name'], 'Original');

      // Clean up
      await dbHelper.resetDatabase();
    });

    test('should seed map_content with ChordPro formatted blocks', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Get cipher map IDs for testing
      final amazingGraceOriginalMap = await db.query(
        'cipher_map',
        where: '''cipher_id = (SELECT id FROM cipher WHERE title = ?) 
                  AND version_name = ?''',
        whereArgs: ['Amazing Grace', 'Original'],
      );
      expect(amazingGraceOriginalMap.length, 1);

      final mapId = amazingGraceOriginalMap.first['id'] as int;

      // Check content blocks for Amazing Grace original
      final contentBlocks = await db.query(
        'map_content',
        where: 'map_id = ?',
        whereArgs: [mapId],
        orderBy: 'content_code',
      );

      expect(contentBlocks.length, 4, reason: 'Should have 4 verses (V1-V4)');

      // Verify content types match song structure
      final contentTypes = contentBlocks.map((c) => c['content_code']).toList();
      expect(contentTypes, containsAll(['V1', 'V2', 'V3', 'V4']));

      // Verify ChordPro format in content
      final verse1 = contentBlocks.firstWhere((c) => c['content_code'] == 'V1');
      final verse1Text = verse1['content_text'] as String;

      // Check for ChordPro chord notation
      expect(
        verse1Text,
        contains('[G]'),
        reason: 'Should contain chord notation',
      );
      expect(verse1Text, contains('mazing'), reason: 'Should contain lyrics');
      expect(verse1Text, contains('\n'), reason: 'Should be multi-line');

      // Clean up
      await dbHelper.resetDatabase();
    });

    test('should have proper foreign key relationships', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Test cipher_map -> cipher relationship
      final mapWithCipher = await db.rawQuery(
        '''
        SELECT cm.id, cm.version_name, c.title, c.author
        FROM cipher_map cm
        JOIN cipher c ON cm.cipher_id = c.id
        WHERE c.title = ?
      ''',
        ['How Great Thou Art'],
      );

      expect(mapWithCipher.length, 1);
      expect(mapWithCipher.first['title'], 'How Great Thou Art');
      expect(mapWithCipher.first['author'], 'Carl Boberg');
      expect(mapWithCipher.first['version_name'], 'Original');

      // Test map_content -> cipher_map relationship
      final contentWithMap = await db.rawQuery(
        '''
        SELECT mc.content_code, mc.content_text, cm.version_name, c.title
        FROM map_content mc
        JOIN cipher_map cm ON mc.map_id = cm.id
        JOIN cipher c ON cm.cipher_id = c.id
        WHERE c.title = ? AND mc.content_code = ?
      ''',
        ['How Great Thou Art', 'C'],
      );

      expect(contentWithMap.length, 1);
      expect(contentWithMap.first['content_code'], 'C');
      expect(contentWithMap.first['version_name'], 'Original');
      expect(contentWithMap.first['content_text'], contains('Then sings my '));

      // Clean up
      await dbHelper.resetDatabase();
    });

    test('should handle transposed key differences correctly', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Get both Amazing Grace versions
      final originalVersion = await db.rawQuery(
        '''
        SELECT cm.id, mc.content_text
        FROM cipher_map cm
        JOIN map_content mc ON cm.id = mc.map_id
        WHERE cm.cipher_id = (SELECT id FROM cipher WHERE title = ?)
          AND cm.version_name = ?
          AND mc.content_code = ?
      ''',
        ['Amazing Grace', 'Original', 'V1'],
      );

      final transposedVersion = await db.rawQuery(
        '''
        SELECT cm.id, mc.content_text
        FROM cipher_map cm
        JOIN map_content mc ON cm.id = mc.map_id
        WHERE cm.cipher_id = (SELECT id FROM cipher WHERE title = ?)
          AND cm.version_name = ?
          AND mc.content_code = ?
      ''',
        ['Amazing Grace', 'Short Version (Key of D)', 'V1'],
      );

      expect(originalVersion.length, 1);
      expect(transposedVersion.length, 1);

      final originalChords = originalVersion.first['content_text'] as String;
      final transposedChords =
          transposedVersion.first['content_text'] as String;

      // Verify different chord progressions
      expect(
        originalChords,
        contains('[G]'),
        reason: 'Original should be in G',
      );
      expect(
        originalChords,
        contains('[D]'),
        reason: 'Original should use D as dominant',
      );

      expect(
        transposedChords,
        contains('[D]'),
        reason: 'Transposed should be in D',
      );
      expect(
        transposedChords,
        contains('[A]'),
        reason: 'Transposed should use A as dominant',
      );

      // Verify same lyrics
      expect(originalChords, contains('mazing'));
      expect(transposedChords, contains('mazing'));

      // Clean up
      await dbHelper.resetDatabase();
    });

    test('should validate song structure matches available content', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Get How Great Thou Art map and its structure
      final mapData = await db.query(
        'cipher_map',
        where: 'cipher_id = (SELECT id FROM cipher WHERE title = ?)',
        whereArgs: ['How Great Thou Art'],
      );

      final songStructure = mapData.first['song_structure'] as String;
      final mapId = mapData.first['id'] as int;

      // Parse song structure
      final structureParts = songStructure.split(',');
      final uniqueParts = structureParts.toSet(); // V1, C, V2, V3, V4

      // Get available content types
      final availableContent = await db.query(
        'map_content',
        columns: ['content_code'],
        where: 'map_id = ?',
        whereArgs: [mapId],
      );

      final availableTypes = availableContent
          .map((c) => c['content_code'] as String)
          .toSet();

      // Verify all structure parts have corresponding content
      for (final part in uniqueParts) {
        expect(
          availableTypes,
          contains(part),
          reason: 'Content should exist for structure part: $part',
        );
      }

      // Expected parts for "V1,C,V2,C,V3,C,V4,C"
      expect(uniqueParts, containsAll(['V1', 'V2', 'V3', 'V4', 'C']));
      expect(availableTypes, containsAll(['V1', 'V2', 'V3', 'V4', 'C']));

      // Clean up
      await dbHelper.resetDatabase();
    });
  });
}
