import 'package:cipher_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:cipher_app/providers/selection_provider.dart';

class CloudCipherCard extends StatelessWidget {
  final CipherDto cipher;

  const CloudCipherCard({super.key, required this.cipher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<SelectionProvider>(
      builder: (context, selectionProvider, child) {
        return Container(
          margin: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.surfaceContainerHigh),
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
                          '${AppLocalizations.of(context)!.musicKey}: ${cipher.musicKey}',
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
                      AppLocalizations.of(context)!.cloudCipher,
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
              IconButton(onPressed: () {}, icon: Icon(Icons.cloud_download)),
            ],
          ),
        );
      },
    );
  }
}
