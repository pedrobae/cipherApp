import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/domain/playlist/playlist.dart';
import '../../../models/domain/playlist/playlist_item.dart';

class PlaylistNavigationDrawer extends StatelessWidget {
  final Playlist playlist;
  final Function(int) onItemSelected;

  const PlaylistNavigationDrawer({
    super.key,
    required this.playlist,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: .8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Items list
          Expanded(
            child: playlist.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.playlist_play,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Playlist vazia',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: playlist.items.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final item = playlist.items[index];
                      return _buildNavigationItem(context, item, index);
                    },
                  ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<LayoutSettingsProvider>(
                  builder: (context, layoutProvider, child) {
                    return IconButton(
                      icon: const Icon(Icons.visibility),
                      tooltip: 'Configurações de Layout',
                      onPressed: () => _showLayoutSettings(context, layoutProvider),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(BuildContext context, PlaylistItem item, int index) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _getColorForType(item.type).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getColorForType(item.type).withValues(alpha: .3),
            width: 1,
          ),
        ),
        child: Icon(
          _getIconForType(item.type),
          size: 16,
          color: _getColorForType(item.type),
        ),
      ),
      title: Text(
        _getTitleForItem(item),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getSubtitleForType(item.type),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onItemSelected(index);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'cipher_version':
        return Icons.music_note;
      case 'text_section':
        return Icons.text_fields;
      default:
        return Icons.help;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'cipher_version':
        return Colors.blue;
      case 'text_section':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTitleForItem(PlaylistItem item) {
    switch (item.type) {
      case 'cipher_version':
        return 'Cifra ${item.contentId}';
      case 'text_section':
        return 'Texto ${item.contentId}';
      default:
        return 'Item ${item.contentId}';
    }
  }

  String _getSubtitleForType(String type) {
    switch (type) {
      case 'cipher_version':
        return 'Cifra musical';
      case 'text_section':
        return 'Seção de texto';
      default:
        return 'Tipo desconhecido';
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