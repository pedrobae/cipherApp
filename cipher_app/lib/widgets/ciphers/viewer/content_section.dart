import 'package:cipher_app/providers/section_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/utils/section_helper.dart';
import 'section_card.dart';

class CipherContentSection extends StatelessWidget {
  const CipherContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<VersionProvider, SectionProvider, LayoutSettingsProvider>(
      builder:
          (context, versionProvider, sectionProvider, layoutSettings, child) {
            final filteredStructure = versionProvider
                .currentVersion
                .songStructure
                .where(
                  (sectionCode) =>
                      ((layoutSettings.showAnnotations ||
                          !isAnnotation(sectionCode)) &&
                      (layoutSettings.showTransitions ||
                          !isTransition(sectionCode))),
                );
            final sectionCardList = filteredStructure.map((sectionCode) {
              String trimmedCode = sectionCode.trim();
              if (!sectionProvider.sections.containsKey(trimmedCode)) {
                return const SizedBox.shrink();
              }
              return CipherSectionCard(
                sectionType: sectionProvider.sections[trimmedCode]!.contentType,
                sectionCode: trimmedCode,
                sectionText: sectionProvider.sections[trimmedCode]!.contentText,
                sectionColor:
                    sectionProvider.sections[trimmedCode]!.contentColor,
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
