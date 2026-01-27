import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditScheduleScreen extends StatefulWidget {
  final Widget content;
  final VoidCallback onSave;

  const EditScheduleScreen({
    super.key,
    required this.content,
    required this.onSave,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late ScheduleProvider _scheduleProvider;

  @override
  void initState() {
    super.initState();
    _scheduleProvider = context.read<ScheduleProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scheduleProvider.addListener(_scheduleErrorListener);
      }
    });
  }

  void _scheduleErrorListener() {
    final error = _scheduleProvider.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scheduleProvider.removeListener(_scheduleErrorListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SelectionProvider, NavigationProvider>(
      builder: (context, selectionProvider, navigationProvider, child) {
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => navigationProvider.pop()),
            title: Text(
              AppLocalizations.of(
                context,
              )!.editPlaceholder(AppLocalizations.of(context)!.scheduleDetails),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // STEP CONTENT
                Expanded(child: widget.content),

                // SAVE BUTTON
                FilledTextButton(
                  text: AppLocalizations.of(context)!.save,
                  onPressed: widget.onSave,
                  isDisabled:
                      (selectionProvider.isSelectionMode &&
                      selectionProvider.selectedItemIds.length != 1),
                  isDarkButton: true,
                ),

                // CANCEL BUTTON
                FilledTextButton(
                  text: AppLocalizations.of(context)!.cancel,
                  onPressed: () => navigationProvider.pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
