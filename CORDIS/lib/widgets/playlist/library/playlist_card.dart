import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/playlist_provider.dart';

class PlaylistCard extends StatelessWidget {
  final int playlistId;

  const PlaylistCard({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final playlist = playlistProvider.getPlaylistById(playlistId)!;

        final itemCount = playlist.items.length;

        // Card content
        return GestureDetector(
          onTap: () {
            // TODO - Open playlist details
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.surfaceContainerHigh),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // INFO
                Expanded(
                  child: Column(
                    spacing: 2.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        itemCount > 1
                            ? '$itemCount ${AppLocalizations.of(context)!.items}'
                            : '$itemCount ${AppLocalizations.of(context)!.item}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                        ),
                      ),
                    ],
                  ),
                ),
                // ACTIONS
                IconButton(
                  onPressed: () {
                    // TODO - Show playlist actions
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
