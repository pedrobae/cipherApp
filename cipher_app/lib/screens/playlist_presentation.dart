import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain/playlist/playlist.dart';
import '../models/domain/playlist/playlist_item.dart';
import '../providers/playlist_provider.dart';
import '../providers/layout_settings_provider.dart';
import '../widgets/presentation/presentation_cipher_section.dart';
import '../widgets/presentation/presentation_text_section.dart';
import '../widgets/presentation/presentation_header.dart';
import '../widgets/presentation/playlist_navigation_drawer.dart';

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
          appBar: _buildAppBar(playlist),
          endDrawer: PlaylistNavigationDrawer(
            playlist: playlist,
            onItemSelected: _scrollToItem,
          ),
          body: _buildPresentationBody(playlist),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Playlist playlist) {
    return AppBar(
      title: Text(
        playlist.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 2,
      actions: [
        // Layout settings (no transpose)
        Consumer<LayoutSettingsProvider>(
          builder: (context, layoutProvider, child) {
            return IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'Configurações de Layout',
              onPressed: () => _showLayoutSettings(context, layoutProvider),
            );
          },
        ),
        // Navigation drawer trigger (showing items list)
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Navegação Rápida',
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildPresentationBody(Playlist playlist) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playlist description if available
          if (playlist.description?.isNotEmpty == true) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          // All playlist items in one continuous column
          ...playlist.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Container(
              key: _itemKeys[index],
              margin: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  PresentationHeader(
                    item: item,
                    index: index + 1,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Section content
                  _buildItemContent(item),
                ],
              ),
            );
          }),
          
          // Extra padding at bottom for better UX
          const SizedBox(height: 100),
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

  void _showLayoutSettings(BuildContext context, LayoutSettingsProvider layoutProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Configurações de Layout',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                
                // Layout options (excluding transpose)
                SwitchListTile(
                  title: const Text('Mostrar Anotações'),
                  subtitle: const Text('Exibe seções de anotações e comentários'),
                  value: layoutProvider.showAnnotations,
                  onChanged: (value) => layoutProvider.toggleNotes(),
                ),
                
                SwitchListTile(
                  title: const Text('Mostrar Transições'),
                  subtitle: const Text('Exibe seções de transição entre partes'),
                  value: layoutProvider.showTransitions,
                  onChanged: (value) => layoutProvider.toggleTransitions(),
                ),
                
                const Divider(),
                
                ListTile(
                  title: const Text('Tamanho da Fonte'),
                  subtitle: Slider(
                    value: layoutProvider.fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    label: '${layoutProvider.fontSize.round()}',
                    onChanged: (value) => layoutProvider.setFontSize(value),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}