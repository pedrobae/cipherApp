import 'package:cipher_app/providers/selection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/screens/cipher/cipher_editor.dart';
import 'package:cipher_app/widgets/ciphers/tag_chip.dart';

class CipherCard extends StatefulWidget {
  final Cipher cipher;
  final Function(int, int) onTap;
  final Function(int, int) onLongPress;

  const CipherCard({
    super.key,
    required this.cipher,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<CipherCard> createState() => _CipherCardState();
}

class _CipherCardState extends State<CipherCard> {
  late ExpansibleController _expansionController;

  @override
  void initState() {
    super.initState();
    _expansionController = ExpansibleController();
  }

  Future<void> _handleExpansionChanged(bool expanded) async {
    final versionProvider = Provider.of<VersionProvider>(
      context,
      listen: false,
    );

    if (expanded) {
      // Checks if this cipher is not already expanded before loading
      if (!(versionProvider.expandedCipherId == widget.cipher.id!)) {
        try {
          await versionProvider.loadVersionsOfCipher(widget.cipher.id!);
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao carregar versões: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    } else {
      // Checks if this cipher is the currently expanded one before collapsing
      if (versionProvider.expandedCipherId == widget.cipher.id!) {
        versionProvider.clearVersions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VersionProvider, SelectionProvider>(
      builder: (context, versionProvider, selectionProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final isThisCipherExpanded =
            versionProvider.expandedCipherId == widget.cipher.id!;

        final isLoadingThisCipher =
            versionProvider.isLoading && isThisCipherExpanded;

        // Collapses the tile if this cipher is no longer the expanded one
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isThisCipherExpanded && _expansionController.isExpanded) {
            _expansionController.collapse();
          }
        });

        return GestureDetector(
          onLongPress: () => _editCipher(versionProvider),
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: theme.shadowColor,
                  blurRadius: 1,
                ),
              ],
            ),
            child: ExpansionTile(
              controller: _expansionController,
              shape: Border(),
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              childrenPadding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              showTrailingIcon: false,
              key: PageStorageKey(widget.cipher.id),
              initiallyExpanded: isThisCipherExpanded,
              maintainState: false,
              onExpansionChanged: _handleExpansionChanged,
              title: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                              widget.cipher.title,
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(widget.cipher.author),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tom: ${widget.cipher.musicKey}'),
                            Text('Tempo: ${widget.cipher.tempo}'),
                          ],
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.cipher.tags
                              .map((tag) => TagChip(tag: tag))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                Column(
                  spacing: 4,
                  children: [
                    Divider(height: 3, color: colorScheme.outline),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditCipher(cipherId: widget.cipher.id),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: theme.shadowColor,
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 16,
                          children: [
                            Icon(
                              Icons.library_music,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            Text(
                              'Criar uma Nova Versão',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isLoadingThisCipher)
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (isThisCipherExpanded)
                      ...versionProvider.versions.map((version) {
                        return GestureDetector(
                          onLongPress: () {
                            widget.onLongPress.call(
                              version.id!,
                              widget.cipher.id!,
                            );
                          },
                          onTap: () {
                            widget.onTap.call(version.id!, widget.cipher.id!);
                          },
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: colorScheme.primary,
                                  blurRadius: 1,
                                ),
                              ],
                              color: colorScheme.surfaceContainer,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 16,
                              children: [
                                Expanded(
                                  child: Text(
                                    version.versionName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Tom: ${version.transposedKey}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (selectionProvider.isSelectionMode) ...[
                                  Checkbox(
                                    value: selectionProvider.isItemSelected(
                                      version.id!,
                                    ),
                                    onChanged: (_) {
                                      selectionProvider.toggleItemSelection(
                                        version.id!,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      })
                    else if (isThisCipherExpanded)
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nenhuma versão encontrada',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editCipher(VersionProvider versionProvider) async {
    await versionProvider.loadVersionsOfCipher(widget.cipher.id!);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditCipher(
            cipherId: widget.cipher.id!,
            versionId: versionProvider.versions.first.id!,
            editCipher: true,
          ),
        ),
      );
    }
  }
}
