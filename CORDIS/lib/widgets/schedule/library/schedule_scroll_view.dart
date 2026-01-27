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

        final nextScheduleIds = scheduleProvider.getNextScheduleIds();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEXT SCHEDULES HEADER
            nextScheduleIds.isNotEmpty
                ? Text(
                    AppLocalizations.of(context)!.nextSchedules,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : SizedBox.shrink(),

            // NEXT SCHEDULES LIST
            SingleChildScrollView(
              child: Column(
                children: nextScheduleIds.map((scheduleId) {
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
