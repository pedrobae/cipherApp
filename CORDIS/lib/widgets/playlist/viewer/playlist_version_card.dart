import 'dart:math';

import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/section.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/screens/cipher/edit_cipher.dart';
import 'package:cordis/utils/date_utils.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/editor/custom_reorderable_delayed.dart';

class PlaylistVersionCard extends StatefulWidget {
  final int playlistId;
  final dynamic versionId;
  final int index;

  const PlaylistVersionCard({
    super.key,
    required this.playlistId,
    required this.index,
    required this.versionId,
  });

  @override
  State<PlaylistVersionCard> createState() => _PlaylistVersionCardState();
}

class _PlaylistVersionCardState extends State<PlaylistVersionCard> {
  @override
  void initState() {
    super.initState();
    // Pre-load cipher data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final versionProvider = context.read<VersionProvider>();
      final sectionProvider = context.read<SectionProvider>();
      final cipherProvider = context.read<CipherProvider>();

      // Ensure cipher is loaded for local versions
      if (widget.versionId is int) {
        await cipherProvider.loadCipherOfVersion(widget.versionId);
      }

      // Ensure the specific version is loaded
      if (!versionProvider.isVersionCached(widget.versionId)) {
        if (widget.versionId is String) {
          await versionProvider.loadCloudUserVersionByFirebaseId(
            widget.versionId,
          );
          sectionProvider.setNewSectionsInCache(
            widget.versionId,
            versionProvider
                .getCloudVersionByFirebaseId(widget.versionId)!
                .sections
                .map(
                  (key, section) =>
                      MapEntry(key, Section.fromFirestore(section)),
                ),
          );
        } else {
          await versionProvider.loadLocalVersionById(widget.versionId);
          await sectionProvider.loadLocalSections(widget.versionId);
        }
      }
    });
  }

  void _onReorder(
    BuildContext context,
    List<String> songStructure,
    int oldIndex,
    int newIndex,
  ) {
    // Create updated song structure
    final updatedStructure = List<String>.from(songStructure);
    if (newIndex > oldIndex) newIndex--;
    final item = updatedStructure.removeAt(oldIndex);
    updatedStructure.insert(newIndex, item);

    // Persist to database
    context.read<VersionProvider>().saveUpdatedSongStructure(
      widget.versionId,
      updatedStructure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer6<
      VersionProvider,
      CipherProvider,
      PlaylistProvider,
      NavigationProvider,
      UserProvider,
      MyAuthProvider
    >(
      builder:
          (
            context,
            versionProvider,
            cipherProvider,
            playlistProvider,
            navigationProvider,
            userProvider,
            authProvider,
            child,
          ) {
            dynamic version;
            bool isCloud;

            if (widget.versionId is String) {
              version = versionProvider.getCloudVersionByFirebaseId(
                widget.versionId,
              );
              isCloud = true;
            } else {
              version = versionProvider.getLocalVersionById(widget.versionId);
              isCloud = false;
            }

            // If version is not cached yet, show loading indicator
            if (version == null) {
              return Center(child: CircularProgressIndicator());
            }

            final List<String> songStructure = version.songStructure;

            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.surfaceContainerLowest),
                borderRadius: BorderRadius.circular(0),
              ),
              padding: const EdgeInsets.only(left: 8),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomReorderableDelayed(
                    delay: Duration(milliseconds: 100),
                    index: widget.index,
                    child: Icon(Icons.drag_indicator),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          start: BorderSide(
                            color: colorScheme.surfaceContainerLowest,
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 8,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  spacing: 4,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isCloud
                                          ? version.title
                                          : cipherProvider
                                                .getCipherById(
                                                  version.cipherId,
                                                )!
                                                .title,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      softWrap: true,
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${AppLocalizations.of(context)!.musicKey}: ',
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                            Text(
                                              isCloud
                                                  ? (version.transposedKey ??
                                                        version.originalKey)
                                                  : (version.transposedKey ??
                                                        cipherProvider
                                                            .getCipherById(
                                                              version.cipherId,
                                                            )!
                                                            .musicKey),
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${AppLocalizations.of(context)!.bpm}: ',
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                            Text(
                                              version.bpm.toString(),
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateTimeUtils.formatDuration(
                                            isCloud
                                                ? Duration(
                                                    seconds: version.duration,
                                                  )
                                                : version.duration,
                                          ),
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                    // REORDERABLE SECTION CHIPS
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 25,
                                      ),
                                      child: ReorderableListView.builder(
                                        shrinkWrap: true,
                                        proxyDecorator:
                                            (child, index, animation) =>
                                                Material(
                                                  type:
                                                      MaterialType.transparency,
                                                  child: child,
                                                ),
                                        buildDefaultDragHandles: false,
                                        physics: const ClampingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: songStructure.length,
                                        onReorder: (oldIndex, newIndex) =>
                                            _onReorder(
                                              context,
                                              songStructure,
                                              oldIndex,
                                              newIndex,
                                            ),
                                        itemBuilder: (_, index) {
                                          final sectionCode =
                                              songStructure[index];
                                          final Section section = isCloud
                                              ? Section.fromFirestore(
                                                  version
                                                      .sections[sectionCode]!,
                                                )
                                              : version.sections![sectionCode];
                                          // To ensure unique keys for identical section codes,
                                          final occurrenceIndex = songStructure
                                              .take(index + 1)
                                              .where(
                                                (code) => code == sectionCode,
                                              )
                                              .length;

                                          // Painter for sections with large codes
                                          final textPainter = TextPainter(
                                            text: TextSpan(
                                              text: sectionCode,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            maxLines: 1,
                                            textDirection: TextDirection.ltr,
                                          )..layout();

                                          return CustomReorderableDelayed(
                                            delay: Duration(milliseconds: 100),
                                            key: ValueKey(
                                              'cipher_${widget.versionId}_section_${sectionCode}_occurrence_$occurrenceIndex',
                                            ),
                                            index: index,
                                            child: Container(
                                              height: 25,
                                              width: max(
                                                25,
                                                textPainter.size.width + 8,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                color: section.contentColor
                                                    .withValues(alpha: 0.8),
                                                border: BoxBorder.all(
                                                  color: section.contentColor,
                                                  width: 2,
                                                ),
                                              ),
                                              margin: const EdgeInsets.only(
                                                right: 4,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  strutStyle: StrutStyle(
                                                    forceStrutHeight: true,
                                                  ),
                                                  sectionCode,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                iconSize: 30,
                                onSelected: (value) {
                                  switch (value) {
                                    case 'delete':
                                      playlistProvider
                                          .removeVersionFromPlaylist(
                                            widget.versionId,
                                            widget.playlistId,
                                          );
                                      break;
                                    case 'copy':
                                      playlistProvider.duplicateVersion(
                                        widget.playlistId,
                                        widget.versionId,
                                        userProvider.getLocalIdByFirebaseId(
                                          authProvider.id!,
                                        )!,
                                      );
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Excluir'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'copy',
                                    child: Row(
                                      children: [
                                        Icon(Icons.copy),
                                        SizedBox(width: 8),
                                        Text('Duplicar'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          FilledTextButton(
                            text: AppLocalizations.of(context)!.view,
                            isDense: true,
                            onPressed: () {
                              navigationProvider.push(
                                EditCipherScreen(
                                  versionType: isCloud
                                      ? VersionType.cloud
                                      : VersionType.local,
                                  versionId: widget.versionId,
                                  cipherId: isCloud ? null : version.cipherId,
                                  isEnabled: false,
                                ),
                              );
                            },
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
  }
}
