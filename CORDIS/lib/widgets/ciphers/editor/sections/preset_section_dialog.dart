import 'package:flutter/material.dart';
import 'package:cordis/utils/section_constants.dart';

class PresetSectionsDialog extends StatelessWidget {
  final Map<String, String> sectionTypes;
  final Function(String) onAdd;

  const PresetSectionsDialog({
    super.key,
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
