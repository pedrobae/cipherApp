import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_text_section.dart';
import 'package:cipher_app/models/dtos/playlist_dto.dart';
import 'package:cipher_app/providers/collaborator_provider.dart';
import 'package:cipher_app/providers/text_section_provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/screens/playlist/playlist_viewer.dart';
import 'package:cipher_app/widgets/dialogs/create_playlist_dialog.dart';
import 'package:cipher_app/widgets/dialogs/delete_playlist_dialog.dart';
import 'package:cipher_app/widgets/playlist/playlist_card.dart';
import 'package:cipher_app/widgets/playlist/join_playlist_dialog.dart';
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
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlaylistProvider>().loadLocalPlaylists();
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
                  if (isSyncing) {
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
                      onRetry: () async {
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
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  FloatingActionButton(
                    heroTag: 'syncPlaylists',
                    onPressed: () => _syncPlaylists(
                      playlistProvider,
                      cipherProvider,
                      userProvider,
                      versionProvider,
                      authProvider,
                      collaboratorProvider,
                    ),
                    child: const Icon(Icons.cloud_sync),
                  ),
                  FloatingActionButton(
                    heroTag: 'add_playlist_fab',
                    onPressed: () =>
                        _showAddPlaylistActions(context, (test) async {}),
                    child: const Icon(Icons.add),
                  ),
                ],
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

      for (final playlistDto in playlistsToSync) {
        await _syncPlaylist(
          playlistDto,
          playlistProvider,
          cipherProvider,
          userProvider,
          versionProvider,
          authProvider,
          collaboratorProvider,
        );
      }

      // Clear cloud playlists only after successful processing
      playlistProvider.clearCloudPlaylists();

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

  Future<void> _syncPlaylist(
    PlaylistDto playlistDto,
    PlaylistProvider playlistProvider,
    CipherProvider cipherProvider,
    UserProvider userProvider,
    VersionProvider versionProvider,
    AuthProvider authProvider,
    CollaboratorProvider collaboratorProvider,
  ) async {
    try {
      setState(() {
        isSyncing = true;
      });

      /// Ensure User Exists (download if necessary)
      await userProvider.ensureUsersExist(
        playlistDto.collaborators
            .map((collaborator) => collaborator['id'] as String)
            .toList(),
      );
      final ownerId = userProvider.getLocalIdByFirebaseId(playlistDto.ownerId);

      /// Upsert Ciphers
      for (final cipherDto in playlistDto.ciphers) {
        await cipherProvider.upsertCipher(cipherDto.toDomain([]));
      }

      /// Upsert Versions
      for (final versionDto in playlistDto.versions) {
        final existingCipherId = cipherProvider.getCachedCipherIdByFirebaseId(
          versionDto.firebaseCipherId!,
        );
        await versionProvider.upsertVersion(
          versionDto.toDomain(cipherId: existingCipherId),
        );
      }

      /// Upsert Playlist
      final playlistId = await playlistProvider.upsertPlaylist(
        playlistDto.toDomain([], ownerId!),
      );

      /// Upsert relationship tables (TextSections, PlaylistVersions)
      for (int index = 0; index < playlistDto.itemOrder.length; index++) {
        final typeId = playlistDto.itemOrder[index].split(':');

        if (typeId[0] == 'textSection') {
          // Upsert TextSection and build PlaylistItem
          final textSectionDto = playlistDto.textSections.firstWhere(
            (section) => section.firebaseId == typeId[1],
          );

          if (mounted) {
            context.read<TextSectionProvider>().upsertTextSection(
              TextSection(
                contentText: textSectionDto.content,
                playlistId: playlistId,
                position: index,
                title: textSectionDto.title,
                firebaseId: textSectionDto.firebaseId!,
                id: -1, // Temporary ID, will be set in upsert
                includerId: ownerId,
              ),
            );
          }
        } else if (typeId[0] == 'version') {
          // Link Version to Playlist
          final versionId = await versionProvider.getLocalIdByFirebaseId(
            typeId[1],
          );

          playlistProvider.upsertVersionOnPlaylist(
            playlistId,
            versionId!,
            index,
            null,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing playlist: $e');
      }
    } finally {
      setState(() {
        isSyncing = false;
      });
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
