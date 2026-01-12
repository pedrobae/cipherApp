import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/auth_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/icon_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/widgets/ciphers/library/cipher_versions_scroll_view.dart';
import 'package:cordis/screens/cipher/cipher_viewer.dart';

class CipherLibraryScreen extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;

  const CipherLibraryScreen({
    super.key,
    this.selectionMode = false,
    this.playlistId,
  });

  @override
  State<CipherLibraryScreen> createState() => _CipherLibraryScreenState();
}

class _CipherLibraryScreenState extends State<CipherLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    final cipherProvider = Provider.of<CipherProvider>(context, listen: false);
    cipherProvider.loadLocalCiphers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer6<
      CipherProvider,
      UserProvider,
      AuthProvider,
      PlaylistProvider,
      VersionProvider,
      SelectionProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            userProvider,
            authProvider,
            playlistProvider,
            versionProvider,
            selectionProvider,
            child,
          ) {
            return Scaffold(
              appBar: widget.selectionMode
                  ? AppBar(
                      title: Text(AppLocalizations.of(context)!.addToPlaylist),
                      backgroundColor: colorScheme.surface,
                    )
                  : null,
              body: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Column(
                  spacing: 8,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchCiphers,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(
                            color: colorScheme.surfaceContainer,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        suffixIcon: const Icon(Icons.search),
                        fillColor: colorScheme.surfaceContainerHighest,
                        visualDensity: VisualDensity.compact,
                      ),
                      onChanged: (value) {
                        // TODO: Implement search functionality
                      },
                    ),
                    // Buttons Row (e.g., Filters, Sort, Create New Cipher)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // CREATE NEW CIPHER
                        IconTextButton(
                          onTap: () {
                            //TODO: Implement create new cipher functionality
                          },
                          text: AppLocalizations.of(context)!.create,
                          icon: Icon(Icons.add, color: colorScheme.onSurface),
                        ),
                        // SORT BUTTON
                        IconTextButton(
                          onTap: () {
                            // TODO: Implement sort functionality
                          },
                          text: AppLocalizations.of(context)!.sort,
                          icon: Icon(Icons.sort, color: colorScheme.onSurface),
                        ),
                        // FILTER BUTTON
                        IconTextButton(
                          onTap: () {
                            // TODO: Implement filter functionality
                          },
                          text: AppLocalizations.of(context)!.filter,
                          icon: Icon(
                            Icons.filter_list,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: CipherVersionsScrollView(
                        selectionMode: widget.selectionMode,
                        playlistId: widget.playlistId,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  void onTapCipherVersion(
    int versionId,
    int cipherId,
    PlaylistProvider playlistProvider,
    UserProvider userProvider,
    AuthProvider authProvider,
    VersionProvider versionProvider,
    SelectionProvider selectionProvider,
  ) {
    if (widget.selectionMode) {
      try {
        if (selectionProvider.isSelectionMode) {
          selectionProvider.toggleItemSelection(versionId);
          return;
        }
        playlistProvider.addVersionToPlaylist(
          widget.playlistId!,
          versionId,
          userProvider.getLocalIdByFirebaseId(authProvider.id!)!,
        );
        versionProvider.loadVersionsForPlaylist(
          playlistProvider.getLocalPlaylistById(widget.playlistId!)!.items,
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorPrefix}$error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CipherViewer(cipherId: cipherId, versionId: versionId),
        ),
      );
    }
  }

  Future<void> onLongPressCipherVersion(
    int versionId,
    int cipherId,
    PlaylistProvider playlistProvider,
    UserProvider userProvider,
    AuthProvider authProvider,
    VersionProvider versionProvider,
    SelectionProvider selectionProvider,
  ) async {
    if (!widget.selectionMode) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CipherViewer(cipherId: cipherId, versionId: versionId),
        ),
      );
    } else {
      selectionProvider.enableSelectionMode();
      selectionProvider.toggleItemSelection(versionId);
    }
  }
}
