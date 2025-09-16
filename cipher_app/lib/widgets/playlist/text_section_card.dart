import 'package:cipher_app/providers/text_section_provider.dart';
import 'package:cipher_app/widgets/dialogs/text_section_dialog.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TextSectionProvider>().loadTextSection(widget.textSectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textSectionProvider = context.watch<TextSectionProvider>();

    return InkWell(
      onTap: _ontap,
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
  void _ontap() {
    TextSectionDialog.show(
      context,
      textSectionId: widget.textSectionId,
    );
  }
}
