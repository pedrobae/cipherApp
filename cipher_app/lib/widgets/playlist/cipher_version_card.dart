import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/cipher_viewer.dart';
import '../../models/domain/cipher/cipher.dart';
import '../../providers/cipher_provider.dart';
import '../cipher/editor/custom_reorderable_delayed.dart';

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
  Cipher? _cipher;
  List<String> _songStructureList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCipher();
  }

  Future<void> _loadCipher() async {
    final cipherProvider = context.read<CipherProvider>();
    final cipher = await cipherProvider.getCipherVersionById(
      widget.cipherVersionId,
    );

    if (mounted && cipher != null) {
      setState(() {
        _cipher = cipher;
        _songStructureList = cipher.versions[0].songStructure
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        _isLoading = false;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    // Update UI immediately (optimistic update)
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _songStructureList.removeAt(oldIndex);
      _songStructureList.insert(newIndex, item);
    });

    // Persist to database (async, no UI blocking)
    final cipherProvider = context.read<CipherProvider>();
    final stringStructure = _songStructureList.toString();
    cipherProvider.updateVersionSongStructure(
      _cipher!.versions[0].id!,
      stringStructure.substring(1, stringStructure.length - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_cipher == null) {
      return const Text('Cifra não encontrada');
    }

    final version = _cipher!.versions[0];

    return InkWell(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) =>
              CipherViewer(cipher: _cipher!, version: version),
        ),
      ),
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
                          _cipher!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Tom: ${version.transposedKey ?? _cipher!.musicKey}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // REORDERABLE SECTION CHIPS
                    SizedBox(
                      height: 30,
                      child: ReorderableListView.builder(
                        proxyDecorator: (child, index, animation) => Material(
                          type: MaterialType.transparency,
                          child: child,
                        ),
                        buildDefaultDragHandles: false,
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: _songStructureList.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          final sectionCode = _songStructureList[index];
                          final section = version.sections![sectionCode];

                          return CustomReorderableDelayed(
                            delay: Duration(milliseconds: 100),
                            key: ValueKey('$section-$index'),
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: section!.contentColor.withValues(
                                    alpha: .8,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Theme.of(context).highlightColor,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  child: Center(
                                    child: Text(
                                      section.contentCode,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
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
  }
}
