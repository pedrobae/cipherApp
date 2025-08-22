import 'package:flutter/material.dart';
import '../models/domain/cipher.dart';
import '../routes/app_routes.dart';
import './tag_chip.dart';

class CipherCard extends StatelessWidget {
  final Cipher cipher;
  final VoidCallback? onAddToPlaylist;

  const CipherCard({super.key, required this.cipher, this.onAddToPlaylist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 5,
                      children: [
                        Text(
                          cipher.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          cipher.author,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Text(
                          'Key: ${cipher.key}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tempo: ${cipher.tempo}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    // Tags display with hash-based colors
                    if (cipher.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: cipher.tags
                            .map(
                              (tag) => TagChip(
                                tag: tag,
                                onTap: () => _handleTagTap(tag),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.playlist_add, color: colorScheme.primary),
                onPressed: onAddToPlaylist,
                tooltip: 'Add to playlist',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTagTap(String tag) {
    // Handle tag tap, e.g., navigate to a tag-specific page or filter content
  }
}
