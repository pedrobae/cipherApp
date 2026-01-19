import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/providers/cipher_provider.dart';
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

    return Consumer4<
      CipherProvider,
      VersionProvider,
      SelectionProvider,
      PlaylistProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            versionProvider,
            selectionProvider,
            playlistProvider,
            child,
          ) {
            // Error handling
            if (cipherProvider.error != null || versionProvider.error != null) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${AppLocalizations.of(context)!.errorPrefix}${cipherProvider.error ?? versionProvider.error}',
                ),
              );
            }
            // Loading state
            if (cipherProvider.isLoading || versionProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            final cipher = cipherProvider.getCipherById(widget.cipherId)!;
            final versionCount = versionProvider.getVersionsOfCipherCount(
              widget.cipherId,
            );

            final versionId = versionProvider.getIdOfOldestVersionOfCipher(
              widget.cipherId,
            );

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
                    if (selectionProvider.isSelectionMode) {
                      selectionProvider.toggleItemSelection(cipher.id);
                      return;
                    }
                    playlistProvider.addVersionToPlaylist(
                      selectionProvider.targetId,
                      versionProvider.getIdOfOldestVersionOfCipher(cipher.id),
                    );
                    versionProvider.loadVersionsForPlaylist(
                      playlistProvider
                          .getPlaylistById(selectionProvider.targetId)!
                          .items,
                    );
                    Navigator.pop(context);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)!.errorPrefix}$error',
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CipherViewer(
                        cipherId: widget.cipherId,
                        versionId: versionProvider.getIdOfOldestVersionOfCipher(
                          widget.cipherId,
                        ),
                        versionType: VersionType.local,
                      ),
                    ),
                  );
                }
              },
              onLongPress: () async {
                if (!selectionProvider.isSelectionMode) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CipherEditor(
                        cipherId: widget.cipherId,
                        versionId: versionProvider.getIdOfOldestVersionOfCipher(
                          widget.cipherId,
                        ),
                        versionType: VersionType.local,
                      ),
                    ),
                  );
                } else {
                  selectionProvider.enableSelectionMode();
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
                              cipher.bpm != ''
                                  ? Text(
                                      cipher.bpm,
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
                    IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                  ],
                ),
              ),
            );
          },
    );
  }
}
