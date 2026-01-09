import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:cordis/models/domain/playlist/playlist_text_section.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/text_section_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Dialog for text section editing and deletion
class NewTextSectionDialog extends StatefulWidget {
  final Playlist playlist;

  const NewTextSectionDialog({super.key, required this.playlist});

  /// Shows the text section dialog
  static void show(BuildContext context, {required Playlist playlist}) {
    showDialog(
      context: context,
      builder: (context) => NewTextSectionDialog(playlist: playlist),
    );
  }

  @override
  State<NewTextSectionDialog> createState() => _TextSectionDialogState();
}

class _TextSectionDialogState extends State<NewTextSectionDialog> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: '');
    contentController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nova Seção de Texto',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title field
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Content field with more space
                Expanded(
                  child: TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _saveChanges(playlistProvider),
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Saves changes to the text section
  void _saveChanges(PlaylistProvider playlistProvider) async {
    final newTitle = titleController.text.trim();
    final newContent = contentController.text.trim();

    if (newTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O título não pode estar vazio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final int nextPosition = widget.playlist.items.last.position + 1;
      await context.read<TextSectionProvider>().createTextSection(
        TextSection.local(
          playlistId: widget.playlist.id,
          title: newTitle,
          contentText: newContent,
          position: nextPosition,
        ),
      );
      // Refresh the playlist to show updated text section
      playlistProvider.trackChange(
        'textSections',
        playlistId: widget.playlist.id,
      );
      playlistProvider.loadPlaylist(widget.playlist.id);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seção criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar seção: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
