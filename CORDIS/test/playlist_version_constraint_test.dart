import 'package:flutter_test/flutter_test.dart';
import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/helpers/database_factory.dart';

void main() {
  group('Playlist Version Constraint Tests', () {
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
      'should allow multiple copies of same version in different positions',
      () async {
        final db = await dbHelper.database;

        // Insert a test playlist
        final playlistId = await db.insert('playlist', {
          'name': 'Test Playlist',
          'description': 'Test description',
          'author_id': 1,
          'is_public': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Insert a test version
        final versionId = 1; // This should exist from seed data

        // Insert the same version multiple times at different positions
        final firstEntry = await db.insert('playlist_version', {
          'version_id': versionId,
          'playlist_id': playlistId,
          'includer_id': 1,
          'position': 1,
          'included_at': DateTime.now().toIso8601String(),
        });

        final secondEntry = await db.insert('playlist_version', {
          'version_id': versionId,
          'playlist_id': playlistId,
          'includer_id': 1,
          'position': 2,
          'included_at': DateTime.now().toIso8601String(),
        });

        final thirdEntry = await db.insert('playlist_version', {
          'version_id': versionId,
          'playlist_id': playlistId,
          'includer_id': 1,
          'position': 3,
          'included_at': DateTime.now().toIso8601String(),
        });

        // All inserts should succeed
        expect(firstEntry, greaterThan(0));
        expect(secondEntry, greaterThan(0));
        expect(thirdEntry, greaterThan(0));

        // Verify all three entries exist
        final results = await db.query(
          'playlist_version',
          where: 'playlist_id = ? AND version_id = ?',
          whereArgs: [playlistId, versionId],
          orderBy: 'position',
        );

        expect(results.length, 3);
        expect(results[0]['position'], 1);
        expect(results[1]['position'], 2);
        expect(results[2]['position'], 3);
      },
    );

    test(
      'should still allow different versions at same position in different playlists',
      () async {
        final db = await dbHelper.database;

        // Insert two test playlists
        final playlist1Id = await db.insert('playlist', {
          'name': 'Test Playlist 1',
          'description': 'Test description',
          'author_id': 1,
          'is_public': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        final playlist2Id = await db.insert('playlist', {
          'name': 'Test Playlist 2',
          'description': 'Test description',
          'author_id': 1,
          'is_public': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Insert same version at same position in different playlists
        final versionId = 1;
        final position = 1;

        final firstEntry = await db.insert('playlist_version', {
          'version_id': versionId,
          'playlist_id': playlist1Id,
          'includer_id': 1,
          'position': position,
          'included_at': DateTime.now().toIso8601String(),
        });

        final secondEntry = await db.insert('playlist_version', {
          'version_id': versionId,
          'playlist_id': playlist2Id,
          'includer_id': 1,
          'position': position,
          'included_at': DateTime.now().toIso8601String(),
        });

        // Both inserts should succeed
        expect(firstEntry, greaterThan(0));
        expect(secondEntry, greaterThan(0));
      },
    );
  });
}
