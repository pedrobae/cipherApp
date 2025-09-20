import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/widgets/playlist/presentation/presentation_cipher_section.dart';
import 'package:cipher_app/widgets/playlist/presentation/presentation_text_section.dart';
import 'package:cipher_app/widgets/playlist/presentation/playlist_navigation_drawer.dart';
import 'package:cipher_app/widgets/settings/layout_settings.dart';

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
        final layoutProvider = context.read<LayoutSettingsProvider>();

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
                backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
                toolbarHeight: kToolbarHeight + 4,
                actions: [
                  Consumer<LayoutSettingsProvider>(
                    builder: (context, layoutProvider, child) {
                      return IconButton(
                        icon: const Icon(Icons.visibility),
                        tooltip: 'Configurações de Layout',
                        onPressed: () =>
                            _showLayoutSettings(context, layoutProvider),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) => DrawerButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                ],
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    textAlign: TextAlign.center,
                    playlist.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: layoutProvider.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryFixed,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 4,
                      children: [
                        const SizedBox(height: 12),
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
                                  ?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontFamily: layoutProvider.fontFamily,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        ...playlist.items.asMap().entries.map((entry) {
                          final itemIndex = entry.key;
                          final item = entry.value;

                          return Container(
                            key: _itemKeys[itemIndex]![-1],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_buildItemContent(item, itemIndex)],
                            ),
                          );
                        }),
                        const SizedBox(height: 200),
                      ],
                    ),
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
                Text('Tipo desconhecido: ${item.type}'),
                Text('ID: ${item.contentId}'),
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

  void _showLayoutSettings(
    BuildContext context,
    LayoutSettingsProvider layoutProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to expand based on content
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SingleChildScrollView(
            child: Align(
              alignment: AlignmentGeometry.center,
              child: LayoutSettings(includeFilters: true, isPresenter: true),
            ),
          ),
        );
      },
    );
  }
}
