import 'package:cordis/providers/collaborator_provider.dart';
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
  void initState() {
    super.initState();
    // Load collaborators when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CollaboratorProvider>(
        context,
        listen: false,
      ).loadCollaborators(widget.playlistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollaboratorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erro: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.loadCollaborators(widget.playlistId);
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final collaborators = provider.getCollaboratorsForPlaylist(
          widget.playlistId,
        );
        if (collaborators.isEmpty) {
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
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index];
              return CollaboratorTile(
                collaborator: collaborator,
                playlistId: widget.playlistId,
              );
            },
          ),
        );
      },
    );
  }
}
