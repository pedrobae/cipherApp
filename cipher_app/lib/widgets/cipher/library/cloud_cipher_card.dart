import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/widgets/cipher/tag_chip.dart';

class CloudCipherCard extends StatelessWidget {
  final CipherDto cipher;
  final VoidCallback onDownload;

  const CloudCipherCard({
    super.key,
    required this.cipher,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        tileColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                Text(cipher.title, style: theme.textTheme.titleLarge),
                Text(cipher.author),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tom: ${cipher.musicKey}'),
                Text('Tempo: ${cipher.tempo}'),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: cipher.tags.map((tag) => TagChip(tag: tag)).toList(),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_for_offline),
          onPressed: onDownload,
        ),
      ),
    );
  }
}
