import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/screens/cipher/cipher_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CipherCard extends StatefulWidget {
  final int cipherId;

  const CipherCard({super.key, required this.cipherId});

  @override
  State<CipherCard> createState() => _CipherCardState();
}

class _CipherCardState extends State<CipherCard> {
  @override
  void initState() {
    super.initState();
    context.read<VersionProvider>().loadVersionsOfCipher(widget.cipherId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<CipherProvider, VersionProvider>(
      builder: (context, cipherProvider, versionProvider, child) {
        final cipher = cipherProvider.getCipherFromCache(widget.cipherId)!;
        final versionCount = versionProvider.getVersionsOfCipherCount(
          widget.cipherId,
        );
        // Error handling
        if (cipherProvider.error != null || versionProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppLocalizations.of(context)!.errorPrefix}${cipherProvider.error ?? versionProvider.error}',
            ),
          );
        }

        // Card content
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.surfaceContainerHigh),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CipherViewer(cipherId: cipher.id!),
                    ),
                  );
                },
                child:
                    // INFO
                    Expanded(
                      child: Column(
                        spacing: 2.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cipher.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            spacing: 16.0,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.musicKey}: ${cipher.musicKey}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              cipher.tempo != ''
                                  ? Text(
                                      cipher.tempo,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    )
                                  : Text('-'),
                              cipher.duration != null
                                  ? Text(
                                      cipher.duration!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    )
                                  : Text('-'),
                            ],
                          ),
                          Text(
                            '$versionCount${AppLocalizations.of(context)!.versions}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLowest,
                                ),
                          ),
                        ],
                      ),
                    ),
              ),
              // ACTIONS
              IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
            ],
          ),
        );
      },
    );
  }
}
