import 'package:flutter/material.dart';
import '../models/domain/cipher.dart';
import '../routes/app_routes.dart';

class CipherCard extends StatelessWidget {
  final Cipher cipher;
  final VoidCallback? onAddToPlaylist;

  static Color _getTagColor(String tag) {
    final hash = tag.hashCode;
    final hue = (hash % 360).toDouble();
    // Adjust saturation and value for better readability
    return HSVColor.fromAHSV(1, hue, 0.5, 0.8).toColor();
  }

  const CipherCard({super.key, required this.cipher, this.onAddToPlaylist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.cipherViewer,
        arguments: cipher,
      ),
      child: Card(
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
                        Text(cipher.author),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Key: ${cipher.key}'),
                        const SizedBox(width: 8),
                        Text('Tempo: ${cipher.tempo}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: cipher.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTagColor(tag),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                          .toList(),
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