import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/widgets/ciphers/editor/sections/chord_token.dart';
import 'package:cipher_app/widgets/ciphers/editor/sections/edit_section_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/ui/content_token.dart';
import 'package:cipher_app/services/tokenization_service.dart';

final double _fontSize = 18;

class TokenContentEditor extends StatefulWidget {
  final Section section;
  final Function(String) onContentChanged;

  const TokenContentEditor({
    super.key,
    required this.onContentChanged,
    required this.section,
  });

  @override
  State<TokenContentEditor> createState() => _TokenContentEditorState();
}

class _TokenContentEditorState extends State<TokenContentEditor> {
  final TokenizationService _tokenizer = TokenizationService();
  List<ContentToken> _tokens = [];
  bool _isDragging = false;

  // Store GlobalKeys for each token to track positions
  final Map<int, GlobalKey> _tokenKeys = {};

  @override
  void initState() {
    super.initState();
    _tokens = _tokenizer.tokenize(widget.section.contentText);
  }

  @override
  void didUpdateWidget(TokenContentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-tokenize if content changed externally
    if (oldWidget.section.contentText != widget.section.contentText) {
      _tokens = _tokenizer.tokenize(widget.section.contentText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.section.contentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.section.contentCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.section.contentType,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      _isDragging
                          ? DragTarget<ContentToken>(
                              onAcceptWithDetails: (details) => {
                                _removeChord(details.data),
                              },
                              builder: (context, candidateData, rejectedData) {
                                if (candidateData.isNotEmpty) {
                                  return Icon(Icons.delete, color: Colors.red);
                                }
                                return Icon(Icons.delete, color: Colors.grey);
                              },
                            )
                          : const SizedBox.shrink(),
                      IconButton(
                        onPressed: () => _openEditSectionDialog(widget.section),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar seção',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Builder(
                builder: (context) {
                  final tokenWidgets = _buildTokenWidgets(
                    context,
                    _tokens,
                    lineSpacing: 8,
                    letterSpacing: 4,
                  );
                  return Stack(children: tokenWidgets);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of positioned widgets, with token widgets as draggable and drag targets
  List<Widget> _buildTokenWidgets(
    BuildContext context,
    List<ContentToken> tokens, {
    double lineSpacing = 8,
    double letterSpacing = 4,
  }) {
    List<Widget> tokenWidgets = [];
    double currentX = 0;
    double currentY = 0;
    double maxWidth = MediaQuery.of(context).size.width;
    lineSpacing =
        lineSpacing + _fontSize; // To accomodate the chords above the lyrics

    // Track word widgets to roll back if line break occurs
    List<Widget> wordWidgets = [];

    // Check if we need to add a preceding chord drag target at the start
    if (!_spaceBeforeLyric(0, tokens)) {
      tokenWidgets.add(Positioned(child: _buildPrecedingChordDragTarget(0)));
      currentX += 24; // Width of the preceding chord drag target
    }

    // Build the widgets for each token
    for (var token in tokens) {
      switch (token.type) {
        case TokenType.chord:
          // Position the chord token widget
          wordWidgets.add(
            Positioned(
              left: currentX,
              top: currentY - _fontSize, // Position above the lyrics
              child: _buildDraggableChord(
                token,
                tokenWidgets.length + wordWidgets.length,
              ),
            ),
          );
          break;

        case TokenType.lyric:
          // Measure the size of the token widget
          final textPainter = TextPainter(
            text: TextSpan(
              text: token.text,
              style: TextStyle(fontSize: _fontSize),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();

          final tokenWidth = textPainter.width;
          final tokenHeight = textPainter.height;

          // Check if adding this token exceeds the max width
          if (currentX + tokenWidth > maxWidth) {
            // Move to next line
            currentX = 0;
            currentY += tokenHeight + lineSpacing;
            // Add all word widgets to the main list and clear
            tokenWidgets.addAll(wordWidgets);
            wordWidgets.clear();
          }

          // Position the token widget
          wordWidgets.add(
            Positioned(
              left: currentX,
              top: currentY,
              child: _buildLyricDragTarget(
                token,
                tokenWidgets.length + wordWidgets.length,
              ),
            ),
          );

          // Update currentX for next token
          currentX += tokenWidth + letterSpacing; // Add some horizontal spacing
          break;

        case TokenType.space:
          // Add all word widgets to the main list and clear
          tokenWidgets.addAll(wordWidgets);
          wordWidgets.clear();

          // Measure the size of the space token widget
          final textPainter = TextPainter(
            text: TextSpan(
              text: ' ',
              style: TextStyle(fontSize: _fontSize),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();

          final tokenWidth = textPainter.width;

          // Check if adding the space token exceeds the max width
          if (currentX + tokenWidth > maxWidth) {
            // Add space drag target at the end of the line
            tokenWidgets.add(
              Positioned(
                left: currentX,
                top: currentY,
                child: _buildSpaceDragTarget(
                  token,
                  tokenWidgets.length + wordWidgets.length,
                  maxWidth - currentX,
                ),
              ),
            );

            // Move to next line
            currentX = 0;
            currentY += textPainter.height + lineSpacing;
          }

          // Position the space token widget
          tokenWidgets.add(
            Positioned(
              left: currentX,
              top: currentY,
              child: _buildSpaceDragTarget(
                token,
                tokenWidgets.length + wordWidgets.length,
                tokenWidth,
              ),
            ),
          );

          // Update currentX for next token
          currentX += tokenWidth + letterSpacing; // Add some horizontal spacing
          break;

        case TokenType.newline:
          // Add all word widgets to the main list and clear
          tokenWidgets.addAll(wordWidgets);
          wordWidgets.clear();

          // Add space drag target that fills the rest of the line
          tokenWidgets.add(
            Positioned(
              left: currentX,
              top: currentY,
              child: _buildSpaceDragTarget(
                token,
                tokenWidgets.length + wordWidgets.length,
                maxWidth - currentX,
              ),
            ),
          );

          // Move to next line
          currentX = 0;
          currentY += _fontSize + lineSpacing; // Add some vertical spacing

          // Check if we need to add a preceding chord drag target at the start of the next verse
          if (!_spaceBeforeLyric(
            tokenWidgets.length +
                wordWidgets.length +
                1, // Next token index after newline
            tokens,
          )) {
            tokenWidgets.add(
              Positioned(
                child: _buildPrecedingChordDragTarget(
                  tokenWidgets.length + wordWidgets.length + 1,
                ),
              ),
            );
            currentX += 24; // Width of the preceding chord drag target
          }
          break;
      }
    }
    return tokenWidgets;
  }

  Widget _buildDraggableChord(ContentToken token, int position) {
    // Assign position to token for reference
    token.position = position;

    // GestureDetector to handle long press to drag transition
    return Draggable<ContentToken>(
      data: token,
      onDragStarted: _toggleDrag,
      onDragEnd: (details) => _toggleDrag(),
      feedback: Material(
        color: Colors.transparent,
        child: ChordToken(
          token: token,
          sectionColor: widget.section.contentColor.withValues(alpha: .5),
          textStyle: TextStyle(fontSize: _fontSize, color: Colors.white),
        ),
      ),
      childWhenDragging: SizedBox.shrink(),
      child: ChordToken(
        token: token,
        sectionColor: widget.section.contentColor,
        textStyle: TextStyle(fontSize: _fontSize, color: Colors.white),
      ),
    );
  }

  Widget _buildLyricDragTarget(ContentToken token, int position) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Container that contains the lyrics, with a globalKey for drag detection
    return DragTarget<ContentToken>(
      onAcceptWithDetails: (details) {
        _addChord(details.data, position);
        if (details.data.position != null) {
          int index = details.data.position!;
          if (index > position) {
            index += 1;
          }
          _removeChordAt(index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isNotEmpty) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                token.text,
                style: TextStyle(
                  fontSize: _fontSize,
                  color: colorScheme.onSurface,
                ),
              ),
              Positioned(
                top: -_fontSize,
                child: ChordToken(
                  token: candidateData.first!,
                  sectionColor: widget.section.contentColor,
                  textStyle: TextStyle(
                    fontSize: _fontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          key: _tokenKeys[position],
          child: Text(
            token.text,
            style: TextStyle(fontSize: _fontSize, color: colorScheme.onSurface),
          ),
        );
      },
    );
  }

  Widget _buildSpaceDragTarget(ContentToken token, int position, double width) {
    // Container that is sized to the lowest between space or remainder of the line
    return DragTarget<ContentToken>(
      onAcceptWithDetails: (details) {
        _addChord(details.data, position);
        if (details.data.position != null) {
          int index = details.data.position!;
          if (index > position) {
            index += 1;
          }
          _removeChordAt(index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isNotEmpty) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -_fontSize,
                child: ChordToken(
                  token: candidateData.first!,
                  sectionColor: widget.section.contentColor,
                  textStyle: TextStyle(
                    fontSize: _fontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }
        return Container(key: _tokenKeys[position], width: width);
      },
    );
  }

  void _openEditSectionDialog(Section section) {
    showDialog(
      context: context,
      builder: (context) => EditSectionDialog(section: section),
    );
  }

  void _toggleDrag() {
    setState(() {
      _isDragging = !_isDragging;
    });
  }

  void _notifyContentChanged() {
    final newContent = _tokenizer.reconstructContent(
      _tokens, // Exclude the last newline token
    );
    widget.onContentChanged(newContent);
  }

  void _addChord(ContentToken token, int position) {
    setState(() {
      _tokens.insert(position, token);
    });
    _notifyContentChanged();
  }

  void _addPrecedingChord(ContentToken token, int position) {
    final emptySpaceToken = ContentToken(text: ' ', type: TokenType.space);
    final newToken = ContentToken(text: token.text, type: token.type);

    setState(() {
      _tokens.insert(position, emptySpaceToken);
      _tokens.insert(position, newToken);
    });

    _notifyContentChanged();
  }

  void _removeChord(ContentToken token) {
    setState(() {
      _tokens.remove(token);
    });
    _notifyContentChanged();
  }

  void _removeChordAt(int position) {
    setState(() {
      _tokens.removeAt(position);
    });
    _notifyContentChanged();
  }

  DragTarget<ContentToken> _buildPrecedingChordDragTarget(int position) =>
      DragTarget<ContentToken>(
        onAcceptWithDetails: (details) {
          _addPrecedingChord(details.data, position);
          if (details.data.position != null) {
            int index = details.data.position!;
            if (index > position) {
              index += 2; // Adjust for two insertions (Chord + Space)
            }
            _removeChordAt(index);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return candidateData.isNotEmpty
              ? ChordToken(
                  token: candidateData.first!,
                  sectionColor: widget.section.contentColor,
                  textStyle: TextStyle(
                    fontSize: _fontSize,
                    color: Colors.white,
                  ),
                )
              : Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      bottom: BorderSide(color: Colors.grey.shade400, width: 2),
                    ),
                  ),
                );
        },
      );

  bool _spaceBeforeLyric(int position, List<ContentToken> tokens) {
    // Check if there is a preceding chord (space before lyrics)
    List<ContentToken> start = [];

    for (
      int i = position;
      (i < tokens.length && tokens[i].type != TokenType.lyric);
      i++
    ) {
      start.add(tokens[i]);
    }

    bool hasPrecedingChord = start.any(
      (token) => token.type == TokenType.space,
    );

    return hasPrecedingChord;
  }
}
