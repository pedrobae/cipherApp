import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/selection_provider.dart';

class CloudCipherCard extends StatelessWidget {
  final VersionDto version;

  const CloudCipherCard({super.key, required this.version});

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
                      version.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      spacing: 16.0,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.musicKey}: ${version.transposedKey ?? version.originalKey}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        version.bpm != ''
                            ? Text(
                                version.bpm,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            : Text('-'),
                        version.bpm != ''
                            ? Text(
                                version.bpm,
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
