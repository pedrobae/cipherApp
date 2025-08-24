import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/helpers/database_helper.dart';

void main() {
  // Initialize database factory for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper Tests', () {
    test('should create database and tables', () async {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      
      // Check if database was created
      expect(db, isNotNull);
      
      // Check if tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      
      final tableNames = tables.map((t) => t['name']).toList();
      
      expect(tableNames, contains('cipher'));
      expect(tableNames, contains('cipher_map'));
      expect(tableNames, contains('map_content'));
      expect(tableNames, contains('tag'));
      expect(tableNames, contains('cipher_tags'));
      expect(tableNames, contains('user'));
      expect(tableNames, contains('playlist'));
      expect(tableNames, contains('playlist_cipher'));
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
      
      expect(afterReset.length, 2, reason: 'Database should have only seed data after reset');
      
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
      expect(ciphers.length, 4);
      
      // Test specific queries
      final fastSongs = await db.query('cipher', where: 'tempo = ?', whereArgs: ['Fast']);
      expect(fastSongs.length, 1);
      expect(fastSongs.first['title'], 'Song 1');
      
      // Clean up this test
      await dbHelper.resetDatabase();
    });
  });
}