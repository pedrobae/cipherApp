import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/text_section_provider.dart';
import '../../providers/layout_settings_provider.dart';

class PresentationTextSection extends StatelessWidget {
  final int textSectionId;

  const PresentationTextSection({
    super.key,
    required this.textSectionId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TextSectionProvider, LayoutSettingsProvider>(
      builder: (context, textSectionProvider, layoutProvider, child) {
        // Load the text section if not already loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!textSectionProvider.textSections.containsKey(textSectionId)) {
            textSectionProvider.loadTextSection(textSectionId);
          }
        });

        if (textSectionProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final textSection = textSectionProvider.textSections[textSectionId];

        if (textSection == null) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red.shade700,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Erro ao carregar seção de texto',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: $textSectionId',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 0),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                if (textSection.title.isNotEmpty) ...[
                  Text(
                    textSection.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: layoutProvider.fontSize + 4, // Slightly larger than content
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Content
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    textSection.contentText,
                    style: TextStyle(
                      fontFamily: layoutProvider.fontFamily,
                      fontSize: layoutProvider.fontSize,
                      color: layoutProvider.lyricColor,
                      height: 1.6, // Good line height for reading
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}