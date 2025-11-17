import 'package:cipher_app/widgets/ciphers/editor/sections/chord_token.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/ui/content_token.dart';
import 'package:cipher_app/services/tokenization_service.dart';

final double _fontSize = 18;

class TokenContentEditor extends StatefulWidget {
  final String sectionCode;
  final String initialContent;
  final Function(String) onContentChanged;
  final Color sectionColor;

  const TokenContentEditor({
    super.key,
    required this.sectionCode,
    required this.initialContent,
    required this.onContentChanged,
    required this.sectionColor,
  });

  @override
  State<TokenContentEditor> createState() => _TokenContentEditorState();
}

class _TokenContentEditorState extends State<TokenContentEditor> {
  final TokenizationService _tokenizer = TokenizationService();
  List<ContentToken> _tokens = [];

  // Store GlobalKeys for each token to track positions
  final Map<int, GlobalKey> _tokenKeys = {};

  @override
  void initState() {
    super.initState();
    _tokens = _tokenizer.tokenize(widget.initialContent);
  }

  @override
  void didUpdateWidget(TokenContentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-tokenize if content changed externally
    if (oldWidget.initialContent != widget.initialContent) {
      _tokens = _tokenizer.tokenize(widget.initialContent);
    }
  }

  void _notifyContentChanged() {
    final newContent = _tokenizer.reconstructContent(_tokens);
    widget.onContentChanged(newContent);
  }

  void _addChord(ContentToken token, int position) {
    final newToken = ContentToken(
      text: token.text,
      type: token.type,
      position: position,
    );

    setState(() {
      _tokens.insert(position, newToken);
    });

    // Check if the token was moved
    if (token.position != null) {
      // Remove token
      int index = token.position!;

      if (index > position) {
        index++;
      }
      _tokens.removeAt(index);
    }

    _notifyContentChanged();
  }

  @override
  Widget build(BuildContext context) {
    final tokenWidgets = <Widget>[];
    for (var i = 0; i < _tokens.length; i++) {
      tokenWidgets.add(_buildTokenWidget(_tokens[i]));
    }

    return Container(
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
    );
  }

  Widget _buildTokenWidget(ContentToken token) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Ensure we have a GlobalKey for this token
    _tokenKeys.putIfAbsent(token.position!, () => GlobalKey());
    switch (token.type) {
      case TokenType.chord:
        // GestureDetector to handle long press to drag transition
        return Draggable<ContentToken>(
          data: token,
          feedback: Material(
            color: Colors.transparent,
            child: ChordToken(
              token: token,
              sectionColor: widget.sectionColor.withValues(alpha: .5),
              textStyle: TextStyle(fontSize: _fontSize, color: Colors.white),
            ),
          ),
          childWhenDragging: SizedBox.shrink(),
          child: ChordToken(
            token: token,
            sectionColor: widget.sectionColor,
            textStyle: TextStyle(fontSize: _fontSize, color: Colors.white),
          ),
        );
      case TokenType.lyric:
      case TokenType.space:
        // Container that contains the lyrics, with a globalKey for drag detection
        return DragTarget<ContentToken>(
          onAcceptWithDetails: (details) {
            _addChord(details.data, token.position!);
          },
          builder: (context, candidateData, rejectedData) {
            if (candidateData.isNotEmpty) {
              return Stack(
                clipBehavior: Clip.none,
                key: _tokenKeys[token.position],
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
                      sectionColor: widget.sectionColor,
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
              key: _tokenKeys[token.position],
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
            _addChord(details.data, token.position!);
          },
          builder: (context, candidateData, rejectedData) {
            if (candidateData.isNotEmpty) {
              return Wrap(
                key: _tokenKeys[token.position],
                children: [
                  ChordToken(
                    token: candidateData.first!,
                    sectionColor: widget.sectionColor,
                    textStyle: TextStyle(
                      fontSize: _fontSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: double.infinity),
                ],
              );
            }
            return SizedBox(width: double.infinity, height: _fontSize);
          },
        );
    }
  }
}
