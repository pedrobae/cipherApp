import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/widgets/cipher/library/cloud_cipher_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CloudCipherList extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;

  const CloudCipherList({
    super.key,
    this.selectionMode = false,
    this.playlistId,
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
        cacheExtent: 200,
        physics: const BouncingScrollPhysics(),
        itemCount: cipherProvider.filteredCloudCiphers.length,
        itemBuilder: (context, index) {
          // Add bounds checking
          if (index >= cipherProvider.filteredCloudCiphers.length) {
            return const SizedBox.shrink();
          }

          final cipher = cipherProvider.filteredCloudCiphers[index];
          return CloudCipherCard(cipher: cipher, onDownload: () {});

          // In selection mode, we can't filter by versions until they're loaded
          // The filtering will happen in the CipherCard when versions are expanded
          // For now, show all ciphers and let user expand to see available versions
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
                  ),
                  onPressed: () {},
                  child: Text(
                    'Procurar cifra na nuvem',
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
