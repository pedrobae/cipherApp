import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/widgets/cipher/viewer/chordpro_view.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';

class CipherSectionCard extends StatelessWidget {
  final String sectionCode;
  final String sectionType;
  final String sectionText;
  final Color sectionColor;

  const CipherSectionCard({
    super.key,
    required this.sectionType,
    required this.sectionCode,
    required this.sectionText,
    required this.sectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LayoutSettingsProvider>();

    if (sectionText.trim().isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Text(
                    sectionCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: ls.fontSize,
                    ),
                  ),
                  Text(
                    sectionType,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: (ls.fontSize * .9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sectionColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: sectionColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ChordProView(song: sectionText, maxWidth: double.infinity),
        ),
      ],
    );
  }
}
