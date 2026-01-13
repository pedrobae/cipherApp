import 'package:cordis/providers/cipher_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoTab extends StatefulWidget {
  final int cipherId;

  const InfoTab({super.key, required this.cipherId});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final tempoController = TextEditingController();
  final musicKeyController = TextEditingController();
  final languageController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithProviderData();
  }

  void _syncWithProviderData() {
    if (mounted) {
      final cipherProvider = context.read<CipherProvider>();
      final cipher = cipherProvider.getCipherFromCache(widget.cipherId)!;

      // Only sync if cipher has changed or if we haven't initialized yet

      titleController.text = cipher.title;
      authorController.text = cipher.author;
      tempoController.text = cipher.tempo;
      musicKeyController.text = cipher.musicKey;
      languageController.text = cipher.language;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    tempoController.dispose();
    musicKeyController.dispose();
    languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CipherProvider>(
      builder: (context, cipherProvider, child) {
        // Trigger sync after the current build if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncWithProviderData();
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              field: 'title',
              cipherProvider: cipherProvider,
              context: context,
              controller: titleController,
              label: 'Título',
              hint: 'Nome da música',
              validator: (value) =>
                  value?.isEmpty == true ? 'Título é obrigatório' : null,
              prefixIcon: Icons.music_note,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              field: 'author',
              cipherProvider: cipherProvider,
              context: context,
              controller: authorController,
              label: 'Autor',
              hint: 'Compositor ou artista',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    field: 'musicKey',
                    cipherProvider: cipherProvider,
                    context: context,
                    controller: musicKeyController,
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
                    field: 'tempo',
                    cipherProvider: cipherProvider,
                    context: context,
                    controller: tempoController,
                    label: 'Tempo',
                    hint: 'Ex: Lento, Médio',
                    prefixIcon: Icons.speed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              field: 'language',
              cipherProvider: cipherProvider,
              context: context,
              controller: languageController,
              label: 'Idioma',
              hint: 'Ex: Português, Inglês',
              prefixIcon: Icons.language,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required CipherProvider cipherProvider,
    required String field,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    int? maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      onChanged: (value) {
        if (field != 'tags') {
          cipherProvider.cacheCipherUpdates(widget.cipherId, field, value);
        } else {
          cipherProvider.cacheCipherTagUpdates(widget.cipherId, value);
        }
      },
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
}
