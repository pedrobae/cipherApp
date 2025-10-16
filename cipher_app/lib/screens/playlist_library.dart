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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<PlaylistProvider, CipherProvider, UserProvider>(
        builder:
            (context, playlistProvider, cipherProvider, userProvider, child) {
              // Handle loading state
              if (playlistProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
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
                onRefresh: () => playlistProvider.loadLocalPlaylists(),
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
  ) async {
    await playlistProvider.loadCloudPlaylists(authProvider.id!);

    for (final playlistDto in playlistProvider.cloudPlaylists) {
      userProvider.ensureUsersExist(playlistDto.collaborators);

      // Ensure all items in the playlist exist locally
      for (final item in playlistDto.items) {
        // If the item is a version, ensure it exists
        if (item.type == 'version') {
          final String cipherCloudId = item.firebaseContentId!.split(':')[0];
          final String versionCloudId = item.firebaseContentId!.split(':')[1];

          final versionId = await versionProvider.getVersionByFirebaseId(
            versionCloudId,
          );

          // If the local version Id isn't found, ensure the cipher exists
          if (versionId == null) {
            int? cipherId = cipherProvider.cipherWithFirebaseIdIsCached(
              cipherCloudId,
            );
            // If the cipher is also not found, download it
            if (cipherId == null) {
              cipherId = await cipherProvider.downloadCipherMetadata(
                cipherCloudId,
              );

              if (cipherId == null) {
                // Handle the error case where the cipher couldn't be downloaded
              }
            }
            // Now that we have the localcipher ID, download the version
            final newVersion = await versionProvider.downloadVersion(
              cipherCloudId,
              versionCloudId,
            );

            if (newVersion == null) {
              // Handle the error case where the version couldn't be downloaded
            }

            // Create a new version locally with the correct cipher ID
            final version = newVersion!.copyWith(cipherId: cipherId);
            await versionProvider.createVersionFromDomain(version);
          }
          // Version exists locally, check update timestamps
          else {
            final localVersion = await versionProvider.getVersionById(
              versionId,
            );
            if (localVersion.updatedAt.isBefore(playlistDto.updatedAt)) {
              // Download the updated version
              final updatedVersion = await versionProvider.downloadVersion(
                cipherCloudId,
                versionCloudId,
              );

              if (updatedVersion == null) {
                // Handle the error case where the version couldn't be downloaded
              }
            }
            // Local version is newer than cloud
          }
        } else if (item.type == 'text') {
          // Text items are always of a single playlist
        }
      }
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
