import 'package:cipher_app/providers/parser_provider.dart';
import 'package:cipher_app/widgets/ciphers/editor/chord_palette.dart';
import 'package:cipher_app/widgets/ciphers/editor/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/providers/section_provider.dart';
import 'package:cipher_app/widgets/ciphers/editor/cipher_form.dart';
import 'package:cipher_app/widgets/ciphers/editor/version_form.dart';

class EditCipher extends StatefulWidget {
  final int? cipherId; // Null for new cipher, populated for edit
  final int? versionId; // Null for new version, populated for edit
  final bool editCipher;
  final bool importedCipher;

  const EditCipher({
    super.key,
    this.cipherId,
    this.versionId,
    this.editCipher = false,
    this.importedCipher = false,
  });

  @override
  State<EditCipher> createState() => _EditCipherState();
}

class _EditCipherState extends State<EditCipher>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Basic info controllers
  bool get _isNewCipher => widget.cipherId == null;
  bool get _isNewVersion => widget.versionId == null;

  bool paletteIsOpen = false;

  @override
  void initState() {
    super.initState();
    if (_isNewCipher && !widget.importedCipher) {
      _tabController = TabController(length: 1, vsync: this);
    } else {
      _tabController = TabController(length: 2, vsync: this);
    }

    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
      _navigateStartTab();
    });

    _tabController.addListener(() {
      // Setting state tp trigger rebuild
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

    if (_isNewCipher) {
      // For new cipher, clear any existing data
      cipherProvider.clearCurrentCipher();
      versionProvider.clearCache();
      sectionProvider.clearCache();

      if (widget.importedCipher) {
        // Load imported cipher data
        final cipher = parserProvider.parsedCipher;
        if (cipher != null) {
          cipherProvider.setCurrentCipher(cipher);
        }

        // Load imported version data
        final version = cipher!.versions.first;
        versionProvider.setCurrentVersion(version);

        // Load sections
        sectionProvider.setSections(version.sections!);
      }
    } else {
      // Load the cipher
      await cipherProvider.loadCipher(widget.cipherId!);
      if (_isNewVersion) {
        // For new version, clear any existing data
        versionProvider.clearCache();
      } else {
        // Load the version
        await versionProvider.loadCurrentVersion(widget.versionId!);
        // Load sections
        await sectionProvider.loadSections(widget.versionId!);
      }
    }
  }

  String _getAppBarTitle() {
    if (_isNewVersion) {
      return 'Nova Versão';
    } else if (_isNewCipher) {
      return 'Nova Cifra';
    } else {
      return 'Editar Cifra';
    }
  }

  void _navigateStartTab() {
    if (_isNewCipher || widget.editCipher) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Cifra', icon: Icon(Icons.info_outline)),
            if (!_isNewCipher || widget.importedCipher) ...[
              const Tab(text: 'Versão', icon: Icon(Icons.music_note)),
            ],
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
                CipherForm(),
              ],
            ),
          ),
          if (!_isNewCipher || widget.importedCipher) ...[
            // Content Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: VersionForm(),
            ),
          ],
        ],
      ),
      floatingActionButton: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.end,
        verticalDirection: VerticalDirection.up,
        children: [
          if (paletteIsOpen) ...[
            ChordPalette(onClose: _togglePalette),
          ] else ...[
            Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isNewCipher)
                  FloatingActionButton(
                    heroTag: 'delete',
                    onPressed: _showDeleteDialog,
                    backgroundColor: colorScheme.errorContainer,
                    child: Icon(
                      Icons.delete,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                FloatingActionButton.extended(
                  heroTag: 'save',
                  onPressed: () async {
                    if (widget.importedCipher) {
                      final cipherId = await _createCipher();
                      if (cipherId != null) {
                        final versionId = await _createVersion(cipherId);
                        if (versionId != null) {
                          await _createSections(versionId);
                        }
                      }
                    } else if (_isNewCipher) {
                      _createCipher();
                    } else if (_isNewVersion) {
                      final versionId = await _createVersion(widget.cipherId!);
                      if (versionId != null) {
                        await _createSections(versionId);
                      }
                    } else {
                      if (_tabController.index == 0) {
                        _saveCipher();
                      } else {
                        _saveVersion();
                        _saveSections();
                      }
                    }
                  },
                  backgroundColor: colorScheme.primary,
                  label: Text(
                    'Salvar',
                    style: theme.textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  icon: Icon(Icons.save, color: colorScheme.onPrimary),
                ),
              ],
            ),
          ],
          // Palette FAB
          if (_tabController.index == 1 && !_tabController.indexIsChanging) ...[
            FloatingActionButton(
              onPressed: _togglePalette,
              child: Icon(Icons.palette),
            ),
          ],
        ],
      ),
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

  Future<void> _createSections(int versionId) async {
    try {
      context.read<SectionProvider>().setCurrentVersionId(versionId);
      await context.read<SectionProvider>().saveSections();
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

  void _saveCipher() async {
    try {
      await context.read<CipherProvider>().saveCipher();
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
      await context.read<SectionProvider>().saveSections();
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
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
