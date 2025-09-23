import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/screens/cipher_viewer.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/cipher/editor/custom_reorderable_delayed.dart';

class CipherVersionCard extends StatefulWidget {
  final int cipherVersionId;
  final VoidCallback? onDelete;

  const CipherVersionCard({
    super.key,
    required this.cipherVersionId,
    this.onDelete,
  });

  @override
  State<CipherVersionCard> createState() => _CipherVersionCardState();
}

class _CipherVersionCardState extends State<CipherVersionCard> {
  @override
  void initState() {
    super.initState();
    // Pre-load cipher data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cipherProvider = context.read<CipherProvider>();
      if (cipherProvider.currentCipher.id == null) {
        cipherProvider.loadCipherOfVersion(widget.cipherVersionId);
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
      widget.cipherVersionId,
      updatedStructure,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VersionProvider>(
      builder: (context, versionProvider, child) {
        final version = versionProvider.getCachedVersion(
          widget.cipherVersionId,
        );

        // If version is not cached yet, show loading indicator
        if (version == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final songStructure = version.songStructure
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        return Consumer<CipherProvider>(
          builder: (context, cipherProvider, child) {
            // Check if cipher is already loaded to avoid redundant calls
            if (cipherProvider.currentCipher.id == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                cipherProvider.loadCipherOfVersion(widget.cipherVersionId);
              });
            }

            // Show loading if cipher is not loaded yet
            if (cipherProvider.currentCipher.id == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            return InkWell(
              onTap: () {
                // Add null safety checks before navigation
                if (cipherProvider.currentCipher.id != null &&
                    version.id != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CipherViewer(
                        cipherId: cipherProvider.currentCipher.id!,
                        versionId: version.id!,
                      ),
                    ),
                  );
                }
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
                                  cipherProvider.currentCipher.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text('Tom: ${version.transposedKey ?? 'N/A'}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // REORDERABLE SECTION CHIPS
                            SizedBox(
                              height: 30,
                              child: ReorderableListView.builder(
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

                                  // Count occurrences of this section code up to current index
                                  // to handle multiple instances of same section (e.g., multiple choruses)
                                  final occurrenceCount = songStructure
                                      .take(index + 1)
                                      .where((code) => code == sectionCode)
                                      .length;

                                  return CustomReorderableDelayed(
                                    delay: Duration(milliseconds: 100),
                                    key: ValueKey(
                                      'cipher_${widget.cipherVersionId}_section_${sectionCode}_occurrence_$occurrenceCount',
                                    ),
                                    index: index,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 4),
                                      child: Chip(
                                        padding: EdgeInsets.all(0),
                                        visualDensity: VisualDensity.compact,
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
                              widget.onDelete?.call();
                            case 'copy':
                            //  TODO copy cipher version in playlist, check the DB, repo and provider
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
                                Text('Copiar'),
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
