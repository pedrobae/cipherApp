import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Library'),
                selected: navigationProvider.selectedIndex == 0,
                onTap: () {
                  navigationProvider.navigateTo(0, NavigationProvider.libraryRoute);
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.featured_play_list),
                title: const Text('Playlists'),
                selected: navigationProvider.selectedIndex == 1,
                onTap: () {
                  navigationProvider.navigateTo(1, NavigationProvider.playlistsRoute);
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                selected: navigationProvider.selectedIndex == 2,
                onTap: () {
                  navigationProvider.navigateTo(2, NavigationProvider.settingsRoute);
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Info'),
                selected: navigationProvider.selectedIndex == 3,
                onTap: () {
                  navigationProvider.navigateTo(3, NavigationProvider.infoRoute);
                  Navigator.pop(context); // Close drawer
                },
              ),
            ],
          ),
        );
      },
    );
  }
}