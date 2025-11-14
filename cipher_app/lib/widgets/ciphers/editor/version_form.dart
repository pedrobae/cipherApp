import 'dart:async';
import 'package:cipher_app/widgets/ciphers/editor/sections/token_content_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/section_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/ciphers/editor/sections/custom_section_dialog.dart';
import 'package:cipher_app/widgets/ciphers/editor/sections/edit_section_dialog.dart';
import 'package:cipher_app/widgets/ciphers/editor/sections/preset_section_dialog.dart';
import 'package:cipher_app/widgets/ciphers/editor/reorderable_structure_chips.dart';
import 'package:cipher_app/utils/section_constants.dart';

class VersionForm extends StatefulWidget {
  const VersionForm({super.key});

  @override
  State<VersionForm> createState() => _VersionFormState();
}

class _VersionFormState extends State<VersionForm> {
  Timer? _debounceTimer;

  void _addSection(
    String sectionCode,
    SectionProvider sectionProvider,
    VersionProvider versionProvider, {
    String? sectionType,
    Color? customColor,
  }) {
    final isNewSection = !sectionProvider.sections.containsKey(sectionCode);

    // Add section to song structure
    versionProvider.addSectionToStruct(sectionCode);

    // Add section to sections map if it's new
    if (isNewSection) {
      sectionProvider.cacheAddSection(
        sectionCode,
        sectionType: sectionType,
        color: customColor,
      );
    }
  }

  void _removeSection(
    int index,
    VersionProvider versionProvider,
    SectionProvider sectionProvider,
  ) {
    versionProvider.removeSectionFromStruct(index);
    if (versionProvider.currentVersion.songStructure.contains(
      versionProvider.currentVersion.songStructure[index],
    )) {
      return;
    }
    sectionProvider.cacheDeleteSection(
      versionProvider.currentVersion.songStructure[index],
    );
  }

  void _showPresetSectionsDialog(
    VersionProvider versionProvider,
    SectionProvider sectionProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => PresetSectionsDialog(
        sectionTypes: predefinedSectionTypes,
        onAdd: (sectionKey) =>
            _addSection(sectionKey, sectionProvider, versionProvider),
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
          sectionKey,
          sectionProvider,
          versionProvider,
          sectionType: name,
          customColor: color,
        ),
      ),
    );
  }

  void _openEditSectionDialog(
    Section section,
    SectionProvider sectionProvider,
    VersionProvider versionProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditSectionDialog(
        section: section,
        onSave: (code, type, text, color) {
          // Update the section with new values
          sectionProvider.cacheUpdatedSection(
            section.contentCode,
            newContentCode: code,
            newContentType: type,
            newContentText: text,
            newColor: color,
          );
          // If the content code has changed, update the song structure accordingly
          if (code != null && code != section.contentCode) {
            versionProvider.updateSectionCodeInStruct(
              oldCode: section.contentCode,
              newCode: code,
            );
          }
        },
        onDelete: () {
          sectionProvider.cacheDeleteSection(section.contentCode);
          versionProvider.removeSectionFromStructByCode(section.contentCode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer3<SectionProvider, VersionProvider, CipherProvider>(
      builder:
          (context, sectionProvider, versionProvider, cipherProvider, child) {
            final version = versionProvider.currentVersion;

            final uniqueSections = version.songStructure.toSet().toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações da Versão',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: version.versionName,
                                decoration: const InputDecoration(
                                  labelText: 'Nome da Versão',
                                  hintText: 'Ex: Original, Acústica',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.queue_music),
                                ),
                                onChanged: (name) => versionProvider
                                    .cacheUpdatedVersion(newVersionName: name),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nome da versão é obrigatório';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: version.transposedKey ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Tom',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (key) => versionProvider
                                    .cacheUpdatedVersion(newTransposedKey: key),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Song Structure Section
                Card(
                  color: colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estrutura da Versão',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        // Quick Add Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showPresetSectionsDialog(
                                  versionProvider,
                                  sectionProvider,
                                ),
                                icon: const Icon(Icons.library_music),
                                label: const Text('Seções Predefinidas'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.all(
                                      Radius.circular(24),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _showCustomSectionDialog(
                                  versionProvider,
                                  sectionProvider,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Seção Personalizada'),
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.all(
                                      Radius.circular(24),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Draggable Section Chips
                        ReorderableStructureChips(
                          songStructure: version.songStructure,
                          sections: sectionProvider.sections,
                          onReorder: (int oldIndex, int newIndex) {
                            versionProvider.cacheReorderedStructure(
                              oldIndex,
                              newIndex,
                            );
                          },
                          onRemoveSection: (int index) {
                            _removeSection(
                              index,
                              versionProvider,
                              sectionProvider,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
                    final section = sectionProvider.sections[sectionCode];
                    return Card(
                      color: colorScheme.surfaceContainerHigh,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              section?.contentColor ??
                                              Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          sectionCode,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          section?.contentType ?? sectionCode,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _openEditSectionDialog(
                                          section!,
                                          sectionProvider,
                                          versionProvider,
                                        ),
                                        icon: const Icon(Icons.edit),
                                        tooltip: 'Editar seção',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TokenContentEditor(
                              sectionCode: sectionCode,
                              initialContent: section?.contentText ?? '',
                              sectionColor:
                                  section?.contentColor ?? Colors.grey,
                              onContentChanged: (newContent) {
                                _debounceTimer?.cancel();
                                _debounceTimer = Timer(
                                  const Duration(milliseconds: 300),
                                  () {
                                    sectionProvider.cacheUpdatedSection(
                                      sectionCode,
                                      newContentText: newContent,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
    );
  }
}
