import 'package:flutter/material.dart';
import '../../models/domain/cipher.dart';
import '../../routes/app_routes.dart';
import 'tag_chip.dart';

class CipherCard extends StatelessWidget {
  final Cipher cipher;
  final VoidCallback? onAddToPlaylist;

  const CipherCard({
    super.key, 
    required this.cipher, 
    this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.cipherViewer, arguments: cipher),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
                      Text(cipher.author, ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Key: ${cipher.musicKey}'),
                      const SizedBox(width: 8),
                      Text('Tempo: ${cipher.tempo}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: cipher.tags.map((tag) => TagChip(tag: tag,)).toList(),
                  ),
                ],
              ),
            ),
              IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: onAddToPlaylist,
                    tooltip: 'Add to playlist',
                  ),
            ],
          ),
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