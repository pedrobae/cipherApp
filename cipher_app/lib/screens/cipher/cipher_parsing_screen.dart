import 'package:cipher_app/models/domain/cipher/section.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SeparationType.values.length,
      vsync: this,
    );
    // Start parsing when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cipher = context.read<ImportProvider>().importedCipher;
      context.read<ParserProvider>().parseCipher(cipher!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cipher Parser'),
        bottom: TabBar(
          controller: _tabController,
          tabs: SeparationType.values.map((type) {
            return Tab(text: type.name);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Confirmar'),
        onPressed: () {
          // Confirm parsing and navigate back
          Navigator.of(context).pop(); // Close the parsing screen
          Navigator.of(context).pop(); // Close the import screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditCipher(importedCipher: true),
            ),
          ); // Open the cipher editor screen
        },
        icon: Icon(Icons.refresh),
      ),
      body: Consumer2<ImportProvider, ParserProvider>(
        builder: (context, importProvider, parserProvider, child) {
          // Display error if parsing failed
          if (parserProvider.error.isNotEmpty) {
            return Center(
              child: Text(
                'Error during parsing: ${parserProvider.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            // Show loading indicator while parsing
            if (parserProvider.isParsing || parserProvider.cipher == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator.adaptive(),
                    SizedBox(height: 16.0),
                    Text('Parsing cipher, please wait...'),
                  ],
                ),
              );
            }
            // Display parsing status
            return Column(
              children: [
                // Header - indicating source and current status, as well as a progress indicator
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: parserProvider.isParsing
                        ? const CircularProgressIndicator.adaptive()
                        : const Icon(Icons.check, color: Colors.green),
                    title: Text(
                      'Parsing Cipher from ${importProvider.getImportType()}',
                    ),
                    subtitle: Text(
                      parserProvider.isParsing
                          ? 'Status: ${parserProvider.getParsingStatus()}'
                          : 'Parsing completed successfully!',
                    ),
                  ),
                ),
                // Body - Show detailed parsing results in tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: SeparationType.values.map((type) {
                      final Map<String, Section> sections;
                      switch (type) {
                        case SeparationType.doubleNewLine:
                          sections = parserProvider
                              .cipher!
                              .parsedDoubleLineSeparatedSections;
                          break;
                        case SeparationType.label:
                          sections = parserProvider
                              .cipher!
                              .parsedLabelSeparatedSections;
                          break;
                      }
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              if (parserProvider.hasParsedMetadata)
                                // --> METADATA CARD
                                Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ...parserProvider.cipher!.metadata.entries
                                          .map((entry) {
                                            return ListTile(
                                              title: Text(entry.key),
                                              subtitle: Text(entry.value),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              if (parserProvider.hasParsedSections &&
                                  !parserProvider.hasParsedChords)
                                // --> LABEL CARDS
                                ...sections.values.map((section) {
                                  return Card(
                                    margin: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      title: Text(section.contentCode),
                                      subtitle: Text(section.contentText),
                                    ),
                                  );
                                }),
                              if (parserProvider.hasParsedChords)
                                // --> SECTION CARDS
                                ...sections.entries.map((entry) {
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
        },
      ),
    );
  }
}
