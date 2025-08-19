import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, _) => Drawer(
        child: ListView(
          children: [
            _buildDrawerHeader(context),
            ...drawerItems.map((item) => _buildDrawerItem(context, item, nav)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    // Extract header to separate method
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Text(
        'Menu',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item, NavigationProvider nav) {
    // Extract item building logic
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      selected: nav.selectedIndex == item.index,
      onTap: () {
        nav.navigateTo(item.index, item.route);
        Navigator.pushNamed(context, item.route);
      },
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final int index;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.index,
  });
}

final List<DrawerItem> drawerItems = [
  DrawerItem(
    icon: Icons.library_books,
    title: 'Library',
    route: '/library',
    index: 0,
  ),
  DrawerItem(
    icon: Icons.featured_play_list,
    title: 'Playlists',
    route: '/playlists',
    index: 1,
  ),
  DrawerItem(
    icon: Icons.settings,
    title: 'Settings',
    route: '/settings',
    index: 2,
  ),
  DrawerItem(
    icon: Icons.info,
    title: 'Info',
    route: '/info',
    index: 3,
  ),
];