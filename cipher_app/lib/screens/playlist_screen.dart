import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../models/domain/playlist.dart';
import '../widgets/dialogs/create_playlist_dialog.dart';
import '../widgets/dialogs/delete_playlist_dialog.dart';
import '../widgets/playlist/playlist_card.dart';
import '../widgets/states/error_state_widget.dart';
import '../widgets/states/empty_state_widget.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load playlists when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylists();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app resumes (in case database was reset from settings)
    if (state == AppLifecycleState.resumed) {
      context.read<PlaylistProvider>().loadPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        centerTitle: true,
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          // Handle loading state
          if (playlistProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle error state
          if (playlistProvider.error != null) {
            return ErrorStateWidget(
              title: 'Erro ao carregar playlists',
              message: playlistProvider.error!,
              onRetry: () => playlistProvider.loadPlaylists(),
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
            onRefresh: () => playlistProvider.loadPlaylists(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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

  void _onPlaylistTap(BuildContext context, Playlist playlist) {
    // TODO: Navigate to playlist viewer/editor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrir playlist: ${playlist.name}'),
        duration: const Duration(seconds: 2),
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
