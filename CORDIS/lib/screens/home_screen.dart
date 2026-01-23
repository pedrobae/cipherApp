import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/screens/playlist/edit_playlist.dart';
import 'package:cordis/screens/schedule/create_Schedule.dart';
import 'package:cordis/widgets/ciphers/library/create_cipher_sheet.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/library/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/my_auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    await context.read<ScheduleProvider>().loadLocalSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          Consumer4<
            MyAuthProvider,
            ScheduleProvider,
            NavigationProvider,
            SelectionProvider
          >(
            builder:
                (
                  context,
                  authProvider,
                  scheduleProvider,
                  navigationProvider,
                  selectionProvider,
                  child,
                ) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  final locale = Localizations.localeOf(context);

                  if (authProvider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.loading),
                        ],
                      ),
                    );
                  }

                  if (authProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.errorMessage(
                              AppLocalizations.of(context)!.authentication,
                              authProvider.error!,
                            ),
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => authProvider.signInAnonymously(),
                            child: Text(AppLocalizations.of(context)!.tryAgain),
                          ),
                        ],
                      ),
                    );
                  }

                  final nextSchedule = scheduleProvider.getNextSchedule();
                  // HOME SCREEN
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 24,
                    children: [
                      // Current date
                      Text(
                        DateFormat(
                          'EEEE, MMM d',
                          locale.languageCode,
                        ).format(DateTime.now()),
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),

                      // Welcome message
                      Text(
                        authProvider.userName != null
                            ? AppLocalizations.of(
                                context,
                              )!.welcome(authProvider.userName as Object)
                            : AppLocalizations.of(context)!.anonymousWelcome,
                        style: Theme.of(context).textTheme.headlineLarge!
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                      ),

                      // NEXT SCHEDULE
                      scheduleProvider.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : nextSchedule != null
                          ? Column(
                              spacing: 16,
                              children: [
                                // SCHEDULE LABEL
                                Text(
                                  AppLocalizations.of(context)!.nextUp,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // SCHEDULE CARD
                                ScheduleCard(scheduleId: nextSchedule.id),
                              ],
                            )
                          : SizedBox.shrink(),

                      // DIRECT CREATION BUTTONS
                      Expanded(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 16,
                            children: [
                              FilledTextButton(
                                isDarkButton: true,
                                text: AppLocalizations.of(context)!
                                    .createPlaceholder(
                                      AppLocalizations.of(context)!.playlist,
                                    ),
                                onPressed: () {
                                  navigationProvider.navigateToRoute(
                                    NavigationRoute.playlists,
                                  );
                                  navigationProvider.push(EditPlaylistScreen());
                                },
                              ),
                              FilledTextButton(
                                text: AppLocalizations.of(context)!
                                    .addPlaceholder(
                                      AppLocalizations.of(context)!.cipher,
                                    ),
                                onPressed: () {
                                  navigationProvider.navigateToRoute(
                                    NavigationRoute.library,
                                  );
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return CreateCipherSheet();
                                    },
                                  );
                                },
                              ),
                              FilledTextButton(
                                text: AppLocalizations.of(
                                  context,
                                )!.assignSchedule,
                                onPressed: () {
                                  navigationProvider.navigateToRoute(
                                    NavigationRoute.schedule,
                                  );
                                  selectionProvider.enableSelectionMode();
                                  navigationProvider.push(
                                    CreateScheduleScreen(),
                                    showAppBar: false,
                                    showDrawerIcon: false,
                                    onPopCallback: () {
                                      selectionProvider.disableSelectionMode();
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
          ),
    );
  }
}
