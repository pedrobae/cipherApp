import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/database/database_helper.dart';

void main() {
  // Initialize database factory for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper();
    });

    test('should create database and tables', () async {
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
    });

    test('should have correct cipher table schema', () async {
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
    });
  });
}