import 'package:cipher_app/repositories/text_section_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/helpers/database_factory.dart';
import 'package:cipher_app/repositories/local_playlist_repository.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';

void main() {
  group('Unified Playlist Items Tests', () {
    late DatabaseHelper dbHelper;
    late PlaylistRepository playlistRepo;
    late TextSectionRepository textSectionRepo;

    setUpAll(() {
      DatabaseFactoryHelper.initializeForTesting();
    });

    setUp(() async {
      dbHelper = DatabaseHelper();
      await dbHelper.resetDatabase();
      playlistRepo = PlaylistRepository();
      PlaylistRepository.setCurrentUserId(1);
      textSectionRepo = TextSectionRepository();
      TextSectionRepository.setCurrentUserId(1);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should get unified playlist items in correct order', () async {
      final db = await dbHelper.database;

      // Create a test playlist
      final playlistId = await db.insert('playlist', {
        'name': 'Test Mixed Playlist',
        'description': 'Playlist with mixed content',
        'author_id': 1,
        'is_public': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Create a test cipher map
      final cipherId = await db.insert('cipher', {
        'title': 'Test Cipher',
        'author': 'Test Author',
        'tempo': 'Medium',
        'music_key': 'C',
        'language': 'en',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final cipherMapId = await db.insert('version', {
        'cipher_id': cipherId,
        'song_structure': 'verse,chorus',
        'transposed_key': 'C',
        'version_name': 'Standard',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Add mixed content in specific order
      // Position 0: Text section
      await textSectionRepo.createPlaylistText(
        playlistId,
        null,
        'Opening Announcements',
        'Welcome to our service!',
        0,
        1,
      );

      // Position 1: Cipher version
      await db.insert('playlist_version', {
        'version_id': cipherMapId,
        'playlist_id': playlistId,
        'includer_id': 1,
        'position': 1,
        'included_at': DateTime.now().toIso8601String(),
      });

      // Position 2: Another text section
      await textSectionRepo.createPlaylistText(
        playlistId,
        null,
        'Prayer Time',
        'Let us pray together',
        2,
        1,
      );

      // Get unified items
      final items = await playlistRepo.getItemsOfPlaylist(playlistId);

      expect(items.length, 3);

      // Check order
      expect(items[0].position, 0);
      expect(items[0].isTextSection, true);

      expect(items[1].position, 1);
      expect(items[1].isCipherVersion, true);

      expect(items[2].position, 2);
      expect(items[2].isTextSection, true);
    });

    test('should reorder playlist items correctly', () async {
      final db = await dbHelper.database;

      // Create a test playlist
      final playlistId = await db.insert('playlist', {
        'name': 'Test Reorder Playlist',
        'description': 'Test reordering',
        'author_id': 1,
        'is_public': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Create a cipher map
      final cipherId = await db.insert('cipher', {
        'title': 'Test Cipher',
        'author': 'Test Author',
        'tempo': 'Medium',
        'music_key': 'C',
        'language': 'en',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final cipherMapId = await db.insert('version', {
        'cipher_id': cipherId,
        'song_structure': 'verse,chorus',
        'transposed_key': 'C',
        'version_name': 'Standard',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Add content
      final textSectionId = await textSectionRepo.createPlaylistText(
        playlistId,
        null,
        'Text 1',
        'Content 1',
        0,
        1,
      );

      final versionId = await db.insert('playlist_version', {
        'version_id': cipherMapId,
        'playlist_id': playlistId,
        'includer_id': 1,
        'position': 1,
        'included_at': DateTime.now().toIso8601String(),
      });

      // Get initial items
      final initialItems = await playlistRepo.getItemsOfPlaylist(playlistId);
      expect(initialItems.length, 2);

      // Create reordered items (swap positions)
      final reorderedItems = [
        PlaylistItem.cipherVersion(cipherMapId, 0, versionId), // Cipher first
        PlaylistItem.textSection(
          initialItems[0].contentId!,
          1,
          textSectionId,
        ), // Text second
      ];

      // Reorder
      await playlistRepo.savePlaylistOrder(playlistId, reorderedItems);

      // Verify new order
      final newItems = await playlistRepo.getItemsOfPlaylist(playlistId);
      expect(newItems.length, 2);
      expect(newItems[0].isCipherVersion, true);
      expect(newItems[0].position, 0);
      expect(newItems[1].isTextSection, true);
      expect(newItems[1].position, 1);
    });
  });
}
