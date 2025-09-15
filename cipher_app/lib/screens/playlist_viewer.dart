import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/widgets/playlist/cipher_version_card.dart';
import 'package:cipher_app/widgets/playlist/text_section_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:provider/provider.dart';
import '../widgets/cipher/editor/custom_reorderable_delayed.dart';
import '../widgets/playlist/collaborators/bottom_sheet.dart';
import '../widgets/dialogs/edit_playlist_dialog.dart';
import '../widgets/playlist/empty_playlist.dart';
import 'cipher_library.dart';

class PlaylistViewer extends StatelessWidget {
  final int playlistId; // Receive the playlist ID from the parent

  const PlaylistViewer({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    // Read the playlist from the provider
    final playlistProvider = context.watch<PlaylistProvider>();
    final playlist = playlistProvider.playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => throw Exception('Playlist not found'),
    );
    if (kDebugMode) {
      playlist.debugPrint();
    }

    final bool hasItems = playlist.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              playlist.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Colaboradores',
            onPressed: () => _showCollaborators(context, playlist),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => _editPlaylist(context, playlist),
          ),
        ],
      ),
      body: hasItems
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReorderableListView.builder(
                proxyDecorator: (child, index, animation) =>
                    Material(type: MaterialType.transparency, child: child),
                buildDefaultDragHandles: true,
                header: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    playlist.description ?? '',
                    textAlign: TextAlign.center,
                  ),
                ),
                itemCount: playlist.items.length,
                onReorder: (oldIndex, newIndex) =>
                    _onReorder(context, playlist, oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final item = playlist.items[index];
                  return CustomReorderableDelayed(
                    delay: const Duration(milliseconds: 200),
                    key: Key('${item.type}_${item.contentId}'),
                    index: index,
                    child: _buildItemWidget(context, item),
                  );
                },
              ),
            )
          : EmptyPlaylist(description: playlist.description),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCiphers(context, playlist),
        tooltip: 'Adicionar Cifras',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddCiphers(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CipherLibraryScreen(
          selectionMode: true,
          playlistId: playlist.id,
          excludeVersionIds: playlist.items
              .where((item) => item.type == 'cipher_version')
              .map((item) => item.contentId)
              .toList(), // Don't show already added
        ),
      ),
    );
  }

  void _showCollaborators(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CollaboratorsBottomSheet(playlist: playlist),
    );
  }

  Widget _buildItemWidget(BuildContext context, PlaylistItem item) {
    switch (item.type) {
      case 'cipher_version':
        return CipherVersionCard(
          cipherVersionId: item.contentId,
          onDelete: () =>
              _handleDeleteVersion(context, playlistId, item.contentId),
        );
      case 'text_section':
        return TextSectionCard(
          textSectionId: item.contentId,
          playlistId: playlistId,
        );
      default:
        return Card(
          child: ListTile(
            leading: const Icon(Icons.help),
            title: Text('Unknown item type: ${item.type}'),
            subtitle: Text('Content ID: ${item.contentId}'),
          ),
        );
    }
  }

  void _editPlaylist(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => EditPlaylistForm(playlist: playlist),
    );
  }

  void _onReorder(
    BuildContext context,
    Playlist playlist,
    int oldIndex,
    int newIndex,
  ) {
    // TODO: Implement unified items reordering
    // For now, disable reordering until we implement the unified approach
    // Need to implement reorderPlaylistItems method in provider

    /* 
    final playlistProvider = context.read<PlaylistProvider>();
    // Update the playlist order in the provider
    playlistProvider.reorderPlaylistCipherMaps(
      playlist.id,
      (playlist.cipherVersionIds
        ..insert(newIndex, playlist.cipherVersionIds.removeAt(oldIndex))),
    );
    */
  }

  void _handleDeleteVersion(
    BuildContext context,
    int playlistId,
    int versionId,
  ) {
    // Show confirmation dialog first
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Cifra'),
        content: const Text('Deseja remover esta cifra da playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Update provider for persistence
              final playlistProvider = context.read<PlaylistProvider>();
              playlistProvider.removeCipherMapFromPlaylist(
                playlistId,
                versionId,
              );
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
