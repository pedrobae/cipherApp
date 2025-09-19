import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/screens/cipher_editor.dart';
import 'package:flutter/material.dart';
import '../../models/domain/cipher/cipher.dart';
import 'tag_chip.dart';

class CipherCard extends StatelessWidget {
  final Cipher cipher;
  final Function(Version, Cipher)? selectVersion;
  final bool isExpanded;
  final VoidCallback onExpand;

  const CipherCard({
    super.key,
    required this.cipher,
    this.selectVersion,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 4,
      child: ExpansionTile(
        shape: Border(),
        tilePadding: EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        showTrailingIcon: false,
        key: PageStorageKey(cipher.id),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          if (expanded) onExpand;
        },
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
                        cipher.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(cipher.author),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tom: ${cipher.musicKey}'),
                      Text('Tempo: ${cipher.tempo}'),
                    ],
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: cipher.tags
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
                    builder: (context) => EditCipher(
                      cipher: cipher,
                      isNewVersion: true,
                      startTab: 'version',
                    ),
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
              ...cipher.versions.map((version) {
                return GestureDetector(
                  onTap: () => selectVersion?.call(version, cipher),
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
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 16,
                      children: [
                        Text(
                          version.versionName!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          'Tom: ${version.transposedKey}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
