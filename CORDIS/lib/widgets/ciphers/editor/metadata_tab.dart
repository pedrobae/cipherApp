import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/editor/select_key_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum InfoField { title, author, versionName, key, bpm, language, tags }

class MetadataTab extends StatefulWidget {
  final int? cipherId;
  final dynamic versionId;
  final VersionType versionType;
  final bool isEnabled;

  const MetadataTab({
    super.key,
    this.cipherId,
    this.versionId,
    required this.versionType,
    this.isEnabled = true,
  });

  @override
  State<MetadataTab> createState() => _MetadataTabState();
}

class _MetadataTabState extends State<MetadataTab> {
  Map<InfoField, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < InfoField.values.length; i++) {
      controllers[InfoField.values[i]] = TextEditingController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithProviderData();
    });
  }

  void _syncWithProviderData() {
    if (mounted) {
      final versionProvider = context.read<VersionProvider>();
      final cipherProvider = context.read<CipherProvider>();

      switch (widget.versionType) {
        case VersionType.cloud:
          final version = versionProvider.getCloudVersionByFirebaseId(
            widget.versionId!,
          )!;

          for (var field in InfoField.values) {
            switch (field) {
              case InfoField.title:
                controllers[field]!.text = version.title;
                break;
              case InfoField.author:
                controllers[field]!.text = version.author;
                break;
              case InfoField.versionName:
                controllers[field]!.text = version.versionName;
                break;
              case InfoField.bpm:
                controllers[field]!.text = version.bpm.toString();
                break;
              case InfoField.key:
                controllers[field]!.text =
                    version.transposedKey ?? version.originalKey;
                break;
              case InfoField.language:
                controllers[field]!.text = version.language;
                break;
              case InfoField.tags:
                // THIS CONTROLLER IS NOT USED, ADDING TAGS IS HANDLED BY A BOTTOM SHEET
                break;
            }
          }
        case VersionType.local:
        case VersionType.import:
          final cipher = cipherProvider.getCipherById(widget.cipherId ?? -1)!;
          final version = versionProvider.getLocalVersionById(
            (widget.versionId as int?) ?? -1,
          )!;

          for (var field in InfoField.values) {
            switch (field) {
              case InfoField.title:
                controllers[field]!.text = cipher.title;
                break;
              case InfoField.author:
                controllers[field]!.text = cipher.author;
                break;
              case InfoField.versionName:
                controllers[field]!.text = version.versionName;
                break;
              case InfoField.bpm:
                controllers[field]!.text = version.bpm.toString();
                break;
              case InfoField.key:
                controllers[field]!.text =
                    version.transposedKey ?? cipher.musicKey;
                break;
              case InfoField.language:
                controllers[field]!.text = cipher.language;
                break;
              case InfoField.tags:
                // THIS CONTROLLER IS NOT USED, ADDING TAGS IS HANDLED BY A BOTTOM SHEET
                break;
            }
          }
        case VersionType.playlist:
          final cipher = cipherProvider.getCipherById(widget.cipherId ?? -1)!;

          final version = versionProvider.getLocalVersionById(-1)!;

          for (var field in InfoField.values) {
            switch (field) {
              case InfoField.title:
                controllers[field]!.text = cipher.title;
                break;
              case InfoField.author:
                controllers[field]!.text = cipher.author;
                break;
              case InfoField.versionName:
                controllers[field]!.text = version.versionName;
                break;
              case InfoField.bpm:
                controllers[field]!.text = version.bpm.toString();
                break;
              case InfoField.key:
                controllers[field]!.text =
                    version.transposedKey ?? cipher.musicKey;
                break;
              case InfoField.language:
                controllers[field]!.text = cipher.language;
                break;
              case InfoField.tags:
                // THIS CONTROLLER IS NOT USED, ADDING TAGS IS HANDLED BY A BOTTOM SHEET
                break;
            }
          }
        case VersionType.brandNew:
          // Do nothing for brand new versions
          break;
      }
    }
  }

  TextEditingController _getController(InfoField field) {
    return controllers[field]!;
  }

  String _getLabel(InfoField field) {
    switch (field) {
      case InfoField.title:
        return AppLocalizations.of(context)!.title;
      case InfoField.author:
        return AppLocalizations.of(context)!.author;
      case InfoField.versionName:
        return AppLocalizations.of(context)!.versionName;
      case InfoField.bpm:
        return AppLocalizations.of(context)!.bpm;
      case InfoField.key:
        return AppLocalizations.of(context)!.musicKey;
      case InfoField.language:
        return AppLocalizations.of(context)!.language;
      case InfoField.tags:
        return AppLocalizations.of(context)!.tags;
    }
  }

  bool _isEnabled(SelectionProvider selectionProvider, InfoField field) {
    switch (field) {
      case InfoField.title:
      case InfoField.versionName:
      case InfoField.author:
      case InfoField.tags:
        if (!widget.isEnabled) return false;
        return !selectionProvider.isSelectionMode;
      case InfoField.bpm:
      case InfoField.key:
      case InfoField.language:
        return true;
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CipherProvider, VersionProvider>(
      builder: (context, cipherProvider, versionProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.0,
          children: [
            for (var field in InfoField.values)
              switch (field) {
                InfoField.tags => SizedBox.shrink(), // TODO: Tags Field
                InfoField.bpm => _buildIntPicker(
                  context: context,
                  cipherProvider: cipherProvider,
                  versionProvider: versionProvider,
                  field: field,
                  min: 20,
                  max: 300,
                ),
                InfoField.key => _buildKeySelector(
                  context: context,
                  cipherProvider: cipherProvider,
                  versionProvider: versionProvider,
                  field: field,
                ),
                _ => _buildTextField(
                  context: context,
                  cipherProvider: cipherProvider,
                  versionProvider: versionProvider,
                  field: field,
                  maxLines: 1,
                ),
              },
          ],
        );
      },
    );
  }

  Widget _buildIntPicker({
    required BuildContext context,
    required CipherProvider cipherProvider,
    required VersionProvider versionProvider,
    required InfoField field,
    required int min,
    required int max,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          _getLabel(field),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        // TODO - implement integer picker
        SizedBox.shrink(),
      ],
    );
  }

  Widget _buildKeySelector({
    required BuildContext context,
    required CipherProvider cipherProvider,
    required VersionProvider versionProvider,
    required InfoField field,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          _getLabel(field),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return SelectKeySheet(controller: _getController(field));
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.surfaceContainerLowest,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListenableBuilder(
                  listenable: _getController(field),
                  builder: (context, child) {
                    return Text(
                      _getController(field).text.isEmpty
                          ? AppLocalizations.of(context)!.keyHint
                          : _getController(field).text,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required CipherProvider cipherProvider,
    required VersionProvider versionProvider,
    required InfoField field,
    int? maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          _getLabel(field),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        TextFormField(
          onChanged: (value) {
            switch (widget.versionType) {
              case VersionType.cloud:
                versionProvider.cacheCloudMetadataUpdate(
                  widget.versionId!,
                  field,
                  value,
                );
                break;
              case VersionType.local:
                cipherProvider.cacheCipherUpdates(
                  widget.cipherId!,
                  field,
                  value,
                );
                break;
              case VersionType.brandNew:
              case VersionType.import:
              case VersionType.playlist:
                cipherProvider.cacheCipherUpdates(
                  widget.cipherId ?? -1,
                  field,
                  value,
                );
                break;
            }
          },
          controller: _getController(field),
          maxLines: maxLines,
          enabled: _isEnabled(context.read<SelectionProvider>(), field),
          decoration: InputDecoration(
            visualDensity: VisualDensity.compact,
            hintText:
                '${AppLocalizations.of(context)!.hintPrefixO}${_getLabel(field)}${AppLocalizations.of(context)!.hintSuffix}',
            hintStyle: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerLowest,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
