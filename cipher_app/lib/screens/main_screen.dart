import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cipher_app/providers/navigation_provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';

import 'package:cipher_app/widgets/login_bottom_sheet.dart';
import 'package:cipher_app/widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    // Open login bottom sheet if not authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
      if (!isAuthenticated) {
        showModalBottomSheet(
          context: context,
          builder: (context) => LoginBottomSheet(),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NavigationProvider>(
      builder: (context, authProvider, navigationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Center(
              child: SvgPicture.asset(
                'assets/logos/v2_simple_color_white.svg',
                width: 200,
              ),
            ),
          ),
          drawer: const AppDrawer(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) {
              navigationProvider.navigateToRoute(NavigationRoute.values[index]);
            },
            items: navigationProvider
                .getNavigationItems(context)
                .map(
                  (navItem) => BottomNavigationBarItem(
                    icon: navItem.icon,
                    label: navItem.title,
                  ),
                )
                .toList(),
          ),
          body: navigationProvider.currentScreen,
        );
      },
    );
  }
}
