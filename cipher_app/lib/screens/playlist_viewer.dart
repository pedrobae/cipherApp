import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/widgets/playlist/cipher_version_card.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/domain/playlist.dart';
import 'package:provider/provider.dart';
import '../widgets/playlist/collaborators_bottom_sheet.dart';
import '../widgets/playlist/edit_playlist_form.dart';
import '../widgets/playlist/empty_playlist_widget.dart';

class PlaylistViewer extends StatelessWidget {
  final Playlist playlist;

  const PlaylistViewer({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final bool hasCipherVersions = playlist.cipherVersionIds.isNotEmpty;

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
            tooltip: 'Versões',
            onPressed: () => _showCollaborators(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _editPlaylist(context),
          ),
        ],
      ),
      body: hasCipherVersions
          ? ReorderableListView(
              proxyDecorator: (child, index, animation) =>
                  Material(type: MaterialType.transparency, child: child),
              buildDefaultDragHandles: true,
              header: Center(child: Text(playlist.description ?? '')),
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final item = playlist.cipherVersionIds.removeAt(oldIndex);
                playlist.cipherVersionIds.insert(newIndex, item);
                playlistProvider.reorderPlaylistCipherMaps(
                  playlist.id,
                  playlist.cipherVersionIds,
                );
              },
              children: playlist.cipherVersionIds.map((cipherVersionId) {
                return CipherVersionCard(
                  key: Key(cipherVersionId.toString()),
                  cipherVersionId: cipherVersionId,
                );
              }).toList(),
            )
          : const EmptyPlaylistWidget(),
    );
  }

  void _showCollaborators(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CollaboratorsBottomSheet(playlist: playlist),
    );
  }

  void _editPlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditPlaylistForm(playlist: playlist),
    );
  }
}
