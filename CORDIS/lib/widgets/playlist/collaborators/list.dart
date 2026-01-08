import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/widgets/playlist/collaborators/tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollaboratorList extends StatefulWidget {
  const CollaboratorList({super.key, required this.playlistId});

  final int playlistId;

  @override
  State<CollaboratorList> createState() => _CollaboratorListState();
}

class _CollaboratorListState extends State<CollaboratorList> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, PlaylistProvider>(
      builder: (context, userProvider, playlistProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userProvider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erro: ${userProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO : Implement retry logic
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final userIds = playlistProvider.currentPlaylist?.collaborators;
        final users = userProvider.getUsersByFirebaseIds(userIds ?? []);

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Nenhum colaborador adicionado'),
                const SizedBox(height: 16),
              ],
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return CollaboratorTile(
                user: user,
                playlistId: widget.playlistId,
              );
            },
          ),
        );
      },
    );
  }
}
