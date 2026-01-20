import 'package:cordis/providers/text_section_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextSectionCard extends StatefulWidget {
  final int textSectionId;
  final int playlistId;

  const TextSectionCard({
    super.key,
    required this.textSectionId,
    required this.playlistId,
  });

  @override
  State<TextSectionCard> createState() => _TextSectionCardState();
}

class _TextSectionCardState extends State<TextSectionCard> {
  @override
  Widget build(BuildContext context) {
    final textSectionProvider = context.watch<TextSectionProvider>();

    return InkWell(
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
                      textSectionProvider
                              .textSections[widget.textSectionId]
                              ?.title ??
                          'ERROR LOADING',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // REORDERABLE SECTION CHIPS
                    Text(
                      textSectionProvider
                              .textSections[widget.textSectionId]
                              ?.contentText ??
                          '',
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
