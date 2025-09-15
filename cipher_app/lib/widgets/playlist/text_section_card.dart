import 'package:cipher_app/providers/text_section_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextSectionCard extends StatelessWidget {
  final int textSectionId;
  final int playlistId;

  const TextSectionCard({
    super.key,
    required this.textSectionId,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    TextSectionProvider().loadTextSection(textSectionId);
    final textSectionProvider = context.watch<TextSectionProvider>();
    return InkWell(
      onTap: () {},
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textSectionProvider.textSections?[textSectionId]?.title ??
                          'ERROR LOADING',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // REORDERABLE SECTION CHIPS
                    Text(
                      'placeholder for text content',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
