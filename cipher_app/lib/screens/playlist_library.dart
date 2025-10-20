import 'package:cipher_app/providers/collaborator_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/screens/playlist_viewer.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/widgets/dialogs/create_playlist_dialog.dart';
import 'package:cipher_app/widgets/dialogs/delete_playlist_dialog.dart';
import 'package:cipher_app/widgets/playlist/playlist_card.dart';
import 'package:cipher_app/widgets/states/error_state_widget.dart';
import 'package:cipher_app/widgets/states/empty_state_widget.dart';

class PlaylistLibraryScreen extends StatefulWidget {
  const PlaylistLibraryScreen({super.key});

  @override
  State<PlaylistLibraryScreen> createState() => _PlaylistLibraryScreenState();
}

class _PlaylistLibraryScreenState extends State<PlaylistLibraryScreen>
    with WidgetsBindingObserver {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlaylistProvider>().loadLocalPlaylists();
        _syncPlaylists(
          context.read<PlaylistProvider>(),
          context.read<CipherProvider>(),
          context.read<UserProvider>(),
          context.read<VersionProvider>(),
          context.read<AuthProvider>(),
          context.read<CollaboratorProvider>(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Consumer4<
            PlaylistProvider,
            CipherProvider,
            UserProvider,
            CollaboratorProvider
          >(
            builder:
                (
                  context,
                  playlistProvider,
                  cipherProvider,
                  userProvider,
                  collaboratorProvider,
                  child,
                ) {
                  // Handle loading state
                  if (playlistProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (playlistProvider.isCloudLoading) {
                    return Center(
                      child: const Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Carregando suas playlists da nuvem...'),
                          CircularProgressIndicator(),
                        ],
                      ),
                    );
                  }

                  // Handle error state
                  if (playlistProvider.error != null) {
                    return ErrorStateWidget(
                      title: 'Erro ao carregar playlists',
                      message: playlistProvider.error!,
                      onRetry: () => playlistProvider.loadLocalPlaylists(),
                    );
                  }

                  // Handle empty state
                  if (playlistProvider.playlists.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.playlist_play,
                      title: 'Nenhuma playlist encontrada',
                      subtitle: 'Crie sua primeira playlist!',
                    );
                  }

                  // Display playlists
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Capture providers synchronously to avoid using context across async gaps
                      final versionProvider = context.read<VersionProvider>();
                      final authProvider = context.read<AuthProvider>();

                      await playlistProvider.loadLocalPlaylists();
                      await _syncPlaylists(
                        playlistProvider,
                        cipherProvider,
                        userProvider,
                        versionProvider,
                        authProvider,
                        collaboratorProvider,
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: playlistProvider.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlistProvider.playlists[index];
                        return PlaylistCard(
                          playlist: playlist,
                          onTap: () => _onPlaylistTap(context, playlist),
                          onDelete: () => _showDeleteDialog(context, playlist),
                        );
                      },
                    ),
                  );
                },
          ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'playlist_fab',
        onPressed: () => _showCreatePlaylistDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _syncPlaylists(
    PlaylistProvider playlistProvider,
    CipherProvider cipherProvider,
    UserProvider userProvider,
    VersionProvider versionProvider,
    AuthProvider authProvider,
    CollaboratorProvider collaboratorProvider,
  ) async {
    try {
      await playlistProvider.loadCloudPlaylists(authProvider.id!);

      // Copy the list to avoid concurrent modification issues
      final playlistsToSync = playlistProvider.cloudPlaylists.toList();
      final syncResults =
          <String, String>{}; // Track success/failure per playlist

      for (final playlistDto in playlistsToSync) {
        try {
          // Ensure collaborators exist (with proper await)
          await userProvider.ensureUsersExist(
            playlistDto.collaborators
                .map((collaborator) => collaborator['id'] as String)
                .toList(),
          );

          List<Map<String, dynamic>> syncedItems = [];

          for (int i = 0; i < playlistDto.items.length; i++) {
            final item = playlistDto.items[i];

            if (item.type == 'cipher_version') {
              final parts = item.firebaseContentId!.split(':');
              if (parts.length != 2) {
                throw Exception(
                  'Invalid firebaseContentId format: ${item.firebaseContentId}',
                );
              }

              final String cipherCloudId = parts[0];
              final String versionCloudId = parts[1];

              // Ensure cipher exists locally
              int? cipherId = await cipherProvider.cipherWithFirebaseIdIsCached(
                cipherCloudId,
              );
              if (cipherId == null) {
                cipherId = await cipherProvider.downloadCipherMetadata(
                  cipherCloudId,
                );

                if (cipherId == null) {
                  throw Exception('Failed to download cipher: $cipherCloudId');
                }
              }

              // Ensure version exists locally
              final newVersion = await versionProvider.downloadVersion(
                cipherCloudId,
                versionCloudId,
              );

              if (newVersion == null) {
                throw Exception('Failed to download version: $versionCloudId');
              }

              final versionLocalId = await versionProvider
                  .getVersionIdByFirebaseId(versionCloudId);

              final version = newVersion.copyWith(
                cipherId: cipherId,
                id: versionLocalId,
              );
              if (versionLocalId == null) {
                // Create version locally with correct cipher ID
                await versionProvider.createVersionFromDomain(version);
              } else {
                // Version already exists locally, for now overwrite it
                // TODO: CHECK BUSINESS RULES MAYBE OPEN A CONFIRMATION DIALOG
                await versionProvider.updateVersion(version);
              }

              syncedItems.add({
                'addedBy': userProvider.getLocalIdByFirebaseId(item.addedBy),
                'type': 'cipher_version',
                'contentId': versionLocalId,
                'position': i,
              });
            } else if (item.type == 'text_section') {
              // Validate text item can be retrieved
              final data = await playlistProvider.downloadTextItemByFirebaseId(
                item.firebaseContentId!,
              );

              if (kDebugMode) {
                print(
                  'Downloaded text item ${item.firebaseContentId} for playlist ${playlistDto.name}',
                );
              }

              syncedItems.add({
                'addedBy': data.addedBy,
                'type': 'text_section',
                'firebaseContentId': item.firebaseContentId!,
                'position': i,
                'title': data.title,
                'content': data.content,
              });
            }
          }

          // Only upsert playlist if we successfully processed at least some items
          if (syncedItems.isNotEmpty || playlistDto.items.isEmpty) {
            final playlistId = await playlistProvider.upsertPlaylist(
              playlistDto.toDomain(
                [],
                userProvider.getLocalIdByFirebaseId(playlistDto.ownerId)!,
              ),
            );

            if (kDebugMode) {
              print(
                'Upserted playlist "${playlistDto.name}" with local ID $playlistId',
              );
            }

            // Upsert text items that were successfully validated
            for (final item in syncedItems) {
              if (item['type'] == 'text_section') {
                await playlistProvider.upsertTextItem(
                  addedBy: userProvider.getLocalIdByFirebaseId(
                    playlistDto.ownerId,
                  )!,
                  playlistId: playlistId,
                  firebaseTextId: item['firebaseContentId'],
                  title: item['title'],
                  content: item['content'],
                  position: item['position'],
                );
              } else if (item['type'] == 'cipher_version') {
                await playlistProvider.upsertVersionOnPlaylist(
                  playlistId,
                  item['contentId'],
                  item['position'],
                  item['addedBy'],
                );
              }
            }
            // Insert collaborators
            for (final collaborator in playlistDto.collaborators) {
              final collaboratorLocalId = userProvider.getLocalIdByFirebaseId(
                collaborator['id'] as String,
              );
              if (collaboratorLocalId != null) {
                await collaboratorProvider.addCollaborator(
                  playlistId,
                  collaboratorLocalId,
                  collaborator['role'] as String,
                );
              }
            }

            syncResults[playlistDto.firebaseId ?? 'unknown'] = 'success';
          } else {
            syncResults[playlistDto.firebaseId ?? 'unknown'] =
                'no_items_synced';
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync playlist ${playlistDto.name}: $e');
          }
          syncResults[playlistDto.firebaseId ?? 'unknown'] = 'error: $e';
        }
      }

      // Clear cloud playlists only after successful processing
      playlistProvider.clearCloudPlaylists();

      // Optional: Report sync results to user
      final successCount = syncResults.values
          .where((result) => result == 'success')
          .length;
      final totalCount = syncResults.length;
      if (kDebugMode) {
        print(
          'Sync completed: $successCount/$totalCount playlists synced successfully',
        );
      }
    } catch (generalError) {
      if (kDebugMode) {
        print('Critical sync error: $generalError');
      }
      // Don't clear cloud playlists if there was a general failure
      rethrow; // Let the UI handle the error
    }
  }

  void _onPlaylistTap(BuildContext context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaylistViewer(playlistId: playlist.id),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => DeletePlaylistDialog(playlist: playlist),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }
}
