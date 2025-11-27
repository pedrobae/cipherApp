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
    final tokenWidgets = _buildTokenWidgets(_tokens);

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
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                verticalDirection: VerticalDirection.down,
                children: tokenWidgets,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTokenWidgets(List<ContentToken> tokens) {
    if (tokens.isEmpty) {
      return [];
    }

    /// CREATE TOKEN WIDGETS
    final tokenWidgets = <Widget>[];

    // If there is no chord preceding line, add a dragtarget at the start
    if (!_spaceBeforeLyric(0, tokens)) {
      tokenWidgets.add(_buildPrecedingChordDragTarget(0));
    }

    // Build the widgets for each token
    for (var i = 0; i < _tokens.length; i++) {
      tokenWidgets.add(_buildTokenWidget(_tokens[i], i));
      if (_tokens[i].type == TokenType.newline) {
        tokenWidgets.add(const SizedBox(width: double.infinity));
        if (!_spaceBeforeLyric(i + 1, tokens)) {
          tokenWidgets.add(_buildPrecedingChordDragTarget(i + 1));
        }
      }
    }

    // Add a final newline token to create a dragtarget at the end
    tokenWidgets.add(
      _buildTokenWidget(
        ContentToken(text: '\n', type: TokenType.newline),
        _tokens.length,
      ),
    );
    return tokenWidgets;
  }

  Widget _buildTokenWidget(ContentToken token, int position) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Ensure we have a GlobalKey for this token
    _tokenKeys.putIfAbsent(position, () => GlobalKey());
    switch (token.type) {
      case TokenType.chord:
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
      case TokenType.lyric:
      case TokenType.space:
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
                style: TextStyle(
                  fontSize: _fontSize,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          },
        );
      case TokenType.newline:
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
                        bottom: BorderSide(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                  );
          },
        );
    }
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
