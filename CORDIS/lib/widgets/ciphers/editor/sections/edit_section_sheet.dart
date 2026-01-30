import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/section.dart';
import 'package:cordis/models/ui/song.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version/local_version_provider.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:cordis/utils/section_constants.dart';
import 'package:provider/provider.dart';

class EditSectionSheet extends StatefulWidget {
  final dynamic versionId;
  final String sectionCode;

  const EditSectionSheet({
    super.key,
    required this.sectionCode,
    required this.versionId,
  });

  @override
  State<EditSectionSheet> createState() => _EditSectionSheetState();
}

class _EditSectionSheetState extends State<EditSectionSheet> {
  late TextEditingController contentCodeController;
  late TextEditingController contentTypeController;
  late TextEditingController contentTextController;
  late Color contentColor;
  late Song _song;
  late Section? section;
  Map<String, Color> availableColors = {};

  @override
  void initState() {
    section = context.read<SectionProvider>().getSection(
      widget.versionId,
      widget.sectionCode,
    );
    _song = Song.fromChordPro(section!.contentText);

    contentCodeController = TextEditingController(text: widget.sectionCode);

    contentTypeController = TextEditingController(text: section!.contentType);

    contentTextController = TextEditingController(
      text: _song.generateChordPro(),
    );

    contentColor = section!.contentColor;

    List<Color> presetColors = [];
    for (var value in commonSectionLabels.values) {
      if (!presetColors.contains(value.color)) {
        availableColors[value.officialLabel] = value.color;
        presetColors.add(value.color);
      }
    }

    // Ensure current color is in available colors
    if (!availableColors.containsValue(contentColor)) {
      availableColors['Current'] = contentColor;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(0),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.editPlaceholder(AppLocalizations.of(context)!.section),
                    style: textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              TextField(
                controller: contentCodeController,
                // enabled: widget.versionId == -1,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.sectionCode,
                ),
              ),
              TextField(
                controller: contentTypeController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.sectionType,
                ),
              ),
              // Default section colors picker
              DropdownButtonFormField<Color>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.sectionColor,
                ),
                initialValue: contentColor,
                items: [
                  ...availableColors.entries.map(
                    (entry) => DropdownMenuItem<Color>(
                      value: entry.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          spacing: 16,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: entry.value,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            Text(entry.key),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: (Color? newColor) {
                  setState(() {
                    contentColor = newColor!;
                  });
                },
              ),
              TextField(
                controller: contentTextController,
                minLines: 4,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.sectionText,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),

              // ACTION BUTTONS
              FilledTextButton(
                text: AppLocalizations.of(context)!.save,
                isDark: true,
                onPressed: () {
                  _updateSection(
                    contentCodeController.text,
                    contentTypeController.text,
                    contentTextController.text,
                    contentColor,
                  );
                  Navigator.of(context).pop();
                },
              ),
              FilledTextButton(
                text: AppLocalizations.of(context)!.delete,
                onPressed: () {
                  _deleteSection();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateSection(String? code, String? type, String? text, Color? color) {
    // Update the section with new values
    context.read<SectionProvider>().cacheUpdatedSection(
      widget.versionId,
      widget.sectionCode,
      newContentCode: code,
      newContentType: type,
      newContentText: text,
      newColor: color,
    );
    // If the content code has changed, update the song structure accordingly
    if (code != null && code != widget.sectionCode) {
      context.read<LocalVersionProvider>().updateSectionCodeInStruct(
        widget.versionId,
        oldCode: widget.sectionCode,
        newCode: code,
      );

      context.read<SectionProvider>().renameSectionKey(
        widget.versionId,
        oldCode: widget.sectionCode,
        newCode: code,
      );
    }
  }

  void _deleteSection() {
    context.read<SectionProvider>().cacheDeleteSection(
      widget.versionId,
      widget.sectionCode,
    );
    context.read<LocalVersionProvider>().removeSectionFromStructByCode(
      widget.versionId,
      widget.sectionCode,
    );
  }
}
