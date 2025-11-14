import 'package:cipher_app/widgets/ciphers/editor/sections/chord_token.dart';
import 'package:flutter/foundation.dart';
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
  int _draggedOverIndex = -1;
  bool _isDragging = false;
  ContentToken? _draggedToken;

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

  void addChord(String chord, int position) {
    setState(() {
      _tokens.insert(
        position,
        ContentToken(text: chord, type: TokenType.chord),
      );
    });

    _notifyContentChanged();
  }

  /// Starts dragging a token by removing it from the list and setting drag state.
  void _startDrag(ContentToken token, int index) {
    if (kDebugMode) {
      print('Starting drag of token "${token.text}" at index $index');
    }
    setState(() {
      _isDragging = true;
      _draggedToken = token;
      _draggedOverIndex = index + 1;
    });
  }

  void _handleDragEnd(LongPressEndDetails details, int index) {
    if (kDebugMode) {
      print('Drag ended, dropping token at index $_draggedOverIndex');
    }

    if (_draggedToken == null) return;

    if (_draggedOverIndex > index) {
      _draggedOverIndex -= 1;
    }

    setState(() {
      // Insert the dragged token back at the last known index
      _tokens.removeAt(index);
      _tokens.insert(
        _draggedOverIndex >= 0 ? _draggedOverIndex : _tokens.length,
        _draggedToken!,
      );
      _isDragging = false;
      _draggedToken = null;
      _draggedOverIndex = -1;
    });

    _notifyContentChanged();
  }

  /// Handles drag updates to determine the token that is under the drag.
  void _handleDragUpdate(LongPressMoveUpdateDetails details) {
    if (!_isDragging || _draggedToken == null) return;

    int? targetIndex;

    for (var entry in _tokenKeys.entries) {
      final key = entry.value;
      final context = key.currentContext;
      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final size = box.size;
      final rect = Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );

      if (rect.contains(details.globalPosition)) {
        targetIndex = entry.key;
        break;
      }
    }

    if (targetIndex != null && targetIndex != _draggedOverIndex) {
      if (kDebugMode) {
        print('Dragged over token index: $targetIndex');
      }
      setState(() {
        _draggedOverIndex = targetIndex!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenWidgets = <Widget>[];
    for (var i = 0; i < _tokens.length; i++) {
      tokenWidgets.add(_buildTokenWidget(_tokens[i], i));
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

  Widget _buildTokenWidget(ContentToken token, int index) {
    // Ensure we have a GlobalKey for this token
    _tokenKeys.putIfAbsent(index, () => GlobalKey());

    switch (token.type) {
      case TokenType.chord:
        // GestureDetector to handle long press to drag transition
        return GestureDetector(
          onLongPressStart: (details) {
            _startDrag(token, index);
          },
          onLongPressMoveUpdate: (details) {
            _handleDragUpdate(details);
          },
          onLongPressEnd: (details) {
            _handleDragEnd(details, index);
          },
          child: token == _draggedToken
              ? SizedBox.shrink()
              : ChordToken(
                  token: token,
                  sectionColor: widget.sectionColor,
                  textStyle: TextStyle(
                    fontSize: _fontSize,
                    color: Colors.white,
                  ),
                ),
        );
      case TokenType.lyric:
      case TokenType.space:
        // Container that contains the lyrics, with a globalKey for drag detection
        return Container(
          key: _tokenKeys[index],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // If dragged over, render the draggedToken before the lyric
              if (index == _draggedOverIndex && _draggedToken != null)
                ChordToken(
                  token: _draggedToken!,
                  sectionColor: widget.sectionColor,
                  textStyle: TextStyle(
                    fontSize: _fontSize,
                    color: Colors.white,
                  ),
                ),
              Text(
                token.text,
                style: TextStyle(fontSize: _fontSize, color: Colors.black),
              ),
            ],
          ),
        );
      case TokenType.newline:
        return SizedBox(width: double.infinity);
    }
  }
}
