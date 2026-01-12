import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/screens/playlist/playlist_presentation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/screens/cipher/cipher_viewer.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/editor/custom_reorderable_delayed.dart';

class CipherVersionCard extends StatefulWidget {
  final int playlistId;
  final int versionId;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const CipherVersionCard({
    super.key,
    required this.playlistId,
    required this.index,
    required this.versionId,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  State<CipherVersionCard> createState() => _CipherVersionCardState();
}

class _CipherVersionCardState extends State<CipherVersionCard> {
  @override
  void initState() {
    super.initState();
    // Pre-load cipher data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cipherProvider = context.read<CipherProvider>();
      final versionProvider = context.read<VersionProvider>();
      final sectionProvider = context.read<SectionProvider>();

      // Ensure the cipher is loaded (loads all ciphers if not already loaded)
      cipherProvider.loadLocalCiphers();

      // Ensure the specific version is loaded
      if (!versionProvider.isVersionCached(widget.versionId)) {
        await versionProvider.loadVersionById(widget.versionId);
        await sectionProvider.loadSections(widget.versionId);
      }
    });
  }

  void _onReorder(
    BuildContext context,
    List<String> songStructure,
    int oldIndex,
    int newIndex,
  ) {
    // Create updated song structure
    final updatedStructure = List<String>.from(songStructure);
    if (newIndex > oldIndex) newIndex--;
    final item = updatedStructure.removeAt(oldIndex);
    updatedStructure.insert(newIndex, item);

    // Persist to database
    final versionProvider = context.read<VersionProvider>();
    versionProvider.saveUpdatedSongStructure(
      widget.versionId,
      updatedStructure,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VersionProvider>(
      builder: (context, versionProvider, child) {
        final version = versionProvider.getVersionById(widget.versionId)!;

        // If version is not cached yet, show loading indicator
        final songStructure = version.songStructure
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        return Consumer2<CipherProvider, PlaylistProvider>(
          builder: (context, cipherProvider, playlistProvider, child) {
            final cipher = cipherProvider.getCipherFromCache(version.cipherId)!;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistPresentationScreen(
                      playlistId: widget.playlistId,
                      initialSectionIndex: widget.index,
                    ),
                  ),
                );
              },
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.end,
                              spacing: 10,
                              children: [
                                Text(
                                  cipher.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text('Tom: ${version.transposedKey ?? 'N/A'}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // REORDERABLE SECTION CHIPS
                            SizedBox(
                              height: 40,
                              child: ReorderableListView.builder(
                                shrinkWrap: true,
                                proxyDecorator: (child, index, animation) =>
                                    Material(
                                      type: MaterialType.transparency,
                                      child: child,
                                    ),
                                buildDefaultDragHandles: false,
                                physics: const ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: songStructure.length,
                                onReorder: (oldIndex, newIndex) => _onReorder(
                                  context,
                                  songStructure,
                                  oldIndex,
                                  newIndex,
                                ),
                                itemBuilder: (context, index) {
                                  final sectionCode = songStructure[index];
                                  final section =
                                      version.sections![sectionCode];
                                  // To ensure unique keys for identical section codes,
                                  final occurrenceCount = songStructure
                                      .take(index + 1)
                                      .where((code) => code == sectionCode)
                                      .length;

                                  return CustomReorderableDelayed(
                                    delay: Duration(milliseconds: 100),
                                    key: ValueKey(
                                      'cipher_${widget.versionId}_section_${sectionCode}_occurrence_$occurrenceCount',
                                    ),
                                    index: index,
                                    child: SizedBox(
                                      height: 25,
                                      child: Chip(
                                        padding: EdgeInsets.all(1),
                                        visualDensity: VisualDensity(
                                          horizontal:
                                              VisualDensity.minimumDensity,
                                        ),
                                        label: Text(
                                          sectionCode,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor:
                                            section?.contentColor ??
                                            Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'delete':
                              widget.onDelete.call();
                            case 'copy':
                              widget.onCopy.call();
                            case 'edit':
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CipherViewer(
                                    cipherId: cipher.id!,
                                    versionId: version.id!,
                                  ),
                                ),
                              );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'copy',
                            child: Row(
                              children: [
                                Icon(Icons.copy),
                                SizedBox(width: 8),
                                Text('Duplicar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
