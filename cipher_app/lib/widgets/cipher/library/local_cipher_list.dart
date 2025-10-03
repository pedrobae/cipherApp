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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<CipherProvider>(
      builder: (context, cipherProvider, child) {
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
            if (cipherProvider.filteredLocalCiphers.isEmpty) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.selectionMode
                          ? Icons.playlist_add_outlined
                          : Icons.music_note_outlined,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.selectionMode
                          ? 'Nenhuma cifra disponível para adicionar'
                          : 'Nenhuma cifra encontrada',
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
                      MaterialPageRoute(
                        builder: (context) => const EditCipher(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Cifra'),
                  heroTag: 'library_fab',
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCiphersList(CipherProvider cipherProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        await cipherProvider.loadLocalCiphers(forceReload: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(4),
        cacheExtent: 200,
        physics: const BouncingScrollPhysics(),
        itemCount: cipherProvider.filteredLocalCiphers.length,
        itemBuilder: (context, index) {
          if (index >= cipherProvider.filteredLocalCiphers.length) {
            return const SizedBox.shrink();
          }

          final cipher = cipherProvider.filteredLocalCiphers[index];
          return CipherCard(cipher: cipher, onTap: widget.onTap);
        },
      ),
    );
  }
}
