import 'package:flutter/material.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 5, // Temporary count
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.playlist_play),
            title: Text('Playlist ${index + 1}'),
            subtitle: Text('${index * 3 + 1} items'),
            onTap: () {
              // TODO: Implement playlist selection
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new playlist creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}