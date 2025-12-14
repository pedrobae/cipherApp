import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/selection_provider.dart';
import 'package:cipher_app/screens/cipher/cipher_viewer.dart';
import 'package:cipher_app/widgets/ciphers/library/cloud_cipher_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CloudCipherList extends StatefulWidget {
  final bool isAddingToPlaylist;
  final int? playlistId;
  final VoidCallback? searchCloudCiphers;
  final VoidCallback changeTab;

  const CloudCipherList({
    super.key,
    this.isAddingToPlaylist = false,
    this.playlistId,
    this.searchCloudCiphers,
    required this.changeTab,
  });

  @override
  State<CloudCipherList> createState() => _CloudCipherListState();
}

class _CloudCipherListState extends State<CloudCipherList> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureDataLoad();
  }

  void _ensureDataLoad() {
    final cipherProvider = Provider.of<CipherProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cipherProvider.loadCloudCiphers();
      }
    });
  }

  Widget _buildCiphersList(
    CipherProvider cipherProvider,
    SelectionProvider selectionProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await cipherProvider.loadCloudCiphers(forceReload: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(4),
        cacheExtent: 200,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: cipherProvider.filteredCloudCiphers.length,
        itemBuilder: (context, index) {
          // Add bounds checking
          if (index >= cipherProvider.filteredCloudCiphers.length) {
            return const SizedBox.shrink();
          }

          final cipher = cipherProvider.filteredCloudCiphers[index];
          return GestureDetector(
            onLongPress: () => {
              selectionProvider.enableSelectionMode(),
              selectionProvider.toggleItemSelection(cipher),
            },
            child: CloudCipherCard(
              cipher: cipher,
              onTap: () {
                selectionProvider.toggleItemSelection(cipher);
              },
              onDownload: () async {
                final navigator = Navigator.of(context);

                await cipherProvider.downloadFullCipher(cipher);
                widget.changeTab();
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => CipherViewer(
                      cipherId: cipherProvider.currentCipher.id!,
                      versionId: cipherProvider.currentCipher.versions.last.id!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBatchDownloadButton(
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
                key: const ValueKey('batch_download_container'),
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('batch_download_button'),
                  style: ButtonStyle(
                    shadowColor: WidgetStateProperty.resolveWith((states) {
                      return Colors.transparent;
                    }),
                  ),
                  onPressed: () async {
                    // Handle bulk download
                    final selectedCiphers = selectionProvider.selectedItems;
                    for (var cipher in selectedCiphers) {
                      await cipherProvider.downloadFullCipher(cipher);
                    }
                    selectionProvider.disableSelectionMode();
                    widget.changeTab();
                  },
                  child: selectionProvider.selectedItems.length == 1
                      ? Text('Baixar a cifra selecionada')
                      : Text(
                          'Baixar ${selectionProvider.selectedItems.length} cifras selecionadas',
                        ),
                ),
              )
            : const SizedBox.shrink(key: ValueKey('empty_space')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<CipherProvider, SelectionProvider>(
      builder: (context, cipherProvider, selectionProvider, child) {
        // Handle loading state
        if (cipherProvider.isLoadingCloud) {
          return const Center(child: CircularProgressIndicator());
        }
        // Handle error state
        if (cipherProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text('${cipherProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      cipherProvider.loadCloudCiphers(forceReload: true),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (cipherProvider.filteredCloudCiphers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                Icon(
                  Icons.cloud_download,
                  size: 64,
                  color: colorScheme.primary,
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return colorScheme.surfaceContainerHighest;
                    }),
                    elevation: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return 0.0;
                      }
                      return 4.0;
                    }),
                    shadowColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.transparent;
                      }
                      return colorScheme.shadow;
                    }),
                  ),
                  onPressed: widget.searchCloudCiphers,
                  child: Text(
                    'Procurar cifras na nuvem',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        // Display cipher list
        return Stack(
          children: [
            _buildCiphersList(cipherProvider, selectionProvider),
            // Always show the button for animation to work
            _buildBatchDownloadButton(selectionProvider, cipherProvider),
          ],
        );
      },
    );
  }
}
