import 'package:flutter/material.dart';
import '../../models/domain/info_item.dart';
import './info_highlight.dart';

class InfoCard extends StatelessWidget {
  final InfoItem item;

  const InfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeChip(context),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                item.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(item.publishedAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            if (item.highlight != null) ...[
              const SizedBox(height: 8),
              HighlightWidget(highlight: item.highlight!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color chipColor;
    Color textColor;

    switch (item.type) {
      case InfoType.news:
        chipColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        break;
      case InfoType.announcement:
        chipColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        break;
      case InfoType.event:
        chipColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        break;
    }

    return Chip(
      label: Text(
        item.type.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      side: BorderSide.none,
    );
  }

  String _formatDate(DateTime date) {
    // Implement your date formatting logic here
    return '${date.day}/${date.month}/${date.year}';
  }
}
