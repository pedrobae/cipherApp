import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/library/schedule_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/schedule_provider.dart';

class ScheduleLibraryScreen extends StatefulWidget {
  const ScheduleLibraryScreen({super.key});

  @override
  State<ScheduleLibraryScreen> createState() => _ScheduleLibraryScreenState();
}

class _ScheduleLibraryScreenState extends State<ScheduleLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleProvider = Provider.of<ScheduleProvider>(
        context,
        listen: false,
      );
      if (mounted) {
        scheduleProvider.loadLocalSchedules();
        scheduleProvider.loadCloudSchedules();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchSchedule,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: colorScheme.surfaceContainer),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  suffixIcon: const Icon(Icons.search),
                  fillColor: colorScheme.surfaceContainerHighest,
                  visualDensity: VisualDensity.compact,
                ),
                onChanged: (value) {
                  scheduleProvider.setSearchTerm(value);
                },
              ),

              Expanded(child: ScheduleScrollView()),

              FilledTextButton(
                onPressed: () {
                  //TODO: Implement create new Schedule functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.amberAccent,
                      content: Text(
                        'Funcionalidade em desenvolvimento,',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
                text: AppLocalizations.of(context)!.create,
                isDarkButton: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
