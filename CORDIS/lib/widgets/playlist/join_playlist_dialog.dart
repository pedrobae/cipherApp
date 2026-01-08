import 'package:cordis/models/dtos/playlist_dto.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/auth_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef SyncPlaylistFunction = Future<void> Function(PlaylistDto playlistDto);

class JoinPlaylistDialog extends StatefulWidget {
  final SyncPlaylistFunction syncPlaylist;

  const JoinPlaylistDialog({super.key, required this.syncPlaylist});

  @override
  State<JoinPlaylistDialog> createState() => _JoinPlaylistDialogState();
}

class _JoinPlaylistDialogState extends State<JoinPlaylistDialog> {
  late final TextEditingController shareCodeController;

  @override
  void initState() {
    shareCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    shareCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, PlaylistProvider, UserProvider>(
      builder: (context, authProvider, playlistProvider, userProvider, child) {
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
                    labelText: 'Insira o código de Compartilhamento',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => joinPlaylistByCode(
                    shareCodeController,
                    authProvider,
                    playlistProvider,
                    userProvider,
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
    AuthProvider authProvider,
    PlaylistProvider playlistProvider,
    UserProvider userProvider,
    Function syncPlaylist,
  ) async {
    try {
      // TODO CHANGE THE FLOW - CARE WITH THE FIRESTORE RULES
      // Fetch playlist data from cloud repository using the code
      await playlistProvider.loadCloudPlaylistByCode(shareCodeController.text);
      final playlistDto = playlistProvider.currentCloudPlaylist;
      if (playlistDto == null) {
        throw Exception(
          'Playlist not found with code - ${shareCodeController.text}',
        );
      }

      // Sync Playlist
      await widget.syncPlaylist(playlistDto);

      final currentUserId = authProvider.id;

      // Add current user as collaborator to the cloud database
      await playlistProvider.addCollaboratorToPlaylist(
        playlistDto.firebaseId!,
        currentUserId!,
      );

      // final playlist = playlistProvider.getPlaylistByFirebaseId(
      //   playlistDto.firebaseId!,
      // );

      // Add current user as collaborator to the local database
      /// TODO: Reimplement on playlist provider refactor
      // await collaboratorProvider.addCollaborator(
      //   playlist!.id,
      //   userProvider.getLocalIdByFirebaseId(currentUserId)!,
      //   roleController.text,
      //   userProvider.getLocalIdByFirebaseId(playlistDto.ownerId)!,
      // );

      // Close Dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error joining playlist: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
