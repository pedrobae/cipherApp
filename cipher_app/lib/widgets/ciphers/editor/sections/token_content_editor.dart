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

  Widget _buildChordTarget(int index) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) => addChord(details.data, index),
      builder: (context, candidateData, rejectedData) {
        return SizedBox();
      },
    );
  }

  Widget _buildTokenWidget(ContentToken token, int index) {
    switch (token.type) {
      case TokenType.chord:
        // Draggable chord token
        return LongPressDraggable<String>(
          data: token.text,
          feedback: SizedBox(),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: ChordToken(token: token, sectionColor: widget.sectionColor),
          ),
          onDragStarted: () {
            removeToken(index);
          },
          child: ChordToken(token: token, sectionColor: widget.sectionColor),
        );
      case TokenType.lyric:
      case TokenType.space:
      case TokenType.newline:
        // Lyric text
        return Text(token.text, style: const TextStyle(fontSize: 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenWidgets = <Widget>[];
    for (var i = 0; i <= _tokens.length; i++) {
      // Add chord target before each token widget
      tokenWidgets.add(_buildChordTarget(i));
      tokenWidgets.add(_buildTokenWidget(_tokens[i], i));
    }
    // Add chord target at the end
    tokenWidgets.add(_buildChordTarget(_tokens.length));

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
        crossAxisAlignment: WrapCrossAlignment.end,
        children: tokenWidgets,
      ),
    );
  }
}
