import 'dart:async';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/cipher/editor/reorderable_structure_chips.dart';
import 'package:cipher_app/utils/section_constants.dart';

class VersionForm extends StatefulWidget {
  const VersionForm({super.key});

  @override
  State<VersionForm> createState() => _VersionFormState();
}

class _VersionFormState extends State<VersionForm> {
  final Map<String, TextEditingController> _sectionControllers = {};
  Timer? _debounceTimer;

  // Track last synced data to avoid unnecessary rebuilds
  Version? _lastSyncedVersion;
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithProviderData();
  }

  void _syncWithProviderData() {
    final versionProvider = Provider.of<VersionProvider>(
      context,
      listen: false,
    );
    final version = versionProvider.currentVersion;

    if (version.sections != null) {
      if (!_hasInitialized || _lastSyncedVersion?.id != version.id) {
        // Update controllers for existing sections
        version.sections!.forEach((key, section) {
          if (!_sectionControllers.containsKey(key)) {
            _sectionControllers[key] = TextEditingController();
          }
          _sectionControllers[key]!.text = section.contentText;
        });

        // Remove controllers for sections that no longer exist
        final keysToRemove = _sectionControllers.keys
            .where((key) => !version.sections!.containsKey(key))
            .toList();
        for (final key in keysToRemove) {
          _sectionControllers[key]?.dispose();
          _sectionControllers.remove(key);
        }

        _hasInitialized = true;
        _lastSyncedVersion = version;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _sectionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changeSection(String sectionCode, VersionProvider versionProvider) {
    final controller = _sectionControllers[sectionCode];
    final contentText = controller?.text ?? '';

    versionProvider.cacheUpdatedSection(sectionCode, contentText);
  }

  void _addSection(
    String sectionCode,
    VersionProvider versionProvider, {
    String? sectionType,
    Color? customColor,
  }) {
    // Create text controller for this section
    if (!_sectionControllers.containsKey(sectionCode)) {
      _sectionControllers[sectionCode] = TextEditingController();
    }

    // Create the section - either custom or use predefined values
    Section newSection;
    if (sectionType != null && customColor != null) {
      // This is a custom section created by user
      newSection = Section(
        versionId: 0, // Will be set when saving
        contentType: sectionType,
        contentCode: sectionCode,
        contentText: '',
        contentColor: customColor,
      );
    } else {
      // This is a preset section
      final displayName = predefinedSectionTypes[sectionCode];
      final color = defaultSectionColors[sectionCode];

      newSection = Section(
        versionId: 0,
        contentType: displayName!,
        contentCode: sectionCode,
        contentText: '',
        contentColor: color ?? Colors.grey,
      );
      versionProvider.cacheAddSection(newSection);
    }
  }

  void _removeSection(int index, VersionProvider versionProvider) {
    versionProvider.cacheRemoveSection(index);
  }

  void _showPresetSectionsDialog(VersionProvider versionProvider) {
    showDialog(
      context: context,
      builder: (context) => _PresetSectionsDialog(
        sectionTypes: predefinedSectionTypes,
        onAdd: (sectionKey) => _addSection(sectionKey, versionProvider),
      ),
    );
  }

  void _showCustomSectionDialog(VersionProvider versionProvider) {
    showDialog(
      context: context,
      builder: (context) => _CustomSectionDialog(
        onAdd: (sectionKey, name, color) => _addSection(
          sectionKey,
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
    return Consumer2<VersionProvider, CipherProvider>(
      builder: (context, versionProvider, cipherProvider, child) {
        // Trigger sync after the current build if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncWithProviderData();
        });

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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Quick Add Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showPresetSectionsDialog(versionProvider),
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
                            onPressed: () =>
                                _showCustomSectionDialog(versionProvider),
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
                      customSections: version.sections!,
                      onReorder: (int oldIndex, int newIndex) {
                        versionProvider.cacheReorderedStructure(
                          oldIndex,
                          newIndex,
                        );
                      },
                      onRemoveSection: (int index) {
                        _removeSection(index, versionProvider);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content Section
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
                final section = version.sections![sectionCode];
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: section?.contentColor ?? Colors.grey,
                                    borderRadius: BorderRadius.circular(6),
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
                                const SizedBox(width: 8),
                                Text(
                                  section?.contentType ?? sectionCode,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sectionControllers[sectionCode],
                          decoration: InputDecoration(
                            hintText:
                                'Conteúdo da seção ${section?.contentType ?? sectionCode}',
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onChanged: (_) {
                            _debounceTimer?.cancel();
                            _debounceTimer = Timer(
                              const Duration(milliseconds: 300),
                              () {
                                _changeSection(sectionCode, versionProvider);
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

class _PresetSectionsDialog extends StatelessWidget {
  final Map<String, String> sectionTypes;
  final Function(String) onAdd;

  const _PresetSectionsDialog({
    required this.sectionTypes,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Seção'),
      content: SizedBox(
        width: double.maxFinite,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sectionTypes.entries.map((entry) {
            return ActionChip(
              label: Text('${entry.key} - ${entry.value}'),
              backgroundColor: (defaultSectionColors[entry.key] ?? Colors.grey)
                  .withValues(alpha: .8),
              labelStyle: const TextStyle(color: Colors.white),
              onPressed: () {
                onAdd(entry.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _CustomSectionDialog extends StatefulWidget {
  final Function(String, String, Color) onAdd;

  const _CustomSectionDialog({required this.onAdd});

  @override
  State<_CustomSectionDialog> createState() => _CustomSectionDialogState();
}

class _CustomSectionDialogState extends State<_CustomSectionDialog> {
  final _keyController = TextEditingController();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _keyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Seção Personalizada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'Código da seção',
              hintText: 'Ex: S1, INT, OUTRO',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da seção',
              hintText: 'Ex: Solo 1, Introdução, Outro',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cor da seção:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _addSection, child: const Text('Adicionar')),
      ],
    );
  }

  void _addSection() {
    final key = _keyController.text.trim().toUpperCase();
    final name = _nameController.text.trim();

    if (key.isNotEmpty && name.isNotEmpty) {
      widget.onAdd(key, name, _selectedColor);
      Navigator.pop(context);
    }
  }
}
