import 'package:cordis/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String itemType;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDangerous;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemType,
    required this.onConfirm,
    this.onCancel,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO fix design

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      contentPadding: EdgeInsets.zero,
      shape: ContinuousRectangleBorder(),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: Text(
        AppLocalizations.of(context)!.deleteConfirmationTitle,
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDangerous ? Colors.red : colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      content: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.deleteConfirmationMessage(itemType),
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            Text(
              AppLocalizations.of(context)!.deleteWarningMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            fixedSize: Size.fromWidth(120),
            foregroundColor: colorScheme.surface,
            backgroundColor: colorScheme.onSurface,
            shape: ContinuousRectangleBorder(),
          ),
          onPressed: () {
            onCancel?.call();
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size.fromWidth(120),
            backgroundColor: Colors.red,
            foregroundColor: colorScheme.surface,
            shape: ContinuousRectangleBorder(),
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    );
  }
}
