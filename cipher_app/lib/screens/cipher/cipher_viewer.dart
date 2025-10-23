import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/screens/cipher/cipher_editor.dart';
import 'package:cipher_app/widgets/settings/layout_settings.dart';
import 'package:cipher_app/widgets/cipher/viewer/content_section.dart';
import 'package:cipher_app/widgets/cipher/viewer/version_header.dart';
import 'package:cipher_app/widgets/cipher/viewer/version_selector.dart';

class CipherViewer extends StatefulWidget {
  final int cipherId;
  final int versionId;

  const CipherViewer({
    super.key,
    required this.cipherId,
    required this.versionId,
  });

  @override
  State<CipherViewer> createState() => _CipherViewerState();
}

class _CipherViewerState extends State<CipherViewer>
    with SingleTickerProviderStateMixin {
  bool _hasSetOriginalKey = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final cipherProvider = context.read<CipherProvider>();
    final versionProvider = context.read<VersionProvider>();

    await cipherProvider.loadCipher(widget.cipherId);
    await versionProvider.loadVersionById(widget.versionId);
  }

  void _addNewVersion() {
    final cipherProvider = context.read<CipherProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditCipher(cipherId: cipherProvider.currentCipher.id),
      ),
    );
  }

  void _editCurrentVersion() {
    final cipherProvider = context.read<CipherProvider>();
    final versionProvider = context.read<VersionProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCipher(
          cipherId: cipherProvider.currentCipher.id,
          versionId: versionProvider.currentVersion.id,
        ),
      ),
    );
  }

  void _selectVersion(int versionId) {
    if (!mounted) return;
    final versionProvider = context.read<VersionProvider>();
    versionProvider.loadVersionById(versionId);
  }

  void _showVersionSelector() {
    final cipherProvider = context.read<CipherProvider>();
    final versionProvider = context.read<VersionProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) => VersionSelectorBottomSheet(
        currentVersion: versionProvider.currentVersion,
        versions: cipherProvider.currentCipher.versions,
        onVersionSelected: _selectVersion,
        onNewVersion: _addNewVersion,
      ),
    );
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

    return Consumer3<CipherProvider, VersionProvider, LayoutSettingsProvider>(
      builder: (context, cipherProvider, versionProvider, settings, child) {
        // Handle loading states
        if (cipherProvider.isLoading || versionProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Carregando...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error states
        if (cipherProvider.error != null || versionProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erro: ${cipherProvider.error ?? versionProvider.error}',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentCipher = cipherProvider.currentCipher;
        final currentVersion = versionProvider.currentVersion;

        // Safety check for data integrity
        if (currentCipher.id == null || currentVersion.id == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Carregando...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final hasVersions = currentCipher.versions.isNotEmpty;

        // Set original key for transposer
        if (!_hasSetOriginalKey && currentCipher.musicKey.isNotEmpty) {
          _hasSetOriginalKey = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            settings.setOriginalKey(currentCipher.musicKey);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(
                  currentCipher.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'por ${currentCipher.author}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              if (hasVersions && currentVersion.id != null) ...[
                IconButton(
                  onPressed: _showLayoutSettings,
                  icon: const Icon(Icons.remove_red_eye),
                  tooltip: 'Layout Settings',
                ),
                IconButton(
                  icon: const Icon(Icons.library_music),
                  tooltip: 'Versões',
                  onPressed: _showVersionSelector,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: _editCurrentVersion,
                ),
              ] else
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Criar primeira versão',
                  onPressed: _addNewVersion,
                ),
            ],
          ),
          body: hasVersions && currentVersion.id != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: CipherVersionHeader(
                        currentVersion: currentVersion,
                      ),
                    ),
                    // Cipher content section
                    if (currentVersion.songStructure.isNotEmpty) ...[
                      Expanded(
                        child: CipherContentSection(
                          cipher: currentCipher,
                          currentVersion: currentVersion,
                          columnCount: settings.columnCount,
                        ),
                      ),
                    ],
                  ],
                )
              : _buildEmptyState(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Nenhuma versão disponível',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta cifra ainda não possui conteúdo.\nCrie a primeira versão para começar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _addNewVersion,
              icon: const Icon(Icons.add),
              label: const Text('Criar primeira versão'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
