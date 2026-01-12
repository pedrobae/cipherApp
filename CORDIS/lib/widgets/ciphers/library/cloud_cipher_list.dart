import 'package:cordis/models/domain/cipher/section.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/screens/cipher/cloud_version_viewer.dart';
import 'package:cordis/widgets/ciphers/library/cloud_cipher_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: REFACTOR THIS WIDGET - VERSION PROVIDER USAGE, ETC.
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
    final vp = Provider.of<VersionProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        vp.loadCloudVersions();
      }
    });
  }

  Widget _buildCiphersList(
    VersionProvider vp,
    SelectionProvider selectionProvider,
    SectionProvider sectionProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await vp.loadCloudVersions(forceReload: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(4),
        cacheExtent: 200,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: vp.filteredCloudVersions.length,
        itemBuilder: (context, index) {
          // Add bounds checking
          if (index >= vp.filteredCloudVersions.length) {
            return const SizedBox.shrink();
          }

          final versionDto = vp.filteredCloudVersions.values.elementAt(index);
          return GestureDetector(
            onLongPress: () => {
              selectionProvider.enableSelectionMode(),
              selectionProvider.toggleItemSelection(versionDto),
            },
            child: CloudCipherCard(
              version: versionDto,
              onTap: () {
                if (selectionProvider.isSelectionMode) {
                  selectionProvider.toggleItemSelection(versionDto);
                  return;
                }
                // Normal tap action
                sectionProvider.setNewSectionsInCache(
                  versionDto.firebaseId,
                  versionDto.sections.map(
                    (code, content) =>
                        MapEntry(code, Section.fromFirestore(content)),
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CloudVersionViewer(versionId: versionDto.firebaseId!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBatchDownloadButton(SelectionProvider selectionProvider) {
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
                    // TODO: Implement batch selection logic
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

    return Consumer3<VersionProvider, SelectionProvider, SectionProvider>(
      builder: (context, vp, selectionProvider, sectionProvider, child) {
        // Handle loading state
        if (vp.isLoadingCloud) {
          return const Center(child: CircularProgressIndicator());
        }
        // Handle error state
        if (vp.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text('${vp.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vp.loadCloudVersions(forceReload: true),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (vp.filteredCloudVersions.isEmpty) {
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
            _buildCiphersList(vp, selectionProvider, sectionProvider),
            // Always show the button for animation to work
            _buildBatchDownloadButton(selectionProvider),
          ],
        );
      },
    );
  }
}
