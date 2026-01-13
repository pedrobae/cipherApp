import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/auth_provider.dart';

import 'package:cordis/widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().addListener(_authListener);
  }

  void _authListener() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushNamed('/login');
    }
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<AuthProvider, NavigationProvider>(
      builder: (context, authProvider, navigationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.surfaceContainer,
            centerTitle: true,
            title: SvgPicture.asset(
              'assets/logos/v2_simple_color_white.svg',
              width: 80,
            ),
          ),
          drawer: AppDrawer(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.surfaceContainerLowest,
                  width: 0.1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: navigationProvider.currentIndex,
              selectedLabelStyle: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              elevation: 2,
              onTap: (index) {
                navigationProvider.navigateToRoute(
                  NavigationRoute.values[index],
                );
              },
              items: navigationProvider
                  .getNavigationItems(
                    context,
                    iconSize: 24,
                    color: colorScheme.onSurface,
                    activeColor: theme.colorScheme.primary,
                  )
                  .map(
                    (navItem) => BottomNavigationBarItem(
                      icon: navItem.icon,
                      label: navItem.title,
                      backgroundColor: colorScheme.surface,
                      activeIcon: navItem.activeIcon,
                    ),
                  )
                  .toList(),
            ),
          ),
          body: navigationProvider.currentScreen,
        );
      },
    );
  }
}
