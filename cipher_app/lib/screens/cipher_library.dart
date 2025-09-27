import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/widgets/search_app_bar.dart';
import 'package:cipher_app/widgets/cipher/cipher_card.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/screens/cipher_viewer.dart';
import 'package:cipher_app/screens/cipher_editor.dart';

class CipherLibraryScreen extends StatefulWidget {
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
  State<CipherLibraryScreen> createState() => _CipherLibraryScreenState();

  static void clearSearchFromOutside(BuildContext context) {
    context.read<CipherProvider>().clearSearch();
  }
}

class _CipherLibraryScreenState extends State<CipherLibraryScreen> {
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

  void _selectVersion(int versionId, int cipherId) {
    if (widget.selectionMode) {
      try {
        context.read<PlaylistProvider>().addCipherMap(
          widget.playlistId!,
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.selectionMode
          ? AppBar(title: const Text('Adicionar à Playlist'))
          : null,
      body: Consumer<CipherProvider>(
        builder: (context, cipherProvider, child) {
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
        },
      ),
      floatingActionButton: widget.selectionMode
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
          return CipherCard(cipher: cipher, selectVersion: _selectVersion);

          // In selection mode, we can't filter by versions until they're loaded
          // The filtering will happen in the CipherCard when versions are expanded
          // For now, show all ciphers and let user expand to see available versions
        },
      ),
    );
  }
}
