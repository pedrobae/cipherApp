import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/screens/cipher_editor.dart';
import 'package:cipher_app/widgets/cipher/tag_chip.dart';

class CipherCard extends StatefulWidget {
  final Cipher cipher;
  final Function(int, int) selectVersion;

  const CipherCard({
    super.key,
    required this.cipher,
    required this.selectVersion,
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
    return Consumer<VersionProvider>(
      builder: (context, versionProvider, child) {
        final theme = Theme.of(context);
        final versions = versionProvider.versions;
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

        return Card(
          color: theme.colorScheme.surfaceContainerHighest,
          elevation: 4,
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
                  Divider(height: 4, thickness: 1.5),
                  SizedBox(height: 2),
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
                        color: theme.colorScheme.primaryContainer,
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
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          Text(
                            'Criar uma Nova Versão',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
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
                  else if (isThisCipherExpanded && versions.isNotEmpty == true)
                    ...versions.map((version) {
                      return GestureDetector(
                        onTap: () {
                          widget.selectVersion.call(
                            version.id!,
                            widget.cipher.id!,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 1),
                                color: theme.primaryColor,
                                blurRadius: 1,
                              ),
                            ],
                            color: theme.colorScheme.surfaceContainer,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 16,
                            children: [
                              Expanded(
                                child: Text(
                                  version.versionName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                'Tom: ${version.transposedKey}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
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
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
