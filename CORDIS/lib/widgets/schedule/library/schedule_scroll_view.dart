import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/widgets/schedule/library/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleScrollView extends StatefulWidget {
  const ScheduleScrollView({super.key});

  @override
  State<ScheduleScrollView> createState() => _ScheduleScrollViewState();
}

class _ScheduleScrollViewState extends State<ScheduleScrollView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        // Handle loading state
        if (scheduleProvider.isLoading || scheduleProvider.isLoadingCloud) {
          return const Center(child: CircularProgressIndicator());
        }

        final monthScheduleIds = scheduleProvider.getNextThisMonthsSchedules();

        return Column(
          children: [
            // THIS MONTH'S SCHEDULES HEADER
            monthScheduleIds.isNotEmpty
                ? Text(
                    AppLocalizations.of(context)!.nextThisMonth,
                    style: theme.textTheme.titleMedium,
                  )
                : SizedBox.shrink(),

            // THIS MONTH'S SCHEDULES LIST
            SingleChildScrollView(
              child: Column(
                children: monthScheduleIds.map((scheduleId) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                    child: ScheduleCard(scheduleId: scheduleId),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
