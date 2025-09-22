import 'dart:async';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/cipher/editor/reorderable_structure_chips.dart';

// Available colors for section selection
const List<Color> _availableColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.amber,
  Colors.teal,
  Colors.brown,
  Colors.indigo,
  Colors.pink,
  Colors.cyan,
  Colors.lime,
];

// Predefined section types with Portuguese display names
const Map<String, String> _predefinedSectionTypes = {
  'I': 'Intro',
  'V1': 'Verso 1',
  'V2': 'Verso 2',
  'V3': 'Verso 3',
  'V4': 'Verso 4',
  'C': 'Refrão',
  'C1': 'Refrão 1',
  'C2': 'Refrão 2',
  'PC': 'Pré-Refrão',
  'B': 'Ponte',
  'B1': 'Ponte 1',
  'B2': 'Ponte 2',
  'S': 'Solo',
  'O': 'Outro',
  'F': 'Final',
  'N': 'Anotações',
  'T': 'Tag',
};

// Default colors for predefined sections
const Map<String, Color> _defaultSectionColors = {
  'I': Colors.purple,
  'V1': Colors.blue,
  'V2': Colors.blue,
  'V3': Colors.blue,
  'V4': Colors.blue,
  'C': Colors.red,
  'C1': Colors.red,
  'C2': Colors.red,
  'PC': Colors.orange,
  'B': Colors.green,
  'B1': Colors.green,
  'B2': Colors.green,
  'S': Colors.amber,
  'O': Colors.brown,
  'F': Colors.indigo,
  'N': Colors.grey,
  'T': Colors.teal,
};

class CipherSectionForm extends StatefulWidget {
  const CipherSectionForm({super.key});

  @override
  State<CipherSectionForm> createState() => _CipherSectionFormState();
}

class _CipherSectionFormState extends State<CipherSectionForm> {
  final Map<String, TextEditingController> _sectionControllers = {};

  Map<String, Section> _currentSections = {};
  List<String> _songStructure = [];
  Timer? _debounceTimer;

  // Track last synced data to avoid unnecessary rebuilds
  Version? _lastSyncedVersion;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

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
    final cipherProvider = Provider.of<CipherProvider>(context, listen: false);

    final cipher = cipherProvider.currentCipher;
    final version = versionProvider.version;

    // Only sync if version has changed or if we haven't initialized yet
    if (!_hasInitialized || _lastSyncedVersion?.id != version?.id) {
      _updateStateFromProviders(cipher, version);
      _hasInitialized = true;
      _lastSyncedVersion = version;
    }
  }

  void _updateStateFromProviders(Cipher? cipher, Version? version) {
    // Handle the case where we have providers with data
    if (version != null) {
      _songStructure = version.songStructure
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      _currentSections = Map.from(version.sections ?? {});
    } else {
      // For new ciphers, start with empty state
      _songStructure = [];
      _currentSections = {};
    }

    // Update controllers for existing sections
    _currentSections.forEach((key, section) {
      if (!_sectionControllers.containsKey(key)) {
        _sectionControllers[key] = TextEditingController();
      }
      _sectionControllers[key]!.text = section.contentText;
    });

    // Remove controllers for sections that no longer exist
    final keysToRemove = _sectionControllers.keys
        .where((key) => !_currentSections.containsKey(key))
        .toList();
    for (final key in keysToRemove) {
      _sectionControllers[key]?.dispose();
      _sectionControllers.remove(key);
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

  void _notifySectionChanged() {
    // Ensure controller exists for every section in structure
    for (final section in _songStructure) {
      if (!_sectionControllers.containsKey(section)) {
        _sectionControllers[section] = TextEditingController();
      }
    }

    // Update content for all sections in structure
    for (final sectionCode in _songStructure) {
      final controller = _sectionControllers[sectionCode];
      final contentText = controller?.text ?? '';

      // Check if we have a section in current sections
      if (_currentSections.containsKey(sectionCode)) {
        // Update existing section content
        _currentSections[sectionCode]!.contentText = contentText;
      } else {
        // Create new section - use predefined values if available, otherwise default
        final displayName = _predefinedSectionTypes[sectionCode];
        final color = _defaultSectionColors[sectionCode];

        _currentSections[sectionCode] = Section(
          versionId: 0,
          contentType:
              displayName ??
              sectionCode, // Use display name or code as fallback
          contentCode: sectionCode,
          contentText: contentText,
          contentColor:
              color ?? Colors.grey, // Use predefined color or grey as fallback
        );
      }
    }

    // Remove sections that are no longer in structure
    _currentSections.removeWhere((key, value) => !_songStructure.contains(key));
  }

  void _addSection(
    String sectionCode, {
    String? sectionType,
    Color? customColor,
  }) {
    setState(() {
      _songStructure.add(sectionCode);

      // Create text controller for this section
      if (!_sectionControllers.containsKey(sectionCode)) {
        _sectionControllers[sectionCode] = TextEditingController();
      }

      // Create the section - either custom or use predefined values
      if (sectionType != null && customColor != null) {
        // This is a custom section created by user
        _currentSections[sectionCode] = Section(
          versionId: 0, // Will be set when saving
          contentType: sectionType,
          contentCode: sectionCode,
          contentText: '',
          contentColor: customColor,
        );
      } else {
        // This is a predefined section - create it if not exists
        if (!_currentSections.containsKey(sectionCode)) {
          final displayName = _predefinedSectionTypes[sectionCode];
          final color = _defaultSectionColors[sectionCode];

          _currentSections[sectionCode] = Section(
            versionId: 0,
            contentType: displayName ?? sectionCode,
            contentCode: sectionCode,
            contentText: '',
            contentColor: color ?? Colors.grey,
          );
        }
      }
    });
    _notifySectionChanged();
  }

  void _removeSection(int index) {
    setState(() {
      final sectionKey = _songStructure[index];
      _songStructure.removeAt(index);

      // Only remove content if this section is not used elsewhere
      if (!_songStructure.contains(sectionKey)) {
        _sectionControllers[sectionKey]?.dispose();
        _sectionControllers.remove(sectionKey);
        _currentSections.remove(sectionKey);
      }
    });
    _notifySectionChanged();
  }

  void _reorderSection(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _songStructure.removeAt(oldIndex);
      _songStructure.insert(newIndex, item);
    });
    _notifySectionChanged();
  }

  Section? _getSectionType(String key) {
    return _currentSections[key];
  }

  void _showPresetSectionsDialog() {
    showDialog(
      context: context,
      builder: (context) => _PresetSectionsDialog(
        sectionTypes: _predefinedSectionTypes,
        usedSections: _songStructure.toSet(),
        onAdd: (sectionKey) => _addSection(sectionKey),
      ),
    );
  }

  void _showCustomSectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _CustomSectionDialog(
        onAdd: (sectionKey, name, color) =>
            _addSection(sectionKey, sectionType: name, customColor: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VersionProvider, CipherProvider>(
      builder: (context, versionProvider, cipherProvider, child) {
        // Trigger sync after the current build if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncWithProviderData();
        });

        final cipher = cipherProvider.currentCipher;
        final version =
            versionProvider.version ??
            Version(cipherId: cipher?.id ?? 0, songStructure: '', sections: {});

        final uniqueSections = _songStructure.toSet().toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
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
                            onChanged: (name) =>
                                versionProvider.updateCipherVersion(
                                  version.copyWith(
                                    versionName: name,
                                    cipherId: cipher!.id,
                                  ),
                                ),
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
                            onChanged: (key) =>
                                versionProvider.updateCipherVersion(
                                  version.copyWith(transposedKey: key),
                                ),
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
                            onPressed: _showPresetSectionsDialog,
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
                            onPressed: _showCustomSectionDialog,
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
                      songStructure: _songStructure,
                      sectionTypes: _predefinedSectionTypes,
                      customSections: _currentSections,
                      onReorder: _reorderSection,
                      onRemoveSection: _removeSection,
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
              ...uniqueSections.map((section) {
                final sectionType = _getSectionType(section);

                return Card(
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
                                    color:
                                        sectionType?.contentColor ??
                                        Colors.grey,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    section,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  sectionType?.contentType ?? section,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sectionControllers[section],
                          decoration: InputDecoration(
                            hintText:
                                'Conteúdo da seção ${sectionType?.contentType ?? section}',
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onChanged: (_) {
                            _debounceTimer?.cancel();
                            _debounceTimer = Timer(
                              const Duration(milliseconds: 300),
                              () {
                                _notifySectionChanged();
                                if (mounted) setState(() {});
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
  final Set<String> usedSections;
  final Function(String) onAdd;

  const _PresetSectionsDialog({
    required this.sectionTypes,
    required this.usedSections,
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
              backgroundColor: (_defaultSectionColors[entry.key] ?? Colors.grey)
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
                children: _availableColors.map((color) {
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
