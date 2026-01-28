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
  final _scrollController = ScrollController();
  final _pastHeaderKey = GlobalKey();

  bool passedFutureSchedules = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_listenForEndOfFutureSchedules);
    });
  }

  void _listenForEndOfFutureSchedules() {
    // CHECK IF WE SCROLLED THE PAST SCHEDULES HEADER
    final box = _pastHeaderKey.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    if (_scrollController.offset >= position.dy + kToolbarHeight) {
      setState(() {
        passedFutureSchedules = true;
      });
    } else {
      setState(() {
        passedFutureSchedules = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        // Handle loading state
        if (scheduleProvider.isLoading || scheduleProvider.isLoadingCloud) {
          return const Center(child: CircularProgressIndicator());
        }

        final futureScheduleIds = scheduleProvider.futureSchedules.keys
            .toList();
        final pastScheduleIds = scheduleProvider.pastSchedules.keys.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SCHEDULES HEADER
            passedFutureSchedules
                ? (pastScheduleIds.isNotEmpty
                      ? Text(
                          AppLocalizations.of(context)!.pastSchedules,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : SizedBox.shrink())
                : (futureScheduleIds.isNotEmpty
                      ? Text(
                          AppLocalizations.of(context)!.futureSchedules,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : SizedBox.shrink()),

            // SCHEDULES LIST
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await scheduleProvider.loadLocalSchedules();
                  await scheduleProvider.loadCloudSchedules();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      ...futureScheduleIds.map((scheduleId) {
                        return ScheduleCard(scheduleId: scheduleId);
                      }),
                      SizedBox(height: 16.0),
                      Text(
                        key: _pastHeaderKey,
                        AppLocalizations.of(context)!.pastSchedules,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ...pastScheduleIds.map((scheduleId) {
                        return ScheduleCard(scheduleId: scheduleId);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
