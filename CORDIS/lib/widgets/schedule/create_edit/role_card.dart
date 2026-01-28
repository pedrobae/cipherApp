import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/widgets/delete_confirmation.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/create_edit/sheet_edit_role.dart';
import 'package:cordis/widgets/schedule/create_edit/sheet_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleCard extends StatelessWidget {
  final dynamic scheduleId;
  final dynamic role; // Role or RoleDTO object

  const RoleCard({super.key, required this.scheduleId, required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) => Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.surfaceContainerLowest),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8.0,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    role.memberIds.isEmpty
                        ? AppLocalizations.of(context)!.noMembers
                        : AppLocalizations.of(
                            context,
                          )!.xMembers(role.memberIds.length),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // ACTIONS
            FilledTextButton(
              text: AppLocalizations.of(context)!.assign,
              isDense: true,
              isDark: true,
              onPressed: () => _openAssignMemberSheet(context, role),
            ),

            FilledTextButton(
              text: AppLocalizations.of(context)!.editPlaceholder(''),
              isDense: true,
              onPressed: () => _openEditRoleSheet(context, role),
            ),

            FilledTextButton(
              text: AppLocalizations.of(context)!.delete,
              isDense: true,
              onPressed: () {
                if (scheduleId is String) return; // TODO handle roleDTOs
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return BottomSheet(
                      onClosing: () {},
                      builder: (context) {
                        return DeleteConfirmationSheet(
                          itemType: AppLocalizations.of(context)!.role,
                          onConfirm: () {
                            scheduleProvider.deleteRole(scheduleId, role.id);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openAssignMemberSheet(BuildContext context, dynamic role) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: UsersBottomSheet(scheduleId: scheduleId, role: role),
        );
      },
    );
  }

  void _openEditRoleSheet(BuildContext context, dynamic role) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditRoleSheet(scheduleId: scheduleId, role: role),
        );
      },
    );
  }
}
