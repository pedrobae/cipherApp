import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/cipher/editor/cipher_basic_info_form.dart';
import 'package:cipher_app/widgets/cipher/editor/cipher_section_form.dart';

class EditCipher extends StatefulWidget {
  final int? cipherId; // Null for create, populated for edit
  final int? versionId; // Specific version to edit

  const EditCipher({super.key, this.cipherId, this.versionId});

  @override
  State<EditCipher> createState() => _EditCipherState();
}

class _EditCipherState extends State<EditCipher>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool _isLoading = true;
  String? _loadError;

  // Basic info controllers
  bool get _isEditMode => widget.cipherId != null;
  bool get _isNewVersion => widget.versionId == null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _tabController = TabController(length: 2, vsync: this);
    } else {
      _tabController = TabController(length: 1, vsync: this);
    }

    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final cipherProvider = context.read<CipherProvider>();
      final versionProvider = context.read<VersionProvider>();

      if (_isEditMode && widget.cipherId != null) {
        // Load the cipher
        await cipherProvider.loadCipher(widget.cipherId!);

        if (_isNewVersion) {
          // For new version: load cipher but don't load any existing version
          // Clear any existing version data to start fresh
          versionProvider.clearCache();
        } else {
          // For editing existing cipher/version: load the specific version if provided
          if (widget.versionId != null) {
            await versionProvider.loadVersionById(widget.versionId!);
          } else {
            // Load the first version of the cipher for edit mode
            final cipher = cipherProvider.currentCipher;
            if (cipher != null && cipher.versions.isNotEmpty) {
              await versionProvider.loadVersionById(cipher.versions.first.id!);
            }
          }
        }
      } else {
        // For new cipher, clear any existing data
        cipherProvider.clearCurrentCipher();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  String _getAppBarTitle() {
    if (_isNewVersion) {
      return 'Nova Versão';
    } else if (_isEditMode) {
      return 'Editar Cifra';
    } else {
      return 'Nova Cifra';
    }
  }

  void _navigateStartTab() {
    if (_isEditMode) {
      _tabController.animateTo(1);
    } else {
      _tabController.animateTo(0);
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

    // Handle loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Handle error state
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Erro ao carregar dados: $_loadError'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

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
                  CipherBasicInfoForm(),
                ],
              ),
            ),
            if (_isEditMode) ...[
              // Content Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: CipherSectionForm(),
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
      await context.read<CipherProvider>().deleteCipher(widget.cipherId!);
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
