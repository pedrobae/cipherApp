import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/utils/section_constants.dart';

class EditSectionDialog extends StatefulWidget {
  final Section section;
  final void Function(String?, String?, String?, Color?) onSave;
  final VoidCallback onDelete;

  const EditSectionDialog({
    super.key,
    required this.section,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditSectionDialog> createState() => _EditSectionDialogState();
}

class _EditSectionDialogState extends State<EditSectionDialog> {
  late TextEditingController contentCodeController;
  late TextEditingController contentTypeController;
  late TextEditingController contentTextController;
  late Color contentColor;
  Map<String, Color> availableColors = {};

  @override
  void initState() {
    contentCodeController = TextEditingController(
      text: widget.section.contentCode,
    );

    contentTypeController = TextEditingController(
      text: widget.section.contentType,
    );

    contentTextController = TextEditingController(
      text: widget.section.contentText,
    );

    contentColor = widget.section.contentColor;

    List<Color> presetColors = [];
    for (var entry in defaultSectionColors.entries) {
      if (!presetColors.contains(entry.value)) {
        availableColors[predefinedSectionTypes[entry.key]!] = entry.value;
        presetColors.add(entry.value);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Section'),
      content: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: contentCodeController,
            decoration: InputDecoration(labelText: 'Content Code'),
          ),
          TextField(
            controller: contentTypeController,
            decoration: InputDecoration(labelText: 'Content Type'),
          ),

          // Default section colors picker
          DropdownButtonFormField<Color>(
            decoration: InputDecoration(labelText: 'Content Color'),
            selectedItemBuilder: (context) {
              return availableColors.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    spacing: 16,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: entry.value,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList();
            },
            items: [
              ...availableColors.entries.map(
                (entry) => DropdownMenuItem<Color>(
                  value: entry.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      spacing: 16,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: entry.value,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        Text(entry.key),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            onChanged: (Color? newColor) {
              setState(() {
                contentColor = newColor!;
              });
            },
          ),
          TextFormField(
            controller: contentTextController,
            minLines: 4,
            decoration: InputDecoration(
              hintText: 'Conteúdo da seção',
              border: const OutlineInputBorder(),
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDelete();
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(
              contentCodeController.text,
              contentTypeController.text,
              contentTextController.text,
              contentColor,
            );
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
