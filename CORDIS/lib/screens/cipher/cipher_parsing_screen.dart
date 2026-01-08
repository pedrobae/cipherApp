import 'package:cipher_app/models/domain/cipher/cipher.dart';
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

        return Scaffold(
          appBar: AppBar(
            title: Text('Analisador de Cifras'),
            bottom: _tabController != null && doc.candidates.isNotEmpty
                ? TabBar(
                    controller: _tabController,
                    tabs: doc.candidates.map((candidate) {
                      return Tab(
                        text:
                            '${candidate.variation.name}\n${candidate.strategy.name}',
                        icon: Icon(_getStrategyIcon(candidate.strategy)),
                      );
                    }).toList(),
                  )
                : null,
          ),
          floatingActionButton: doc.candidates.isNotEmpty
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
          ],
        ),
      );
    }

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
              ),
            ],
          ),
        ),

        // Body - Tabs with parsing results
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (var candidate in parserProvider.doc!.candidates)
                _buildParsingResultTab(
                  candidate.strategy,
                  candidate.variation,
                  candidate.cipher,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParsingResultTab(
    ParsingStrategy strategy,
    ImportVariation variation,
    Cipher cipher,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Strategy info card
            Card(
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(_getStrategyIcon(strategy)),
                    title: Text(strategy.name),
                    trailing: Chip(
                      label: Text(
                        '${cipher.versions.first.sectionCount} seções',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Título: ${cipher.title}'),
                        Text('Artista: ${cipher.author}'),
                        if (cipher.tempo.isNotEmpty)
                          Text('Tempo: ${cipher.tempo}'),
                        if (cipher.musicKey.isNotEmpty)
                          Text('Tom: ${cipher.musicKey}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (var section in cipher.versions.first.sections!.entries) ...[
              CipherSectionCard(
                sectionCode: section.value.contentCode,
                sectionType: section.value.contentType,
                sectionText: section.value.contentText,
                sectionColor: section.value.contentColor,
              ),
            ],
          ],
        ),
      ),
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
