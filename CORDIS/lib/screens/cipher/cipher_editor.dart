import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/parser_provider.dart';
import 'package:cordis/widgets/ciphers/editor/chord_palette.dart';
import 'package:cordis/widgets/ciphers/editor/delete_dialog.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/widgets/ciphers/editor/info_tab.dart';
import 'package:cordis/widgets/ciphers/editor/sections_tab.dart';

class CipherEditor extends StatefulWidget {
  final int? cipherId; // Null for new cipher
  final dynamic versionId; // Null for new version // could be int or String
  final VersionType versionType;

  const CipherEditor({
    super.key,
    this.cipherId,
    this.versionId,
    required this.versionType,
  });

  @override
  State<CipherEditor> createState() => _CipherEditorState();
}

class _CipherEditorState extends State<CipherEditor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool paletteIsOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load data and navigate to start tab after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _navigateStartTab();
    });

    _tabController.addListener(() {
      // Setting state to trigger rebuild
      setState(() {
        paletteIsOpen = false;
      });
    });
  }

  Future<void> _loadData() async {
    final cipherProvider = context.read<CipherProvider>();
    final versionProvider = context.read<VersionProvider>();
    final parserProvider = context.read<ParserProvider>();
    final sectionProvider = context.read<SectionProvider>();

    switch (widget.versionType) {
      case VersionType.import:
        // Load imported cipher data
        final cipher = parserProvider.parsedCipher!;

        cipherProvider.setNewCipherInCache(cipher);
        // Load imported version data
        final version = cipher.versions.first;
        versionProvider.setNewVersionInCache(version);
        // Load sections
        sectionProvider.setNewSectionsInCache(
          -1,
          version.sections!,
        ); // -1 for new/imported versions
      case VersionType.cloud:
        // Load cloud version
        await versionProvider.ensureCloudVersionIsLoaded(widget.versionId!);
        // Load sections
        final version = versionProvider
            .getCloudVersionByFirebaseId(widget.versionId!)!
            .toDomain();
        sectionProvider.setNewSectionsInCache(
          widget.versionId!,
          version.sections!,
        );
        break;
      case VersionType.local:
        // Load the cipher
        await cipherProvider.loadCipher(widget.cipherId!);
        // Load the version
        await versionProvider.loadVersion(widget.versionId!);
        // Load sections
        await sectionProvider.loadSections(widget.versionId!);
        break;
      case VersionType.brandNew:
        // Nothing to load for brand new cipher/version
        break;
    }
  }

  void _navigateStartTab() {
    if (widget.versionType == VersionType.brandNew ||
        widget.versionType == VersionType.import) {
      _tabController.animateTo(0);
    } else {
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer3<CipherProvider, VersionProvider, SectionProvider>(
      builder:
          (context, cipherProvider, versionProvider, sectionProvider, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.cipherEditorTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              body: Column(
                spacing: 16,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          width: 1,
                          color: colorScheme.surfaceContainerHigh,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: TabBar(
                        labelPadding: const EdgeInsets.all(0),
                        dividerHeight: 0,
                        labelColor: colorScheme.onSurface,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(
                            width: 0.5,
                            color: colorScheme.surfaceContainerHigh,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        controller: _tabController,
                        tabs: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 8,
                              children: [
                                const Icon(Icons.info_outline),
                                Text(AppLocalizations.of(context)!.info),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 8,
                              children: [
                                const Icon(Icons.music_note),
                                Text(AppLocalizations.of(context)!.sections),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Basic Info Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Basic cipher info
                              InfoTab(
                                cipherId: widget.cipherId,
                                versionId: widget.versionId,
                                versionType: widget.versionType,
                              ),
                            ],
                          ),
                        ),
                        // Content Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: SectionsTab(
                            versionId: widget.versionId,
                            versionType: widget.versionType,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save and Delete/Cancel Buttons
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Column(
                      spacing: 16,
                      children: [
                        FilledTextButton(
                          isDarkButton: true,
                          onPressed: () {
                            if (widget.versionType == VersionType.import ||
                                widget.versionType == VersionType.brandNew) {
                              _createCipher(
                                cipherProvider,
                                versionProvider,
                                sectionProvider,
                              );
                            } else {
                              _saveCipher(
                                cipherProvider,
                                versionProvider,
                                sectionProvider,
                              );
                            }
                          },
                          text: AppLocalizations.of(context)!.save,
                        ),
                        FilledTextButton(
                          onPressed: () {
                            if (widget.versionType == VersionType.import ||
                                widget.versionType == VersionType.brandNew) {
                              Navigator.pop(context);
                            } else {
                              _showDeleteDialog(widget.cipherId != null);
                            }
                          },
                          text:
                              (widget.versionType == VersionType.import ||
                                  widget.versionType == VersionType.brandNew)
                              ? AppLocalizations.of(context)!.cancel
                              : AppLocalizations.of(context)!.delete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.end,
                verticalDirection: VerticalDirection.up,
                children: [
                  if (paletteIsOpen) ...[
                    ChordPalette(
                      cipherId: widget.cipherId ?? -1,
                      versionId: widget.versionId ?? -1,
                      onClose: _togglePalette,
                    ),
                  ],
                  // Palette FAB
                  if (_tabController.index == 1 &&
                      !_tabController.indexIsChanging) ...[
                    FloatingActionButton(
                      onPressed: _togglePalette,
                      child: Icon(Icons.palette),
                    ),
                  ],
                ],
              ),
            );
          },
    );
  }

  void _createCipher(
    CipherProvider cipherProvider,
    VersionProvider versionProvider,
    SectionProvider sectionProvider,
  ) async {
    try {
      if (widget.cipherId != null) {
        throw Exception(
          AppLocalizations.of(context)!.cannotCreateCipherExistingCipher,
        );
      }

      final cipherId = await cipherProvider.createCipher();
      if (mounted) {
        if (cipherId == null) {
          throw Exception(AppLocalizations.of(context)!.failedToCreateCipher);
        }
      }

      final versionId = await versionProvider.createVersion(cipherId!);
      if (mounted) {
        if (versionId == null) {
          throw Exception(AppLocalizations.of(context)!.failedToCreateVersion);
        }
      }

      await sectionProvider.createSectionsForNewVersion(versionId!);

      if (mounted) {
        Navigator.pop(context, true); // Close screen
        if (widget.versionType == VersionType.import) {
          Navigator.pop(context, true); // Close parser screen
          Navigator.pop(context, true); // Close import screen
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.cipherCreatedSuccessfully,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorCreating}${e.toString()}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _saveCipher(
    CipherProvider cipherProvider,
    VersionProvider versionProvider,
    SectionProvider sectionProvider,
  ) async {
    try {
      await cipherProvider.saveCipher(widget.cipherId!);

      await versionProvider.saveVersion(versionId: widget.versionId);

      await sectionProvider.saveSections(widget.versionId!);

      if (mounted) {
        Navigator.pop(context, true); // Close screen
        if (widget.versionType == VersionType.import) {
          Navigator.pop(context, true); // Close parser screen
          Navigator.pop(context, true); // Close import screen
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.cipherSavedSuccessfully,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(bool deleteCipher) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          deleteCipher: deleteCipher,
          cipherId: widget.cipherId,
          versionId: widget.versionId,
        );
      },
    );
  }

  void _togglePalette() {
    setState(() {
      paletteIsOpen = !paletteIsOpen;
    });
  }
}
