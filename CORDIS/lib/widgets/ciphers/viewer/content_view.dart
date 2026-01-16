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

class ContentView extends StatefulWidget {
  final dynamic versionId;

  ContentView({super.key, required this.versionId});

  final List<GlobalKey> sectionKeys = [];

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<VersionProvider, SectionProvider, LayoutSettingsProvider>(
      builder:
          (context, versionProvider, sectionProvider, layoutSettings, child) {
            final songStructure = versionProvider.getSongStructure(
              widget.versionId,
            );

            final filteredStructure = songStructure
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
              widget.sectionKeys.add(GlobalKey());
              if (section == null) {
                return const SizedBox.shrink();
              }
              return SectionCard(
                key: widget.sectionKeys[entry.key],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        filteredStructure: filteredStructure.values.toList(),
                        scrollController: scrollController,
                        sectionKeys: widget.sectionKeys,
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        spacing: 16,
                        children: [
                          // Your structure list...
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
                ],
              ),
            );
          },
    );
  }
}
