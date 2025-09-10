import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_drawer.dart';
import 'cipher_library.dart';
import 'playlist_library.dart';
import 'settings_screen.dart';
import 'info_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: AppBar(title: Text((navigationProvider.routeTitle))),
          drawer: const AppDrawer(),
          body: IndexedStack(
            index: navigationProvider.selectedIndex,
            children: const [
              CipherLibraryScreen(),
              PlaylistLibraryScreen(),
              SettingsScreen(),
              InfoScreen(),
            ],
          ),
        );
      },
    );
  }
}
