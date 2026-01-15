import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/screens/cipher/cipher_editor.dart';
import 'package:cordis/widgets/settings/layout_settings.dart';
import 'package:cordis/widgets/ciphers/viewer/content_section.dart';
import 'package:cordis/widgets/ciphers/viewer/version_header.dart';
import 'package:cordis/widgets/ciphers/viewer/version_selector.dart';

class CipherViewer extends StatefulWidget {
  final int? cipherId;
  final int? versionId;
  final VersionType versionType;

  const CipherViewer({
    super.key,
    required this.cipherId,
    this.versionId,
    required this.versionType,
  });

  @override
  State<CipherViewer> createState() => _CipherViewerState();
}

class _CipherViewerState extends State<CipherViewer>
    with SingleTickerProviderStateMixin {
  bool _hasSetOriginalKey = false;
  late int versionId;

  @override
  void initState() {
    super.initState();
    switch (widget.versionType) {
      case VersionType.import:
      case VersionType.brandNew:
        versionId = -1;
        break;
      case VersionType.local:
        versionId =
            widget.versionId ??
            context.read<VersionProvider>().getIdOfOldestVersionOfCipher(
              widget.cipherId!,
            );
        break;
      case VersionType.cloud:
        versionId = widget.versionId!;
        break;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final sectionProvider = context.read<SectionProvider>();
    await sectionProvider.loadSections(versionId);
  }

  void _addNewVersion() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CipherEditor(
          cipherId: widget.cipherId,
          versionId: -1,
          versionType: VersionType.brandNew,
        ),
      ),
    );
  }

  void _editCurrentVersion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CipherEditor(
          cipherId: widget.cipherId,
          versionId: widget.versionId,
          versionType: widget.versionType,
        ),
      ),
    );
  }

  void _selectVersion(int versionId) async {
    if (!mounted) return;
    final versionProvider = context.read<VersionProvider>();
    final sectionProvider = context.read<SectionProvider>();
    await versionProvider.loadVersion(versionId);
    await sectionProvider.loadSections(versionId);
  }

  void _showVersionSelector(VersionProvider versionProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => VersionSelectorBottomSheet(
        versionIds: versionProvider.getVersionsByCipherId(
          widget.cipherId!,
        ), // TODO switch on version type
        currentVersionId: versionId,
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

    return Consumer4<
      CipherProvider,
      VersionProvider,
      SectionProvider,
      LayoutSettingsProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            versionProvider,
            sectionProvider,
            settings,
            child,
          ) {
            // Handle loading states
            if (cipherProvider.isLoading || versionProvider.isLoading) {
              return Scaffold(
                appBar: AppBar(title: const Text('Carregando...')),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            // Handle error states
            if (cipherProvider.error != null ||
                versionProvider.error != null ||
                sectionProvider.error != null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Erro')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro: ${cipherProvider.error ?? versionProvider.error ?? sectionProvider.error}',
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

            final cipher = cipherProvider.getCipherById(
              widget.cipherId!,
            ); // TODO switch on version type
            final currentVersion = versionProvider.getVersionById(versionId)!;
            final hasVersions = cipher!.versions.isNotEmpty;

            // Set original key for transposer
            if (!_hasSetOriginalKey && cipher.musicKey.isNotEmpty) {
              _hasSetOriginalKey = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                settings.setOriginalKey(cipher.musicKey);
              });
            }

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    Text(
                      cipher.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'por ${cipher.author}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
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
                      onPressed: () => _showVersionSelector(versionProvider),
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
                              versionId: currentVersion.id!,
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
