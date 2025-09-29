import 'package:cipher_app/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/text_section_provider.dart';

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
                  const Icon(Icons.list, color: Colors.white, size: 32),
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
                        Icon(Icons.playlist_play, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Playlist vazia',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      );
                    },
                    itemCount: playlist.items.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final item = playlist.items[index];
                      return _buildNavigationItem(context, item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    PlaylistItem item,
    int index,
  ) {
    return Consumer3<CipherProvider, VersionProvider, TextSectionProvider>(
      builder:
          (
            context,
            cipherProvider,
            versionProvider,
            textSectionProvider,
            child,
          ) {
            return FutureBuilder<String>(
              future: _getItemTitle(
                item,
                cipherProvider,
                versionProvider,
                textSectionProvider,
              ),
              builder: (context, snapshot) {
                final title = snapshot.data ?? 'ERROR GETTING CIPHER TITLE';

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getColorForType(item.type).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getColorForType(
                          item.type,
                        ).withValues(alpha: .3),
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
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                );
              },
            );
          },
    );
  }

  Future<String> _getItemTitle(
    PlaylistItem item,
    CipherProvider cipherProvider,
    VersionProvider versionProvider,
    TextSectionProvider textSectionProvider,
  ) async {
    switch (item.type) {
      case 'cipher_version':
        final version = versionProvider.getCachedVersion(item.contentId);
        final cipher = cipherProvider.getCachedCipher(version!.cipherId);
        return cipher!.title;

      case 'text_section':
        await textSectionProvider.loadTextSection(item.contentId);
        final textSection = textSectionProvider.textSections[item.contentId];
        if (textSection != null && textSection.title.isNotEmpty) {
          return textSection.title;
        }
        return 'Seção de Texto ${item.contentId}';
      default:
        return 'Item ${item.contentId}';
    }
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
}
