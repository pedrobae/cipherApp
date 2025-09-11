import 'package:flutter/material.dart';
import '../../models/domain/cipher.dart';
import 'tag_chip.dart';

class CipherCard extends StatelessWidget {
  final Cipher cipher;
  final Function(CipherVersion, Cipher)? selectVersion;
  final bool isExpanded;
  final VoidCallback onExpand;

  const CipherCard({
    super.key,
    required this.cipher,
    this.selectVersion,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          key: PageStorageKey(cipher.id),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            if (expanded) onExpand;
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 10,
                      children: [
                        Text(
                          cipher.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(cipher.author),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Tom: ${cipher.musicKey}'),
                        const SizedBox(width: 8),
                        Text('Tempo: ${cipher.tempo}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: cipher.tags
                          .map((tag) => TagChip(tag: tag))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: cipher.maps.map((version) {
            return InkWell(
              onTap: selectVersion!(version, cipher),
              child: Row(
                spacing: 16,
                children: [
                  Text(
                    version.versionName!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Tom: ${version.transposedKey}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


// CipherCard(
//   cipher: cipher,
//   onAddToPlaylist: () {
//     // Handle adding to playlist
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => PlaylistSelectionSheet(cipher: cipher),
//     );
//   },
// ),