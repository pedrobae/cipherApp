import 'package:cordis/models/dtos/version_dto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/widgets/ciphers/tag_chip.dart';

class CloudCipherCard extends StatelessWidget {
  final VersionDto version;
  final VoidCallback onTap;

  const CloudCipherCard({
    super.key,
    required this.version,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<SelectionProvider>(
      builder: (context, selectionProvider, child) {
        return Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 1),
                color: theme.shadowColor,
                blurRadius: 1,
              ),
            ],
          ),
          child: ListTile(
            onTap: onTap,
            tileColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            title: Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(version.title, style: theme.textTheme.titleLarge),
                    Text(version.author),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tom: ${version.transposedKey ?? version.originalKey}',
                    ),
                    Text('Tempo: ${version.tempo}'),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: version.tags
                      .map((tag) => TagChip(tag: tag))
                      .toList(),
                ),
              ],
            ),
            trailing: selectionProvider.isSelectionMode
                ? Checkbox(
                    value: selectionProvider.selectedItems.contains(version),
                    onChanged: (value) {
                      selectionProvider.toggleItemSelection(version);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
