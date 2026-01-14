import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum InfoField { title, author, versionName, bpm, musicKey, language, duration }

class InfoTab extends StatefulWidget {
  final int? cipherId;
  final String? versionId;
  final VersionType versionType;

  const InfoTab({
    super.key,
    this.cipherId,
    this.versionId,
    required this.versionType,
  });

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  Map<InfoField, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < InfoField.values.length; i++) {
      controllers[InfoField.values[i]] = TextEditingController();
    }
    _syncWithProviderData();
  }

  void _syncWithProviderData() {
    if (mounted) {
      switch (widget.versionType) {
        case VersionType.cloud:
          final versionProvider = context.read<VersionProvider>();
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
                controllers[field]!.text = version.bpm;
                break;
              case InfoField.musicKey:
                controllers[field]!.text =
                    version.transposedKey ?? version.originalKey;
                break;
              case InfoField.language:
                controllers[field]!.text = version.language;
                break;
              case InfoField.duration:
                controllers[field]!.text = version.duration;
                break;
            }
          }
        case VersionType.local:
        case VersionType.import:
          final cipherProvider = context.read<CipherProvider>();
          final cipher = cipherProvider.getCipherById(widget.cipherId ?? -1)!;

          final versionProvider = context.read<VersionProvider>();
          final version = versionProvider.getVersionById(
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
                controllers[field]!.text = cipher.bpm;
                break;
              case InfoField.musicKey:
                controllers[field]!.text =
                    version.transposedKey ?? cipher.musicKey;
                break;
              case InfoField.language:
                controllers[field]!.text = cipher.language;
                break;
              case InfoField.duration:
                controllers[field]!.text = cipher.duration;
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
      case InfoField.musicKey:
        return AppLocalizations.of(context)!.musicKey;
      case InfoField.language:
        return AppLocalizations.of(context)!.language;
      case InfoField.duration:
        return AppLocalizations.of(context)!.duration;
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
              _buildTextField(
                context: context,
                cipherProvider: cipherProvider,
                versionProvider: versionProvider,
                field: field,
                maxLines: 1,
              ),
          ],
        );
      },
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
              case VersionType.brandNew:
              case VersionType.import:
                cipherProvider.cacheCipherUpdates(-1, field, value);
                break;
            }
          },
          controller: _getController(field),
          maxLines: maxLines,
          decoration: InputDecoration(
            visualDensity: VisualDensity.compact,
            hintText:
                '${AppLocalizations.of(context)!.hintPrefixO}${_getLabel(field)}${AppLocalizations.of(context)!.hintSuffix}',
            hintStyle: TextStyle(color: colorScheme.surfaceContainerLowest),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerLowest,
                width: 1,
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
