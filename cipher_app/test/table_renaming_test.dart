import 'package:flutter_test/flutter_test.dart';

import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/helpers/database_factory.dart';

void main() {
  group('Table Renaming Tests', () {
    late DatabaseHelper dbHelper;

    setUpAll(() {
      DatabaseFactoryHelper.initializeForTesting();
    });

    setUp(() async {
      dbHelper = DatabaseHelper();
      await dbHelper.resetDatabase();
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test(
      'should have new table names (version, section, playlist_version)',
      () async {
        final db = await dbHelper.database;

        // Check if new tables exist
        final tableResult = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
        );

        final tableNames = tableResult
            .map((row) => row['name'] as String)
            .toList();

        // Should have new table names
        expect(tableNames, contains('version'));
        expect(tableNames, contains('section'));
        expect(tableNames, contains('playlist_version'));

        // Should NOT have old table names
        expect(tableNames, isNot(contains('cipher_map')));
        expect(tableNames, isNot(contains('map_content')));
        expect(tableNames, isNot(contains('playlist_cipher_map')));
      },
    );

    test('should have data in new tables from seeding', () async {
      final db = await dbHelper.database;

      // Check version table has data
      final versions = await db.query('version');
      expect(versions.length, greaterThan(0));

      // Check section table has data
      final sections = await db.query('section');
      expect(sections.length, greaterThan(0));

      // Check playlist_version table has data
      final playlistVersions = await db.query('playlist_version');
      expect(playlistVersions.length, greaterThan(0));

      // Verify correct column names
      final versionColumns = await db.rawQuery('PRAGMA table_info(version)');
      final versionColumnNames = versionColumns
          .map((row) => row['name'] as String)
          .toList();
      expect(versionColumnNames, contains('cipher_id'));
      expect(versionColumnNames, contains('song_structure'));

      final sectionColumns = await db.rawQuery('PRAGMA table_info(section)');
      final sectionColumnNames = sectionColumns
          .map((row) => row['name'] as String)
          .toList();
      expect(sectionColumnNames, contains('version_id'));
      expect(sectionColumnNames, contains('content_type'));

      final playlistVersionColumns = await db.rawQuery(
        'PRAGMA table_info(playlist_version)',
      );
      final playlistVersionColumnNames = playlistVersionColumns
          .map((row) => row['name'] as String)
          .toList();
      expect(playlistVersionColumnNames, contains('version_id'));
      expect(playlistVersionColumnNames, contains('playlist_id'));
      expect(playlistVersionColumnNames, contains('position'));
    });

    test('should maintain referential integrity between new tables', () async {
      final db = await dbHelper.database;

      // Test version -> cipher relationship
      final versionCipherJoin = await db.rawQuery('''
        SELECT v.id, c.title
        FROM version v
        JOIN cipher c ON v.cipher_id = c.id
      ''');
      expect(versionCipherJoin.length, greaterThan(0));

      // Test section -> version relationship
      final sectionVersionJoin = await db.rawQuery('''
        SELECT s.id, v.version_name
        FROM section s
        JOIN version v ON s.version_id = v.id
      ''');
      expect(sectionVersionJoin.length, greaterThan(0));

      // Test playlist_version -> playlist and version relationship
      final playlistVersionJoin = await db.rawQuery('''
        SELECT pv.id, p.name, v.version_name
        FROM playlist_version pv
        JOIN playlist p ON pv.playlist_id = p.id
        JOIN version v ON pv.version_id = v.id
      ''');
      expect(playlistVersionJoin.length, greaterThan(0));
    });
  });
}
