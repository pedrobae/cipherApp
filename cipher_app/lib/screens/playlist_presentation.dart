import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain/playlist/playlist_item.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist/presentation/presentation_cipher_section.dart';
import '../widgets/playlist/presentation/presentation_text_section.dart';
import '../widgets/playlist/presentation/playlist_navigation_drawer.dart';

class PlaylistPresentationScreen extends StatefulWidget {
  final int playlistId;

  const PlaylistPresentationScreen({super.key, required this.playlistId});

  @override
  State<PlaylistPresentationScreen> createState() =>
      _PlaylistPresentationScreenState();
}

class _PlaylistPresentationScreenState
    extends State<PlaylistPresentationScreen> {
  late ScrollController _scrollController;
  final Map<int, Map<int, GlobalKey>> _itemKeys = {};
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollUpdate() {
    if (!_isScrolling) {
      // Track scroll position for future collaboration features
      // TODO: Future - broadcast position to collaborators
      // final position = _scrollController.offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final playlist = playlistProvider.playlists.firstWhere(
          (p) => p.id == widget.playlistId,
          orElse: () => throw Exception('Playlist not found'),
        );

        // Generate keys for each item for scroll targeting
        for (int i = 0; i < playlist.items.length; i++) {
          if (!_itemKeys.containsKey(i)) {
            _itemKeys[i] = {-1: GlobalKey()};
          }
        }

        return Scaffold(
          endDrawer: PlaylistNavigationDrawer(
            playlist: playlist,
            onItemSelected: (index) => _scrollToItem(index, null),
          ),
          body: CustomScrollView(
            controller: _scrollController, // Keep your existing controller
            slivers: <Widget>[
              SliverAppBar(
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    children: [
                      Text(
                        playlist.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      if (playlist.description?.isNotEmpty == true)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            playlist.description!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      ...playlist.items.asMap().entries.map((entry) {
                        final itemIndex = entry.key;
                        final item = entry.value;

                        return Container(
                          key: _itemKeys[itemIndex]![-1],
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_buildItemContent(item, itemIndex)],
                          ),
                        );
                      }),
                      const SizedBox(height: 200),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemContent(PlaylistItem item, int itemIndex) {
    switch (item.type) {
      case 'cipher_version':
        return PresentationCipherSection(
          versionId: item.contentId,
          onSectionKeysCreated: (versionId, sectionKeys) {
            setState(() {
              if (!_itemKeys.containsKey(itemIndex)) {
                _itemKeys[itemIndex] = {-1: GlobalKey()};
              }
              _itemKeys[itemIndex]!.addAll(sectionKeys);
            });
          },
        );
      case 'text_section':
        return PresentationTextSection(textSectionId: item.contentId);
      default:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.help, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Tipo desconhecido: ${item.type}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'ID: ${item.contentId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
    }
  }

  Future<void> _scrollToItem(int itemIndex, int? sectionIndex) async {
    if (!_itemKeys.containsKey(itemIndex)) return;

    if (!_itemKeys[itemIndex]!.containsKey(sectionIndex)) sectionIndex = -1;

    final key = _itemKeys[itemIndex]![sectionIndex];
    final context = key?.currentContext;

    if (context != null) {
      _isScrolling = true;
      // Calculate the position to scroll to
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final scrollPosition =
          _scrollController.offset + position.dy - 100; // 100px offset from top

      await _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      _isScrolling = false;
    }
  }
}
