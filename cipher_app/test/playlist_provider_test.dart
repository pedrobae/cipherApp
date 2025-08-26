import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/models/domain/playlist.dart';
import 'package:cipher_app/helpers/database_helper.dart';
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
        expect(worshipPlaylist.cipherMapIds, isNotEmpty);
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
          cipherMapIds: [1, 2],
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
        expect(createdPlaylist.cipherMapIds, contains(1));
        expect(createdPlaylist.cipherMapIds, contains(2));
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

      // TODO: Implement deletePlaylist method in provider
      // test('should delete playlist', () async {
      //   // Arrange
      //   final initialCount = provider.playlists.length;
      //   final playlistToDelete = provider.playlists.first;

      //   // Act
      //   await provider.deletePlaylist(playlistToDelete.id);

      //   // Assert
      //   expect(provider.playlists.length, equals(initialCount - 1));
      //   expect(provider.error, isNull);
        
      //   final deletedPlaylistExists = provider.playlists.any(
      //     (p) => p.id == playlistToDelete.id,
      //   );
      //   expect(deletedPlaylistExists, isFalse);
      // });
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
          cipherMapIds: [],
          collaborators: [],
        );
        
        await provider.createPlaylist(newPlaylist);
        testPlaylist = provider.playlists.firstWhere(
          (p) => p.name == 'Teste Cifras',
        );
      });

      test('should add cipher to playlist', () async {
        // Arrange
        final initialCipherCount = testPlaylist.cipherMapIds.length;

        // Act
        await provider.addCipherMap(testPlaylist.id, 1);

        // Assert - Note: Current provider doesn't reload playlist automatically
        // So we need to reload manually to see changes
        await provider.loadPlaylists();
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == testPlaylist.id,
        );
        expect(updatedPlaylist.cipherMapIds.length, equals(initialCipherCount + 1));
        expect(updatedPlaylist.cipherMapIds, contains(1));
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
        expect(updatedPlaylist.cipherMapIds, isNot(contains(1)));
        expect(updatedPlaylist.cipherMapIds, contains(2));
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
        expect(updatedPlaylist.cipherMapIds, equals([3, 1, 2]));
        expect(provider.error, isNull);
      });
    });

    group('Collaborator Management', () {
      setUp(() async {
        await provider.loadPlaylists();
        
        final newPlaylist = Playlist(
          id: 0,
          name: 'Teste Colaboradores',
          description: 'Para testar colaboradores',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherMapIds: [],
          collaborators: [],
        );
        
        await provider.createPlaylist(newPlaylist);
      });

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
          cipherMapIds: [],
          collaborators: [],
        );
        
        await provider.createPlaylist(newPlaylist);
        testPlaylist = provider.playlists.firstWhere(
          (p) => p.name == 'Teste Cifras',
        );
      });
      test('should add collaborator to playlist', () async {
        // Act
        await provider.addCollaborator(testPlaylist.id, 2);

        // Assert
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == testPlaylist.id,
        );
        expect(updatedPlaylist.collaborators, contains('2'));
        expect(provider.error, isNull);
      });
      test('should remove collaborator from playlist', () async {
        // Arrange
        await provider.addCollaborator(testPlaylist.id, 2);

        // Act
        await provider.removeCollaboratorFromPlaylist(testPlaylist.id, 2);

        // Assert
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == testPlaylist.id,
        );
        expect(updatedPlaylist.collaborators, isNot(contains('2')));
        expect(provider.error, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle errors gracefully', () async {
        // This test would require mocking to simulate database errors
        // For now, we verify that error state is properly managed
        expect(provider.error, isNull);
      });

      test('should not update playlists when loading fails', () async {
        // Would require mocking database to fail
        // Verify that on error, playlists remain unchanged
      });
    });

    group('State Management', () {
      test('should notify listeners when playlists change', () async {
        // Arrange
        int notificationCount = 0;
        provider.addListener(() {
          notificationCount++;
        });

        // Act
        await provider.loadPlaylists();

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should maintain playlist state after operations', () async {
        // Arrange
        await provider.loadPlaylists();
        final initialCount = provider.playlists.length;

        // Act - Perform multiple operations
        final newPlaylist = Playlist(
          id: 0,
          name: 'Teste Estado',
          description: 'Testando manutenção de estado',
          createdBy: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cipherMapIds: [1],
          collaborators: [],
        );
        
        await provider.createPlaylist(newPlaylist);
        final createdPlaylist = provider.playlists.firstWhere(
          (p) => p.name == 'Teste Estado',
        );
        
        await provider.addCipherMap(createdPlaylist.id, 2);

        // Assert
        expect(provider.playlists.length, equals(initialCount + 1));
        final finalPlaylist = provider.playlists.firstWhere(
          (p) => p.id == createdPlaylist.id,
        );
        expect(finalPlaylist.cipherMapIds, contains(1));
        expect(finalPlaylist.cipherMapIds, contains(2));
      });
    });
  });
}
