import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain/playlist/playlist.dart';
import '../models/domain/playlist/playlist_item.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist/presentation/presentation_cipher_section.dart';
import '../widgets/playlist/presentation/presentation_text_section.dart';
import '../widgets/playlist/presentation/playlist_navigation_drawer.dart';

class PlaylistPresentationScreen extends StatefulWidget {
  final int playlistId;

  const PlaylistPresentationScreen({
    super.key,
    required this.playlistId,
  });

  @override
  State<PlaylistPresentationScreen> createState() => _PlaylistPresentationScreenState();
}

class _PlaylistPresentationScreenState extends State<PlaylistPresentationScreen> {
  late ScrollController _scrollController;
  final Map<int, GlobalKey> _itemKeys = {};
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Listen to scroll changes to update current position
    _scrollController.addListener(_onScrollUpdate);
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
            _itemKeys[i] = GlobalKey();
          }
        }

        return Scaffold(
          endDrawer: PlaylistNavigationDrawer(
            playlist: playlist,
            onItemSelected: _scrollToItem,
          ),
          body: _buildPresentationBody(playlist),
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: 'Navegação Rápida',
                child: const Icon(Icons.list),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPresentationBody(Playlist playlist) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  if (playlist.description?.isNotEmpty == true) ...[
                  Text(
                    playlist.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ],
                ],
              ),
            ),
          
          ...playlist.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Container(
              key: _itemKeys[index],
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemContent(item),
                ],
              ),
            );
          }),
          
          // Extra padding at bottom for better UX
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildItemContent(PlaylistItem item) {
    switch (item.type) {
      case 'cipher_version':
        return PresentationCipherSection(
          versionId: item.contentId,
        );
      case 'text_section':
        return PresentationTextSection(
          textSectionId: item.contentId,
        );
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

  Future<void> _scrollToItem(int itemIndex) async {
    if (!_itemKeys.containsKey(itemIndex)) return;
    
    final key = _itemKeys[itemIndex];
    final context = key?.currentContext;
    
    if (context != null) {
      _isScrolling = true;
      
      // Calculate the position to scroll to
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final scrollPosition = _scrollController.offset + position.dy - 100; // 100px offset from top
      
      await _scrollController.animateTo(
        scrollPosition.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      
      _isScrolling = false;
    }
  }
  
}