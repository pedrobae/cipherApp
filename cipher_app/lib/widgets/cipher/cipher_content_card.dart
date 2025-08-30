import 'package:flutter/material.dart';
import '../../utils/section_color_manager.dart';
import 'package:cipher_app/widgets/chordpro_view.dart';

class CipherContentCard extends StatelessWidget{
  final String contentType;
  final String contentText;

  const CipherContentCard({
    super.key,
    required this.contentType,
    required this.contentText,
  });

  @override
  Widget build(BuildContext context) {
    // Get the section color for this content type
    final sectionColor = SectionColorManager.getSectionColor(contentType, null);
    
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
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
          ),
        ),
        const SizedBox(height: 12),
      ]
    );
  }
}