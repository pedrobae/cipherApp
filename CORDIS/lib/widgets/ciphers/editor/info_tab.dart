import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum InfoField { title, author, bpm, musicKey, language, duration }

class InfoTab extends StatefulWidget {
  final int? cipherId;
  final String? versionId;

  const InfoTab({super.key, this.cipherId, this.versionId});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final bpmController = TextEditingController();
  final musicKeyController = TextEditingController();
  final languageController = TextEditingController();
  final durationController = TextEditingController();

  late bool isCloud;

  @override
  void initState() {
    super.initState();
    if (widget.versionId != null) {
      isCloud = true;
    } else {
      isCloud = false;
    }
    _syncWithProviderData();
  }

  void _syncWithProviderData() {
    if (mounted) {
      if (isCloud) {
        final versionProvider = context.read<VersionProvider>();
        final version = versionProvider.getCloudVersionByFirebaseId(
          widget.versionId!,
        )!;

        titleController.text = version.title;
        authorController.text = version.author;
        bpmController.text = version.bpm;
        musicKeyController.text = version.transposedKey ?? version.originalKey;
        languageController.text = version.language;
        durationController.text = version.duration;
      } else {
        final cipherProvider = context.read<CipherProvider>();
        final cipher = cipherProvider.getCipherFromCache(widget.cipherId!)!;

        titleController.text = cipher.title;
        authorController.text = cipher.author;
        bpmController.text = cipher.bpm;
        musicKeyController.text = cipher.musicKey;
        languageController.text = cipher.language;
        durationController.text = cipher.duration;
      }
    }
  }

  TextEditingController _getController(InfoField field) {
    switch (field) {
      case InfoField.title:
        return titleController;
      case InfoField.author:
        return authorController;
      case InfoField.bpm:
        return bpmController;
      case InfoField.musicKey:
        return musicKeyController;
      case InfoField.language:
        return languageController;
      case InfoField.duration:
        return durationController;
    }
  }

  String _getLabel(InfoField field) {
    switch (field) {
      case InfoField.title:
        return AppLocalizations.of(context)!.title;
      case InfoField.author:
        return AppLocalizations.of(context)!.author;
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
    titleController.dispose();
    authorController.dispose();
    bpmController.dispose();
    musicKeyController.dispose();
    languageController.dispose();
    durationController.dispose();
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildTextField(
                  context: context,
                  cipherProvider: cipherProvider,
                  versionProvider: versionProvider,
                  field: field,
                  maxLines: 1,
                ),
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

    return TextFormField(
      onChanged: (value) {
        if (isCloud) {
          versionProvider.cacheCloudMetadataUpdate(
            widget.versionId!,
            field,
            value,
          );
        } else {
          cipherProvider.cacheCipherUpdates(widget.cipherId!, field, value);
        }
      },
      controller: _getController(field),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: _getLabel(field),
        hintText: '${_getLabel(field)}...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
