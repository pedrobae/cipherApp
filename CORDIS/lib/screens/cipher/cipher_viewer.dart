import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/screens/cipher/cipher_editor.dart';
import 'package:cordis/widgets/settings/layout_settings.dart';
import 'package:cordis/widgets/ciphers/viewer/content_view.dart';

class CipherViewer extends StatefulWidget {
  final int? cipherId;
  final dynamic versionId;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final sectionProvider = context.read<SectionProvider>();
    final versionProvider = context.read<VersionProvider>();

    switch (widget.versionType) {
      case VersionType.import:
      case VersionType.brandNew:
        break;
      case VersionType.local:
        if (widget.versionId != null) {
          await sectionProvider.loadLocalSections(widget.versionId);
        }
        break;
      case VersionType.cloud:
        if (widget.versionId != null) {
          final version = versionProvider.getCloudVersionByFirebaseId(
            widget.versionId,
          );
          sectionProvider.setNewSectionsInCache(
            widget.versionId,
            version!.toDomain().sections!,
          );
        }
        break;
      case VersionType.playlist:
        // THROW EXCEPTION. YOU CANNOT OPEN THE VIEWER FOR A PLAYLIST VERSION
        throw Exception('Cannot open CipherViewer for a playlist version.');
    }
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

  void _editCurrentVersion(NavigationProvider navigationProvider) {
    navigationProvider.push(
      CipherEditor(
        cipherId: widget.cipherId,
        versionId: widget.versionId,
        versionType: widget.versionType,
      ),
      showAppBar: false,
      showDrawerIcon: false,
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

    return Consumer5<
      CipherProvider,
      VersionProvider,
      SectionProvider,
      LayoutSettingsProvider,
      NavigationProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            versionProvider,
            sectionProvider,
            settings,
            navigationProvider,
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

            Cipher? cipher;
            if (widget.cipherId != null) {
              cipher = cipherProvider.getCipherById(widget.cipherId!);
            }

            dynamic version = versionProvider.getVersionById(
              widget.versionId,
            ); // Version or VersionDTO

            // Set original key for transposer
            if (!_hasSetOriginalKey) {
              if (widget.versionType == VersionType.cloud) {
                settings.setOriginalKey(version.originalKey ?? '');
                _hasSetOriginalKey = true;
              } else {
                settings.setOriginalKey(cipher!.musicKey);
                _hasSetOriginalKey = true;
              }
            }

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    Text(
                      cipher?.title ?? version.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.by} ${cipher?.author ?? version.author}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: _showLayoutSettings,
                    icon: const Icon(Icons.remove_red_eye),
                    tooltip: 'Layout Settings',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    onPressed: () => _editCurrentVersion(navigationProvider),
                  ),
                ],
              ),
              body: ContentView(versionId: widget.versionId),
            );
          },
    );
  }
}
