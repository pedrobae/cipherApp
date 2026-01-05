import 'package:cipher_app/l10n/app_localizations.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VersionCard extends StatelessWidget {
  const VersionCard({
    super.key,
    required this.versionId,
    required this.cipherId,
  });
  final int versionId;
  final int cipherId;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CipherProvider, VersionProvider>(
      builder: (context, cipherProvider, versionProvider, child) {
        final version = versionProvider.getCachedVersionById(versionId);
        final cipher = cipherProvider.getCachedCipherById(cipherId);
        // Error handling
        if (cipherProvider.error != null || versionProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppLocalizations.of(context)!.errorPrefix}${cipherProvider.error ?? versionProvider.error}',
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
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
                          '${AppLocalizations.of(context)!.musicKey}: ${version.transposedKey ?? cipher.musicKey}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        cipher.tempo != ''
                            ? Text(
                                cipher.tempo,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            : Text('-'),
                        cipher.duration != null
                            ? Text(
                                cipher.duration!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            : Text('-'),
                      ],
                    ),
                    Text(
                      version.versionName,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLowest,
                      ),
                    ),
                  ],
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
