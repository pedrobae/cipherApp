import 'package:cordis/providers/auth_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/widgets/ciphers/library/local_cipher_list.dart';
import 'package:cordis/widgets/ciphers/library/cloud_cipher_list.dart';
import 'package:cordis/screens/cipher/cipher_viewer.dart';

class CipherLibraryScreen extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;

  const CipherLibraryScreen({
    super.key,
    this.selectionMode = false,
    this.playlistId,
  });

  @override
  State<CipherLibraryScreen> createState() => _CipherLibraryScreenState();
}

class _CipherLibraryScreenState extends State<CipherLibraryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late CipherProvider _cipherProvider; // To clear search on dispose
  late VersionProvider _versionProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cipherProvider = Provider.of<CipherProvider>(context, listen: false);
    _versionProvider = Provider.of<VersionProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cipherProvider.clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer6<
      CipherProvider,
      UserProvider,
      AuthProvider,
      PlaylistProvider,
      VersionProvider,
      SelectionProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            userProvider,
            authProvider,
            playlistProvider,
            versionProvider,
            selectionProvider,
            child,
          ) {
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
                    const Tab(
                      text: 'Local',
                      icon: Icon(Icons.my_library_music),
                    ),
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
                          onTap: (int versionId, int cipherId) =>
                              onTapCipherVersion(
                                versionId,
                                cipherId,
                                playlistProvider,
                                userProvider,
                                authProvider,
                                versionProvider,
                                selectionProvider,
                              ),
                          onLongPress: (int versionId, int cipherId) {
                            onLongPressCipherVersion(
                              versionId,
                              cipherId,
                              playlistProvider,
                              userProvider,
                              authProvider,
                              versionProvider,
                              selectionProvider,
                            );
                          },
                          selectionMode: widget.selectionMode,
                          playlistId: widget.playlistId,
                        ),
                        CloudCipherList(
                          searchCloudCiphers: _searchCloudCiphers,
                          changeTab: () {
                            _tabController.index = 0;
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
                            : versionProvider.searchCachedCloudVersions(value);
                      },
                      hint: 'Procure Cifras...',
                      title: widget.selectionMode
                          ? 'Adicionar à Playlist'
                          : null,
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
          },
    );
  }

  void _searchCloudCiphers() {
    _versionProvider.searchCachedCloudVersions(_searchController.text);
  }

  void onTapCipherVersion(
    int versionId,
    int cipherId,
    PlaylistProvider playlistProvider,
    UserProvider userProvider,
    AuthProvider authProvider,
    VersionProvider versionProvider,
    SelectionProvider selectionProvider,
  ) {
    if (widget.selectionMode) {
      try {
        if (selectionProvider.isSelectionMode) {
          selectionProvider.toggleItemSelection(versionId);
          return;
        }
        playlistProvider.addVersionToPlaylist(
          widget.playlistId!,
          versionId,
          userProvider.getLocalIdByFirebaseId(authProvider.id!)!,
        );
        versionProvider.loadVersionsForPlaylist(
          playlistProvider.currentPlaylist!.items,
        );
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

  Future<void> onLongPressCipherVersion(
    int versionId,
    int cipherId,
    PlaylistProvider playlistProvider,
    UserProvider userProvider,
    AuthProvider authProvider,
    VersionProvider versionProvider,
    SelectionProvider selectionProvider,
  ) async {
    if (!widget.selectionMode) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CipherViewer(cipherId: cipherId, versionId: versionId),
        ),
      );
    } else {
      selectionProvider.enableSelectionMode();
      selectionProvider.toggleItemSelection(versionId);
    }
  }
}
