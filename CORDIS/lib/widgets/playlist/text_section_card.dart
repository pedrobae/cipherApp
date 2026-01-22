import 'package:cordis/providers/flow_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextSectionCard extends StatefulWidget {
  final int flowItemId;
  final int playlistId;

  const TextSectionCard({
    super.key,
    required this.flowItemId,
    required this.playlistId,
  });

  @override
  State<TextSectionCard> createState() => _TextSectionCardState();
}

class _TextSectionCardState extends State<TextSectionCard> {
  @override
  Widget build(BuildContext context) {
    final flowItemProvider = context.watch<FlowItemProvider>();

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
                      flowItemProvider.flowItems[widget.flowItemId]?.title ??
                          'ERROR LOADING',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // REORDERABLE SECTION CHIPS
                    Text(
                      flowItemProvider
                              .flowItems[widget.flowItemId]
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
