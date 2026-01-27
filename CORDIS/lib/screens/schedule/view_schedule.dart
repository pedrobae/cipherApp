import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/schedule.dart';
import 'package:cordis/models/dtos/schedule_dto.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/screens/schedule/edit_schedule.dart';
import 'package:cordis/utils/date_utils.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:cordis/widgets/schedule/create_edit/details_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewScheduleScreen extends StatefulWidget {
  final dynamic scheduleId;

  const ViewScheduleScreen({super.key, required this.scheduleId});

  @override
  State<ViewScheduleScreen> createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController annotationsController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    locationController.dispose();
    annotationsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer4<
      ScheduleProvider,
      NavigationProvider,
      SelectionProvider,
      UserProvider
    >(
      builder:
          (
            context,
            scheduleProvider,
            navigationProvider,
            selectionProvider,
            userProvider,
            child,
          ) {
            // LOADING STATE
            if (scheduleProvider.isLoading) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.loading),
                  leading: BackButton(
                    onPressed: () {
                      navigationProvider.pop();
                    },
                  ),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            // ERROR STATE
            if (scheduleProvider.error != null &&
                scheduleProvider.error?.isNotEmpty == true) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.error),
                  leading: BackButton(
                    onPressed: () {
                      navigationProvider.pop();
                    },
                  ),
                ),
                body: Center(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.errorMessage(
                          AppLocalizations.of(context)!.load,
                          scheduleProvider.error!,
                        ),
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          scheduleProvider.loadLocalSchedules();
                          scheduleProvider.loadCloudSchedules();
                        },
                        child: Text(AppLocalizations.of(context)!.tryAgain),
                      ),
                    ],
                  ),
                ),
              );
            }

            final schedule = scheduleProvider.getScheduleById(
              widget.scheduleId,
            );

            if (schedule == null) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.scheduleNotFound),
                  leading: BackButton(
                    onPressed: () {
                      navigationProvider.pop();
                    },
                  ),
                ),
                body: Center(
                  child: Text(
                    AppLocalizations.of(context)!.scheduleNotFoundMessage,
                  ),
                ),
              );
            }

            final playlist = schedule.playlist; // Playlist or PlaylistDto

            int memberCount = 0;
            for (var role in schedule.roles) {
              memberCount += role.memberIds.length as int;
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(schedule.name),
                leading: BackButton(
                  onPressed: () {
                    navigationProvider.pop();
                  },
                ),
                actions: [
                  // PLAY MODE
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill),
                    onPressed: () {
                      // TODO: Navigate to play mode screen
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.surfaceContainerLowest,
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    spacing: 28,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        colorScheme,
                        AppLocalizations.of(context)!.scheduleDetails,
                        [
                          Text(
                            schedule.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            spacing: 16,
                            children: [
                              Text(
                                DateTimeUtils.formatDate(
                                  (schedule is Schedule)
                                      ? schedule.date
                                      : (schedule as ScheduleDto).datetime
                                            .toDate(),
                                ),
                              ),
                              Text(
                                (schedule is Schedule)
                                    ? schedule.time.format(context)
                                    : '${schedule.datetime.toDate().hour.toString().padLeft(2, '0')}:${ //
                                      schedule.datetime.toDate().minute.toString().padLeft(2, '0')}',
                              ),
                              Text(schedule.location),
                            ],
                          ),
                          FilledTextButton(
                            text: AppLocalizations.of(context)!.editPlaceholder(
                              AppLocalizations.of(context)!.scheduleDetails,
                            ),
                            isDarkButton: true,
                            isDense: true,
                            onPressed: () {
                              navigationProvider.push(
                                EditScheduleScreen(
                                  content: ScheduleForm(
                                    nameController: nameController,
                                    dateController: dateController,
                                    startTimeController: startTimeController,
                                    locationController: locationController,
                                    annotationsController:
                                        annotationsController,
                                  ),
                                  onSave: () {
                                    scheduleProvider.cacheScheduleDetails(
                                      schedule.id,
                                      name: nameController.text,
                                      date: dateController.text,
                                      startTime: startTimeController.text,
                                      location: locationController.text,
                                      annotations: annotationsController.text,
                                    );
                                    scheduleProvider.saveScheduleDetails(
                                      schedule.id,
                                    );
                                    navigationProvider.pop();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // PLAYLIST SECTION
                      _buildSectionCard(
                        colorScheme,
                        AppLocalizations.of(context)!.playlist,
                        [
                          if (playlist == null) ...[
                            Text(
                              AppLocalizations.of(context)!.noPlaylistAssigned,
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            FilledTextButton(
                              text: AppLocalizations.of(
                                context,
                              )!.schedulePlaylist,
                              onPressed: () {
                                // TODO : Navigate to change playlist screen
                              },
                              isDense: true,
                              isDarkButton: true,
                            ),
                          ] else ...[
                            Text(playlist.name, style: textTheme.titleMedium),
                            Row(
                              children: [
                                Text(
                                  (playlist.items.length == 1)
                                      ? '1 ${AppLocalizations.of(context)!.item}'
                                      : '${playlist.items.length} ${AppLocalizations.of(context)!.pluralPlaceholder(
                                          AppLocalizations.of(context)!.item, //
                                        )}',
                                ),
                                Text(
                                  '${AppLocalizations.of(context)!.duration}: ${DateTimeUtils.formatDuration(playlist.duration)}',
                                ),
                              ],
                            ),
                            FilledTextButton(
                              text: AppLocalizations.of(
                                context,
                              )!.changePlaylist,
                              isDarkButton: true,
                              isDense: true,
                              onPressed: () {
                                // TODO : Navigate to change playlist screen
                              },
                            ),
                          ],
                        ],
                      ),

                      // MEMBERS SECTION
                      _buildSectionCard(
                        colorScheme,
                        '${AppLocalizations.of(context)!.role} & ${ //
                        AppLocalizations.of(context)!.pluralPlaceholder(
                          AppLocalizations.of(context)!.member, //
                        )}',
                        [
                          Text(
                            schedule.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            spacing: 16,
                            children: [
                              Text(
                                (schedule.roles.length == 1)
                                    ? '1 ${AppLocalizations.of(context)!.role}'
                                    : '${schedule.roles.length} ${AppLocalizations.of(context)!.pluralPlaceholder(
                                        AppLocalizations.of(context)!.role, //
                                      )}',
                              ),
                              Text(
                                (memberCount == 1)
                                    ? '1 ${AppLocalizations.of(context)!.member}'
                                    : '$memberCount ${AppLocalizations.of(context)!.pluralPlaceholder(
                                        AppLocalizations.of(context)!.member, //
                                      )}',
                              ),
                            ],
                          ),
                          FilledTextButton(
                            text: AppLocalizations.of(
                              context,
                            )!.editPlaceholder(''),
                            isDarkButton: true,
                            isDense: true,
                            onPressed: () {
                              // TODO : Navigate to edit members screen
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget _buildSectionCard(
    ColorScheme colorScheme,
    String label,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: colorScheme.surfaceContainerLowest),
          ),
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}
