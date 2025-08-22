import 'dart:math' as math;

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
          shape: LinearBorder(),
          width: math.min(
            math.max(MediaQuery.of(context).size.width * (2 / 3), 224),
            320,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Text(
                  'Cipher App',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Biblioteca'),
                selected: navigationProvider.selectedIndex == 0,
                onTap: () {
                  navigationProvider.navigateTo(
                    0,
                    NavigationProvider.libraryRoute,
                  );
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.featured_play_list_outlined),
                title: const Text('Playlists'),
                selected: navigationProvider.selectedIndex == 1,
                onTap: () {
                  navigationProvider.navigateTo(
                    1,
                    NavigationProvider.playlistsRoute,
                  );
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações'),
                selected: navigationProvider.selectedIndex == 2,
                onTap: () {
                  navigationProvider.navigateTo(
                    2,
                    NavigationProvider.settingsRoute,
                  );
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Informações'),
                selected: navigationProvider.selectedIndex == 3,
                onTap: () {
                  navigationProvider.navigateTo(
                    3,
                    NavigationProvider.infoRoute,
                  );
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
