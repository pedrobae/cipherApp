import 'package:cordis/l10n/app_localizations.dart';
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

class EditCipher extends StatefulWidget {
  final int? cipherId; // Null for new cipher
  final int? versionId; // Null for new version
  final bool importedCipher;

  const EditCipher({
    super.key,
    this.cipherId,
    this.versionId,
    this.importedCipher = false,
  });

  @override
  State<EditCipher> createState() => _EditCipherState();
}

class _EditCipherState extends State<EditCipher>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late bool isEdit;

  bool paletteIsOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    isEdit = (widget.cipherId == null && widget.versionId == null);

    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
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

    if (widget.importedCipher) {
      // Load imported cipher data
      final cipher = parserProvider.parsedCipher;
      if (cipher != null) {
        cipherProvider.setNewCipherInCache(cipher);
        // Load imported version data
        final version = cipher.versions.first;
        versionProvider.setNewVersionInCache(version);
        // Load sections
        sectionProvider.setNewSectionsInCache(
          -1,
          version.sections!,
        ); // -1 for new/imported versions
      }
    } else {
      // Load the cipher
      await cipherProvider.loadCipher(widget.cipherId!);
      // Load the version
      await versionProvider.loadVersion(widget.versionId!);
      // Load sections
      await sectionProvider.loadSections(widget.versionId!);
    }
  }

  void _navigateStartTab() {
    if (isEdit) {
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
            title: Text(AppLocalizations.of(context)!.cipherEditorTitle),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: AppLocalizations.of(context)!.info,
                  icon: const Icon(Icons.info_outline),
                ),
                Tab(
                  text: AppLocalizations.of(context)!.sections,
                  icon: const Icon(Icons.music_note),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Basic Info Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Basic cipher info
                    InfoTab(cipherId: widget.cipherId ?? -1),
                  ],
                ),
              ),
              // Content Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: SectionsTab(versionId: widget.versionId),
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
              ] else
                ...[],
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
