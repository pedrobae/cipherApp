import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/create_edit/role_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RolesAndUsersForm extends StatefulWidget {
  final dynamic scheduleId;

  const RolesAndUsersForm({super.key, this.scheduleId});

  @override
  State<RolesAndUsersForm> createState() => _RolesAndUsersFormState();
}

class _RolesAndUsersFormState extends State<RolesAndUsersForm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        final schedule = scheduleProvider.getScheduleById(widget.scheduleId);

        if (schedule == null) {
          return Center(child: Text('Schedule not found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ROLES LIST
            if (schedule.roles.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.noRoles),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.addRolesInstructions),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView.builder(
                  itemCount: schedule.roles.length,
                  itemBuilder: (context, index) {
                    final role = schedule.roles[index];
                    return RoleCard(role: role);
                  },
                ),
              ),
            ],

            // ADD ROLE BUTTON
            FilledTextButton.icon(
              text: AppLocalizations.of(context)!.role,
              icon: Icons.add,
              onPressed: () {},
              isDense: true,
            ),
          ],
        );
      },
    );
  }
}
