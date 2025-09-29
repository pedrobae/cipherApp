import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/screens/cipher_editor.dart';
import 'package:cipher_app/widgets/cipher/library/expandible_cipher_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocalCipherList extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;
  final Function(int versionId, int cipherId) onTap;

  const LocalCipherList({
    super.key,
    this.selectionMode = false,
    this.playlistId,
    required this.onTap,
  });

  @override
  State<LocalCipherList> createState() => _LocalCipherListState();
}

class _LocalCipherListState extends State<LocalCipherList> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataIfNeeded();
  }

  void _loadDataIfNeeded() {
    final cipherProvider = Provider.of<CipherProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cipherProvider.loadLocalCiphers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cipherProvider = Provider.of<CipherProvider>(context);

    return _buildContent(cipherProvider);
  }

  Widget _buildContent(CipherProvider cipherProvider) {
    // Handle loading state
    if (cipherProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Handle error state
    if (cipherProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Erro: ${cipherProvider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  cipherProvider.loadLocalCiphers(forceReload: true),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Handle empty state
        if (cipherProvider.localCiphers.isEmpty) ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.selectionMode
                      ? Icons.playlist_add_outlined
                      : Icons.music_note_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.selectionMode
                      ? 'Nenhuma cifra disponível para adicionar'
                      : 'Nenhuma cifra encontrada',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ] else ...[
          // Display cipher list
          _buildCiphersList(cipherProvider),
        ],
        if (!widget.selectionMode)
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            right: MediaQuery.of(context).viewInsets.right + 8,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EditCipher()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Cifra'),
              heroTag: 'library_fab',
            ),
          ),
      ],
    );
    // Handle empty state
  }

  Widget _buildCiphersList(CipherProvider cipherProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        await cipherProvider.loadLocalCiphers(forceReload: true);
      },
      child: ListView.builder(
        cacheExtent: 200,
        physics: const BouncingScrollPhysics(),
        itemCount: cipherProvider.localCiphers.length,
        itemBuilder: (context, index) {
          // Add bounds checking
          if (index >= cipherProvider.localCiphers.length) {
            return const SizedBox.shrink();
          }

          final cipher = cipherProvider.localCiphers[index];
          return CipherCard(cipher: cipher, onTap: widget.onTap);

          // In selection mode, we can't filter by versions until they're loaded
          // The filtering will happen in the CipherCard when versions are expanded
          // For now, show all ciphers and let user expand to see available versions
        },
      ),
    );
  }
}
