import 'package:flutter/material.dart';
import '../../models/domain/cipher.dart';

class CipherHeaderSection extends StatelessWidget {
  final Cipher cipher;

  const CipherHeaderSection({
    super.key,
    required this.cipher,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildInfoChip(context, 'Tom', cipher.musicKey),
                const SizedBox(width: 4),
                _buildInfoChip(context, 'Tempo', cipher.tempo),
                const SizedBox(width: 4),
                _buildInfoChip(context, 'Idioma', cipher.language),
              ],
            ),
            if (cipher.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cipher.tags.map((tag) => 
                  Chip(
                    label: Text(
                      tag,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
