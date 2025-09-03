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

    final layoutProvider = context.watch<LayoutSettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                children: [
                  Text(
                    sectionCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: layoutProvider.fontSize,
                    ),
                  ),
                  SizedBox(width: 8,),
                  Text(
                    sectionType,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: (layoutProvider.fontSize*.9)
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
          child: ChordProView(
            song: sectionText,
            maxWidth: double.infinity,
            lyricStyle: layoutProvider.lyricTextStyle,
            chordStyle: layoutProvider.chordTextStyle,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
