import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/screens/cipher_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/cipher/cipher_card.dart';
import '../providers/cipher_provider.dart';
import '../providers/playlist_provider.dart';
import 'cipher_editor.dart';

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
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataIfNeeded();
  }

  void _loadDataIfNeeded() {
    final cipherProvider = Provider.of<CipherProvider>(context, listen: false);
    if (!_hasInitialized && !cipherProvider.hasLoadedCiphers && mounted) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cipherProvider.loadCiphers();
        }
      });
    }
  }

  void _selectVersion(Version version, Cipher cipher) {
    if (widget.selectionMode) {
      context.read<PlaylistProvider>().addCipherMap(
        widget.playlistId!,
        version.id!,
      );

      context.read<CipherProvider>().clearSearch();

      Navigator.pop(context);
    } else {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CipherViewer(cipher: cipher, version: version),
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
              _buildContent(cipherProvider),
            ],
          );
        },
      ),
      floatingActionButton: widget.selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
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
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    // Handle error state
    if (cipherProvider.error != null) {
      return Expanded(
        child: Center(
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
                onPressed: () => cipherProvider.loadCiphers(),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Handle empty state
    if (cipherProvider.ciphers.isEmpty) {
      return Expanded(
        child: Center(
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
      );
    }

    // Display filtered ciphers list for selection mode
    return _buildCiphersList(cipherProvider);
  }

  Widget _buildCiphersList(CipherProvider cipherProvider) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          cacheExtent: 200,
          physics: const BouncingScrollPhysics(),
          itemCount: cipherProvider.ciphers.length,
          itemBuilder: (context, index) {
            // Add bounds checking
            if (index >= cipherProvider.ciphers.length) {
              return const SizedBox.shrink();
            }

            final cipher = cipherProvider.ciphers[index];

            // In selection mode, filter out ciphers with all versions already added
            if (widget.selectionMode && widget.excludeVersionIds != null) {
              final availableVersions = cipher.versions
                  .where(
                    (version) =>
                        !widget.excludeVersionIds!.contains(version.id),
                  )
                  .toList();

              // Hide cipher if no available versions
              if (availableVersions.isEmpty) {
                return const SizedBox.shrink();
              }
            }

            return CipherCard(
              cipher: cipher,
              isExpanded: cipherProvider.expandedCipher?.id == cipher.id,
              onExpand: () => cipherProvider.toggleExpandCipher(cipher.id!),
              selectVersion: _selectVersion,
            );
          },
        ),
      ),
    );
  }
}
