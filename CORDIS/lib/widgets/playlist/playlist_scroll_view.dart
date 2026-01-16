import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistScrollView extends StatefulWidget {
  const PlaylistScrollView({super.key});

  @override
  State<PlaylistScrollView> createState() => _PlaylistScrollViewState();
}

class _PlaylistScrollViewState extends State<PlaylistScrollView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer3<PlaylistProvider, MyAuthProvider, UserProvider>(
      builder:
          (context, playlistProvider, myAuthProvider, userProvider, child) {
            // Handle loading state
            if (playlistProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle error state
            if (playlistProvider.error != null) {
              return Center(
                child: Column(
                  children: [
                    Text(playlistProvider.error!),
                    ElevatedButton(
                      onPressed: () {
                        playlistProvider.loadLocalPlaylists();
                      },
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ],
                ),
              );
            }

            // Display playlist list
            return RefreshIndicator(
              onRefresh: () async {
                playlistProvider.loadLocalPlaylists();
              },
              child: playlistProvider.filteredPlaylists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note_outlined,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noPlaylistsFound,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      cacheExtent: 500,
                      itemCount: playlistProvider.filteredPlaylists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlistProvider
                            .filteredPlaylists
                            .values
                            .elementAt(index);
                        return ListTile(
                          title: Text(playlist.name),
                          // Additional playlist details can be added here
                        );
                      },
                    ),
            );
          },
    );
  }
}
