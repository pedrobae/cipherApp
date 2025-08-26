import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/repositories/playlist_repository.dart';
import 'package:cipher_app/models/domain/playlist.dart';
import 'package:cipher_app/helpers/database_helper.dart';

void main() {
  group('PlaylistRepository', () {
    late PlaylistRepository repository;
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      repository = PlaylistRepository();
      databaseHelper = DatabaseHelper();
      
      // Set current user for testing
      PlaylistRepository.setCurrentUserId(1);
      
      // Reset database for each test
      await databaseHelper.resetDatabase();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    group('CRUD Operations', () {
      test('should create a playlist successfully', () async {
        // Arrange
        final playlist = Playlist(
          id: 0, // Will be auto-generated
          name: 'Teste Playlist',
          description: 'Uma playlist de teste',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherMapIds: [1, 2], // Reference existing seeded cipher maps
          collaborators: [],
        );

        // Act
        final playlistId = await repository.createPlaylist(playlist);

        // Assert
        expect(playlistId, isA<int>());
        expect(playlistId, greaterThan(0));

        // Verify the playlist was created with relationships
        final retrievedPlaylist = await repository.getPlaylistById(playlistId);
        expect(retrievedPlaylist, isNotNull);
        expect(retrievedPlaylist!.name, equals('Teste Playlist'));
        expect(retrievedPlaylist.cipherMapIds, contains(1));
        expect(retrievedPlaylist.cipherMapIds, contains(2));
      });

      test('should get all playlists', () async {
        // Arrange - playlists should be seeded by default

        // Act
        final playlists = await repository.getAllPlaylists();

        // Assert
        expect(playlists, isA<List<Playlist>>());
        expect(playlists.length, greaterThanOrEqualTo(2)); // At least 2 seeded playlists
        
        // Check if seeded playlists exist
        final worshipPlaylist = playlists.firstWhere(
          (p) => p.name == 'Culto Dominical',
          orElse: () => throw Exception('Worship playlist not found'),
        );
        expect(worshipPlaylist.cipherMapIds, isNotEmpty);
      });

      test('should get playlist by ID with relationships', () async {
        // Arrange - Use seeded data
        final allPlaylists = await repository.getAllPlaylists();
        final existingPlaylist = allPlaylists.first;

        // Act
        final playlist = await repository.getPlaylistById(existingPlaylist.id);

        // Assert
        expect(playlist, isNotNull);
        expect(playlist!.id, equals(existingPlaylist.id));
        expect(playlist.name, equals(existingPlaylist.name));
        expect(playlist.cipherMapIds, equals(existingPlaylist.cipherMapIds));
      });

      test('should return null for non-existent playlist', () async {
        // Act
        final playlist = await repository.getPlaylistById(99999);

        // Assert
        expect(playlist, isNull);
      });

      test('should update playlist name and description', () async {
        // Arrange
        final allPlaylists = await repository.getAllPlaylists();
        final existingPlaylist = allPlaylists.first;
        final playlistId = existingPlaylist.id;

        // Act
        await repository.updatePlaylist(
          playlistId,
          name: 'Nome Atualizado',
          description: 'Descrição atualizada',
        );

        // Assert
        final updatedPlaylist = await repository.getPlaylistById(playlistId);
        expect(updatedPlaylist, isNotNull);
        expect(updatedPlaylist!.name, equals('Nome Atualizado'));
        expect(updatedPlaylist.description, equals('Descrição atualizada'));
      });

      test('should delete playlist and all relationships', () async {
        // Arrange
        final allPlaylists = await repository.getAllPlaylists();
        final playlistToDelete = allPlaylists.first;
        final playlistId = playlistToDelete.id;

        // Act
        await repository.deletePlaylist(playlistId);

        // Assert
        final deletedPlaylist = await repository.getPlaylistById(playlistId);
        expect(deletedPlaylist, isNull);

        // Verify relationships were also deleted
        final db = await databaseHelper.database;
        
        final cipherRelations = await db.query(
          'playlist_cipher_map',
          where: 'playlist_id = ?',
          whereArgs: [playlistId],
        );
        expect(cipherRelations, isEmpty);

        final collaboratorRelations = await db.query(
          'user_playlist',
          where: 'playlist_id = ?',
          whereArgs: [playlistId],
        );
        expect(collaboratorRelations, isEmpty);
      });
    });

    group('Cipher Management', () {
      late int testPlaylistId;

      setUp(() async {
        // Create a test playlist for cipher operations
        final playlist = Playlist(
          id: 0,
          name: 'Test Cipher Management',
          description: 'Testing cipher operations',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherMapIds: [],
          collaborators: [],
        );
        testPlaylistId = await repository.createPlaylist(playlist);
      });

      test('should add cipher map to playlist', () async {
        // Act
        await repository.addCipherMapToPlaylist(testPlaylistId, 1);

        // Assert
        final playlist = await repository.getPlaylistById(testPlaylistId);
        expect(playlist!.cipherMapIds, contains(1));
      });

      test('should add cipher map with correct position', () async {
        // Arrange - Add first cipher map
        await repository.addCipherMapToPlaylist(testPlaylistId, 1);

        // Act - Add second cipher map
        await repository.addCipherMapToPlaylist(testPlaylistId, 2);

        // Assert
        final playlist = await repository.getPlaylistById(testPlaylistId);
        expect(playlist!.cipherMapIds, equals([1, 2]));
      });

      test('should remove cipher map from playlist', () async {
        // Arrange
        await repository.addCipherMapToPlaylist(testPlaylistId, 1);
        await repository.addCipherMapToPlaylist(testPlaylistId, 2);

        // Act
        await repository.removeCipherMapFromPlaylist(testPlaylistId, 1);

        // Assert
        final playlist = await repository.getPlaylistById(testPlaylistId);
        expect(playlist!.cipherMapIds, equals([2]));
        expect(playlist.cipherMapIds, isNot(contains(1)));
      });

      test('should reorder playlist cipher maps', () async {
        // Arrange
        await repository.addCipherMapToPlaylist(testPlaylistId, 1);
        await repository.addCipherMapToPlaylist(testPlaylistId, 2);
        await repository.addCipherMapToPlaylist(testPlaylistId, 3);

        // Act - Reorder: [1,2,3] -> [3,1,2]
        await repository.reorderPlaylistCipherMaps(testPlaylistId, [3, 1, 2]);

        // Assert
        final playlist = await repository.getPlaylistById(testPlaylistId);
        expect(playlist!.cipherMapIds, equals([3, 1, 2]));
      });
    });

    group('Collaborator Management', () {
      late int testPlaylistId;

      setUp(() async {
        final playlist = Playlist(
          id: 0,
          name: 'Test Collaborators',
          description: 'Testing collaborator operations',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherMapIds: [],
          collaborators: [],
        );
        testPlaylistId = await repository.createPlaylist(playlist);
      });

      test('should add collaborator to playlist', () async {
        // Act
        await repository.addCollaboratorToPlaylist(testPlaylistId, 2, addedBy: 1);

        // Assert
        final playlist = await repository.getPlaylistById(testPlaylistId);
        expect(playlist!.collaborators, contains('2'));
      });

      test('should remove collaborator from playlist', () async {
        // Arrange
        await repository.addCollaboratorToPlaylist(testPlaylistId, 2, addedBy: 1);

        // Act
        await repository.removeCollaboratorFromPlaylist(testPlaylistId, 2);

        // Assert
        final playlist = await repository.getPlaylistById(testPlaylistId);
        expect(playlist!.collaborators, isNot(contains('2')));
      });
    });

    group('Edge Cases', () {
      test('should handle empty playlist creation', () async {
        // Arrange
        final emptyPlaylist = Playlist(
          id: 0,
          name: 'Empty Playlist',
          description: null,
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherMapIds: [],
          collaborators: [],
        );

        // Act
        final playlistId = await repository.createPlaylist(emptyPlaylist);

        // Assert
        expect(playlistId, greaterThan(0));
        final retrievedPlaylist = await repository.getPlaylistById(playlistId);
        expect(retrievedPlaylist!.cipherMapIds, isEmpty);
        expect(retrievedPlaylist.collaborators, isEmpty);
      });

      test('should handle playlist with collaborators but no ciphers', () async {
        // Arrange
        final playlist = Playlist(
          id: 0,
          name: 'Collaborator Only Playlist',
          description: 'Has collaborators but no cipher maps',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherMapIds: [],
          collaborators: ['2'],
        );

        // Act
        final playlistId = await repository.createPlaylist(playlist);

        // Assert
        final retrievedPlaylist = await repository.getPlaylistById(playlistId);
        expect(retrievedPlaylist!.cipherMapIds, isEmpty);
        expect(retrievedPlaylist.collaborators, contains('2'));
      });
    });
  });
}
