import 'package:flutter/material.dart';
import '../../models/domain/playlist.dart';

class CollaboratorsBottomSheet extends StatelessWidget {
  final Playlist playlist;

  const CollaboratorsBottomSheet({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Colaboradores',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Collaborators Bottom Sheet - TODO'),
        ],
      ),
    );
  }
}
