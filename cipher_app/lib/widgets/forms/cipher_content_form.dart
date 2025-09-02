import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/domain/cipher.dart';
import '../../utils/section_color_manager.dart';
import 'reorderable_structure_chips.dart';

class CipherContentForm extends StatefulWidget {
  final TextEditingController? versionNameController;
  final Cipher? cipher;
  final CipherMap? currentVersion;
  final Function(Map<String, String>) onContentChanged;
  final Function(List<String>)? onStructureChanged;

  const CipherContentForm({
    super.key,
    this.versionNameController,
    this.cipher,
    this.currentVersion,
    required this.onContentChanged,
    this.onStructureChanged,
  });

  @override
  State<CipherContentForm> createState() => _CipherContentFormState();
}

class _CipherContentFormState extends State<CipherContentForm> {
  List<String> _songStructure = [];
  final Map<String, TextEditingController> _contentControllers = {};
  Map<String, String> _currentContent = {};
  final Map<String, SectionType> _customSections = {};
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeContent();
  }

  void _initializeContent() {
    // Always start with blank state for new version
    _songStructure = [];
    _currentContent = {};

    if (widget.currentVersion != null) {
      _songStructure = widget.currentVersion!.songStructure
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      _currentContent = Map.from(widget.currentVersion!.content);

      _currentContent.forEach((key, value) {
        _contentControllers[key] = TextEditingController(text: value);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStructureChanged?.call(_songStructure);
      _notifyContentChanged();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _contentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateSongStructure() {
    // Update current content without including songStructure as a key
    _currentContent.clear();
    _contentControllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) {
        _currentContent[key] = controller.text.trim();
      }
    });

    // Notify parent with both content and structure
    _notifyContentChanged();
    widget.onStructureChanged?.call(_songStructure);
  }

  void _notifyContentChanged() {
    // DEBUG: Print all section keys and their content before saving
    for (final section in _songStructure) {
      // Ensure controller exists for every section
      if (!_contentControllers.containsKey(section)) {
        _contentControllers[section] = TextEditingController();
      }
    }
    // Collect all content from section controllers
    _currentContent.clear();
    for (final section in _songStructure) {
      final controller = _contentControllers[section];
      if (controller != null) {
        _currentContent[section] = controller.text;
      } else {
        _currentContent[section] = '';
      }
    }

    // Also include version name from the passed controller if available
    if (widget.versionNameController != null &&
        widget.versionNameController!.text.trim().isNotEmpty) {
      _currentContent['versionName'] = widget.versionNameController!.text
          .trim();
    }

    widget.onContentChanged(_currentContent);
  }

  void _addSection(
    String sectionKey, {
    String? customName,
    Color? customColor,
  }) {
    setState(() {
      _songStructure.add(sectionKey);

      if (customName != null && customColor != null) {
        _customSections[sectionKey] = SectionType(customName, customColor);
      }

      if (!_contentControllers.containsKey(sectionKey)) {
        _contentControllers[sectionKey] = TextEditingController(
          text: _currentContent[sectionKey] ?? '',
        );
      }
    });
    _updateSongStructure();
  }

  void _removeSection(int index) {
    setState(() {
      final sectionKey = _songStructure[index];
      _songStructure.removeAt(index);

      // Only remove content if this section is not used elsewhere
      if (!_songStructure.contains(sectionKey)) {
        _contentControllers[sectionKey]?.dispose();
        _contentControllers.remove(sectionKey);
        _currentContent.remove(sectionKey);
        _customSections.remove(sectionKey);
      }
    });
    _updateSongStructure();
  }

  void _reorderSection(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _songStructure.removeAt(oldIndex);
      _songStructure.insert(newIndex, item);
    });
    _updateSongStructure();
  }

  SectionType _getSectionType(String key) {
    return SectionColorManager.getSectionType(key, _customSections);
  }

  void _showPresetSectionsDialog() {
    showDialog(
      context: context,
      builder: (context) => _PresetSectionsDialog(
        sectionTypes: SectionColorManager.predefinedSectionTypes,
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
            _addSection(sectionKey, customName: name, customColor: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uniqueSections = _songStructure.toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informações da Versão',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: widget.versionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Versão',
                    hintText: 'Ex: Original, Acústica, Tom de C',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  onChanged: (_) => _notifyContentChanged(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome da versão é obrigatório';
                    }
                    return null;
                  },
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
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                    ),
                  ],
                ),

                // Draggable Section Chips
                ReorderableStructureChips(
                  songStructure: _songStructure,
                  sectionTypes: SectionColorManager.predefinedSectionTypes,
                  customSections: _customSections,
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
                                color: sectionType.color,
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
                              sectionType.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentControllers[section],
                      decoration: InputDecoration(
                        hintText: 'Conteúdo da seção ${sectionType.name}',
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (_) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(
                          const Duration(milliseconds: 300),
                          () {
                            _notifyContentChanged();
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
  }
}

class _PresetSectionsDialog extends StatelessWidget {
  final Map<String, SectionType> sectionTypes;
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
              label: Text('${entry.key} - ${entry.value.name}'),
              backgroundColor: entry.value.color.withValues(alpha: .8),
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
                children: SectionColorManager.availableColors.map((color) {
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
