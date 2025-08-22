import 'package:flutter/material.dart';

class HighlightWidget extends StatelessWidget {
  final Map<String, dynamic> highlight;

  const HighlightWidget({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: highlight.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
                children: [
                  TextSpan(
                    text: '${_formatKey(entry.key)}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  TextSpan(
                    text: _formatValue(entry.value),
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatKey(String key) {
    // Convert camelCase or snake_case to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ')
        .trim();
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';

    // Handle DateTime objects
    if (value is DateTime) {
      return _formatDateTime(value);
    }

    // Handle DateTime strings (ISO format)
    if (value is String && _isDateTimeString(value)) {
      try {
        final dateTime = DateTime.parse(value);
        return _formatDateTime(dateTime);
      } catch (e) {
        // If parsing fails, return original string
        return value;
      }
    }

    // Handle other data types
    return value.toString();
  }

  bool _isDateTimeString(String value) {
    // Check for common DateTime string patterns
    final dateTimeRegexes = [
      RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'), // ISO format
      RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'), // SQL format
      RegExp(r'^\d{4}-\d{2}-\d{2}$'), // Date only
    ];

    return dateTimeRegexes.any((regex) => regex.hasMatch(value));
  }

  String _formatDateTime(DateTime dateTime) {
    // Format: DD/MM/YYYY HH:MM
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    // Check if time is midnight (00:00) - likely a date-only value
    if (dateTime.hour == 0 && dateTime.minute == 0 && dateTime.second == 0) {
      return '$day/$month/$year';
    }

    return '$day/$month/$year $hour:$minute';
  }
}
