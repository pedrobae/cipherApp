import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/screens/schedule/view_schedule.dart';
import 'package:cordis/widgets/delete_confirmation.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/library/duplicate_schedule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleCard extends StatelessWidget {
  final dynamic scheduleId;
  final bool showActions;

  const ScheduleCard({
    super.key,
    required this.scheduleId,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer5<
      ScheduleProvider,
      PlaylistProvider,
      MyAuthProvider,
      UserProvider,
      NavigationProvider
    >(
      builder:
          (
            context,
            scheduleProvider,
            playlistProvider,
            authProvider,
            userProvider,
            navigationProvider,
            child,
          ) {
            // LOADING STATE
            if (scheduleProvider.isLoading || userProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            final schedule = scheduleProvider.getScheduleById(scheduleId)!;
            final playlist = playlistProvider.getPlaylistById(
              schedule.playlistId,
            );
            return Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.surfaceContainerLowest,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(0),
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
                            // SCHEDULE NAME
                            Text(
                              schedule.name,
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
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
                            playlist != null
                                ? Text(
                                    '${AppLocalizations.of(context)!.playlist}: ${playlist.name}',
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
                          onPressed: () => _openScheduleActionsSheet(
                            context,
                            scheduleId,
                            scheduleProvider,
                          ),
                          icon: Icon(Icons.more_vert),
                        ),
                      ],
                    ],
                  ),
                  // BOTTOM BUTTONS
                  FilledTextButton(
                    isDark: true,
                    isDense: true,
                    onPressed: () {
                      navigationProvider.push(
                        ViewScheduleScreen(scheduleId: scheduleId),
                        showAppBar: false,
                        showDrawerIcon: false,
                      );
                    },
                    text: AppLocalizations.of(context)!.view,
                  ),
                  FilledTextButton(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.amberAccent,
                          content: Text(
                            'Funcionalidade em desenvolvimento,',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                    text: AppLocalizations.of(context)!.share,
                    isDense: true,
                  ),
                ],
              ),
            );
          },
    );
  }

  void _openScheduleActionsSheet(
    BuildContext context,
    dynamic scheduleId,
    ScheduleProvider scheduleProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.scheduleActions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              // ACTIONS
              // duplicate
              FilledTextButton.trailingIcon(
                text: AppLocalizations.of(context)!.duplicatePlaceholder(''),
                tooltip: AppLocalizations.of(
                  context,
                )!.duplicateTooltip(AppLocalizations.of(context)!.setup),
                onPressed: () =>
                    _openDuplicateScheduleSheet(context, scheduleId),
                trailingIcon: Icons.chevron_right,
                isDiscrete: true,
              ),
              // delete
              FilledTextButton.trailingIcon(
                text: AppLocalizations.of(context)!.delete,
                tooltip: AppLocalizations.of(context)!.deleteScheduleTooltip,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return DeleteConfirmationSheet(
                        itemType: AppLocalizations.of(context)!.schedule,
                        onConfirm: () {
                          Navigator.of(context).pop();
                          scheduleProvider.deleteSchedule(scheduleId);
                        },
                      );
                    },
                  );
                },
                trailingIcon: Icons.chevron_right,
                isDangerous: true,
                isDiscrete: true,
              ),

              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _openDuplicateScheduleSheet(BuildContext context, dynamic scheduleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DuplicateScheduleSheet(scheduleId: scheduleId),
        );
      },
    );
  }
}
