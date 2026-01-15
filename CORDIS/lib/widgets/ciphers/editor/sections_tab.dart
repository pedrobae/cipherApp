import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/editor/reorderable_structure_chips.dart';
import 'package:cordis/widgets/ciphers/editor/sections/token_content_editor.dart';
import 'package:cordis/utils/section_constants.dart';

class SectionsTab extends StatefulWidget {
  final dynamic versionId;
  final VersionType versionType;

  const SectionsTab({super.key, this.versionId, required this.versionType});

  @override
  State<SectionsTab> createState() => _SectionsTabState();
}

class _SectionsTabState extends State<SectionsTab> {
  void _addSection(
    dynamic versionId,
    String sectionCode,
    SectionProvider sectionProvider,
    VersionProvider versionProvider, {
    String? sectionType,
    Color? customColor,
  }) {
    final isNewSection = !sectionProvider
        .getSections(versionId)
        .containsKey(sectionCode);

    // Add section to song structure
    versionProvider.addSectionToStruct(versionId, sectionCode);

    // Add section to sections map if it's new
    if (isNewSection) {
      sectionProvider.cacheAddSection(
        versionId,
        sectionCode,
        sectionType: sectionType,
        color: customColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer3<SectionProvider, VersionProvider, CipherProvider>(
      builder:
          (context, sectionProvider, versionProvider, cipherProvider, child) {
            List<String> uniqueSections;
            switch (widget.versionType) {
              case VersionType.local:
              case VersionType.brandNew:
                uniqueSections = versionProvider
                    .getSongStructure(widget.versionId)
                    .toSet()
                    .toList();
                break;
              case VersionType.cloud:
                uniqueSections = versionProvider
                    .getSongStructure(widget.versionId)
                    .toSet()
                    .toList();
                break;
              case VersionType.import:
                uniqueSections = versionProvider
                    .getSongStructure(-1)
                    .toSet()
                    .toList();
                break;
            }

            if (sectionProvider.isLoading || versionProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 32,
              children: [
                // STRUCTURE SECTION
                Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // LABEL
                        Text(
                          AppLocalizations.of(context)!.songStructure,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),

                        // ADD SECTION BUTTON
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.addSection,
                          icon: const Icon(Icons.add),
                          color: colorScheme.shadow,
                          onPressed: () {},
                        ),
                      ],
                    ),

                    // DRAGGABLE CHIPS
                    ReorderableStructureChips(versionId: widget.versionId),
                  ],
                ),
                // CONTENT SECTION
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LABEL
                    Text(
                      AppLocalizations.of(context)!.lyrics,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    // SECTIONS
                    if (uniqueSections.isEmpty)
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.noSectionsInStructurePrompt,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurface),
                      )
                    else
                      ...uniqueSections.map((sectionCode) {
                        return TokenContentEditor(
                          versionId: widget.versionId,
                          sectionCode: sectionCode,
                        );
                      }),
                  ],
                ),
              ],
            );
          },
    );
  }
}
