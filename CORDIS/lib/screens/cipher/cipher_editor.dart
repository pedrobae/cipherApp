import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/parser_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/widgets/ciphers/editor/chord_palette.dart';
import 'package:cordis/widgets/ciphers/editor/delete_dialog.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/widgets/ciphers/editor/metadata_tab.dart';
import 'package:cordis/widgets/ciphers/editor/sections_tab.dart';

class CipherEditor extends StatefulWidget {
  final int? cipherId; // Null for new cipher
  final dynamic versionId; // Null for new version // could be int or String
  final int? playlistId;
  final VersionType versionType;
  final bool isEnabled;

  const CipherEditor({
    super.key,
    this.cipherId,
    this.versionId,
    this.playlistId,
    required this.versionType,
    this.isEnabled = true,
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
    final sectionProvider = context.read<SectionProvider>();

    switch (widget.versionType) {
      case VersionType.import:
        final parserProvider = context.read<ParserProvider>();

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
        await sectionProvider.loadLocalSections(widget.versionId!);
        break;
      case VersionType.brandNew:
      // Nothing to load for brand new cipher/version
      case VersionType.playlist:
        final playlistProvider = context.read<PlaylistProvider>();

        final String playlistName = playlistProvider
            .getPlaylistById(widget.playlistId!)!
            .name;

        // Create a new copy of the version for editing
        // Load the version
        final Version originalVersion = versionProvider.getVersionById(
          widget.versionId!,
        )!;
        // Create a copy of the version in cache
        versionProvider.setNewVersionInCache(
          originalVersion.copyWith(
            versionName: AppLocalizations.of(
              context,
            )!.playlistVersionName(playlistName),
          ),
        );

        // Load the cipher
        await cipherProvider.loadCipher(widget.cipherId!);

        // Load the sections in cache
        await sectionProvider.loadLocalSections(widget.versionId!);

        sectionProvider.setNewSectionsInCache(
          -1,
          sectionProvider.getSections(widget.versionId!),
        );
        break;
    }
  }

  void _navigateStartTab() {
    switch (widget.versionType) {
      case VersionType.import:
      case VersionType.brandNew:
        _tabController.index = 1; // Sections tab
        break;
      case VersionType.playlist:
      case VersionType.cloud:
      case VersionType.local:
        _tabController.index = 0; // Info tab
        break;
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

    return Consumer6<
      CipherProvider,
      VersionProvider,
      SectionProvider,
      SelectionProvider,
      NavigationProvider,
      PlaylistProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            versionProvider,
            sectionProvider,
            selectionProvider,
            navigationProvider,
            playlistProvider,
            child,
          ) {
            return Scaffold(
              appBar: AppBar(
                leading: selectionProvider.isSelectionMode
                    ? BackButton(
                        onPressed: () {
                          navigationProvider.pop();
                          selectionProvider.toggleItemSelection(
                            widget.versionId!,
                          );
                          selectionProvider.enableSelectionMode();
                        },
                      )
                    : null,
                title: Text(
                  selectionProvider.isSelectionMode
                      ? AppLocalizations.of(context)!.addSongToLibrary
                      : AppLocalizations.of(context)!.cipherEditorTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actions: [
                  if (selectionProvider.isSelectionMode)
                    TextButton(
                      onPressed: () async {
                        for (dynamic versionId
                            in selectionProvider.selectedItemIds) {
                          if (versionId.runtimeType == int) {
                            // LOCAL VERSION: Create a copy of the version in the database
                            versionId = await versionProvider.createVersion(
                              null,
                            );
                          } else {
                            // CLOUD VERSION: Upsert the version locally and add to playlist
                            final cipherId = await cipherProvider.upsertCipher(
                              Cipher.fromVersionDto(
                                versionProvider.cloudVersions[versionId]!,
                              ),
                            );

                            versionId = await versionProvider.upsertVersion(
                              versionProvider.cloudVersions[versionId]!
                                  .toDomain(cipherId: cipherId),
                            );
                          }
                          // Create Section entries for the new version
                          await sectionProvider.createSections(versionId);
                          await sectionProvider.loadLocalSections(versionId);
                          playlistProvider.addVersionToPlaylist(
                            selectionProvider.targetId!,
                            versionId,
                          );
                        }
                        selectionProvider.clearSelection();
                        navigationProvider.pop(); // Close editor
                        navigationProvider.pop(); // Close cipher library
                      },
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontSize: 20,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
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
                              MetadataTab(
                                cipherId: widget.cipherId,
                                versionId: widget.versionId,
                                versionType: widget.versionType,
                                isEnabled: widget.isEnabled,
                              ),
                            ],
                          ),
                        ),
                        // Content Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: SectionsTab(
                            versionId:
                                widget.versionType == VersionType.playlist
                                ? -1
                                : widget.versionId,
                            versionType: widget.versionType,
                            isEnabled: widget.isEnabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save and Delete/Cancel Buttons
                  if (!selectionProvider.isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  navigationProvider,
                                );
                              } else {
                                _saveCipher(
                                  cipherProvider,
                                  versionProvider,
                                  sectionProvider,
                                  navigationProvider,
                                );
                              }
                            },
                            text: AppLocalizations.of(context)!.save,
                          ),
                          FilledTextButton(
                            onPressed: () {
                              if (widget.versionType == VersionType.import ||
                                  widget.versionType == VersionType.brandNew) {
                                navigationProvider.pop();
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
              floatingActionButton: selectionProvider.isSelectionMode
                  ? null
                  : Column(
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
    NavigationProvider navigation,
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

      await sectionProvider.createSections(versionId!);

      if (mounted) {
        navigation.pop(); // Close screen
        if (widget.versionType == VersionType.import) {
          navigation.pop(); // Close import screen
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
              AppLocalizations.of(context)!.errorMessage(
                AppLocalizations.of(context)!.create,
                e.toString(),
              ),
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
    NavigationProvider navigationProvider,
  ) async {
    try {
      await cipherProvider.saveCipher(widget.cipherId!);

      await versionProvider.saveVersion(versionId: widget.versionId);

      await sectionProvider.saveSections(widget.versionId!);

      if (mounted) {
        navigationProvider.pop(); // Close screen
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
