import 'package:cipher_app/widgets/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/playlist_provider.dart';
import 'package:cipher_app/widgets/cipher/library/local_cipher_list.dart';
import 'package:cipher_app/widgets/cipher/library/cloud_cipher_list.dart';
import 'package:cipher_app/screens/cipher_viewer.dart';

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
}

class _CipherLibraryScreenState extends State<CipherLibraryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late CipherProvider _cipherProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cipherProvider = Provider.of<CipherProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cipherProvider.clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cipherProvider = Provider.of<CipherProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: widget.selectionMode
          ? AppBar(
              title: const Text('Adicionar à Playlist'),
              backgroundColor: colorScheme.surface,
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: .3),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Local', icon: Icon(Icons.my_library_music)),
            const Tab(text: 'Cloud', icon: Icon(Icons.cloud)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: TabBarView(
              controller: _tabController,
              children: [
                LocalCipherList(
                  onTap: (int versionId, int cipherId) {
                    if (widget.selectionMode) {
                      try {
                        context.read<PlaylistProvider>().addCipherMap(
                          widget.playlistId!,
                          versionId,
                        );
                        Navigator.pop(context);
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao adicionar à playlist: $error',
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CipherViewer(
                            cipherId: cipherId,
                            versionId: versionId,
                          ),
                        ),
                      );
                    }
                  },
                ),
                CloudCipherList(
                  searchCloudCiphers: _searchCloudCiphers,
                  changeTab: () {
                    _tabController.index = 0;
                  },
                  openCipher: (int cipherId, int versionId) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CipherViewer(
                          cipherId: cipherId,
                          versionId: versionId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: kToolbarHeight,
            child: SearchAppBar(
              searchController: _searchController,
              onSearchChanged: (value) {
                _tabController.index == 0
                    ? cipherProvider.searchLocalCiphers(value)
                    : cipherProvider.searchCachedCloudCiphers(value);
              },
              hint: 'Procure Cifras...',
              title: widget.selectionMode ? 'Adicionar à Playlist' : null,
            ),
          ),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              return _tabController.index == 1
                  ? Positioned(
                      right: 0,
                      top: 3,
                      child: IconButton(
                        icon: Icon(
                          Icons.cloud_download,
                          color: Theme.of(context).colorScheme.primary,
                          size: kToolbarHeight / 1.5,
                        ),
                        tooltip: 'Procurar na Nuvem',
                        onPressed: _searchCloudCiphers,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _searchCloudCiphers() {
    _cipherProvider.searchCloudCiphers(_searchController.text);
  }
}
