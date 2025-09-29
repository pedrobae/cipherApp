import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/widgets/cipher/cipher_card.dart';
import 'package:cipher_app/widgets/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocalCipherList extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;
  final Function(int versionId, int cipherId) selectVersion;

  const LocalCipherList({
    super.key,
    this.selectionMode = false,
    this.playlistId,
    required this.selectVersion,
  });

  @override
  State<LocalCipherList> createState() => _LocalCipherListState();
}

class _LocalCipherListState extends State<LocalCipherList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataIfNeeded();
  }

  void _loadDataIfNeeded() {
    final cipherProvider = Provider.of<CipherProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cipherProvider.loadCiphers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cipherProvider = Provider.of<CipherProvider>(context);

    return Column(
      children: [
        SearchAppBar(
          searchController: _searchController,
          onSearchChanged: (value) {
            cipherProvider.searchCiphers(value);
          },
          hint: 'Procure Cifras...',
          title: widget.selectionMode ? 'Adicionar à Playlist' : null,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await cipherProvider.loadCiphers(forceReload: true);
            },
            child: _buildContent(cipherProvider),
          ),
        ),
      ],
    );
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
              onPressed: () => cipherProvider.loadCiphers(forceReload: true),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }
    // Handle empty state
    if ((cipherProvider.localCiphers + cipherProvider.cloudCiphers).isEmpty) {
      return Center(
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
      );
    }
    // Display filtered ciphers list for selection mode
    return _buildCiphersList(cipherProvider);
  }

  Widget _buildCiphersList(CipherProvider cipherProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          return CipherCard(
            cipher: cipher,
            selectVersion: widget.selectVersion,
          );

          // In selection mode, we can't filter by versions until they're loaded
          // The filtering will happen in the CipherCard when versions are expanded
          // For now, show all ciphers and let user expand to see available versions
        },
      ),
    );
  }
}
