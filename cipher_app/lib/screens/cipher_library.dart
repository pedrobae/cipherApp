import 'package:cipher_app/models/domain/cipher.dart';
import 'package:cipher_app/screens/cipher_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/cipher/cipher_card.dart';
import '../providers/cipher_provider.dart';
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
  final Set<int> _selectedVersionIds = {};

  int? _expandedCipherId;

  void _onExpand(int cipherId) {
    setState(() {
      _expandedCipherId = cipherId;
    });
  }

  void _selectVersion(CipherVersion version, Cipher cipher) {
    if (widget.selectionMode) {}
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CipherViewer(cipher: cipher, version: version),
      ),
    );
  }

  void _loadDataIfNeeded() {
    if (!_hasInitialized && mounted) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CipherProvider>().loadCiphers();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadDataIfNeeded();
    return Scaffold(
      appBar: widget.selectionMode
          ? AppBar(title: const Text('Adicionar à Playlist'))
          : null,
      body: Column(
        children: [
          SearchAppBar(
            searchController: _searchController,
            onSearchChanged: (value) {
              context.read<CipherProvider>().searchCiphers(value);
            },
            hint: 'Procure Cifras...',
            title: widget.selectionMode ? 'Adicionar à Playlist' : null,
          ),
          Consumer<CipherProvider>(
            builder: (context, cipherProvider, child) {
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
                      Text('Erro: ${cipherProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => cipherProvider.loadCiphers(),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              // Handle empty state
              if (cipherProvider.ciphers.isEmpty) {
                return const Center(child: Text('Nenhuma cifra encontrada'));
              }

              // Display ciphers
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    cacheExtent: 200,
                    physics:
                        const BouncingScrollPhysics(), // Smoother scrolling
                    itemCount: cipherProvider.ciphers.length,
                    itemBuilder: (context, index) {
                      // Add bounds checking
                      if (index >= cipherProvider.ciphers.length) {
                        return const SizedBox.shrink();
                      }

                      final cipher = cipherProvider.ciphers[index];

                      // In selection mode, filter out already added versions
                      if (widget.selectionMode &&
                          widget.excludeVersionIds != null) {
                        final hasExcludedVersions = cipher.maps.any(
                          (version) =>
                              widget.excludeVersionIds!.contains(version.id),
                        );
                        if (hasExcludedVersions) {
                          return const SizedBox.shrink();
                        }
                      }

                      return CipherCard(
                        cipher: cipher,
                        isExpanded: _expandedCipherId == cipher.id,
                        onExpand: () => _onExpand(cipher.id!),
                        selectVersion: _selectVersion,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
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

  void _addSelectedToPlaylist() {
    if (widget.playlistId == null || _selectedVersionIds.isEmpty) return;

    // TODO: Add selected versions to playlist
    // final playlistProvider = context.read<PlaylistProvider>();
    // for (final versionId in _selectedVersionIds) {
    //   playlistProvider.addCipherMapToPlaylist(widget.playlistId!, versionId);
    // }

    // Return to playlist viewer
    Navigator.pop(context);
  }
}
