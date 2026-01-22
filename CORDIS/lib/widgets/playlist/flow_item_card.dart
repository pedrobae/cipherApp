import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/flow_item_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/utils/date_utils.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/flow_item_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlowItemCard extends StatelessWidget {
  final int flowItemId;
  final int playlistId;

  const FlowItemCard({
    super.key,
    required this.flowItemId,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<FlowItemProvider, NavigationProvider>(
      builder: (context, flowItemProvider, navigationProvider, child) {
        final flowItem = flowItemProvider.getFlowItem(flowItemId);

        // Loading state
        if (flowItem == null) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: colorScheme.surfaceContainerLowest),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flowItem.title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateTimeUtils.formatDuration(flowItem.duration),
                          style: textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    // maybe switch to PopupMenuButton
                    onPressed: () {
                      // TODO - show flowItem actions
                    },
                    icon: Icon(Icons.more_vert_rounded, size: 30),
                  ),
                ],
              ),
              FilledTextButton(
                text: AppLocalizations.of(context)!.view,
                isDense: true,
                onPressed: () {
                  navigationProvider.push(
                    FlowItemEditor(
                      playlistId: playlistId,
                      flowItemId: flowItemId,
                    ),
                    showAppBar: false,
                    showDrawerIcon: false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
