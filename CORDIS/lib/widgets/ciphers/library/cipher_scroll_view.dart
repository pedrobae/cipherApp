import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/library/cipher_card.dart';
import 'package:cordis/widgets/ciphers/library/cloud_cipher_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CipherScrollView extends StatefulWidget {
  final int? playlistId;

  const CipherScrollView({super.key, this.playlistId});

  @override
  State<CipherScrollView> createState() => _CipherScrollViewState();
}

class _CipherScrollViewState extends State<CipherScrollView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData({bool forceReload = false}) {
    context.read<CipherProvider>().loadLocalCiphers(forceReload: forceReload);
    context.read<VersionProvider>().loadCloudVersions(forceReload: forceReload);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CipherProvider, SelectionProvider, VersionProvider>(
      builder:
          (context, cipherProvider, selectionProvider, versionProvider, child) {
            // Handle loading state
            if (cipherProvider.isLoading || versionProvider.isLoadingCloud) {
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
                    Text(
                      AppLocalizations.of(context)!.errorMessage(
                        AppLocalizations.of(context)!.loading,
                        cipherProvider.error!,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          cipherProvider.loadLocalCiphers(forceReload: true),
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                // Display cipher list
                _buildCiphersList(cipherProvider, versionProvider),

                if (selectionProvider.isSelectionMode) ...[
                  _buildBatchAddButton(selectionProvider, cipherProvider),
                ],
              ],
            );
          },
    );
  }

  Widget _buildCiphersList(
    CipherProvider cipherProvider,
    VersionProvider versionProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return RefreshIndicator(
      onRefresh: () async {
        _loadData(forceReload: true);
      },
      child:
          (cipherProvider.filteredLocalCipherCount == 0 &&
              versionProvider.filteredCloudVersionCount == 0)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noCiphersFound,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              cacheExtent: 500,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  (cipherProvider.filteredLocalCipherCount +
                  versionProvider.filteredCloudVersionCount),
              itemBuilder: (context, index) {
                if (index >= cipherProvider.filteredLocalCipherCount) {
                  final cloudIndex =
                      index - cipherProvider.filteredLocalCipherCount;
                  final version = versionProvider.filteredCloudVersions.values
                      .toList()[cloudIndex];
                  return CloudCipherCard(version: version);
                }

                final cipherList = cipherProvider.filteredLocalCiphers.values
                    .toList();

                final cipher = cipherList[index];
                return CipherCard(cipherId: cipher.id);
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
                    // Handle adding selected versions to playlist
                    for (var versionId in selectionProvider.selectedItems) {
                      await context
                          .read<PlaylistProvider>()
                          .addVersionToPlaylist(widget.playlistId!, versionId);
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
