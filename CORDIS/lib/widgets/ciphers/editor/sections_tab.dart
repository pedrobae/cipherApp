import 'dart:async';
import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/editor/sections/custom_section_dialog.dart';
import 'package:cordis/widgets/ciphers/editor/sections/preset_section_dialog.dart';
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
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

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

  void _showPresetSectionsDialog(
    VersionProvider versionProvider,
    SectionProvider sectionProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => PresetSectionsDialog(
        sectionTypes: predefinedSectionTypes,
        onAdd: (sectionKey) => _addSection(
          widget.versionId,
          sectionKey,
          sectionProvider,
          versionProvider,
        ),
      ),
    );
  }

  void _showCustomSectionDialog(
    VersionProvider versionProvider,
    SectionProvider sectionProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomSectionDialog(
        onAdd: (sectionKey, name, color) => _addSection(
          widget.versionId,
          sectionKey,
          sectionProvider,
          versionProvider,
          sectionType: name,
          customColor: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer3<SectionProvider, VersionProvider, CipherProvider>(
      builder:
          (context, sectionProvider, versionProvider, cipherProvider, child) {
            List<String> uniqueSections;
            dynamic version; // Version or VersionDto
            switch (widget.versionType) {
              case VersionType.local:
              case VersionType.brandNew:
                version = versionProvider.getVersionById(widget.versionId)!;
                uniqueSections = version.songStructure.toSet().toList();
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Song Structure Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.songStructure,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),

                        // Add Section Button
                      ],
                    ),

                    // Draggable Section Chips
                    ReorderableStructureChips(versionId: widget.versionId),
                  ],
                ),
                // CONTENT SECTION
                if (uniqueSections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Adicione seções para começar a criar o conteúdo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...uniqueSections.map((sectionCode) {
                    final section = sectionProvider.getSection(
                      widget.versionId,
                      sectionCode,
                    );
                    return TokenContentEditor(
                      section: section!,
                      onContentChanged: (newContent) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(
                          const Duration(milliseconds: 300),
                          () {
                            sectionProvider.cacheUpdatedSection(
                              widget.versionId,
                              sectionCode,
                              newContentText: newContent,
                            );
                          },
                        );
                      },
                    );
                  }),
              ],
            );
          },
    );
  }
}
