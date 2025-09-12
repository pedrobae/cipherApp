import 'package:flutter/material.dart';
import '../../models/domain/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.playlist_play, color: Colors.white),
        ),
        title: Text(
          playlist.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (playlist.description != null &&
                playlist.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  playlist.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${playlist.cipherVersionIds.length} ${playlist.cipherVersionIds.length == 1 ? 'música' : 'músicas'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete, color: Colors.red),
        ),
        onTap: onTap,
      ),
    );
  }
}
