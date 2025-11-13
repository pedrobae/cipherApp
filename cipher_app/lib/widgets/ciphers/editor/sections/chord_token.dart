import 'package:cipher_app/models/ui/content_token.dart';
import 'package:flutter/material.dart';

class ChordToken extends StatelessWidget {
  final ContentToken token;
  final Function(String, int) addChord;
  final Function(int) removeChord;
  final int index;

  const ChordToken({
    super.key,
    required this.token,
    required this.index,
    required this.addChord,
    required this.removeChord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DragTarget<String>(
      onAcceptWithDetails: (details) => addChord(details.data, index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<String>(
          data: token.text,
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                token.text,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                token.text,
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          onDragStarted: () {
            // Remove chord from current position when drag starts
            removeChord(index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(8),
              border: candidateData.isNotEmpty
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Text(
              token.text,
              style: TextStyle(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}
