import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/screens/cipher/cipher_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/widgets/playlist/playlist_version_card.dart';
import 'package:cordis/widgets/playlist/text_section_card.dart';

class PlaylistViewer extends StatefulWidget {
  final int playlistId; // Receive the playlist ID from the parent

  const PlaylistViewer({super.key, required this.playlistId});

  @override
  State<PlaylistViewer> createState() => _PlaylistViewerState();
}

class _PlaylistViewerState extends State<PlaylistViewer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final playlistProvider = context.read<PlaylistProvider>();
      final versionProvider = context.read<VersionProvider>();

      await playlistProvider.loadPlaylist(widget.playlistId);

      await versionProvider.loadVersionsForPlaylist(
        playlistProvider.getPlaylistById(widget.playlistId)!.items,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer6<
      PlaylistProvider,
      CipherProvider,
      UserProvider,
      MyAuthProvider,
      NavigationProvider,
      SelectionProvider
    >(
      builder:
          (
            context,
            playlistProvider,
            cipherProvider,
            userProvider,
            authProvider,
            navigationProvider,
            selectionProvider,
            child,
          ) {
            final playlist = playlistProvider.getPlaylistById(
              widget.playlistId,
            );
            // Handle loading state
            if (playlist == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              appBar: AppBar(
                leading: BackButton(color: colorScheme.onSurface),
                title: Text(
                  playlist.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),

                // Save button
                actions: [
                  IconButton(
                    icon: Icon(Icons.save, color: colorScheme.onSurface),
                    onPressed: () {
                      // TODO save playlist changes
                    },
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _openPlaylistEditSheet(
                    context,
                    navigationProvider,
                    selectionProvider,
                    theme,
                  );
                },
                backgroundColor: colorScheme.onSurface,
                shape: const CircleBorder(),
                child: Icon(Icons.add, color: colorScheme.onPrimary),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16.0,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: playlist.items.isEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.emptyPlaylist,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.emptyPlaylistInstructions,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              )
                            // ITEMS LIST
                            : Builder(
                                builder: (context) {
                                  final items = _buildPlaylistItems(
                                    context,
                                    playlist,
                                    playlistProvider,
                                    userProvider,
                                    authProvider,
                                  );

                                  return SingleChildScrollView(
                                    child: Column(children: [...items]),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  void _openPlaylistEditSheet(
    BuildContext context,
    NavigationProvider navigationProvider,
    SelectionProvider selectionProvider,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheet(
          shape: LinearBorder(),
          onClosing: () {},
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              color: theme.colorScheme.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.quickAction,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  // ACTIONS
                  // ADD SONG TO PLAYLIST
                  GestureDetector(
                    onTap: () {
                      // Enable selection mode
                      selectionProvider.enableSelectionMode();
                      selectionProvider.setTarget(widget.playlistId);

                      // Close the bottom sheet
                      Navigator.of(context).pop();

                      // Navigate to Cipher Library Screen
                      navigationProvider.push(
                        CipherLibraryScreen(),
                        showAppBar: false,
                        showDrawerIcon: false,
                        onPopCallback: () {
                          // Disable selection mode when returning
                          selectionProvider.disableSelectionMode();
                          selectionProvider.clearTarget();
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainer,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addSong,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.shadow,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ADD FLOW ITEM TO PLAYLIST
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainer,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addFlowItem,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.shadow,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // DELETE PLAYLIST
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.delete,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.shadow,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPlaylistItems(
    BuildContext context,
    Playlist playlist,
    PlaylistProvider playlistProvider,
    UserProvider userProvider,
    MyAuthProvider authProvider,
  ) {
    return playlist.items.asMap().entries.map((entry) {
      final item = entry.value;

      switch (item.type) {
        case PlaylistItemType.version:
          return PlaylistVersionCard(
            playlistId: widget.playlistId,
            versionId: item.contentId!,
            index: item.position,
            onDelete: () {},
            onCopy: () => playlistProvider.duplicateVersion(
              widget.playlistId,
              item.contentId!,
              userProvider.getLocalIdByFirebaseId(authProvider.id!)!,
            ),
          );
        case PlaylistItemType.textSection:
          return TextSectionCard(
            textSectionId: item.contentId!,
            playlistId: widget.playlistId,
          );
      }
    }).toList();
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
}
