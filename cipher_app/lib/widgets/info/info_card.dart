import 'package:flutter/material.dart';
import '../../models/domain/info_item.dart';

class InfoCard extends StatelessWidget {
  final InfoItem item;

  const InfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _buildTypeChip(context),
            Text(
              item.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
            const Spacer(),
            if (item.content != null && item.content!.isNotEmpty)
              _buildContentSection(theme, colorScheme),
            Text(
              _formatDate(item.publishedAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
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

  Widget _buildContentSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          ...item.content!.entries.map((entry) {
            return _buildContentRow(theme, colorScheme, entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildContentRow(
    ThemeData theme,
    ColorScheme colorScheme,
    String key,
    dynamic value,
  ) {
    final icon = _getIconForKey(key, colorScheme);
    final label = _getLabelForKey(key);
    final displayValue = _getValueForKey(value, key);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        icon,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            displayValue,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getIconForKey(String key, ColorScheme colorScheme) {
    switch (key) {
      case 'location':
        return Icon(Icons.location_on, size: 16, color: colorScheme.onPrimary);
      case 'date':
        return Icon(
          Icons.calendar_today,
          size: 16,
          color: colorScheme.onPrimary,
        );
      case 'time':
        return Icon(Icons.access_time, size: 16, color: colorScheme.onPrimary);
      default:
        return Icon(Icons.info_outline, size: 16, color: colorScheme.onPrimary);
    }
  }

  String _getLabelForKey(String key) {
    switch (key) {
      case 'location':
        return 'Local: ';
      case 'date':
        return 'Data: ';
      case 'time':
        return 'Hora: ';
      default:
        return '${key[0].toUpperCase()}${key.substring(1)}: ';
    }
  }

  String _getValueForKey(dynamic value, String key) {
    if (key == 'date' || key == 'deadline') {
      final parsedDate = DateTime.tryParse(value);
      if (parsedDate != null) {
        return _formatDate(parsedDate);
      }
    } else if (key == 'time') {
      final parsedTime = DateTime.tryParse(value);
      if (parsedTime != null) {
        return _formatTime(parsedTime);
      }
    }
    return value as String;
  }

  String _formatDate(DateTime date) {
    // Implement your date formatting logic here
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    // Implement your time formatting logic here
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
