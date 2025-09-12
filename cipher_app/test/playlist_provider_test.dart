import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/models/domain/playlist.dart';
import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/repositories/playlist_repository.dart';

void main() {
  group('PlaylistProvider', () {
    late PlaylistProvider provider;
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      provider = PlaylistProvider();
      databaseHelper = DatabaseHelper();

      // Set current user for testing
      PlaylistRepository.setCurrentUserId(1);

      // Reset database for each test
      await databaseHelper.resetDatabase();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    group('Loading States', () {
      test('should start with empty state', () {
        expect(provider.playlists, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.isSaving, isFalse);
        expect(provider.error, isNull);
      });

      test('should set loading state when loading playlists', () async {
        // Arrange
        bool loadingStateDetected = false;
        provider.addListener(() {
          if (provider.isLoading) {
            loadingStateDetected = true;
          }
        });

        // Act
        await provider.loadPlaylists();

        // Assert
        expect(loadingStateDetected, isTrue);
        expect(provider.isLoading, isFalse); // Should be false after completion
      });

      test('should load seeded playlists successfully', () async {
        // Act
        await provider.loadPlaylists();

        // Assert
        expect(provider.playlists, isNotEmpty);
        expect(provider.error, isNull);
        expect(provider.isLoading, isFalse);

        // Check for seeded playlists
        final worshipPlaylist = provider.playlists.firstWhere(
          (p) => p.name == 'Culto Dominical',
          orElse: () => throw Exception('Seeded playlist not found'),
        );
        expect(worshipPlaylist.cipherVersionIds, isNotEmpty);
      });
    });

    group('Playlist Management', () {
      setUp(() async {
        await provider.loadPlaylists();
      });

      test('should create new playlist', () async {
        // Arrange
        final initialCount = provider.playlists.length;
        final newPlaylist = Playlist(
          id: 0,
          name: 'Nova Playlist de Teste',
          description: 'Descrição da playlist de teste',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherVersionIds: [1, 2],
          collaborators: [],
        );

        // Act
        await provider.createPlaylist(newPlaylist);

        // Assert
        expect(provider.playlists.length, equals(initialCount + 1));
        expect(provider.error, isNull);

        final createdPlaylist = provider.playlists.firstWhere(
          (p) => p.name == 'Nova Playlist de Teste',
        );
        expect(createdPlaylist.cipherVersionIds, contains(1));
        expect(createdPlaylist.cipherVersionIds, contains(2));
      });

      test('should update playlist info', () async {
        // Arrange
        final existingPlaylist = provider.playlists.first;
        final originalName = existingPlaylist.name;

        // Act
        await provider.updatePlaylistInfo(
          existingPlaylist.id,
          'Nome Atualizado',
          'Nova descrição',
        );

        // Assert
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == existingPlaylist.id,
        );
        expect(updatedPlaylist.name, equals('Nome Atualizado'));
        expect(updatedPlaylist.description, equals('Nova descrição'));
        expect(updatedPlaylist.name, isNot(equals(originalName)));
        expect(provider.error, isNull);
      });

      test('should delete playlist', () async {
        // Arrange
        final initialCount = provider.playlists.length;
        final playlistToDelete = provider.playlists.first;

        // Act
        await provider.deletePlaylist(playlistToDelete.id);

        // Assert
        expect(provider.playlists.length, equals(initialCount - 1));
        expect(provider.error, isNull);

        final deletedPlaylistExists = provider.playlists.any(
          (p) => p.id == playlistToDelete.id,
        );
        expect(deletedPlaylistExists, isFalse);
      });
    });

    group('Cipher Management', () {
      late Playlist testPlaylist;

      setUp(() async {
        await provider.loadPlaylists();

        // Create a test playlist for cipher operations
        final newPlaylist = Playlist(
          id: 0,
          name: 'Teste Cifras',
          description: 'Para testar operações de cifras',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherVersionIds: [],
          collaborators: [],
        );

        await provider.createPlaylist(newPlaylist);
        testPlaylist = provider.playlists.firstWhere(
          (p) => p.name == 'Teste Cifras',
        );
      });

      test('should add cipher to playlist', () async {
        // Arrange
        final initialCipherCount = testPlaylist.cipherVersionIds.length;

        // Act
        await provider.addCipherMap(testPlaylist.id, 1);

        // Assert - Note: Current provider doesn't reload playlist automatically
        // So we need to reload manually to see changes
        await provider.loadPlaylists();
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == testPlaylist.id,
        );
        expect(
          updatedPlaylist.cipherVersionIds.length,
          equals(initialCipherCount + 1),
        );
        expect(updatedPlaylist.cipherVersionIds, contains(1));
        expect(provider.error, isNull);
      });

      test('should remove cipher from playlist', () async {
        // Arrange - Add cipher first
        await provider.addCipherMap(testPlaylist.id, 1);
        await provider.addCipherMap(testPlaylist.id, 2);

        // Act
        await provider.removeCipherMapFromPlaylist(testPlaylist.id, 1);

        // Assert
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == testPlaylist.id,
        );
        expect(updatedPlaylist.cipherVersionIds, isNot(contains(1)));
        expect(updatedPlaylist.cipherVersionIds, contains(2));
        expect(provider.error, isNull);
      });

      test('should reorder playlist cipher maps', () async {
        // Arrange
        await provider.addCipherMap(testPlaylist.id, 1);
        await provider.addCipherMap(testPlaylist.id, 2);
        await provider.addCipherMap(testPlaylist.id, 3);

        // Act - Reorder from [1,2,3] to [3,1,2]
        await provider.reorderPlaylistCipherMaps(testPlaylist.id, [3, 1, 2]);

        // Assert - Reload to see changes
        await provider.loadPlaylists();
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == testPlaylist.id,
        );
        expect(updatedPlaylist.cipherVersionIds, equals([3, 1, 2]));
        expect(provider.error, isNull);
      });
    });
  });
}
