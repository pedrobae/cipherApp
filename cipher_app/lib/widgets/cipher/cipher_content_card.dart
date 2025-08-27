import 'package:flutter/material.dart';
import '../../models/domain/cipher.dart';

class CipherContentCard extends StatelessWidget{
  final MapContent cipherContent;

  const CipherContentCard({
    super.key,
    required this.cipherContent
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cipherContent.contentType.isNotEmpty)
          Text(
            cipherContent.contentType,
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
            cipherContent.contentText,
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