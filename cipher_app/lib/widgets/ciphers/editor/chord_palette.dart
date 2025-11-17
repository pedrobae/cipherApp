import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/ui/content_token.dart';
import 'package:cipher_app/widgets/ciphers/editor/sections/chord_token.dart';
import 'package:provider/provider.dart';

class ChordPalette extends StatelessWidget {
  final VoidCallback onClose;

  const ChordPalette({super.key, required this.onClose});

  /// Generate chords for the current key
  /// Returns major scale chords (I, ii, iii, IV, V, vi, vii°)
  List<String> _getChordsForKey(String key) {
    // Map of major keys to their scale chords
    final Map<String, List<String>> keyChords = {
      'C': ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'Bdim'],
      'D': ['D', 'Em', 'F#m', 'G', 'A', 'Bm', 'C#dim'],
      'E': ['E', 'F#m', 'G#m', 'A', 'B', 'C#m', 'D#dim'],
      'F': ['F', 'Gm', 'Am', 'Bb', 'C', 'Dm', 'Edim'],
      'G': ['G', 'Am', 'Bm', 'C', 'D', 'Em', 'F#dim'],
      'A': ['A', 'Bm', 'C#m', 'D', 'E', 'F#m', 'G#dim'],
      'B': ['B', 'C#m', 'D#m', 'E', 'F#', 'G#m', 'A#dim'],
      // Add flat keys
      'Bb': ['Bb', 'Cm', 'Dm', 'Eb', 'F', 'Gm', 'Adim'],
      'Eb': ['Eb', 'Fm', 'Gm', 'Ab', 'Bb', 'Cm', 'Ddim'],
      'Ab': ['Ab', 'Bbm', 'Cm', 'Db', 'Eb', 'Fm', 'Gdim'],
      'Db': ['Db', 'Ebm', 'Fm', 'Gb', 'Ab', 'Bbm', 'Cdim'],
      'Gb': ['Gb', 'Abm', 'Bbm', 'Cb', 'Db', 'Ebm', 'Fdim'],
    };

    // Return chords for key, or default C major if not found
    return keyChords[key] ?? keyChords['C']!;
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
        final chords = _getChordsForKey(musicKey);

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
                    onPressed: onClose,
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
                children: chords.asMap().entries.map((entry) {
                  final chord = entry.value;
                  final token = ContentToken(
                    text: chord,
                    type: TokenType.chord,
                    position: null,
                  );
                  return Draggable<ContentToken>(
                    data: token,
                    feedback: Material(
                      color: Colors.transparent,
                      child: ChordToken(
                        token: token,
                        sectionColor: colorScheme.primary.withValues(alpha: .7),
                        textStyle: TextStyle(
                          fontSize: 16,
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
                          fontSize: 16,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    child: ChordToken(
                      token: token,
                      sectionColor: colorScheme.primary,
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

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
