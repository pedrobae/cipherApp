import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cipher_provider.dart';
import '../models/domain/cipher.dart';
import '../widgets/forms/cipher_basic_info_form.dart';
import '../widgets/forms/cipher_content_form.dart';

class EditCipher extends StatefulWidget {
  final Cipher? cipher; // Null for create, populated for edit
  final CipherMap? currentVersion; // Specific version to edit
  final bool isNewVersion; // Creating a new version of existing cipher

  const EditCipher({
    super.key, 
    this.cipher,
    this.currentVersion,
    this.isNewVersion = false,
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

  // Version-specific controllers
  final _versionNameController = TextEditingController();

  // Content data
  Map<String, String> _cipherContent = {};
  List<String> _songStructure = [];

  bool get _isEditMode => widget.cipher != null;
  bool get _isNewVersionMode => widget.isNewVersion;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFields();
  }

  void _initializeFields() {
    // Always start with empty version name and content
    _versionNameController.text = '';
    _cipherContent = {};
    _songStructure = []; // Empty structure by default
    
    if (_isEditMode) {
      final cipher = widget.cipher!;
      // Only populate basic cipher info for existing ciphers
      _titleController.text = cipher.title;
      _authorController.text = cipher.author;
      _tempoController.text = cipher.tempo;
      _musicKeyController.text = cipher.musicKey;
      _languageController.text = cipher.language;
      _tagsController.text = cipher.tags.join(', ');
      
      // Only populate version data if editing a specific version (not creating new)
      if (!_isNewVersionMode && widget.currentVersion != null) {
        _versionNameController.text = widget.currentVersion!.versionName ?? '';
        _cipherContent = Map.from(widget.currentVersion!.content);
        _songStructure = widget.currentVersion!.songStructure.split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
  }

  String _getSaveButtonText() {
    if (_isNewVersionMode) {
      return 'Criar Versão';
    } else if (_isEditMode) {
      return 'Salvar';
    } else {
      return 'Criar';
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

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _tempoController.dispose();
    _musicKeyController.dispose();
    _languageController.dispose();
    _tagsController.dispose();
    _versionNameController.dispose();
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
            Tab(
              text: _isNewVersionMode ? 'Informações da Cifra' : 'Informações', 
              icon: const Icon(Icons.info_outline),
            ),
            const Tab(text: 'Conteúdo', icon: Icon(Icons.music_note)),
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
                  // Version info section (if editing/creating version)
                  if (_isEditMode) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações da Versão',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _versionNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome da Versão',
                                hintText: 'Ex: Original, Acústica, Tom de C',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.label),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nome da versão é obrigatório';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
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
            // Content Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: CipherContentForm(
                cipher: widget.cipher,
                currentVersion: widget.currentVersion,
                onContentChanged: (content) {
                  _cipherContent = content;
                },
                onStructureChanged: (structure) {
                  _songStructure = structure;
                },
              ),
            ),
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
          FloatingActionButton.extended(
            heroTag: 'save',
            onPressed: context.watch<CipherProvider>().isSaving ? null : _saveCipher,
            icon: context.watch<CipherProvider>().isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(_isEditMode ? Icons.save : Icons.add),
            label: Text(_getSaveButtonText()),
          ),
        ],
      ),
    );
  }

  void _saveCipher() async {
    if (!_formKey.currentState!.validate()) {
      // Switch to basic info tab if validation fails
      _tabController.animateTo(0);
      return;
    }

    // Validate that version has content (except when creating cipher without content)
    if (_cipherContent.isEmpty && (_isEditMode || _isNewVersionMode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione conteúdo à versão antes de salvar'),
          backgroundColor: Colors.orange,
        ),
      );
      _tabController.animateTo(1); // Switch to content tab
      return;
    }

    try {
      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create cipher map for this version (only if has content)
      CipherMap? cipherMap;
      if (_cipherContent.isNotEmpty) {
        cipherMap = CipherMap(
          id: _isNewVersionMode ? null : widget.currentVersion?.id,
          cipherId: _isEditMode ? widget.cipher!.id! : 0,
          songStructure: _songStructure.join(','),
          content: _cipherContent,
          versionName: _versionNameController.text.trim().isNotEmpty 
              ? _versionNameController.text.trim() 
              : 'Versão sem nome',
          transposedKey: null,
          createdAt: _isNewVersionMode ? DateTime.now() : widget.currentVersion?.createdAt,
        );
      }

      // Prepare cipher data
      List<CipherMap> updatedMaps;
      if (_isNewVersionMode && cipherMap != null) {
        // Adding new version to existing cipher
        updatedMaps = [...widget.cipher!.maps, cipherMap];
      } else if (_isEditMode && widget.currentVersion != null && cipherMap != null) {
        // Editing existing version
        updatedMaps = widget.cipher!.maps.map((map) => 
            map.id == widget.currentVersion!.id ? cipherMap! : map).toList();
      } else {
        // Creating new cipher
        updatedMaps = cipherMap != null ? [cipherMap] : [];
      }

      final cipherData = Cipher(
        id: _isEditMode ? widget.cipher!.id : null,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        tempo: _tempoController.text.trim(),
        musicKey: _musicKeyController.text.trim(),
        language: _languageController.text.trim(),
        isLocal: true,
        tags: tags,
        maps: updatedMaps,
      );

      final cipherProvider = context.read<CipherProvider>();

      if (_isEditMode) {
        await cipherProvider.updateCipher(cipherData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isNewVersionMode 
                  ? 'Nova versão criada com sucesso!' 
                  : 'Cifra atualizada com sucesso!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        await cipherProvider.createCipher(cipherData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cifra criada com sucesso!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
