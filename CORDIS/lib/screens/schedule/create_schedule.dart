import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/screens/playlist/playlist_library.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/create_edit/details_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({super.key});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  int creationStep = 1;
  late ScheduleProvider _scheduleProvider;

  @override
  void initState() {
    super.initState();
    _scheduleProvider = context.read<ScheduleProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scheduleProvider.addListener(_scheduleErrorListener);
      }
    });
  }

  void _scheduleErrorListener() {
    final error = _scheduleProvider.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scheduleProvider.removeListener(_scheduleErrorListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer6<
      ScheduleProvider,
      PlaylistProvider,
      UserProvider,
      MyAuthProvider,
      SelectionProvider,
      NavigationProvider
    >(
      builder:
          (
            context,
            scheduleProvider,
            playlistProvider,
            userProvider,
            myAuthProvider,
            selectionProvider,
            navigationProvider,
            child,
          ) {
            final textTheme = Theme.of(context).textTheme;
            final colorScheme = Theme.of(context).colorScheme;

            return Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    switch (creationStep) {
                      case 1:
                        navigationProvider.pop();
                      case 2:
                        setState(() {
                          creationStep = 1;
                        });
                      case 3:
                        setState(() {
                          creationStep = 2;
                        });
                      default:
                        null;
                    }
                  },
                ),
                title: Text(
                  AppLocalizations.of(context)!.schedulePlaylist,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // STEP INDICATOR
                    Text(
                      AppLocalizations.of(context)!.stepXofY(creationStep, 3),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // STEP INSTRUCTION
                    switch (creationStep) {
                      1 => Text(
                        AppLocalizations.of(
                          context,
                        )!.selectPlaylistForScheduleInstruction,
                        style: textTheme.bodyLarge,
                      ),
                      2 => Text(
                        AppLocalizations.of(
                          context,
                        )!.fillScheduleDetailsInstruction,
                        style: textTheme.bodyLarge,
                      ),
                      3 => Text(
                        AppLocalizations.of(
                          context,
                        )!.createRolesAndAssignUsersInstruction,
                        style: textTheme.bodyLarge,
                      ),
                      _ => SizedBox.shrink(),
                    },
                    switch (creationStep) {
                      1 => SizedBox(height: 16),
                      2 => SizedBox.shrink(),
                      3 => SizedBox(height: 16),
                      _ => SizedBox.shrink(),
                    },

                    // STEP CONTENT
                    switch (creationStep) {
                      1 => Expanded(child: PlaylistLibraryScreen()),
                      2 => Expanded(child: ScheduleForm()),
                      // 3 => Expanded(child: ScheduleRolesAndUsersForm()),
                      _ => SizedBox.shrink(),
                    },

                    // CONTINUE / CREATE BUTTON
                    FilledTextButton(
                      text: switch (creationStep) {
                        1 => AppLocalizations.of(context)!.keepGoing,
                        2 => AppLocalizations.of(context)!.keepGoing,
                        3 => AppLocalizations.of(context)!.createPlaceholder(
                          AppLocalizations.of(context)!.schedule,
                        ),
                        _ => 'ERROR',
                      },
                      onPressed: () {
                        switch (creationStep) {
                          case 1:
                            // Cache Brand New Schedule
                            scheduleProvider.cacheBrandNewSchedule(
                              playlistProvider.getPlaylistById(
                                selectionProvider.selectedItemIds.first,
                              )!,
                              myAuthProvider.id!,
                            );

                            // Proceed to step 2
                            setState(() {
                              creationStep = 2;
                            });
                            break;
                          case 2:
                            // Cache Schedule Details
                            // TODO
                            // Proceed to step 3
                            setState(() {
                              creationStep = 3;
                            });
                            break;
                          case 3:
                            // Create Schedule
                            scheduleProvider.createFromCache().then((success) {
                              if (success) {
                                navigationProvider.navigateToRoute(
                                  NavigationRoute.schedule,
                                );
                              }
                            });
                            break;
                          default:
                            null;
                        }
                      },
                      isDisabled: selectionProvider.selectedItemIds.length != 1,
                      isDarkButton: true,
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}
