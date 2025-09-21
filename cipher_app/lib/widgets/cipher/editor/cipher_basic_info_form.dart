import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CipherBasicInfoForm extends StatelessWidget {
  const CipherBasicInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CipherProvider>(
      builder: (context, cipherProvider, child) {
        final cipher = cipherProvider.currentCipher;

        final titleController = TextEditingController();
        final authorController = TextEditingController();
        final tempoController = TextEditingController();
        final musicKeyController = TextEditingController();
        final languageController = TextEditingController();
        final tagsController = TextEditingController();

        if (cipher != null) {
          titleController.text = cipher.title;
          authorController.text = cipher.author;
          tempoController.text = cipher.tempo;
          musicKeyController.text = cipher.musicKey;
          languageController.text = cipher.language;
          tagsController.text = cipher.tags.join(', ');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
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
              context: context,
              controller: languageController,
              label: 'Idioma',
              hint: 'Ex: Português, Inglês',
              prefixIcon: Icons.language,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              context: context,
              controller: tagsController,
              label: 'Tags (opcional)',
              hint: 'Separe por vírgula: louvor, adoração, natal',
              prefixIcon: Icons.tag,
              maxLines: 2,
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
}
