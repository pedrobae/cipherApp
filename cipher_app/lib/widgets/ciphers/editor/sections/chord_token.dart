import 'package:cipher_app/models/ui/content_token.dart';
import 'package:flutter/material.dart';

class ChordToken extends StatelessWidget {
  final ContentToken token;
  final Color sectionColor;

  const ChordToken({
    super.key,
    required this.token,
    required this.sectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chord text above
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: sectionColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            token.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        // Vertical flag line
        Container(
          width: 2,
          height: 16, // Adjust height to reach lyrics line
          color: sectionColor,
        ),
      ],
    );
  }
}
