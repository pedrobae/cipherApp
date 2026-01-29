import 'package:cordis/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/helpers/chords/chords.dart';
import 'package:cordis/models/ui/content_token.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/editor/sections/chord_token.dart';

double _fontSize = 20;

class ChordPalette extends StatefulWidget {
  final dynamic versionId;
  final VoidCallback onClose;

  const ChordPalette({
    super.key,
    required this.versionId,
    required this.onClose,
  });
  @override
  State<ChordPalette> createState() => _ChordPaletteState();
}

class _ChordPaletteState extends State<ChordPalette> {
  final TextEditingController _customChordController = TextEditingController();
  String customChord = '';
  final _chordVariationsNotifier = ValueNotifier<List<String>>([]);

  void _showChordVariations(String baseChord, int chordIndex) {
    final chordVariations = ChordHelper().getVariationsForChord(
      baseChord,
      chordIndex,
    );

    if (chordVariations.every(
      (variation) => _chordVariationsNotifier.value.contains(variation),
    )) {
      _chordVariationsNotifier.value = [];
    } else {
      _chordVariationsNotifier.value = chordVariations;
    }
  }

  @override
  void initState() {
    super.initState();
    _customChordController.addListener(() {
      setState(() {
        customChord = _customChordController.text;
      });
    });
  }

  @override
  void dispose() {
    _customChordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VersionProvider, CipherProvider>(
      builder: (context, versionProvider, cipherProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final key =
            versionProvider.getMusicKeyOfVersion(widget.versionId) ??
            cipherProvider
                .getCipherById(
                  versionProvider.getCipherIdOfLocalVersion(widget.versionId),
                )!
                .musicKey;

        final chords = ChordHelper().getChordsForKey(key);

        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(),
            boxShadow: [
              BoxShadow(
                color: colorScheme.surfaceContainerLow,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.commonChordsOfKey(chords[0]),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              // CUSTOM CHORD INPUT
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.customChord,

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        isDense: true,
                      ),
                      cursorHeight: 20,
                      textAlign: TextAlign.center,
                      controller: _customChordController,
                      expands: false,
                    ),
                  ),
                  // CUSTOM CHORD
                  if (customChord.isNotEmpty)
                    _buildDraggableChordToken(
                      customChord,
                      colorScheme.primaryContainer,
                      colorScheme.onPrimaryContainer,
                    ),
                ],
              ),
              ValueListenableBuilder<List<String>>(
                valueListenable: _chordVariationsNotifier,
                builder: (context, chordVariations, child) {
                  if (chordVariations.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.surfaceContainerLowest,
                        ),
                        bottom: BorderSide(
                          color: colorScheme.surfaceContainerLowest,
                        ),
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final variation in chordVariations)
                          _buildDraggableChordToken(
                            variation,
                            colorScheme.primaryContainer,
                            colorScheme.onPrimaryContainer,
                          ),
                      ],
                    ),
                  );
                },
              ),
              // Draggable chords
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < chords.length; i++)
                    Builder(
                      builder: (builder) {
                        final chord = chords[i];
                        return GestureDetector(
                          onLongPress: () => {_showChordVariations(chord, i)},
                          child: _buildDraggableChordToken(
                            chord,
                            colorScheme.primaryContainer,
                            colorScheme.onPrimaryContainer,
                          ),
                        );
                      },
                    ),
                ],
              ),
              // Instruction text
              Text(
                AppLocalizations.of(context)!.draggableChordInstruction,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.chordExpansionInstruction,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Draggable<ContentToken> _buildDraggableChordToken(
    String chord,
    Color sectionColor,
    Color textColor,
  ) {
    final token = ContentToken(text: chord, type: TokenType.chord);
    return Draggable<ContentToken>(
      data: token,
      feedback: Material(
        color: Colors.transparent,
        child: ChordToken(
          token: token,
          sectionColor: sectionColor.withValues(alpha: .7),
          textStyle: TextStyle(fontSize: _fontSize, color: textColor),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: ChordToken(
          token: token,
          sectionColor: sectionColor.withValues(alpha: .4),
          textStyle: TextStyle(
            fontSize: _fontSize,
            color: textColor.withValues(alpha: .4),
          ),
        ),
      ),
      child: ChordToken(
        token: token,
        sectionColor: sectionColor,
        textStyle: TextStyle(fontSize: _fontSize, color: textColor),
      ),
    );
  }
}
