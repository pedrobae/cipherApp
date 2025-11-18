import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/helpers/chords/chords.dart';
import 'package:cipher_app/models/ui/content_token.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/widgets/ciphers/editor/sections/chord_token.dart';

double _fontSize = 20;

class ChordPalette extends StatefulWidget {
  final VoidCallback onClose;

  const ChordPalette({super.key, required this.onClose});

  @override
  State<ChordPalette> createState() => _ChordPaletteState();
}

class _ChordPaletteState extends State<ChordPalette> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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

    // Estimate popup width based on number of variations
    // Each chord token is roughly 50-60px wide + padding
    final estimatedPopupWidth = (chordVariations.length * 60.0) + 16.0;

    // Get the chord button's global position
    final chordButtonX = details.globalPosition.dx - details.localPosition.dx;

    // Calculate horizontal position (center popup above the chord button)
    double leftPosition =
        chordButtonX + (details.localPosition.dx) - (estimatedPopupWidth / 2);

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
                          child: Draggable<ContentToken>(
                            data: ContentToken(
                              text: variation,
                              type: TokenType.chord,
                              position: null,
                            ),
                            feedback: Material(
                              color: Colors.transparent,
                              child: ChordToken(
                                token: ContentToken(
                                  text: variation,
                                  type: TokenType.chord,
                                  position: null,
                                ),
                                sectionColor: colorScheme.primary.withValues(
                                  alpha: .7,
                                ),
                                textStyle: TextStyle(
                                  fontSize: _fontSize,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            onDragStarted: _removeOverlay,
                            child: ChordToken(
                              token: ContentToken(
                                text: variation,
                                type: TokenType.chord,
                                position: null,
                              ),
                              sectionColor: colorScheme.secondaryContainer,
                              textStyle: TextStyle(
                                fontSize: _fontSize - 2,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Acordes - Tom: $musicKey',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
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

                        final token = ContentToken(
                          text: chord,
                          type: TokenType.chord,
                          position: null,
                        );
                        return GestureDetector(
                          onLongPressStart: (details) =>
                              _showChordVariations(context, chord, i, details),
                          child: Draggable<ContentToken>(
                            data: token,
                            feedback: Material(
                              color: Colors.transparent,
                              child: ChordToken(
                                token: token,
                                sectionColor: colorScheme.primary.withValues(
                                  alpha: .7,
                                ),
                                textStyle: TextStyle(
                                  fontSize: _fontSize,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: ChordToken(
                                token: token,
                                sectionColor: colorScheme.primaryContainer,
                                textStyle: TextStyle(
                                  fontSize: _fontSize,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            child: ChordToken(
                              token: token,
                              sectionColor: colorScheme.primary,
                              textStyle: TextStyle(
                                fontSize: _fontSize,
                                color: colorScheme.onPrimary,
                              ),
                            ),
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
            ],
          ),
        );
      },
    );
  }
}
