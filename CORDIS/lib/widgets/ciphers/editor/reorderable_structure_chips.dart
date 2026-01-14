import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:cordis/widgets/ciphers/editor/custom_reorderable_delayed.dart';
import 'package:provider/provider.dart';

class ReorderableStructureChips extends StatefulWidget {
  final dynamic versionId;

  const ReorderableStructureChips({super.key, required this.versionId});

  @override
  State<ReorderableStructureChips> createState() =>
      _ReorderableStructureChipsState();
}

class _ReorderableStructureChipsState extends State<ReorderableStructureChips> {
  void _reorder(int oldIndex, int newIndex, VersionProvider versionProvider) {
    versionProvider.cacheReorderedStructure(
      widget.versionId ?? -1,
      oldIndex,
      newIndex,
    );
  }

  void _removeSection(
    int index,
    VersionProvider versionProvider,
    SectionProvider sectionProvider,
  ) {
    versionProvider.removeSectionFromStruct(widget.versionId ?? -1, index);
    if (versionProvider
        .getSongStructure(widget.versionId ?? -1)
        .contains(
          versionProvider.getSongStructure(widget.versionId ?? -1)[index],
        )) {
      return;
    }
    sectionProvider.cacheDeleteSection(
      widget.versionId ?? -1,
      versionProvider.getSongStructure(widget.versionId ?? -1)[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer2<VersionProvider, SectionProvider>(
      builder: (context, versionProvider, sectionProvider, child) {
        final songStructure = versionProvider.getSongStructure(
          widget.versionId ?? -1,
        );

        return Container(
          padding: EdgeInsets.all(8),
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.surfaceContainerLowest),
            borderRadius: BorderRadius.circular(0),
          ),
          child: songStructure.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noSectionsInStructurePrompt,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ReorderableListView.builder(
                  proxyDecorator: (child, index, animation) =>
                      Material(type: MaterialType.transparency, child: child),
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: songStructure.length,

                  onReorder: (oldIndex, newIndex) =>
                      _reorder(oldIndex, newIndex, versionProvider),
                  itemBuilder: (context, index) {
                    final sectionCode = songStructure[index];
                    final section = sectionProvider.getSection(
                      widget.versionId,
                      sectionCode,
                    )!;
                    final color = section.contentColor;

                    return CustomReorderableDelayed(
                      delay: Duration(milliseconds: 100),
                      key: ValueKey('$sectionCode-$index'),
                      index: index,
                      child: Container(
                        key: ValueKey('$sectionCode-$index'),
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: .8),
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  color: colorScheme.shadow,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  sectionCode,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: GestureDetector(
                                onTap: () => _removeSection(
                                  index,
                                  versionProvider,
                                  sectionProvider,
                                ),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: colorScheme.onSurface,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
