import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleCard extends StatelessWidget {
  final int scheduleId;
  final bool showActions;

  const ScheduleCard({
    super.key,
    required this.scheduleId,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<ScheduleProvider, MyAuthProvider, UserProvider>(
      builder: (context, scheduleProvider, authProvider, userProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final schedule = scheduleProvider.getScheduleById(scheduleId)!;
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.surfaceContainerLowest),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SCHEDULE NAME
                        Text(
                          schedule.name,
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // WHEN & WHERE
                        Wrap(
                          spacing: 16.0,
                          children: [
                            Text(
                              '${schedule.date.day}/${schedule.date.month}/${schedule.date.year}',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              schedule.time.format(context),
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              schedule.location,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),

                        // PLAYLIST INFO
                        schedule.playlist != null
                            ? Text(
                                '${AppLocalizations.of(context)!.playlist}: ${schedule.playlist!.name}',
                                style: theme.textTheme.bodyMedium,
                              )
                            : SizedBox.shrink(),

                        // YOUR ROLE INFO
                        Text(
                          '${AppLocalizations.of(context)!.role}: ${scheduleProvider.getUserRoleInSchedule(scheduleId, userProvider.getLocalIdByFirebaseId(authProvider.id!)) ?? AppLocalizations.of(context)!.generalMember}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (showActions) ...[
                    IconButton(
                      onPressed: () {
                        // TODO: Implement schedule actions
                      },
                      icon: Icon(Icons.more_vert),
                    ),
                  ],
                ],
              ),
              // BOTTOM BUTTONS
              FilledTextButton(
                isDarkButton: true,
                onPressed: () {
                  // TODO: Implement navigation to schedule view
                },
                text: AppLocalizations.of(context)!.view,
              ),
              FilledTextButton(
                onPressed: () {
                  // TODO: Implement share functionality
                },
                text: AppLocalizations.of(context)!.share,
              ),
            ],
          ),
        );
      },
    );
  }
}
