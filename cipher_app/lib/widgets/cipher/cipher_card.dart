import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/providers/expand_provider.dart';
import 'package:cipher_app/screens/cipher_editor.dart';
import 'package:cipher_app/widgets/cipher/tag_chip.dart';

class CipherCard extends StatefulWidget {
  final Cipher cipher;
  final Function(Version, Cipher)? selectVersion;

  const CipherCard({super.key, required this.cipher, this.selectVersion});

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
    final expandProvider = Provider.of<ExpandProvider>(context, listen: false);

    if (expanded) {
      // Checks if this cipher is not already expanded before loading
      if (!expandProvider.isCipherExpanded(widget.cipher.id!)) {
        try {
          await expandProvider.loadExpandedCipher(widget.cipher.id!);
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao expandir versões: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    } else {
      // Checks if this cipher is the currently expanded one before collapsing
      if (expandProvider.isCipherExpanded(widget.cipher.id!)) {
        expandProvider.clearCache();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpandProvider>(
      builder: (context, expandProvider, child) {
        final expandedCipher = expandProvider.expandedCipher;
        final isThisCipherExpanded = expandProvider.isCipherExpanded(
          widget.cipher.id!,
        );
        final isLoadingThisCipher =
            expandProvider.isLoading &&
            expandProvider.isCipherExpanded(widget.cipher.id!);

        // Collapses the tile if this cipher is no longer the expanded one
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isThisCipherExpanded && _expansionController.isExpanded) {
            _expansionController.collapse();
          }
        });

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            style: Theme.of(context).textTheme.titleLarge,
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
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Theme.of(context).shadowColor,
                            blurRadius: 1,
                          ),
                        ],
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 16,
                        children: [
                          const Icon(Icons.library_music),
                          Text(
                            'Criar uma Nova Versão',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
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
                  else if (isThisCipherExpanded &&
                      expandedCipher!.versions.isNotEmpty)
                    ...expandedCipher.versions.map((version) {
                      return GestureDetector(
                        onTap: () {
                          widget.selectVersion?.call(version, widget.cipher);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 1),
                                color: Theme.of(context).primaryColor,
                                blurRadius: 1,
                              ),
                            ],
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 16,
                            children: [
                              Expanded(
                                child: Text(
                                  version.versionName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              Text(
                                'Tom: ${version.transposedKey}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
