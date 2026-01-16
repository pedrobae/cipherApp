import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/user_provider.dart';
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
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.surface),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Navigate to schedule view
                },
                child: Text(
                  AppLocalizations.of(context)!.view,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colorScheme.surface,
                  side: BorderSide(color: colorScheme.onSurface),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.share,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
