import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/text_section_provider.dart';
import '../../../providers/layout_settings_provider.dart';

class PresentationTextSection extends StatelessWidget {
  final int textSectionId;

  const PresentationTextSection({super.key, required this.textSectionId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TextSectionProvider, LayoutSettingsProvider>(
      builder: (context, textSectionProvider, layoutProvider, child) {
        if (textSectionProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
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
                  Icon(Icons.error, color: Colors.red.shade700, size: 32),
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
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                if (textSection.title.isNotEmpty) ...[
                  Text(
                    textSection.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: layoutProvider.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: layoutProvider.fontSize * .8,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Divider(thickness: 1.5, height: 0),
                // Content
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    textSection.contentText,
                    style: TextStyle(
                      fontFamily: layoutProvider.fontFamily,
                      fontSize: layoutProvider.fontSize,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2, // Good line height for reading
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
