import 'package:cipher_app/widgets/ciphers/editor/sections/chord_token.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/ui/content_token.dart';
import 'package:cipher_app/services/tokenization_service.dart';

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

  void removeToken(int position) {
    setState(() {
      _tokens.removeAt(position);
    });

    _notifyContentChanged();
  }

  void _addChar(String char, int index) {
    TokenType tokenType;
    switch (char) {
      case '\n':
        tokenType = TokenType.newline;
      case ' ':
      case '\t':
        tokenType = TokenType.space;
      default:
        tokenType = TokenType.lyric;
    }

    final token = ContentToken(text: char, type: tokenType);

    setState(() {
      _tokens.insert(index, token);
    });

    _notifyContentChanged();
  }

  void addChord(String chord, int position) {
    setState(() {
      _tokens.insert(
        position,
        ContentToken(text: chord, type: TokenType.chord),
      );
    });

    _notifyContentChanged();
  }

  Widget _buildToken(ContentToken token, int index) {
    switch (token.type) {
      case TokenType.chord:
        return ChordToken(
          token: token,
          addChord: addChord,
          removeChord: removeToken,
          index: index,
        );

      case TokenType.lyric:
        // STATIC CHARACTER - Drop target only
        return DragTarget<String>(
          onAcceptWithDetails: (details) => addChord(details.data, index),
          builder: (context, candidateData, rejectedData) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: candidateData.isNotEmpty ? 4 : 0,
              ),
              decoration: candidateData.isNotEmpty
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: widget.sectionColor,
                          width: 2,
                        ),
                      ),
                    )
                  : null,
              child: Text(token.text, style: const TextStyle(fontSize: 14)),
            );
          },
        );

      case TokenType.space:
        // STATIC SPACE - Drop target only
        return DragTarget<String>(
          onAcceptWithDetails: (details) => addChord(details.data, index),
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 4, // Smaller width for character-level precision
              height: 16,
              color: candidateData.isNotEmpty
                  ? widget.sectionColor.withValues(alpha: 0.3)
                  : Colors.transparent,
            );
          },
        );

      case TokenType.newline:
        // LINE BREAK - Drop target for placing chords at line start
        return DragTarget<String>(
          onAcceptWithDetails: (details) => addChord(details.data, index),
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              height: candidateData.isNotEmpty ? 24 : 8,
              color: candidateData.isNotEmpty
                  ? widget.sectionColor.withValues(alpha: 0.2)
                  : Colors.transparent,
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 0, // No spacing for character-level precision
        runSpacing: 0,
        children: _tokens.asMap().entries.map((entry) {
          return _buildToken(entry.value, entry.key);
        }).toList(),
      ),
    );
  }
}
