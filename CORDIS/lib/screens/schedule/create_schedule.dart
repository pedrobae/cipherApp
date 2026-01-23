import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/schedule_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/widgets/playlist/library/playlist_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({super.key});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer5<
      ScheduleProvider,
      PlaylistProvider,
      UserProvider,
      MyAuthProvider,
      NavigationProvider
    >(
      builder:
          (
            context,
            scheduleProvider,
            playlistProvider,
            userProvider,
            myAuthProvider,
            navigationProvider,
            child,
          ) {
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    navigationProvider.pop();
                  },
                ),
                title: Text(AppLocalizations.of(context)!.schedulePlaylist),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppLocalizations.of(context)!.stepXofY(1, 3)),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.selectPlaylistForScheduleInstruction,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchPlaylist,
                    ),
                    onChanged: (value) {
                      playlistProvider.setSearchTerm(value);
                    },
                  ),
                  Expanded(child: PlaylistScrollView()),
                ],
              ),
            );
          },
    );
  }
}
