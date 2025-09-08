import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/widgets/playlist/cipher_version_card.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/domain/playlist.dart';
import 'package:provider/provider.dart';
import '../widgets/cipher/editor/custom_reorderable_delayed.dart';
import '../widgets/playlist/collaborators_bottom_sheet.dart';
import '../widgets/playlist/edit_playlist_form.dart';
import '../widgets/playlist/empty_playlist_widget.dart';

class PlaylistViewer extends StatefulWidget {
  final Playlist playlist;

  const PlaylistViewer({super.key, required this.playlist});

  @override
  State<PlaylistViewer> createState() => _PlaylistViewerState();
}

class _PlaylistViewerState extends State<PlaylistViewer> {
  late List<int> _cipherVersionIds;

  @override
  void initState() {
    super.initState();
    _cipherVersionIds = List.from(widget.playlist.cipherVersionIds);
  }

  void _onReorder(int oldIndex, int newIndex) {
    // Update UI immediately (optimistic update)
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _cipherVersionIds.removeAt(oldIndex);
      _cipherVersionIds.insert(newIndex, item);
    });

    // Persist to database (async, no UI blocking)
    final playlistProvider = context.read<PlaylistProvider>();
    playlistProvider.reorderPlaylistCipherMaps(
      widget.playlist.id,
      _cipherVersionIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCipherVersions = _cipherVersionIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.playlist.name,
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: hasCipherVersions
            ? ReorderableListView.builder(
                proxyDecorator: (child, index, animation) =>
                    Material(type: MaterialType.transparency, child: child),
                buildDefaultDragHandles: true,
                header: Center(child: Text(widget.playlist.description ?? '')),
                itemCount: _cipherVersionIds.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final cipherVersionId = _cipherVersionIds[index];
                  return CustomReorderableDelayed(
                    delay: Duration(milliseconds: 200),
                    key: Key(cipherVersionId.toString()),
                    index: index,
                    child: CipherVersionCard(cipherVersionId: cipherVersionId),
                  );
                },
              )
            : const EmptyPlaylistWidget(),
      ),
    );
  }

  void _showCollaborators(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CollaboratorsBottomSheet(playlist: widget.playlist),
    );
  }

  void _editPlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditPlaylistForm(playlist: widget.playlist),
    );
  }
}
