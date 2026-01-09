import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/utils/section_helper.dart';
import 'section_card.dart';

class CipherContentSection extends StatelessWidget {
  const CipherContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<VersionProvider, SectionProvider, LayoutSettingsProvider>(
      builder:
          (context, versionProvider, sectionProvider, layoutSettings, child) {
            final versionId = versionProvider.currentVersion.id;
            final filteredStructure = versionProvider.currentSongStructure
                .where(
                  (sectionCode) =>
                      ((layoutSettings.showAnnotations ||
                          !isAnnotation(sectionCode)) &&
                      (layoutSettings.showTransitions ||
                          !isTransition(sectionCode))),
                );
            final sectionCardList = filteredStructure.map((sectionCode) {
              String trimmedCode = sectionCode.trim();
              final section = sectionProvider.getSection(
                versionId,
                trimmedCode,
              );
              if (section == null) {
                return const SizedBox.shrink();
              }
              return CipherSectionCard(
                sectionType: section.contentType,
                sectionCode: trimmedCode,
                sectionText: section.contentText,
                sectionColor: section.contentColor,
              );
            }).toList();
            return Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                  crossAxisCount: layoutSettings.columnCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: sectionCardList.length,
                  itemBuilder: (context, index) => sectionCardList[index],
                ),
              ),
            );
          },
    );
  }
}
