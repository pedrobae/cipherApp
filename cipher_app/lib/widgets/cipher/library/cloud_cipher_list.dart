import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/widgets/cipher/library/cloud_cipher_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CloudCipherList extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;
  final VoidCallback? searchCloudCiphers;
  final VoidCallback changeTab;
  final Function(int cipherId, int versionId) openCipher;

  const CloudCipherList({
    super.key,
    this.selectionMode = false,
    this.playlistId,
    this.searchCloudCiphers,
    required this.changeTab,
    required this.openCipher,
  });

  @override
  State<CloudCipherList> createState() => _CloudCipherListState();
}

class _CloudCipherListState extends State<CloudCipherList> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataIfNeeded();
  }

  void _loadDataIfNeeded() {
    final cipherProvider = Provider.of<CipherProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cipherProvider.loadCloudCiphers();
      }
    });
  }

  Widget _buildCiphersList(CipherProvider cipherProvider) {
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
          return CloudCipherCard(
            cipher: cipher,
            onDownload: () async {
              await cipherProvider.downloadAndInsertCipher(cipher);
              widget.changeTab();
              widget.openCipher(
                cipherProvider.currentCipher.id!,
                cipherProvider.currentCipher.versions.last.id!,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<CipherProvider>(
      builder: (context, cipherProvider, child) {
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
                      cipherProvider.loadLocalCiphers(forceReload: true),
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
        return _buildCiphersList(cipherProvider);
      },
    );
  }
}
