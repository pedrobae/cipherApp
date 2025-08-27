import 'package:flutter/material.dart';

class CipherContentCard extends StatelessWidget{
  final String contentType;
  final String contentText;

  const CipherContentCard({
    super.key,
    required this.contentType,
    required this.contentText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            contentType,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.8),
            ),
          ),
          child: Text(
            contentText,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ]
    );
  }
}