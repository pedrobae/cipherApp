import 'package:cordis/helpers/codes.dart';
import 'package:cordis/providers/auth_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/domain/playlist/playlist.dart';
import '../../providers/playlist_provider.dart';

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Playlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da Playlist',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _createPlaylist, child: const Text('Criar')),
      ],
    );
  }

  void _createPlaylist() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final uid = context.read<AuthProvider>().id;
    final createdBy = uid != null
        ? context.read<UserProvider>().getLocalIdByFirebaseId(uid)!
        : -1;

    final newPlaylist = Playlist(
      id: 0, // Will be overwritten by an auto-generated id on db insertion
      name: name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdBy: createdBy,
      isPublic: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      collaborators: const [],
      shareCode: generateShareCode(),
      items: const [],
    );

    Navigator.of(context).pop();
    context.read<PlaylistProvider>().createPlaylist(newPlaylist);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist "$name" criada'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
