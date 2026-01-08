import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<NavigationProvider, AuthProvider>(
      builder: (context, navigationProvider, authProvider, child) {
        return Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.horizontal(
              right: Radius.circular(50),
            ),
          ),
          width: math.min(
            math.max(MediaQuery.of(context).size.width * (2 / 3), 224),
            320,
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'App de Cifras',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Biblioteca'),
                selected: navigationProvider.selectedIndex == 0,
                onTap: () {
                  navigationProvider.navigateToLibrary();
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.featured_play_list_outlined),
                title: const Text('Playlists'),
                selected: navigationProvider.selectedIndex == 1,
                onTap: () {
                  navigationProvider.navigateToPlaylists();
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações'),
                selected: navigationProvider.selectedIndex == 2,
                onTap: () {
                  navigationProvider.navigateToSettings();
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Informações'),
                selected: navigationProvider.selectedIndex == 3,
                onTap: () {
                  navigationProvider.navigateToInfo();
                  Navigator.pop(context); // Close drawer
                },
              ),
              // Push admin to bottom
              const Spacer(),
              if (authProvider.isAdmin) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Administração'),
                  selected: navigationProvider.selectedIndex == 4,
                  onTap: () {
                    navigationProvider.navigateToAdmin();
                    Navigator.pop(context); // Close drawer
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
