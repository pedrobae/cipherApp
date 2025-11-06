import 'package:cipher_app/screens/cipher/import/cipher_parsing.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:provider/provider.dart';

class ImportTextScreen extends StatefulWidget {
  final int? cipherId;

  const ImportTextScreen({super.key, this.cipherId});

  @override
  State<ImportTextScreen> createState() => _ImportTextScreenState();
}

class _ImportTextScreenState extends State<ImportTextScreen> {
  final TextEditingController _importTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<ImportProvider>().setImportType(ImportType.text);
  }

  @override
  void dispose() {
    _importTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar de Texto')),
      body: Consumer<ImportProvider>(
        builder: (context, importProvider, child) {
          // Handle Error State
          if (importProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro ao importar: ${importProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  FilledButton.icon(
                    label: const Text('Tentar Novamente'),
                    onPressed: () {
                      importProvider.clearError();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          }

          // Handle Loading State
          if (importProvider.isImporting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Default State
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 4,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: TextField(
                      expands: true,
                      maxLines: null,
                      selectAllOnFocus: true,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      textAlignVertical: TextAlignVertical(y: -1),
                      controller: _importTextController,
                      decoration: InputDecoration(
                        hintText: 'Cole o texto de uma cifra.',
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    label: const Text('Importar'),
                    onPressed: () async {
                      final text = _importTextController.text;
                      if (text.isNotEmpty) {
                        final navigator = Navigator.of(context);
                        await importProvider.importText(data: text);
                        // Navigate to parsing screen
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CipherParsing(source: ImportType.text),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.import_export),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
