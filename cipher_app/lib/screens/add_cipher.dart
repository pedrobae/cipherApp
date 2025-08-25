import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cipher_provider.dart';
import '../models/domain/cipher.dart';

class AddCipher extends StatefulWidget {
  final Cipher? cipher; // Null for create, populated for edit

  const AddCipher({super.key, this.cipher});

  @override
  State<AddCipher> createState() => _AddCipherState();
}

class _AddCipherState extends State<AddCipher> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _tempoController = TextEditingController();
  final _keyController = TextEditingController();
  final _languageController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditMode => widget.cipher != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditMode) {
      final cipher = widget.cipher!;
      _titleController.text = cipher.title;
      _authorController.text = cipher.author;
      _tempoController.text = cipher.tempo;
      _keyController.text = cipher.musicKey;
      _languageController.text = cipher.language;
      _tagsController.text = cipher.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _tempoController.dispose();
    _keyController.dispose();
    _languageController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Cifra' : 'Nova Cifra'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: Icon(Icons.delete, color: colorScheme.error),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Título',
                hint: 'Nome da música',
                validator: (value) =>
                    value?.isEmpty == true ? 'Título é obrigatório' : null,
                prefixIcon: Icons.music_note,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _authorController,
                label: 'Autor',
                hint: 'Compositor ou artista',
                validator: (value) =>
                    value?.isEmpty == true ? 'Autor é obrigatório' : null,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _keyController,
                      label: 'Tom',
                      hint: 'Ex: C, G, Am',
                      validator: (value) =>
                          value?.isEmpty == true ? 'Tom é obrigatório' : null,
                      prefixIcon: Icons.piano,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _tempoController,
                      label: 'Tempo',
                      hint: 'Ex: Lento, Médio',
                      validator: (value) =>
                          value?.isEmpty == true ? 'Tempo é obrigatório' : null,
                      prefixIcon: Icons.speed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _languageController,
                label: 'Idioma',
                hint: 'Ex: Português, Inglês',
                validator: (value) =>
                    value?.isEmpty == true ? 'Idioma é obrigatório' : null,
                prefixIcon: Icons.language,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _tagsController,
                label: 'Tags (opcional)',
                hint: 'Separe por vírgula: louvor, adoração, natal',
                prefixIcon: Icons.tag,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _isLoading ? null : _saveCipher,
                icon: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Icon(_isEditMode ? Icons.save : Icons.add),
                label: Text(_isEditMode ? 'Salvar Alterações' : 'Criar Cifra'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              if (_isEditMode) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    int? maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.primary)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  void _saveCipher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final cipherData = Cipher(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        tempo: _tempoController.text.trim(),
        musicKey: _keyController.text.trim(),
        language: _languageController.text.trim(),
        isLocal: true,
        tags: tags,
      );

      final cipherProvider = context.read<CipherProvider>();

      if (_isEditMode) {
        await cipherProvider.updateCipher(cipherData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cifra atualizada com sucesso!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        await cipherProvider.addCipher(cipherData);
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
