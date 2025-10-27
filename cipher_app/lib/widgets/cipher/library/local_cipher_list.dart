import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/providers/selection_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:cipher_app/screens/cipher/cipher_editor.dart';
import 'package:cipher_app/widgets/cipher/library/expandible_cipher_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocalCipherList extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;
  final Function(int versionId, int cipherId) onTap;
  final Function(int versionId, int cipherId) onLongPress;

  const LocalCipherList({
    super.key,
    this.selectionMode = false,
    this.playlistId,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<LocalCipherList> createState() => _LocalCipherListState();
}

class _LocalCipherListState extends State<LocalCipherList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CipherProvider>().loadLocalCiphers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<CipherProvider, SelectionProvider>(
      builder: (context, cipherProvider, selectionProvider, child) {
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

            if (!widget.selectionMode) ...[
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
                  label: const Text('Nova Cifra'),
                  heroTag: 'library_fab',
                ),
              ),
            ] else if (selectionProvider.isSelectionMode) ...[
              _buildBatchAddButton(selectionProvider, cipherProvider),
            ],
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
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: cipherProvider.filteredLocalCiphers.length,
        itemBuilder: (context, index) {
          if (index >= cipherProvider.filteredLocalCiphers.length) {
            return const SizedBox.shrink();
          }

          final cipher = cipherProvider.filteredLocalCiphers[index];
          return CipherCard(
            cipher: cipher,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
          );
        },
      ),
    );
  }

  Widget _buildBatchAddButton(
    SelectionProvider selectionProvider,
    CipherProvider cipherProvider,
  ) {
    return Positioned(
      bottom: 4,
      left: 8,
      right: 8,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 1), // Start from bottom
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                ),
                child: child,
              ),
            ),
          );
        },
        child: selectionProvider.isSelectionMode
            ? SizedBox(
                key: const ValueKey('batch_add_to_playlist_container'),
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('batch_add_to_playlist_button'),
                  style: ButtonStyle(
                    shadowColor: WidgetStateProperty.resolveWith((states) {
                      return Colors.transparent;
                    }),
                  ),
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    final userProvider = context.read<UserProvider>();
                    // Handle adding selected versions to playlist
                    for (var versionId in selectionProvider.selectedItems) {
                      await context
                          .read<PlaylistProvider>()
                          .addVersionToPlaylist(
                            widget.playlistId!,
                            versionId,
                            userProvider.getLocalIdByFirebaseId(
                              authProvider.id!,
                            )!,
                          );
                    }
                    selectionProvider.disableSelectionMode();
                  },
                  child: selectionProvider.selectedItems.length == 1
                      ? Text('Adicionar à Playlist')
                      : Text(
                          'Adicionar ${selectionProvider.selectedItems.length} versões à Playlist',
                        ),
                ),
              )
            : const SizedBox.shrink(key: ValueKey('empty_space')),
      ),
    );
  }
}
