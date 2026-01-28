import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/schedule.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/utils/date_utils.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/create_edit/details_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DuplicateScheduleSheet extends StatefulWidget {
  final dynamic scheduleId;

  const DuplicateScheduleSheet({super.key, required this.scheduleId});

  @override
  State<DuplicateScheduleSheet> createState() => _DuplicateScheduleSheetState();
}

class _DuplicateScheduleSheetState extends State<DuplicateScheduleSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController roomVenueController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleProvider = context.read<ScheduleProvider>();
      final schedule = scheduleProvider.getScheduleById(widget.scheduleId)!;

      nameController.text = schedule?.name ?? '';
      dateController.text = (schedule is Schedule)
          ? DateTimeUtils.formatDate(schedule.date)
          : schedule.datetime.toDate().toIso8601String();
      startTimeController.text = (schedule is Schedule)
          ? '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}'
          : '${schedule.datetime.toDate().hour.toString().padLeft(2, '0')}:${ //
            schedule.datetime.toDate().minute.toString().padLeft(2, '0')}';
      locationController.text = schedule?.location ?? '';
      roomVenueController.text = schedule?.roomVenue ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    locationController.dispose();
    roomVenueController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.duplicatePlaceholder(
                      AppLocalizations.of(context)!.schedule,
                    ),
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

              // FORM
              ScheduleForm(
                nameController: nameController,
                dateController: dateController,
                startTimeController: startTimeController,
                locationController: locationController,
                roomVenueController: roomVenueController,
              ),

              // ACTIONS
              // confirm
              FilledTextButton(
                text: AppLocalizations.of(context)!.keepGoing,
                isDark: true,
                onPressed: () {
                  // TODO implement duplication logic
                  Navigator.of(context).pop();
                },
              ),

              // cancel
              FilledTextButton(
                text: AppLocalizations.of(context)!.cancel,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
