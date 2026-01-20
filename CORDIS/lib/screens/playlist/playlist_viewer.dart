import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/screens/cipher/cipher_library.dart';
import 'package:cordis/widgets/filled_text_button.dart';
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
      final cipherProvider = context.read<CipherProvider>();

      await versionProvider.loadVersionsForPlaylist(
        playlistProvider.getPlaylistById(widget.playlistId)!.items,
      );

      // Ensure all ciphers are loaded (loads all ciphers if not already loaded)
      await cipherProvider.loadLocalCiphers();
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
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16.0,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          spacing: 12.0,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (playlist.items.isEmpty) ...[
                              Column(
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
                                  SizedBox(height: 24),
                                ],
                              ),
                            ] else ...[
                              // ITEMS LIST
                            ],
                            // ADD ITEMS BUTTON
                            FilledTextButton(
                              text: AppLocalizations.of(context)!.addSong,
                              isDense: true,
                              onPressed: () {
                                selectionProvider.enableSelectionMode();
                                selectionProvider.setTarget(widget.playlistId);

                                navigationProvider.push(
                                  const CipherLibraryScreen(),
                                  isDense: true,
                                );
                              },
                            ),
                            FilledTextButton(
                              text: AppLocalizations.of(context)!.addFlowItem,
                              isDense: true,
                              onPressed: () {
                                // TODO add flow items
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    FilledTextButton(
                      text: AppLocalizations.of(context)!.save,
                      isDarkButton: true,
                      onPressed: () {
                        // TODO save playlist changes
                      },
                    ),
                    FilledTextButton(
                      text: AppLocalizations.of(context)!.cancel,
                      onPressed: () {
                        navigationProvider.pop();
                      },
                    ),
                  ],
                ),
              ),
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
        case PlaylistItemType.cipherVersion:
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
