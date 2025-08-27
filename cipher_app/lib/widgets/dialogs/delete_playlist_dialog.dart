import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/domain/playlist.dart';
import '../../providers/playlist_provider.dart';

class DeletePlaylistDialog extends StatelessWidget {
  final Playlist playlist;

  const DeletePlaylistDialog({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir Playlist'),
      content: Text('Tem certeza que deseja excluir "${playlist.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => _deletePlaylist(context),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Excluir'),
        ),
      ],
    );
  }

  void _deletePlaylist(BuildContext context) {
    Navigator.of(context).pop();
    context.read<PlaylistProvider>().deletePlaylist(playlist.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist "${playlist.name}" excluída'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
