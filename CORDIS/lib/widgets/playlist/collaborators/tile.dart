import 'package:cordis/models/domain/user.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollaboratorTile extends StatelessWidget {
  final int playlistId;
  final User user;

  const CollaboratorTile({
    super.key,
    required this.playlistId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return ListTile(
          contentPadding: EdgeInsets.only(left: 8),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primary,
            backgroundImage: user.profilePhoto != null
                ? NetworkImage(user.profilePhoto!)
                : null,
            child: user.profilePhoto == null
                ? Text(
                    user.username,
                    style: TextStyle(color: colorScheme.onPrimary),
                  )
                : null,
          ),
          title: Text(user.username),
          subtitle: Text(user.mail),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.more_vert, color: colorScheme.primary),
                onPressed: () {
                  _showRemoveConfirmationDialog(
                    context,
                    user,
                    playlistProvider,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRemoveConfirmationDialog(
    BuildContext context,
    User user,
    PlaylistProvider playlistProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Colaborador'),
        content: Text(
          'Tem certeza que deseja remover ${user.username} da playlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // TODO: Implement remove collaborator logic when playlistProvider Refactor
              // playlistProvider.removeCollaborator(
              //   playlistId,
              //   user.userId,
              // );
              Navigator.of(context).pop();
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
