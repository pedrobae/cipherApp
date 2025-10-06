import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/admin_provider.dart';
import 'package:cipher_app/services/admin_bulk_service.dart';

class AdminBulkImportScreen extends StatefulWidget {
  const AdminBulkImportScreen({super.key});

  @override
  State<AdminBulkImportScreen> createState() => _AdminBulkImportScreenState();
}

class _AdminBulkImportScreenState extends State<AdminBulkImportScreen> {
  final TextEditingController _jsonController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _uploadToCloud = true;
  bool _showSample = false;

  @override
  void dispose() {
    _jsonController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importação em Lote (Admin)'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.0,
              children: [
                _buildHeader(colorScheme),
                _buildUploadOptions(),
                _buildJsonInput(adminProvider),
                _buildActionButtons(adminProvider),
                _buildProgressSection(adminProvider, colorScheme),
                _buildResultsSection(adminProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Importação Administrativa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Esta funcionalidade permite importar múltiplas cifras em lote. '
              'Cole um JSON no formato correto ou use o botão "Ver Exemplo" para referência.',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Opções de Importação',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Enviar para Firebase (Nuvem)'),
              subtitle: const Text(
                'Além do banco local, enviar para Firestore',
              ),
              value: _uploadToCloud,
              onChanged: (value) {
                setState(() {
                  _uploadToCloud = value ?? true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonInput(AdminProvider adminProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'JSON das Cifras',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showSample = !_showSample;
                    });
                  },
                  icon: Icon(
                    _showSample ? Icons.visibility_off : Icons.visibility,
                  ),
                  label: Text(_showSample ? 'Ocultar Exemplo' : 'Ver Exemplo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_showSample) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Exemplo de JSON:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: adminProvider.getSampleJsonTemplate(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Exemplo copiado para a área de transferência!',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copiar exemplo',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Text(
                          adminProvider.getSampleJsonTemplate(),
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _jsonController,
              maxLines: 15,
              decoration: InputDecoration(
                hintText: 'Cole o JSON das cifras aqui...',
                border: const OutlineInputBorder(),
                suffixIcon: _jsonController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _jsonController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            if (_jsonController.text.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    adminProvider.isValidJsonStructure(_jsonController.text)
                        ? Icons.check_circle
                        : Icons.error,
                    color:
                        adminProvider.isValidJsonStructure(_jsonController.text)
                        ? Colors.green
                        : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    adminProvider.isValidJsonStructure(_jsonController.text)
                        ? '${adminProvider.countCiphersInJson(_jsonController.text)} cifras detectadas'
                        : 'Formato JSON inválido',
                    style: TextStyle(
                      color:
                          adminProvider.isValidJsonStructure(
                            _jsonController.text,
                          )
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AdminProvider adminProvider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _jsonController.text.isNotEmpty && !adminProvider.isImporting
                ? () async {
                    final isValid = await adminProvider.validateJson(
                      _jsonController.text,
                    );
                    if (!isValid) {
                      _scrollToResults();
                    }
                  }
                : null,
            icon: const Icon(Icons.fact_check),
            label: const Text('Validar JSON'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _jsonController.text.isNotEmpty && !adminProvider.isImporting
                ? () async {
                    final success = await adminProvider.importFromJson(
                      jsonString: _jsonController.text,
                      uploadToCloud: _uploadToCloud,
                    );

                    if (success) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✅ Importação concluída com sucesso!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      _scrollToResults();
                    }
                  }
                : null,
            icon: adminProvider.isImporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload),
            label: Text(
              adminProvider.isImporting ? 'Importando...' : 'Importar Cifras',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
    AdminProvider adminProvider,
    ColorScheme colorScheme,
  ) {
    if (!adminProvider.isImporting && adminProvider.currentProgress == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso da Importação',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: adminProvider.progressPercentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '${adminProvider.currentProgress} de ${adminProvider.totalProgress} - ${adminProvider.currentStatus}',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(AdminProvider adminProvider) {
    if (adminProvider.error != null) {
      return _buildErrorCard(adminProvider.error!);
    }

    if (adminProvider.lastValidationResult != null) {
      return _buildValidationResultCard(adminProvider.lastValidationResult!);
    }

    if (adminProvider.lastImportResult != null) {
      return _buildImportResultCard(adminProvider.lastImportResult!);
    }

    return _buildEmptyState();
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Erro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(error),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationResultCard(ValidationResult result) {
    return Card(
      color: result.isValid ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isValid ? Icons.check_circle : Icons.warning,
                  color: result.isValid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resultado da Validação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.getSummary()),
          ],
        ),
      ),
    );
  }

  Widget _buildImportResultCard(BulkImportResult result) {
    return Card(
      color: result.hasAnyFailures
          ? Colors.orange.shade50
          : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.hasAnyFailures ? Icons.warning : Icons.check_circle,
                  color: result.hasAnyFailures ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resultado da Importação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.getSummary()),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Cole um JSON e use "Validar" ou "Importar"',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
