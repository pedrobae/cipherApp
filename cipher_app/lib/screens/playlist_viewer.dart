import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/playlist/cipher_version_card.dart';
import 'package:cipher_app/widgets/playlist/text_section_card.dart';
import 'package:cipher_app/widgets/playlist/empty_playlist.dart';
import 'package:cipher_app/widgets/cipher/editor/custom_reorderable_delayed.dart';
import 'package:cipher_app/widgets/playlist/collaborators/bottom_sheet.dart';
import 'package:cipher_app/widgets/dialogs/edit_playlist_dialog.dart';
import 'package:cipher_app/widgets/dialogs/new_text_section_dialog.dart';
import 'cipher_library.dart';
import 'playlist_presentation.dart';

class PlaylistViewer extends StatefulWidget {
  final int playlistId; // Receive the playlist ID from the parent

  const PlaylistViewer({super.key, required this.playlistId});

  @override
  State<PlaylistViewer> createState() => _PlaylistViewerState();
}

class _PlaylistViewerState extends State<PlaylistViewer> {
  bool _versionsLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load versions when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlaylistVersions();
    });
  }

  Future<void> _loadPlaylistVersions() async {
    try {
      final playlistProvider = context.read<PlaylistProvider>();
      final playlist = playlistProvider.playlists.firstWhere(
        (p) => p.id == widget.playlistId,
        orElse: () => throw Exception('Playlist not found'),
      );

      if (playlist.items.isNotEmpty) {
        final versionProvider = context.read<VersionProvider>();
        final cipherProvider = context.read<CipherProvider>();

        // Load versions for playlist
        await versionProvider.loadVersionsForPlaylist(playlist.items);

        // Ensure all ciphers are loaded (loads all ciphers if not already loaded)
        if (!cipherProvider.hasLoadedCiphers) {
          await cipherProvider.loadCiphers();
        }

        if (mounted) {
          setState(() {
            _versionsLoaded = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _versionsLoaded = true;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading playlist versions: $e');
      }
      if (mounted) {
        setState(() {
          _versionsLoaded = true; // Still show the UI even if loading failed
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar versões: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload versions if they haven't been loaded yet
    // Use post-frame callback to avoid setState during build
    if (!_versionsLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPlaylistVersions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the playlist from the provider
    final playlistProvider = context.watch<PlaylistProvider>();
    final playlist = playlistProvider.playlists.firstWhere(
      (p) => p.id == widget.playlistId,
      orElse: () => throw Exception('Playlist not found'),
    );

    final bool hasItems = playlist.items.isNotEmpty;

    // Show loading if versions haven't been loaded yet
    if (!_versionsLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(playlist.name), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          if (hasItems)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: 'Modo Apresentação',
              onPressed: () => _openPresentationMode(context, playlist),
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
      floatingActionButton: SpeedDial(
        children: [
          SpeedDialChild(
            onTap: () => _navigateToAddCiphers(context, playlist),
            child: Icon(Icons.library_music),
          ),
          SpeedDialChild(
            onTap: () => _addTextSection(context, playlist),
            child: Icon(Icons.text_snippet),
          ),
        ],
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
              _handleDeleteVersion(context, widget.playlistId, item.contentId),
          onCopy: () => _handleCopyVersion(context, item.contentId),
        );
      case 'text_section':
        return TextSectionCard(
          textSectionId: item.contentId,
          playlistId: widget.playlistId,
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
  ) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    try {
      await context.read<PlaylistProvider>().reorderItems(
        oldIndex,
        newIndex,
        playlist,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reordenar: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tentar Novamente',
              textColor: Colors.white,
              onPressed: () =>
                  _onReorder(context, playlist, oldIndex, newIndex),
            ),
          ),
        );
      }
    }
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

  void _handleCopyVersion(BuildContext context, int versionId) {
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID da versão copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openPresentationMode(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PlaylistPresentationScreen(playlistId: playlist.id),
      ),
    );
  }

  void _addTextSection(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => NewTextSectionDialog(playlist: playlist),
    );
  }
}
