import 'package:cipher_app/models/ui/content_token.dart';
import 'package:flutter/material.dart';

class ChordToken extends StatelessWidget {
  final ContentToken token;
  final Color sectionColor;
  final TextStyle textStyle;

  const ChordToken({
    super.key,
    required this.token,
    required this.sectionColor,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: sectionColor,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        token.text,
        style: textStyle.copyWith(fontSize: textStyle.fontSize! * 0.8),
      ),
    );
  }
}
