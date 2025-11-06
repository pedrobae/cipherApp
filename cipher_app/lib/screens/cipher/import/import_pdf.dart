import 'package:cipher_app/screens/cipher/cipher_parsing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:flutter/material.dart';

class ImportPdfScreen extends StatefulWidget {
  final bool isNewCipher;

  const ImportPdfScreen({super.key, required this.isNewCipher});

  @override
  State<ImportPdfScreen> createState() => _ImportPdfScreenState();
}

class _ImportPdfScreenState extends State<ImportPdfScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ImportProvider>().setImportType(ImportType.pdf);
  }

  /// Opens file picker and allows user to select a PDF file
  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      // User selected a file
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;

        if (mounted) {
          context.read<ImportProvider>().setSelectedFile(path!);
        }
      }
      // If result is null, user canceled - do nothing
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar de PDF')),
      body: Consumer<ImportProvider>(
        builder: (context, importProvider, child) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  color: colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                            ),
                            Text(
                              'Como importar',
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '• Selecione um PDF com cifra\n'
                          '• Fonte mono é recomendada se possível\n'
                          '• Separe estrofes com linhas vazias\n'
                          '• Acordes acima das letras',
                        ),
                      ],
                    ),
                  ),
                ),

                // File selection button
                OutlinedButton.icon(
                  onPressed: importProvider.isImporting ? null : _pickPdfFile,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Selecionar Arquivo PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 16),

                // Selected file display
                if (importProvider.selectedFile != null)
                  Card(
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arquivo selecionado:',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  importProvider.selectedFile!,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              // Clear selected file
                              importProvider.clearSelectedFile();
                              importProvider.clearError();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error display
                if (importProvider.error != null)
                  Card(
                    color: colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              importProvider.error!,
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const Spacer(),

                // Process button
                FilledButton.icon(
                  onPressed:
                      (importProvider.selectedFile != null &&
                          !importProvider.isImporting)
                      ? () async {
                          final navigator = Navigator.of(context);
                          await importProvider.importText();
                          navigator.push(
                            MaterialPageRoute(
                              builder: (context) => CipherParsing(),
                            ),
                          );
                        }
                      : null,
                  icon: importProvider.isImporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high),
                  label: Text(
                    importProvider.isImporting
                        ? 'Processando...'
                        : 'Processar PDF',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
