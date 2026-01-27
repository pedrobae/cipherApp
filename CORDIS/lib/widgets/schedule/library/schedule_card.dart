import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/screens/schedule/view_schedule.dart';
import 'package:cordis/widgets/filled_text_button.dart';
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
                          onPressed: () {
                            // TODO: Implement schedule actions
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
}
