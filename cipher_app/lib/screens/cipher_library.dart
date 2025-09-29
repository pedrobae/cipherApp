import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/widgets/cipher/local_cipher_list.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/screens/cipher_viewer.dart';
import 'package:cipher_app/screens/cipher_editor.dart';
import 'package:provider/provider.dart';

class CipherLibraryScreen extends StatelessWidget {
  final bool selectionMode;
  final int? playlistId;
  final List<int>? excludeVersionIds;

  const CipherLibraryScreen({
    super.key,
    this.selectionMode = false,
    this.playlistId,
    this.excludeVersionIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectionMode
          ? AppBar(title: const Text('Adicionar à Playlist'))
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud),
            label: 'Nuvem',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.my_library_music),
            label: 'Local',
          ),
        ],
      ),
      body: LocalCipherList(
        selectVersion: (int versionId, int cipherId) {
          if (selectionMode) {
            try {
              context.read<PlaylistProvider>().addCipherMap(
                playlistId!,
                versionId,
              );

              context.read<CipherProvider>().clearSearch();

              Navigator.pop(context);
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao adicionar à playlist: $error'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    CipherViewer(cipherId: cipherId, versionId: versionId),
              ),
            );
          }
        },
      ),
      floatingActionButton: selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EditCipher()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Cifra'),
              heroTag: 'library_fab',
            ),
    );
  }
}
