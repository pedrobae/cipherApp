// ignore_for_file: use_build_context_synchronously

import 'package:cipher_app/models/dtos/text_section_dto.dart';
import 'package:cipher_app/models/dtos/version_dto.dart';
import 'package:cipher_app/providers/text_section_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:cipher_app/providers/collaborator_provider.dart';
import 'package:cipher_app/screens/cipher/cipher_library.dart';
import 'package:cipher_app/screens/playlist/playlist_presentation.dart';
import 'package:cipher_app/widgets/playlist/cipher_version_card.dart';
import 'package:cipher_app/widgets/playlist/text_section_card.dart';
import 'package:cipher_app/widgets/ciphers/editor/custom_reorderable_delayed.dart';
import 'package:cipher_app/widgets/playlist/collaborators/bottom_sheet.dart';
import 'package:cipher_app/widgets/dialogs/edit_playlist_dialog.dart';
import 'package:cipher_app/widgets/dialogs/new_text_section_dialog.dart';

class PlaylistViewer extends StatefulWidget {
  final int playlistId; // Receive the playlist ID from the parent
  final VoidCallback? syncPlaylist;

  const PlaylistViewer({
    super.key,
    required this.playlistId,
    this.syncPlaylist,
  });

  @override
  State<PlaylistViewer> createState() => _PlaylistViewerState();
}

class _PlaylistViewerState extends State<PlaylistViewer> {
  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPlaylist();
  }

  void _loadPlaylist() {
    // Load versions when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final playlistProvider = context.read<PlaylistProvider>();
      final versionProvider = context.read<VersionProvider>();
      final cipherProvider = context.read<CipherProvider>();

      // Load the playlist
      await playlistProvider.loadPlaylist(widget.playlistId);

      // Load versions for playlist
      await versionProvider.loadVersionsForPlaylist(
        playlistProvider.currentPlaylist!.items,
      );

      // Ensure all ciphers are loaded (loads all ciphers if not already loaded)
      await cipherProvider.loadCiphers();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read the playlist from the provider
    return Consumer6<
      PlaylistProvider,
      VersionProvider,
      CipherProvider,
      UserProvider,
      AuthProvider,
      CollaboratorProvider
    >(
      builder:
          (
            context,
            playlistProvider,
            versionProvider,
            cipherProvider,
            userProvider,
            authProvider,
            collaboratorProvider,
            child,
          ) {
            final colorScheme = Theme.of(context).colorScheme;
            final playlist = playlistProvider.currentPlaylist;
            // Handle loading state
            if (playlist == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                shadowColor: colorScheme.shadow,
                elevation: 4,
                title: Column(
                  children: [
                    Text(
                      playlist.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                actions: [
                  if (widget.syncPlaylist != null) ...[
                    IconButton(
                      onPressed: widget.syncPlaylist,
                      icon: Icon(Icons.cloud_sync),
                    ),
                  ],
                  if (playlist.createdBy ==
                      userProvider.getLocalIdByFirebaseId(
                        authProvider.id!,
                      )) ...[
                    IconButton(
                      onPressed: () {
                        _publishPlaylist(
                          collaboratorProvider,
                          userProvider,
                          playlistProvider,
                          authProvider,
                          cipherProvider,
                          versionProvider,
                          playlist,
                        );
                      },
                      icon: const Icon(Icons.cloud_upload),
                    ),
                  ],
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      key: Key('${item.type}_${item.id}'),
                      index: index,
                      child: _buildItemWidget(
                        context,
                        item,
                        playlistProvider,
                        userProvider,
                        authProvider,
                      ),
                    );
                  },
                ),
              ),
              bottomNavigationBar: _buildBottomActionBar(
                context,
                playlist,
                colorScheme,
              ),
            );
          },
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    Playlist playlist,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: .1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildActionButton(
              context,
              icon: Icons.library_music,
              label: 'Adicionar Cifra',
              onPressed: () => _navigateToAddCiphers(context, playlist),
            ),
            _buildActionButton(
              context,
              icon: Icons.text_snippet,
              label: 'Adicionar Texto',
              onPressed: () => _addTextSection(context, playlist),
            ),
            _buildActionButton(
              context,
              icon: Icons.fullscreen_sharp,
              label: 'Apresentação',
              onPressed: () => _openPresentationMode(context, playlist),
              highlighted: true,
            ),
            _buildActionButton(
              context,
              icon: Icons.group,
              label: 'Colaboradores',
              onPressed: () => _showCollaborators(context, playlist),
            ),
            _buildActionButton(
              context,
              icon: Icons.edit,
              label: 'Editar',
              onPressed: () => _editPlaylist(context, playlist),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool highlighted = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: highlighted
              ? BorderRadius.circular(100)
              : BorderRadius.circular(8),
          color: highlighted ? colorScheme.primary : null,
          boxShadow: [
            BoxShadow(
              color: highlighted ? colorScheme.shadow : Colors.transparent,
              blurRadius: highlighted ? 6.0 : 0.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(highlighted ? 4.0 : 0),
          child: Icon(
            icon,
            semanticLabel: label,
            size: highlighted ? 48 : 28,
            color: highlighted ? colorScheme.onPrimary : colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _navigateToAddCiphers(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CipherLibraryScreen(selectionMode: true, playlistId: playlist.id),
      ),
    );
  }

  void _showCollaborators(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CollaboratorsBottomSheet(playlist: playlist),
    );
  }

  Widget _buildItemWidget(
    BuildContext context,
    PlaylistItem item,
    PlaylistProvider playlistProvider,
    UserProvider userProvider,
    AuthProvider authProvider,
  ) {
    switch (item.type) {
      case 'cipher_version':
        return CipherVersionCard(
          versionId: item.contentId!,
          index: item.position,
          onDelete: () =>
              _handleDeleteVersion(context, item.id!, widget.playlistId),
          onCopy: () => playlistProvider.duplicateVersion(
            widget.playlistId,
            item.contentId!,
            userProvider.getLocalIdByFirebaseId(authProvider.id!)!,
          ),
        );
      case 'text_section':
        return TextSectionCard(
          textSectionId: item.contentId!,
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

  void _handleDeleteVersion(BuildContext context, int itemId, int playlistId) {
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
              playlistProvider.removeVersionFromPlaylist(itemId, playlistId);
            },
            child: const Text('Remover'),
          ),
        ],
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

  Future<void> _publishPlaylist(
    CollaboratorProvider collaboratorProvider,
    UserProvider userProvider,
    PlaylistProvider playlistProvider,
    AuthProvider authProvider,
    CipherProvider cipherProvider,
    VersionProvider versionProvider,
    Playlist playlist,
  ) async {
    final textSectionProvider = context.read<TextSectionProvider>();

    collaboratorProvider.loadCollaborators(playlist.id);
    final ownerFirebaseId = userProvider.getFirebaseIdByLocalId(
      playlist.createdBy,
    );

    final fullCollaborators = collaboratorProvider.getCollaboratorsForPlaylist(
      playlist.id,
    );

    List<Map<String, dynamic>> collaborators = [];
    for (final fullCollab in fullCollaborators) {
      collaborators.add({
        'id': userProvider.getFirebaseIdByLocalId(fullCollab.userId),
        'role': fullCollab.role,
      });
    }

    List<VersionDto> versions = [];
    List<TextSectionDto> textSections = [];
    for (final item in playlist.items) {
      switch (item.type) {
        case 'cipher_version':
          final version = versionProvider.getCachedVersionById(item.contentId!);
          versions.add(version.toDto());

          break;
        case 'text_section':
          final textSection = await textSectionProvider.getTextSectionById(
            item.contentId!,
          );
          if (textSection != null) {
            textSections.add(textSection.toDto());
          }
          break;
        default:
          // Unknown type, skip
          break;
      }
    }

    final playlistDto = playlist.toDto(
      ownerFirebaseId,
      collaborators,
      versions,
      textSections,
    );

    if (playlist.firebaseId == null) {
      if (kDebugMode) {
        print('Publishing new playlist: ${playlist.name}');
      }
      playlistProvider.uploadPlaylist(playlistDto);
    } else {
      if (kDebugMode) {
        print('Updating existing playlist: ${playlist.name}');
      }
      playlistProvider.uploadChanges(playlist.id, playlistDto);
    }
  }
}
