import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/widgets/cipher/editor/cipher_basic_info_form.dart';
import 'package:cipher_app/widgets/cipher/editor/cipher_section_form.dart';

class EditCipher extends StatefulWidget {
  final Cipher? cipher; // Null for create, populated for edit
  final Version? currentVersion; // Specific version to edit
  final bool isNewVersion; // Creating a new version of existing cipher
  final String startTab;

  const EditCipher({
    super.key,
    this.cipher,
    this.currentVersion,
    this.isNewVersion = false,
    this.startTab = 'cipher',
  });

  @override
  State<EditCipher> createState() => _EditCipherState();
}

class _EditCipherState extends State<EditCipher>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Basic info controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _tempoController = TextEditingController();
  final _musicKeyController = TextEditingController();
  final _languageController = TextEditingController();
  final _tagsController = TextEditingController();

  bool get _isEditMode => widget.cipher != null;
  bool get _isNewVersionMode => widget.isNewVersion;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _tabController = TabController(length: 2, vsync: this);
    } else {
      _tabController = TabController(length: 1, vsync: this);
    }
    _initializeFields();
  }

  void _initializeFields() {
    // Always start with blank state for new cipher/version
    if (_isEditMode) {
      final cipher = widget.cipher!;
      _titleController.text = cipher.title;
      _authorController.text = cipher.author;
      _tempoController.text = cipher.tempo;
      _musicKeyController.text = cipher.musicKey;
      _languageController.text = cipher.language;
      _tagsController.text = cipher.tags.join(', ');
    }
  }

  String _getAppBarTitle() {
    if (_isNewVersionMode) {
      return 'Nova Versão';
    } else if (_isEditMode) {
      return 'Editar Cifra';
    } else {
      return 'Nova Cifra';
    }
  }

  void _navigateStartTab() {
    final Map<String, int> tabMap;
    if (_isEditMode) {
      tabMap = {'cipher': 0, 'version': 1};
    } else {
      tabMap = {'cipher': 0};
    }
    _tabController.animateTo(tabMap[widget.startTab]!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _tempoController.dispose();
    _musicKeyController.dispose();
    _languageController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    _navigateStartTab();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Cifra', icon: Icon(Icons.info_outline)),
            if (_isEditMode) ...[
              const Tab(text: 'Versão', icon: Icon(Icons.music_note)),
            ],
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Basic Info Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Basic cipher info
                  CipherBasicInfoForm(
                    titleController: _titleController,
                    authorController: _authorController,
                    tempoController: _tempoController,
                    musicKeyController: _musicKeyController,
                    languageController: _languageController,
                    tagsController: _tagsController,
                  ),
                ],
              ),
            ),
            if (_isEditMode) ...[
              // Content Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: CipherSectionForm(
                  cipherId: widget.cipher!.id!,
                  originalKey: widget.cipher!.musicKey,
                  versionId: widget.isNewVersion
                      ? null
                      : widget.currentVersion!.id,
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEditMode)
            FloatingActionButton(
              heroTag: 'delete',
              onPressed: _showDeleteDialog,
              backgroundColor: colorScheme.errorContainer,
              child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
            ),
          if (_isEditMode) const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cifra'),
        content: const Text(
          'Tem certeza que deseja excluir esta cifra? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _deleteCipher,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteCipher() async {
    try {
      await context.read<CipherProvider>().deleteCipher(widget.cipher!.id!);
      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context, true); // Close screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cifra excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
