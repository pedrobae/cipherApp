import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StructureList extends StatelessWidget {
  final dynamic versionId;
  final Function(BuildContext context, int index) scrollToSection;

  const StructureList({
    super.key,
    required this.versionId,
    required this.scrollToSection,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer2<VersionProvider, SectionProvider>(
      builder: (context, versionProvider, sectionProvider, child) {
        final songStructure = versionProvider.getSongStructure(versionId ?? -1);

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
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: [
                      ...songStructure.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sectionCode = entry.value;
                        final section = sectionProvider.getSection(
                          versionId,
                          sectionCode,
                        )!;
                        final color = section.contentColor;
                        return GestureDetector(
                          onTap: scrollToSection(context, index),
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
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
