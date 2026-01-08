import 'package:flutter_test/flutter_test.dart';

import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/helpers/database_factory.dart';

void main() {
  group('Database Migration Tests', () {
    late DatabaseHelper dbHelper;

    setUpAll(() {
      DatabaseFactoryHelper.initializeForTesting();
    });

    setUp(() async {
      dbHelper = DatabaseHelper();
      // Reset database for each test
      await dbHelper.resetDatabase();
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should create playlist_text table with position column', () async {
      final db = await dbHelper.database;

      // Check if playlist_text table exists and has position column
      final result = await db.rawQuery('PRAGMA table_info(playlist_text)');

      // Extract column names
      final columns = result.map((row) => row['name'] as String).toList();

      expect(columns, contains('id'));
      expect(columns, contains('playlist_id'));
      expect(columns, contains('title'));
      expect(columns, contains('content'));
      expect(columns, contains('position'));
      expect(columns, contains('added_by'));
      expect(columns, contains('added_at'));
    });

    test('should insert playlist_text with position', () async {
      final db = await dbHelper.database;

      // Insert a test playlist first
      final playlistId = await db.insert('playlist', {
        'name': 'Test Playlist',
        'description': 'Test description',
        'author_id': 1,
        'is_public': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Insert a text section with position
      final textId = await db.insert('playlist_text', {
        'playlist_id': playlistId,
        'title': 'Test Text',
        'content': 'Test content',
        'position': 5,
        'added_by': 1,
        'added_at': DateTime.now().toIso8601String(),
      });

      expect(textId, greaterThan(0));

      // Verify the text was inserted with correct position
      final results = await db.query(
        'playlist_text',
        where: 'id = ?',
        whereArgs: [textId],
      );

      expect(results.length, 1);
      expect(results.first['position'], 5);
      expect(results.first['title'], 'Test Text');
    });
  });
}
