import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/models/domain/parsing_cipher.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/import_provider.dart';
import 'package:cordis/providers/parser_provider.dart';
import 'package:cordis/screens/cipher/cipher_editor.dart';
import 'package:cordis/widgets/ciphers/viewer/section_card.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<ImportProvider, ParserProvider>(
      builder: (context, importProvider, parserProvider, child) {
        final doc = parserProvider.doc;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.cipherParsing),
            bottom:
                _tabController != null &&
                    doc != null &&
                    doc.candidates.isNotEmpty
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
          body: doc == null
              ? Center(
                  child: Text(
                    parserProvider.error.isNotEmpty
                        ? parserProvider.error
                        : AppLocalizations.of(context)!.noCiphersFound,
                  ),
                )
              : _buildBody(importProvider, parserProvider),
          bottomNavigationBar: doc == null
              ? null
              : Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.surfaceContainerLowest,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: FilledTextButton.icon(
                    text: AppLocalizations.of(context)!.confirm,
                    icon: Icons.check,
                    isDarkButton: true,
                    onPressed: () {
                      // Set chosen cipher in parser provider
                      context.read<ParserProvider>().parsedCipher =
                          doc.candidates[_tabController!.index].cipher;
                      // Confirm parsing and navigate to editor
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CipherEditor(
                            versionType: VersionType.import,
                            versionId: -1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBody(
    ImportProvider importProvider,
    ParserProvider parserProvider,
  ) {
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
            Text(AppLocalizations.of(context)!.loading),
          ],
        ),
      );
    }

    // Display parsing results in tabs
    return Column(
      children: [
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final version = cipher.versions.first;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            // Strategy info card
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(25),
                border: Border.all(color: colorScheme.primary),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(_getStrategyIcon(strategy)),
                    title: Text(
                      version.versionName,
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(100),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: colorScheme.onSurface,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.nSections(version.sectionCount),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.titleWithPlaceholder(cipher.title),
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.authorWithPlaceholder(cipher.author),
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (cipher.bpm != 0)
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.bpmWithPlaceholder(cipher.bpm),
                            style: theme.textTheme.bodyMedium,
                          ),
                        if (cipher.musicKey.isNotEmpty)
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.keyWithPlaceholder(cipher.musicKey),
                            style: theme.textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  AppLocalizations.of(context)!.songStructure,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.surfaceContainerLowest,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: version.songStructure.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.noSectionsInStructurePrompt,
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,

                          child: Row(
                            children: [
                              ...version.songStructure.asMap().entries.map((
                                entry,
                              ) {
                                final sectionCode = entry.value;
                                final section = version.sections![sectionCode]!;
                                final color = section.contentColor;
                                return Container(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: .8),
                                      borderRadius: BorderRadius.circular(0),
                                      border: Border.all(
                                        color: colorScheme.shadow,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        sectionCode,
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  AppLocalizations.of(context)!.sections,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                for (var section in version.sections!.entries) ...[
                  SectionCard(
                    sectionCode: section.value.contentCode,
                    sectionType: section.value.contentType,
                    sectionText: section.value.contentText,
                    sectionColor: section.value.contentColor,
                  ),
                ],
              ],
            ),
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
