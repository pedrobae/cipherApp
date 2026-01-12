import 'package:cordis/providers/section_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/settings/layout_settings.dart';
import 'package:cordis/widgets/ciphers/viewer/content_section.dart';

class CloudVersionViewer extends StatefulWidget {
  final String versionId;

  const CloudVersionViewer({super.key, required this.versionId});

  @override
  State<CloudVersionViewer> createState() => _CloudVersionViewerState();
}

class _CloudVersionViewerState extends State<CloudVersionViewer>
    with SingleTickerProviderStateMixin {
  bool _hasSetOriginalKey = false;

  void _editCurrentVersion() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditCipher(versionId: widget.versionId),
    //   ),
    // );
  }

  void _showLayoutSettings() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: LayoutSettings(
              includeTransposer: true,
              includeFilters: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer3<VersionProvider, SectionProvider, LayoutSettingsProvider>(
      builder: (context, versionProvider, sectionProvider, settings, child) {
        // Handle loading states
        if (versionProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Carregando...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error states
        if (versionProvider.error != null || sectionProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erro: ${versionProvider.error ?? sectionProvider.error}',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentVersion = versionProvider.getCloudVersionByFirebaseId(
          widget.versionId,
        )!;

        // Set original key for transposer
        if (!_hasSetOriginalKey) {
          _hasSetOriginalKey = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            settings.setOriginalKey(
              currentVersion.transposedKey ?? currentVersion.originalKey,
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(
                  currentVersion.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'por ${currentVersion.author}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              if (currentVersion.firebaseId != null) ...[
                IconButton(
                  onPressed: _showLayoutSettings,
                  icon: const Icon(Icons.remove_red_eye),
                  tooltip: 'Layout Settings',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: _editCurrentVersion,
                ),
              ],
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cipher content section
              if (currentVersion.songStructure.isNotEmpty) ...[
                Expanded(
                  child: CipherContentSection(
                    versionId: currentVersion.firebaseId!,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
