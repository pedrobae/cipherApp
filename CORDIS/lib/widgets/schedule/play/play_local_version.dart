import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/utils/date_utils.dart';
import 'package:cordis/utils/section_helper.dart';
import 'package:cordis/widgets/ciphers/viewer/section_card.dart';
import 'package:cordis/widgets/ciphers/viewer/structure_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class PlayLocalVersion extends StatefulWidget {
  final int versionId;

  const PlayLocalVersion({super.key, required this.versionId});

  @override
  State<PlayLocalVersion> createState() => _PlayLocalVersionState();
}

class _PlayLocalVersionState extends State<PlayLocalVersion> {
  late final ScrollController _scrollController;
  final List<GlobalKey> sectionKeys = [];
  bool showTopBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ENSURE CONTENT DATA IS LOADED
      await _ensureDataLoaded();
    });
  }

  Future<void> _ensureDataLoaded() async {
    final versionProvider = context.read<VersionProvider>();
    final sectionProvider = context.read<SectionProvider>();

    await versionProvider.loadLocalVersionById(widget.versionId);
    await sectionProvider.loadLocalSections(widget.versionId);

    // SET UP SCROLL LISTENER
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 105 && !showTopBar) {
      setState(() {
        showTopBar = true;
      });
    } else if (_scrollController.offset <= 105 && showTopBar) {
      setState(() {
        showTopBar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer4<
      CipherProvider,
      VersionProvider,
      SectionProvider,
      LayoutSettingsProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            versionProvider,
            sectionProvider,
            layoutSettings,
            child,
          ) {
            final version = versionProvider.getLocalVersionById(
              widget.versionId,
            )!;

            final cipher = cipherProvider.getCipherById(version.cipherId)!;

            final filteredStructure = version.songStructure
                .where(
                  (sectionCode) =>
                      ((layoutSettings.showAnnotations ||
                          !isAnnotation(sectionCode)) &&
                      (layoutSettings.showTransitions ||
                          !isTransition(sectionCode))),
                )
                .toList()
                .asMap();
            final sectionCardList = filteredStructure.entries.map((entry) {
              String trimmedCode = entry.value.trim();
              final section = sectionProvider.getSection(
                widget.versionId,
                trimmedCode,
              );
              sectionKeys.add(GlobalKey());
              if (section == null) {
                return const SizedBox.shrink();
              }
              return SectionCard(
                key: sectionKeys[entry.key],
                sectionType: section.contentType,
                sectionCode: trimmedCode,
                sectionText: sectionProvider
                    .getSections(widget.versionId)[trimmedCode]!
                    .contentText,
                sectionColor: sectionProvider
                    .getSections(widget.versionId)[trimmedCode]!
                    .contentColor,
              );
            }).toList();

            // Add space at the end of the list for better scrolling
            sectionCardList.add(SizedBox(height: 200));
            return Stack(
              children: [
                // CONTENT
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        // HEADER
                        Text(
                          cipher.title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Row(
                          spacing: 16.0,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.keyWithPlaceholder(
                                version.transposedKey ?? cipher.musicKey,
                              ),
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.bpmWithPlaceholder(version.bpm),
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              '${AppLocalizations.of(context)!.duration}: ${DateTimeUtils.formatDuration(version.duration)}',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border.fromBorderSide(
                              BorderSide(
                                color: colorScheme.surfaceContainerLowest,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 8.0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.songStructure,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              StructureList(
                                versionId: widget.versionId,
                                filteredStructure: filteredStructure.values
                                    .toList(),
                                scrollController: _scrollController,
                                sectionKeys: sectionKeys,
                              ),
                            ],
                          ),
                        ),

                        // SECTION CARDS GRID
                        MasonryGridView.count(
                          crossAxisCount: layoutSettings.columnCount,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          itemCount: sectionCardList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) =>
                              sectionCardList[index],
                        ),
                      ],
                    ),
                  ),
                ),

                // SCROLL-CONDITIONAL TOP SONG STRUCTURE BAR
                if (showTopBar)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border(
                              bottom: BorderSide(
                                color: colorScheme.surfaceContainerHigh,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 64,
                            ),
                            child: StructureList(
                              versionId: widget.versionId,
                              filteredStructure: filteredStructure.values
                                  .toList(),
                              scrollController: _scrollController,
                              sectionKeys: sectionKeys,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border(
                              left: BorderSide(
                                color: colorScheme.surfaceContainerHigh,
                                width: 1,
                              ),
                              bottom: BorderSide(
                                color: colorScheme.surfaceContainerHigh,
                                width: 1,
                              ),
                            ),
                          ),
                          height: 64,
                          width: 64,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
    );
  }
}
