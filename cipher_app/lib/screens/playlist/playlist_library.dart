import 'package:cipher_app/models/dtos/playlist_dto.dart';
import 'package:cipher_app/providers/collaborator_provider.dart';
import 'package:cipher_app/widgets/playlist/join_playlist_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/screens/playlist/playlist_viewer.dart';
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

typedef SyncPlaylistFunction = Future<void> Function(PlaylistDto playlistDto);

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
    return Consumer6<
      PlaylistProvider,
      CipherProvider,
      UserProvider,
      VersionProvider,
      AuthProvider,
      CollaboratorProvider
    >(
      builder:
          (
            context,
            playlistProvider,
            cipherProvider,
            userProvider,
            versionProvider,
            authProvider,
            collaboratorProvider,
            child,
          ) {
            return Scaffold(
              body: Builder(
                builder: (context) {
                  // Handle loading state
                  if (playlistProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Handle cloud loading state
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
                  // Handle Error State
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
                  return RefreshIndicator(
                    onRefresh: () async {
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
                          onTap: () => _onPlaylistTap(
                            context,
                            playlist.id,
                            playlistProvider,
                            cipherProvider,
                            userProvider,
                            versionProvider,
                            collaboratorProvider,
                            authProvider,
                            playlistFirebaseId: playlist.firebaseId,
                          ),
                          onDelete: () => _showDeleteDialog(context, playlist),
                        );
                      },
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                heroTag: 'add_playlist_fab',
                onPressed: () => _showAddPlaylistActions(
                  context,
                  (playlistDto) => syncPlaylist(
                    playlistProvider,
                    cipherProvider,
                    userProvider,
                    versionProvider,
                    collaboratorProvider,
                    authProvider,
                    playlistDto: playlistDto,
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            );
          },
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
        final (firebaseId, status) = await syncPlaylist(
          playlistProvider,
          cipherProvider,
          userProvider,
          versionProvider,
          collaboratorProvider,
          authProvider,
          playlistDto: playlistDto,
        );

        syncResults[firebaseId] = status;
      }

      // Clear cloud playlists only after successful processing
      playlistProvider.clearCloudPlaylists();

      final successCount = syncResults.values
          .where((result) => result == 'success')
          .length;
      final totalCount = syncResults.length;
      if (kDebugMode) {
        print(
          'Sync completed: $successCount/$totalCount playlists synced successfully',
        );
      }

      // Clear versions and current cipher after sync
      versionProvider.clearVersions();
      cipherProvider.clearCurrentCipher();
    } catch (generalError) {
      if (kDebugMode) {
        print('Critical sync error: $generalError');
      }
      // Don't clear cloud playlists if there was a general failure
      rethrow; // Let the UI handle the error
    }
  }

  Future<(String, String)> syncPlaylist(
    PlaylistProvider playlistProvider,
    CipherProvider cipherProvider,
    UserProvider userProvider,
    VersionProvider versionProvider,
    CollaboratorProvider collaboratorProvider,
    AuthProvider authProvider, {
    PlaylistDto? playlistDto,
  }) async {
    try {
      playlistDto ??= playlistProvider.currentCloudPlaylist;

      if (playlistDto == null) {
        throw Exception("No playlist dto received or loaded");
      }

      // Ensure collaborators exist (with proper await)
      await userProvider.ensureUsersExist(
        playlistDto.collaborators
            .map((collaborator) => collaborator['id'] as String)
            .toList(),
      );

      List<Map<String, dynamic>> textSectionItems = [];
      List<Map<String, dynamic>> versionSectionItems = [];

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

          int? versionLocalId = await versionProvider.getLocalIdByFirebaseId(
            versionCloudId,
          );

          if (versionLocalId == null) {
            // Create version locally with correct cipher ID
            final version = newVersion.copyWith(cipherId: cipherId);

            versionLocalId = await versionProvider.createVersionFromDomain(
              version,
            );
          } else {
            // Version already exists locally, for now overwrite it
            // TODO: CHECK BUSINESS RULES MAYBE OPEN A CONFIRMATION DIALOG
            final version = newVersion.copyWith(
              cipherId: cipherId,
              id: versionLocalId,
            );

            await versionProvider.updateVersion(version);
          }

          versionSectionItems.add({
            'addedBy': userProvider.getLocalIdByFirebaseId(item.addedBy),
            'contentId': versionLocalId,
            'position': i,
          });
        } else if (item.type == 'text_section') {
          // Download text section content
          final data = await playlistProvider.downloadTextItemByFirebaseId(
            item.firebaseContentId!,
          );

          if (kDebugMode) {
            print(
              'Downloaded text item ${item.firebaseContentId} for playlist ${playlistDto.name}',
            );
          }

          textSectionItems.add({
            'addedBy': userProvider.getLocalIdByFirebaseId(item.addedBy),
            'type': 'text_section',
            'firebaseContentId': item.firebaseContentId!,
            'position': i,
            'title': data.title,
            'content': data.content,
          });
        }
      }

      // Only upsert playlist if we successfully processed at least some items
      if (versionSectionItems.isNotEmpty ||
          playlistDto.items.isEmpty ||
          textSectionItems.isNotEmpty) {
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

        // Prune existing items and collaborators
        await playlistProvider.prunePlaylistItems(
          playlistId,
          versionSectionItems,
          textSectionItems,
        );

        // Upsert text items that were successfully validated
        for (final item in textSectionItems) {
          await playlistProvider.upsertTextItem(
            addedBy: userProvider.getLocalIdByFirebaseId(playlistDto.ownerId)!,
            playlistId: playlistId,
            firebaseTextId: item['firebaseContentId'],
            title: item['title'],
            content: item['content'],
            position: item['position'],
          );
        }
        // Upsert version items
        for (final item in versionSectionItems) {
          await playlistProvider.upsertVersionOnPlaylist(
            playlistId,
            item['contentId'],
            item['position'],
            item['addedBy'],
          );
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
              userProvider.getLocalIdByFirebaseId(authProvider.id!)!,
            );
          }
        }

        return (playlistDto.firebaseId ?? 'unknown', 'success');
      } else {
        return (playlistDto.firebaseId ?? 'unknown', 'no_items_synced');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync playlist ${playlistDto?.name}: $e');
      }
      return (playlistDto?.firebaseId ?? 'unknown', 'error: $e');
    }
  }

  void _onPlaylistTap(
    BuildContext context,
    int playlistId,
    PlaylistProvider playlistProvider,
    CipherProvider cipherProvider,
    UserProvider userProvider,
    VersionProvider versionProvider,
    CollaboratorProvider collaboratorProvider,
    AuthProvider authProvider, {
    String? playlistFirebaseId,
  }) async {
    if (playlistFirebaseId == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlaylistViewer(playlistId: playlistId),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlaylistViewer(
            playlistId: playlistId,
            syncPlaylist: () async {
              playlistProvider.loadCloudPlaylist(playlistFirebaseId);

              await syncPlaylist(
                playlistProvider,
                cipherProvider,
                userProvider,
                versionProvider,
                collaboratorProvider,
                authProvider,
              );
            },
          ),
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => DeletePlaylistDialog(playlist: playlist),
    );
  }

  void _showAddPlaylistActions(
    BuildContext context,
    SyncPlaylistFunction syncPlaylist,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Criar Nova Playlist'),
              onTap: () {
                Navigator.pop(context);
                _showCreatePlaylistDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Entrar em Playlist'),
              subtitle: const Text('Use um código de convite'),
              onTap: () {
                Navigator.pop(context);
                _showJoinPlaylistDialog(context, syncPlaylist);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }

  void _showJoinPlaylistDialog(
    BuildContext context,
    SyncPlaylistFunction syncPlaylist,
  ) {
    showDialog(
      context: context,
      builder: (context) => JoinPlaylistDialog(syncPlaylist: syncPlaylist),
    );
  }
}
