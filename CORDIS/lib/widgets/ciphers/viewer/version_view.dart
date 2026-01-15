import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/viewer/structure_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/utils/section_helper.dart';
import 'section_card.dart';

class VersionView extends StatefulWidget {
  final dynamic versionId;
  const VersionView({super.key, required this.versionId});

  @override
  State<VersionView> createState() => _VersionViewState();
}

class _VersionViewState extends State<VersionView> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  void _scrollToSectionIndex(BuildContext context, int index) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final scrollPosition =
        scrollController.offset + position.dy - 100; // 100px offset from top

    scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<VersionProvider, SectionProvider, LayoutSettingsProvider>(
      builder:
          (context, versionProvider, sectionProvider, layoutSettings, child) {
            final songStructure = versionProvider.getSongStructure(
              widget.versionId,
            );

            final filteredStructure = songStructure.where(
              (sectionCode) =>
                  ((layoutSettings.showAnnotations ||
                      !isAnnotation(sectionCode)) &&
                  (layoutSettings.showTransitions ||
                      !isTransition(sectionCode))),
            );
            final sectionCardList = filteredStructure.map((sectionCode) {
              String trimmedCode = sectionCode.trim();
              final section = sectionProvider.getSection(
                widget.versionId,
                trimmedCode,
              );
              if (section == null) {
                return const SizedBox.shrink();
              }
              return CipherSectionCard(
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16,
                children: [
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.songStructure,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      StructureList(
                        versionId: widget.versionId,
                        scrollToSection: (BuildContext context, int index) =>
                            _scrollToSectionIndex(context, index),
                      ),
                    ],
                  ),
                  MasonryGridView.count(
                    crossAxisCount: layoutSettings.columnCount,
                    controller: scrollController,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: sectionCardList.length,
                    itemBuilder: (context, index) => sectionCardList[index],
                  ),
                ],
              ),
            );
          },
    );
  }
}
