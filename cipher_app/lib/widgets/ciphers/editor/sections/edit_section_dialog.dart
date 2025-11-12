import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:flutter/material.dart';

class EditSectionDialog extends StatelessWidget {
  final Section section;
  final void Function(String?, String?, Color?) onSave;
  final VoidCallback onDelete;

  const EditSectionDialog({
    super.key,
    required this.section,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation of the dialog UI goes here
    return AlertDialog(
      title: Text('Edit Section'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fields for editing sectionKey, sectionName, and sectionColor
        ],
      ),
      actions: [
        TextButton(onPressed: onDelete, child: Text('Delete')),
        TextButton(
          onPressed: () {
            // Call onSave with updated values
            onSave(
              section.contentCode,
              section.contentType,
              section.contentColor,
            );
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
