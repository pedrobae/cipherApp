import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/section_color_manager.dart';
import 'package:cipher_app/widgets/cipher/viewer/chordpro_view.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';

class CipherContentCard extends StatelessWidget {
  final String contentType;
  final String? contentText;

  const CipherContentCard({
    super.key,
    required this.contentType,
    this.contentText,
  });

  @override
  Widget build(BuildContext context) {
    // Get the section color for this content type
    final sectionColor = SectionColorManager.getSectionColor(contentType, null);
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
              child: Text(
                contentType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: layoutProvider.fontSize,
                ),
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
            song: contentText,
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
