import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/import_provider.dart';
import 'package:cipher_app/providers/parser_provider.dart';
import 'package:cipher_app/screens/cipher/cipher_editor.dart';
import 'package:cipher_app/widgets/ciphers/viewer/section_card.dart';

class CipherParsingScreen extends StatefulWidget {
  const CipherParsingScreen({super.key});

  @override
  State<CipherParsingScreen> createState() => _CipherParsingScreenState();
}

class _CipherParsingScreenState extends State<CipherParsingScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Start parsing when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cipher = context.read<ImportProvider>().importedCipher;
      if (cipher != null) {
        context.read<ParserProvider>().parseCipher(cipher);
        // Initialize tab controller after knowing available strategies
        final doc = context.read<ParserProvider>().doc;
        setState(() {
          _tabController = TabController(
            length: doc!.candidates.length,
            vsync: this,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ImportProvider, ParserProvider>(
      builder: (context, importProvider, parserProvider, child) {
        final doc = parserProvider.doc;
        if (doc == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Analisador de Cifras')),
            body: Center(child: Text('Nenhum documento para analisar.')),
          );
        }
        final availableStrategies = doc.candidates
            .map((candidate) => candidate.strategy)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('Analisador de Cifras'),
            bottom: _tabController != null && availableStrategies.isNotEmpty
                ? TabBar(
                    controller: _tabController,
                    tabs: availableStrategies.map((strategy) {
                      return Tab(
                        text: strategy.name,
                        icon: Icon(_getStrategyIcon(strategy)),
                      );
                    }).toList(),
                  )
                : null,
          ),
          floatingActionButton: availableStrategies.isNotEmpty
              ? FloatingActionButton.extended(
                  label: Text('Confirmar'),
                  icon: Icon(Icons.check),
                  onPressed: () {
                    // Set chosen cipher in parser provider
                    context.read<ParserProvider>().parsedCipher =
                        doc.candidates[_tabController!.index].cipher;
                    // Confirm parsing and navigate back
                    Navigator.of(context).pop(); // Close the parsing screen
                    Navigator.of(context).pop(); // Close the import screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditCipher(importedCipher: true),
                      ),
                    );
                  },
                )
              : null,
          body: _buildBody(importProvider, parserProvider),
        );
      },
    );
  }

  Widget _buildBody(
    ImportProvider importProvider,
    ParserProvider parserProvider,
  ) {
    // Display error if parsing failed
    if (parserProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erro durante análise:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                parserProvider.error,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // Show loading indicator while parsing
    if (parserProvider.isParsing ||
        parserProvider.cipher == null ||
        _tabController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(),
            SizedBox(height: 16.0),
            Text('Analisando cifra, aguarde...'),
            if (parserProvider.parsingStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  parserProvider.parsingStatus,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      );
    }

    final doc = parserProvider.doc!;
    final cipher = parserProvider.cipher!;
    final availableStrategies = doc.candidates
        .map((candidate) => candidate.strategy)
        .toList();

    // Display parsing results in tabs
    return Column(
      children: [
        // Header - parsing status and metadata
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  'Cifra importada de ${importProvider.getImportType()}',
                ),
                subtitle: Text(
                  '${availableStrategies.length} estratégias disponíveis',
                ),
              ),
              if (cipher.metadata.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cipher.metadata.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(entry.value.toString()),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),

        // Body - Tabs with parsing results
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: availableStrategies.map((strategy) {
              final result = doc.candidates[_tabController!.index];

              if (result.cipher.versions.first.sectionCount == 0) {
                return Center(
                  child: Text('Nenhuma seção encontrada com esta estratégia'),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Strategy info card
                      Card(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          leading: Icon(_getStrategyIcon(strategy)),
                          title: Text(strategy.name),
                          trailing: Chip(
                            label: Text(
                              '${result.cipher.versions.first.sectionCount} seções',
                            ),
                          ),
                        ),
                      ),

                      // Section cards
                      ...(result.cipher.versions.first.sections?.entries ?? [])
                          .map((entry) {
                            return CipherSectionCard(
                              sectionCode: entry.value.contentCode,
                              sectionType: entry.value.contentType,
                              sectionText: entry.value.contentText,
                              sectionColor: entry.value.contentColor,
                            );
                          }),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getStrategyIcon(ParsingStrategy strategy) {
    switch (strategy) {
      case ParsingStrategy.doubleNewLine:
        return Icons.format_line_spacing;
      case ParsingStrategy.sectionLabels:
        return Icons.label;
      case ParsingStrategy.pdfFormatting:
        return Icons.picture_as_pdf;
    }
  }
}
