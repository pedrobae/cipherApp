import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/widgets/filled_text_button.dart';
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
              case VersionType.playlist:
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
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          onPressed: () {
                            _showNewSectionSheet(
                              context,
                              sectionProvider,
                              versionProvider,
                            );
                          },
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

  void _addSection(
    SectionLabels sectionLabel,
    SectionProvider sectionProvider,
    VersionProvider versionProvider,
  ) {
    final isNewSection = !sectionProvider
        .getSections(widget.versionId)
        .containsKey(sectionLabel.code);

    // Add section to song structure
    versionProvider.addSectionToStruct(widget.versionId, sectionLabel.code);
    // Add section to sections map if it's new
    if (isNewSection) {
      sectionProvider.cacheAddSection(
        widget.versionId,
        sectionLabel.code,
        sectionLabel.color,
        sectionLabel.officialLabel,
      );
    }

    Navigator.of(context).pop();
  }

  void _showNewSectionSheet(
    BuildContext context,
    SectionProvider sectionProvider,
    VersionProvider versionProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    SectionLabels? selectedLabel;

    showModalBottomSheet(
      context: context,
      barrierColor: colorScheme.onSurface.withAlpha(85),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Icon Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              // LABEL
              Text(
                AppLocalizations.of(context)!.addSection,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),

              SizedBox(height: 8),

              // DROPDOWN MENU
              DropdownButtonFormField<SectionLabels>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.selectSectionType,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.surfaceContainerLowest,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                items: commonSectionLabels.values.map((sectionLabels) {
                  return DropdownMenuItem<SectionLabels>(
                    value: sectionLabels,
                    child: Text(
                      '${sectionLabels.code} - ${sectionLabels.officialLabel}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedLabel = value;
                },
              ),

              SizedBox(height: 16),

              FilledTextButton(
                text: AppLocalizations.of(context)!.save,
                onPressed: () {
                  _addSection(selectedLabel!, sectionProvider, versionProvider);
                },
                isDarkButton: true,
              ),

              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
