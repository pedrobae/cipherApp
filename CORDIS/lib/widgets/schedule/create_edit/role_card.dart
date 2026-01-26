import 'package:cordis/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final dynamic role; // Role or RoleDTO object

  const RoleCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(role.name, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  role.memberIds.isEmpty
                      ? AppLocalizations.of(context)!.noMembers
                      : AppLocalizations.of(
                          context,
                        )!.xMembers(role.memberIds.length),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
