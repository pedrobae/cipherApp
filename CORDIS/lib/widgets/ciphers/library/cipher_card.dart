import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/screens/cipher/cipher_editor.dart';
import 'package:cordis/screens/cipher/cipher_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CipherCard extends StatefulWidget {
  final int cipherId;

  const CipherCard({super.key, required this.cipherId});

  @override
  State<CipherCard> createState() => _CipherCardState();
}

class _CipherCardState extends State<CipherCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VersionProvider>().loadVersionsOfCipher(widget.cipherId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer5<
      CipherProvider,
      VersionProvider,
      SelectionProvider,
      PlaylistProvider,
      NavigationProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            versionProvider,
            selectionProvider,
            playlistProvider,
            navigationProvider,
            child,
          ) {
            // Error handling
            if (cipherProvider.error != null || versionProvider.error != null) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.errorMessage(
                    AppLocalizations.of(context)!.loading,
                    cipherProvider.error ?? versionProvider.error!,
                  ),
                ),
              );
            }

            final cipher = cipherProvider.getCipherById(widget.cipherId)!;
            final versionCount = versionProvider.getVersionsOfCipherCount(
              widget.cipherId,
            );

            final versionId = versionProvider.getIdOfOldestVersionOfCipher(
              widget.cipherId,
            );

            // Loading state
            if (cipherProvider.isLoading ||
                versionProvider.isLoading ||
                versionId == null) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            final version = versionProvider.getVersionById(versionId)!;
            Duration duration;
            if (version.runtimeType != Version) {
              duration = Duration(seconds: (version as VersionDto).duration);
            } else {
              duration = (version as Version).duration;
            }

            // Card content
            return GestureDetector(
              onTap: () {
                if (selectionProvider.isSelectionMode) {
                  try {
                    selectionProvider.toggleItemSelection(versionId);
                    navigationProvider.push(
                      CipherEditor(
                        cipherId: widget.cipherId,
                        versionId: versionId,
                        versionType: VersionType.playlist,
                      ),
                      showAppBar: false,
                      showDrawerIcon: false,
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.errorMessage(
                            AppLocalizations.of(context)!.addToPlaylist,
                            error.toString(),
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                } else {
                  navigationProvider.push(
                    CipherViewer(
                      cipherId: widget.cipherId,
                      versionId: versionProvider.getIdOfOldestVersionOfCipher(
                        widget.cipherId,
                      ),
                      versionType: VersionType.local,
                    ),
                  );
                }
              },
              onLongPress: () async {
                if (!selectionProvider.isSelectionMode) {
                  navigationProvider.push(
                    CipherEditor(
                      cipherId: widget.cipherId,
                      versionId: versionProvider.getIdOfOldestVersionOfCipher(
                        widget.cipherId,
                      ),
                      versionType: VersionType.local,
                    ),
                  );
                } else {
                  selectionProvider.toggleItemSelection(
                    versionProvider.getIdOfOldestVersionOfCipher(
                      widget.cipherId,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.surfaceContainerLowest),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // INFO
                    Expanded(
                      child: Column(
                        spacing: 2.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cipher.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            spacing: 16.0,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.musicKey}: ${cipher.musicKey}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              version.bpm != 0
                                  ? Text(
                                      version.bpm.toString(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    )
                                  : Text('-'),
                              duration != Duration.zero
                                  ? Text(
                                      version.duration,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    )
                                  : Text('-'),
                            ],
                          ),
                          Text(
                            '$versionCount${AppLocalizations.of(context)!.versions}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLowest,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // ACTIONS
                    IconButton(
                      onPressed: () {
                        // TODO: implement actions menu
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Funcionalidade em desenvolvimento 🚧',
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}
