import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/playlist/flow_item.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/models/dtos/schedule_dto.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/flow_item_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/schedule/play/play_cloud_version.dart';
import 'package:cordis/widgets/schedule/play/play_flow_item.dart';
import 'package:cordis/widgets/schedule/play/play_local_version.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayScheduleScreen extends StatefulWidget {
  final dynamic scheduleId;

  const PlayScheduleScreen({super.key, required this.scheduleId});

  @override
  State<PlayScheduleScreen> createState() => PlayScheduleScreenState();
}

class PlayScheduleScreenState extends State<PlayScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final bool isCloud = widget.scheduleId is String;

  bool isPlaying = false;

  late final TabController _tabController;
  int currentTabIndex = 0;
  List<PlaylistItem> playlistItems = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureDataLoaded();

      _tabController = TabController(length: playlistItems.length, vsync: this);
    });
    super.initState();
  }

  Future<void> _ensureDataLoaded() async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final playlistProvider = context.read<PlaylistProvider>();
    final versionProvider = context.read<VersionProvider>();
    final flowItemProvider = context.read<FlowItemProvider>();

    if (widget.scheduleId == null) throw Exception("Schedule ID is required");

    if (!isCloud) {
      await scheduleProvider.loadLocalSchedule(widget.scheduleId);
      final schedule = scheduleProvider.schedules[widget.scheduleId];
      await playlistProvider.loadPlaylist(schedule.playlistId);
      await versionProvider.loadVersionsForPlaylist(
        playlistProvider.getPlaylistById(schedule.playlistId)!.items,
      );
      await flowItemProvider.loadFlowItemByPlaylistId(schedule.playlistId);
      playlistItems = playlistProvider
          .getPlaylistById(schedule.playlistId)!
          .items;
    } else {
      if (!scheduleProvider.schedules.containsKey(widget.scheduleId)) {
        await scheduleProvider.fetchSchedule(widget.scheduleId);
      }

      final schedule = scheduleProvider.schedules[widget.scheduleId];
      if (schedule == null) {
        throw Exception("Schedule not found");
      }

      playlistItems = (schedule as ScheduleDto).playlist!.getPlaylistItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer6<
      ScheduleProvider,
      PlaylistProvider,
      VersionProvider,
      CipherProvider,
      FlowItemProvider,
      NavigationProvider
    >(
      builder:
          (
            context,
            scheduleProvider,
            playlistProvider,
            versionProvider,
            cipherProvider,
            flowItemProvider,
            navigationProvider,
            child,
          ) {
            return Stack(
              children: [
                // TAB VIEWER
                playlistItems.isEmpty
                    ? (versionProvider.isLoading ||
                              scheduleProvider.isLoading ||
                              flowItemProvider.isLoading ||
                              cipherProvider.isLoading ||
                              playlistProvider.isLoading)
                          ? Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            )
                          : Center(
                              child: Text(
                                AppLocalizations.of(context)!.noPlaylistItems,
                                style: textTheme.bodyMedium,
                              ),
                            )
                    : TabBarView(
                        controller: _tabController,
                        children: playlistItems.map((item) {
                          switch (item.type) {
                            case PlaylistItemType.version:
                              if (isCloud) {
                                return PlayCloudVersion(
                                  versionDTO:
                                      (scheduleProvider.schedules[widget
                                                  .scheduleId]
                                              as ScheduleDto)
                                          .playlist!
                                          .versions[item.firebaseContentId]!,
                                );
                              } else {
                                // Local version play
                                return PlayLocalVersion(versionId: item.id!);
                              }
                            case PlaylistItemType.flowItem:
                              if (isCloud) {
                                final flowItemMap =
                                    (scheduleProvider.schedules[widget
                                                .scheduleId]
                                            as ScheduleDto)
                                        .playlist!
                                        .flowItems[item.firebaseContentId]!;

                                return PlayFlowItem(
                                  flowItem: FlowItem(
                                    firebaseId: item.firebaseContentId!,
                                    playlistId: -1,
                                    title: flowItemMap['title'] as String,
                                    contentText:
                                        flowItemMap['contentText'] as String,
                                    duration: Duration(
                                      seconds: (flowItemMap['duration'] as int),
                                    ),
                                    position: flowItemMap['position'] as int,
                                  ),
                                );
                              } else {
                                return PlayFlowItem(
                                  flowItem: flowItemProvider.getFlowItem(
                                    item.id!,
                                  )!,
                                );
                              }
                          }
                        }).toList(),
                      ),

                // TOP RIGHT CLOSE BUTTON
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => navigationProvider.pop(),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.close,
                        color: colorScheme.shadow,
                        size: 26,
                      ),
                    ),
                  ),
                ),

                // BOTTOM PLAY CONTROLS
                Positioned(
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.surfaceContainerHigh,
                          width: .5,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // PREVIOUS ITEM BUTTON
                            GestureDetector(
                              onTap: () {
                                // TODO: Go to previous item
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                height: 48,
                                child: Icon(
                                  Icons.chevron_left,
                                  color: colorScheme.shadow,
                                  size: 48,
                                ),
                              ),
                            ),

                            // PAUSE/PLAY BUTTON
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPlaying = !isPlaying;
                                });
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                height: 48,
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: colorScheme.shadow,
                                  size: 48,
                                ),
                              ),
                            ),

                            // NEXT ITEM BUTTON
                            GestureDetector(
                              onTap: () {
                                // TODO: Go to next item
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                height: 48,
                                child: Icon(
                                  Icons.chevron_right,
                                  color: colorScheme.shadow,
                                  size: 48,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            String nextTitle = '';
                            if (currentTabIndex + 1 < playlistItems.length) {
                              final nextItem =
                                  playlistItems[currentTabIndex + 1];
                              if (nextItem.type == PlaylistItemType.version) {
                                if (isCloud) {
                                  nextTitle =
                                      ((scheduleProvider.schedules[widget
                                                  .scheduleId]
                                              as ScheduleDto)
                                          .playlist
                                          ?.versions[nextItem.firebaseContentId]
                                          ?.title) ??
                                      '';
                                } else {
                                  nextTitle =
                                      cipherProvider
                                          .getCipherById(nextItem.id!)
                                          ?.title ??
                                      '';
                                }
                              } else if (nextItem.type ==
                                  PlaylistItemType.flowItem) {
                                if (isCloud) {
                                  nextTitle =
                                      ((scheduleProvider.schedules[widget
                                                      .scheduleId]
                                                  as ScheduleDto)
                                              .playlist
                                              ?.flowItems[nextItem
                                              .firebaseContentId]?['title']
                                          as String?) ??
                                      '';
                                } else {
                                  nextTitle =
                                      flowItemProvider
                                          .getFlowItem(nextItem.id!)
                                          ?.title ??
                                      '';
                                }
                              }
                            }
                            return Text(
                              nextTitle.isEmpty
                                  ? '-'
                                  : AppLocalizations.of(
                                      context,
                                    )!.nextPlaceholder(nextTitle),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.shadow,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }
}
