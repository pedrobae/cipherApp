import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/helpers/chords/chords.dart';
import 'package:cordis/models/ui/content_token.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/editor/sections/chord_token.dart';

double _fontSize = 20;

class ChordPalette extends StatefulWidget {
  final VoidCallback onClose;

  const ChordPalette({super.key, required this.onClose});

  @override
  State<ChordPalette> createState() => _ChordPaletteState();
}

class _ChordPaletteState extends State<ChordPalette> {
  OverlayEntry? _overlayEntry;
  final TextEditingController _customChordController = TextEditingController();
  String _customChord = '';

  @override
  void initState() {
    super.initState();
    _customChordController.addListener(() {
      setState(() {
        _customChord = _customChordController.text;
      });
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _customChordController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VersionProvider, CipherProvider>(
      builder: (context, versionProvider, cipherProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final musicKey =
            versionProvider.currentVersion.transposedKey ??
            cipherProvider.currentCipher.musicKey;
        final chords = ChordHelper().getChordsForKey(musicKey);

        return Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 220),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                spacing: 4,
                children: [
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Acordes - Tom: ${chords[0]}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // CUSTOM CHORD INPUT
                  SizedBox(
                    width: 80,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Personalizado',

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
                  if (_customChord.isNotEmpty)
                    _buildDraggableChordToken(
                      _customChord,
                      colorScheme.primaryContainer,
                      colorScheme.onPrimaryContainer,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    color: colorScheme.onSurface,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Divider(),
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
                          onLongPressStart: (details) =>
                              _showChordVariations(context, chord, i, details),
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
                'Arraste os acordes para as letras',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Toque e segure um acorde para ver variações',
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

  void _showChordVariations(
    BuildContext context,
    String baseChord,
    int chordIndex,
    LongPressStartDetails details,
  ) {
    _removeOverlay(); // Remove any existing overlay

    final chordVariations = ChordHelper().getVariationsForChord(
      baseChord,
      chordIndex,
    );

    if (chordVariations.isEmpty) return;

    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    final estimatedPopupWidth = (chordVariations.length * 60.0) + 16.0;
    // Calculate horizontal position (center popup above the chord button)
    double leftPosition = details.globalPosition.dx - (estimatedPopupWidth / 2);

    // Prevent overflow on left edge
    if (leftPosition < 8) {
      leftPosition = 8;
    }

    // Prevent overflow on right edge
    if (leftPosition + estimatedPopupWidth > screenSize.width - 8) {
      leftPosition = screenSize.width - estimatedPopupWidth - 8;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier to dismiss on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Variations popup
          Positioned(
            left: leftPosition,
            top: details.globalPosition.dy - details.localPosition.dy - 40,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final variation in chordVariations)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            _removeOverlay();
                            // Variation selected - could trigger insertion here if needed
                          },
                          child: _buildDraggableChordToken(
                            variation,
                            colorScheme.primaryContainer,
                            colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
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
