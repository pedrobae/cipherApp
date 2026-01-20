import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/widgets/playlist/library/playlist_scroll_view.dart';
import 'package:cordis/widgets/icon_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/playlist_provider.dart';

class PlaylistLibraryScreen extends StatefulWidget {
  const PlaylistLibraryScreen({super.key});

  @override
  State<PlaylistLibraryScreen> createState() => _PlaylistLibraryScreenState();
}

class _PlaylistLibraryScreenState extends State<PlaylistLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlaylistProvider>().loadLocalPlaylists();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Column(
            spacing: 8,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchPlaylist,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: colorScheme.surfaceContainer),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  suffixIcon: const Icon(Icons.search),
                  fillColor: colorScheme.surfaceContainerHighest,
                  visualDensity: VisualDensity.compact,
                ),
                onChanged: (value) {
                  playlistProvider.setSearchTerm(value);
                },
              ),
              // Buttons Row (e.g., Filters, Sort, Create New Cipher)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CREATE NEW PLAYLIST BUTTON
                  IconTextButton(
                    onTap: () {
                      //TODO: Implement create new Playlist functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento 🚧'),
                        ),
                      );
                    },
                    text: AppLocalizations.of(context)!.create,
                    icon: Icon(Icons.add, color: colorScheme.onSurface),
                  ),
                  // TODO think of these buttons
                  // SORT BUTTON
                  IconTextButton(
                    onTap: () {},
                    text: AppLocalizations.of(context)!.sort,
                    icon: Icon(Icons.sort, color: colorScheme.onSurface),
                  ),
                  // FILTER BUTTON
                  IconTextButton(
                    onTap: () {},
                    text: AppLocalizations.of(context)!.filter,
                    icon: Icon(Icons.filter_list, color: colorScheme.onSurface),
                  ),
                ],
              ),

              Expanded(child: PlaylistScrollView()),
            ],
          ),
        );
      },
    );
  }
}
