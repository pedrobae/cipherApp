import 'package:flutter/material.dart';
import 'package:cipher_app/widgets/cipher/tag_chip.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';

class CloudCipherCard extends StatelessWidget {
  final Cipher cipher;
  final VoidCallback onDownload;
  final bool isSelectMode;

  const CloudCipherCard({
    super.key,
    required this.cipher,
    required this.onDownload,
    this.isSelectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      shape: Border(),
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
    );
  }
}
