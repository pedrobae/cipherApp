import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/schedule_card.dart';
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
    await context.read<ScheduleProvider>().loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer2<MyAuthProvider, ScheduleProvider>(
        builder: (context, authProvider, scheduleProvider, child) {
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
                    '${AppLocalizations.of(context)!.errorPrefix}${authProvider.error}',
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
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
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      FilledTextButton(
                        darkButton: true,
                        text: AppLocalizations.of(context)!.createPlaylist,
                        onPressed: () {
                          // TODO: Implement navigation to create playlist
                        },
                      ),
                      FilledTextButton(
                        text: AppLocalizations.of(context)!.addSongToLibrary,
                        onPressed: () {
                          // TODO: Implement navigation to schedule view
                        },
                      ),
                      FilledTextButton(
                        text: AppLocalizations.of(context)!.assignSchedule,
                        onPressed: () {
                          // TODO: Implement navigation assign schedule
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
