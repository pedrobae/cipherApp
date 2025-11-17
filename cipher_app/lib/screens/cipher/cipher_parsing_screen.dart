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

class _CipherParsingScreenState extends State<CipherParsingScreen> {
  @override
  void initState() {
    // Start parsing when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cipher = context.read<ImportProvider>().importedCipher;
      context.read<ParserProvider>().parseCipher(cipher!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cipher Parser')),
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
                'Error: ${parserProvider.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // Display parsing status
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 8,
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
                  // Body - Show detailed parsing results
                  if (parserProvider.hasParsedMetadata)
                    // --> METADATA CARD
                    Card(
                      margin: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ...parserProvider.cipher!.metadata.entries.map((
                            entry,
                          ) {
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
                    // --> SECTIONS CARDS
                    ...parserProvider.cipher!.sections.map((section) {
                      if (section['isDuplicate'] == true) {
                        return const SizedBox.shrink();
                      }
                      return Card(
                        margin: const EdgeInsets.all(16.0),
                        child: ListTile(
                          title: Text(section['label']),
                          subtitle: Text(section['contentText']),
                        ),
                      );
                    }),

                  if (parserProvider.hasParsedChords)
                    // --> SECTION CARDS
                    ...parserProvider.cipher!.parsedSections.entries.map((
                      entry,
                    ) {
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
        },
      ),
    );
  }
}
