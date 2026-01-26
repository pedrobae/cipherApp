import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/screens/cipher/view_cipher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/selection_provider.dart';

class CloudCipherCard extends StatelessWidget {
  final VersionDto version;
  final int? playlistId;

  const CloudCipherCard({super.key, required this.version, this.playlistId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<SelectionProvider, NavigationProvider>(
      builder: (context, selectionProvider, navigationProvider, child) {
        return GestureDetector(
          onTap: () {
            navigationProvider.push(
              ViewCipherScreen(
                cipherId: null,
                versionId: version.firebaseId!,
                versionType: VersionType.cloud,
              ),
              showAppBar: false,
              showDrawerIcon: false,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.surfaceContainerLowest),
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
                          version.bpm != 0
                              ? Text(
                                  version.bpm.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                )
                              : Text('-'),
                          version.duration != 0
                              ? Text(
                                  version.duration.toString(),
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
          ),
        );
      },
    );
  }
}
