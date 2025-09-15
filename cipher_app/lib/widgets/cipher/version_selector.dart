import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:flutter/material.dart';

class VersionSelectorBottomSheet extends StatelessWidget {
  final List<Version> versions;
  final Version currentVersion;
  final Function(Version) onVersionSelected;
  final VoidCallback onNewVersion;

  const VersionSelectorBottomSheet({
    super.key,
    required this.versions,
    required this.currentVersion,
    required this.onVersionSelected,
    required this.onNewVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Icon(Icons.library_music),
              ),
              Text(
                'Versões da Cifra',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onNewVersion();
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (versions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhuma versão encontrada',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              itemCount: versions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final version = versions[index];
                final isSelected = version.id == currentVersion.id;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.music_note,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    version.versionName ?? 'Versão ${index + 1}',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (version.createdAt != null)
                        Text(
                          'Criada em ${_formatDate(version.createdAt!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.radio_button_checked,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.radio_button_unchecked),
                  onTap: () {
                    Navigator.pop(context);
                    onVersionSelected(version);
                  },
                );
              },
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
