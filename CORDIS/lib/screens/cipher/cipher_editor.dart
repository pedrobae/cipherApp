import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/parser_provider.dart';
import 'package:cordis/widgets/ciphers/editor/chord_palette.dart';
import 'package:cordis/widgets/ciphers/editor/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/widgets/ciphers/editor/info_tab.dart';
import 'package:cordis/widgets/ciphers/editor/sections_tab.dart';

class CipherEditor extends StatefulWidget {
  final int? cipherId; // Null for new cipher
  final dynamic versionId; // Null for new version // could be int or String
  final VersionType versionType;

  const CipherEditor({
    super.key,
    this.cipherId,
    this.versionId,
    required this.versionType,
  });

  @override
  State<CipherEditor> createState() => _CipherEditorState();
}

class _CipherEditorState extends State<CipherEditor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool paletteIsOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data
    _loadData();

    // Navigate to start tab after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateStartTab();
    });

    _tabController.addListener(() {
      // Setting state to trigger rebuild
      setState(() {
        paletteIsOpen = false;
      });
    });
  }

  Future<void> _loadData() async {
    final cipherProvider = context.read<CipherProvider>();
    final versionProvider = context.read<VersionProvider>();
    final parserProvider = context.read<ParserProvider>();
    final sectionProvider = context.read<SectionProvider>();

    switch (widget.versionType) {
      case VersionType.import:
        // Load imported cipher data
        final cipher = parserProvider.parsedCipher!;

        cipherProvider.setNewCipherInCache(cipher);
        // Load imported version data
        final version = cipher.versions.first;
        versionProvider.setNewVersionInCache(version);
        // Load sections
        sectionProvider.setNewSectionsInCache(
          -1,
          version.sections!,
        ); // -1 for new/imported versions
      case VersionType.cloud:
        // Load cloud version
        await versionProvider.ensureCloudVersionIsLoaded(widget.versionId!);
        // Load sections
        final version = versionProvider
            .getCloudVersionByFirebaseId(widget.versionId!)!
            .toDomain();
        sectionProvider.setNewSectionsInCache(
          widget.versionId!,
          version.sections!,
        );
        break;
      case VersionType.local:
        // Load the cipher
        await cipherProvider.loadCipher(widget.cipherId!);
        // Load the version
        await versionProvider.loadVersion(widget.versionId!);
        // Load sections
        await sectionProvider.loadSections(widget.versionId!);
        break;
      case VersionType.brandNew:
        // Nothing to load for brand new cipher/version
        break;
    }
  }

  void _navigateStartTab() {
    if (widget.versionType == VersionType.brandNew ||
        widget.versionType == VersionType.import) {
      _tabController.animateTo(0);
    } else {
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<SectionProvider>(
      builder: (context, sectionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.cipherEditorTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Column(
            spacing: 16,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      width: 1,
                      color: colorScheme.surfaceContainerHigh,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: TabBar(
                    labelPadding: const EdgeInsets.all(0),
                    dividerHeight: 0,
                    labelColor: colorScheme.onSurface,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(
                        width: 0.5,
                        color: colorScheme.surfaceContainerHigh,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    controller: _tabController,
                    tabs: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 8,
                          children: [
                            const Icon(Icons.info_outline),
                            Text(AppLocalizations.of(context)!.info),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 8,
                          children: [
                            const Icon(Icons.music_note),
                            Text(AppLocalizations.of(context)!.sections),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Basic Info Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Basic cipher info
                          InfoTab(
                            cipherId: widget.cipherId,
                            versionType: widget.versionType,
                          ),
                        ],
                      ),
                    ),
                    // Content Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: SectionsTab(
                        versionId: widget.versionId,
                        versionType: widget.versionType,
                      ),
                    ),
                  ],
                ),
              ),
              // Save and Delete/Cancel Buttons
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _saveCipher(widget.cipherId ?? -1),
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: colorScheme.surface,
                        side: BorderSide(color: colorScheme.onSurface),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _showDeleteDialog(false),
                      child: Text(
                        (widget.versionType == VersionType.import ||
                                widget.versionType == VersionType.brandNew)
                            ? AppLocalizations.of(context)!.cancel
                            : AppLocalizations.of(context)!.delete,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            verticalDirection: VerticalDirection.up,
            children: [
              if (paletteIsOpen) ...[
                ChordPalette(
                  cipherId: widget.cipherId ?? -1,
                  versionId: widget.versionId ?? -1,
                  onClose: _togglePalette,
                ),
              ],
              // Palette FAB
              if (_tabController.index == 1 &&
                  !_tabController.indexIsChanging) ...[
                FloatingActionButton(
                  onPressed: _togglePalette,
                  child: Icon(Icons.palette),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<int?> _createCipher() async {
    int? cipherId;
    try {
      cipherId = await context.read<CipherProvider>().createCipher();
      if (mounted) {
        Navigator.pop(context, true); // Close screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cifra criada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    return cipherId;
  }

  Future<int?> _createVersion(int cipherId) async {
    int? versionId;
    try {
      versionId = await context.read<VersionProvider>().createVersion(cipherId);
      if (mounted) {
        Navigator.pop(context, true); // Close screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Versão criada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    return versionId;
  }

  Future<void> _createSections(
    int versionId,
    SectionProvider sectionProvider,
  ) async {
    try {
      await sectionProvider.saveSections(versionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _saveCipher(int cipherId) async {
    try {
      await context.read<CipherProvider>().saveCipher(cipherId);
      if (mounted) {
        Navigator.pop(context, true); // Close screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cifra salva com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _saveVersion() async {
    try {
      await context.read<VersionProvider>().saveVersion();
      if (mounted) {
        Navigator.pop(context, true); // Close screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Versão salva com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _saveSections() async {
    try {
      await context.read<SectionProvider>().saveSections(widget.versionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seções salvas com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(bool deleteCipher) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          deleteCipher: deleteCipher,
          cipherId: widget.cipherId,
          versionId: widget.versionId,
        );
      },
    );
  }

  void _togglePalette() {
    setState(() {
      paletteIsOpen = !paletteIsOpen;
    });
  }
}
