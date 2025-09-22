import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/cipher/editor/cipher_basic_info_form.dart';
import 'package:cipher_app/widgets/cipher/editor/cipher_section_form.dart';

class EditCipher extends StatefulWidget {
  final int? cipherId; // Null for new cipher, populated for edit
  final int? versionId; // Null for new version, populate for edit

  const EditCipher({super.key, this.cipherId, this.versionId});

  @override
  State<EditCipher> createState() => _EditCipherState();
}

class _EditCipherState extends State<EditCipher>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true; // To render the loading screen
  String? _loadError;

  // Basic info controllers
  bool get _isNewCipher => widget.cipherId == null;
  bool get _isNewVersion => widget.versionId == null;

  @override
  void initState() {
    super.initState();
    if (_isNewCipher) {
      _tabController = TabController(length: 1, vsync: this);
    } else {
      _tabController = TabController(length: 2, vsync: this);
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

      if (_isNewCipher) {
        // For new cipher, clear any existing data
        cipherProvider.clearCurrentCipher();
      } else {
        // Load the cipher
        await cipherProvider.loadCipher(widget.cipherId!);
        if (_isNewVersion) {
          // For new version, clear any existing data
          versionProvider.clearCache();
        } else {
          // Load the version
          await versionProvider.loadVersionById(widget.versionId!);
        }
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
    } else if (_isNewCipher) {
      return 'Nova Cifra';
    } else {
      return 'Editar Cifra';
    }
  }

  void _navigateStartTab() {
    if (_isNewCipher) {
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
            if (!_isNewCipher) ...[
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
                CipherBasicInfoForm(),
              ],
            ),
          ),
          if (!_isNewCipher) ...[
            // Content Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: CipherSectionForm(),
            ),
          ],
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isNewCipher)
            FloatingActionButton(
              heroTag: 'delete',
              onPressed: _showDeleteDialog,
              backgroundColor: colorScheme.errorContainer,
              child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
            ),
          if (!_isNewCipher) const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: 'save',
            onPressed: () {
              if (_tabController.index == 0) {
                _saveCipher();
              } else {
                _saveVersion();
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
    );
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        if (_tabController.index == 0) {
          return AlertDialog(
            title: const Text('Excluir Cifra'),
            content: const Text(
              'Tem certeza que deseja excluir esta cifra? Excluir uma cifra excluirá todas as suas versões.',
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
          );
        } else {
          return AlertDialog(
            title: const Text('Excluir Versão'),
            content: const Text(
              'Tem certeza que deseja excluir esta versão? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: _deleteVersion,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Excluir'),
              ),
            ],
          );
        }
      },
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

  void _deleteVersion() async {
    try {
      await context.read<VersionProvider>().deleteCipherVersion(
        widget.versionId!,
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Versão excluída com sucesso!')));
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
