import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinPlaylistDialog extends StatefulWidget {
  final Function syncPlaylist;

  const JoinPlaylistDialog({super.key, required this.syncPlaylist});

  @override
  State<JoinPlaylistDialog> createState() => _JoinPlaylistDialogState();
}

class _JoinPlaylistDialogState extends State<JoinPlaylistDialog> {
  late final TextEditingController shareCodeController;
  late final TextEditingController roleController;

  @override
  void initState() {
    shareCodeController = TextEditingController();
    roleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    shareCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PlaylistProvider>(
      builder: (context, authProvider, playlistProvider, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: [
                TextField(
                  controller: shareCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Share Code',
                  ),
                ),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Enter Role'),
                ),
                ElevatedButton(
                  onPressed: () => joinPlaylistByCode(
                    shareCodeController,
                    roleController,
                    authProvider,
                    playlistProvider,
                    widget.syncPlaylist,
                  ),
                  child: const Text('Join Playlist'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> joinPlaylistByCode(
    TextEditingController shareCodeController,
    TextEditingController roleController,
    AuthProvider authProvider,
    PlaylistProvider playlistProvider,
    Function syncPlaylist,
  ) async {
    try {
      // Fetch playlist data from cloud repository using the code
      await playlistProvider.loadCloudPlaylistByCode(shareCodeController.text);
      final playlistDto = playlistProvider.currentPlaylist;
      if (playlistDto == null) {
        throw Exception(
          'Playlist not found with code - ${shareCodeController.text}',
        );
      }

      // Add current user as collaborator
      final currentUserId = authProvider.id;
      await playlistProvider.addCollaboratorToPlaylist(
        playlistDto.firebaseId!,
        currentUserId!,
        roleController.text,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error joining playlist: $e');
      }
    }
  }
}
