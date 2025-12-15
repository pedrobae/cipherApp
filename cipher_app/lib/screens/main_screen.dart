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
  late VoidCallback _authListener;

  @override
  void initState() {
    super.initState();
    _authListener = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authProvider = context.read<AuthProvider>();
        if (!authProvider.isAuthenticated && mounted) {
          showModalBottomSheet(
            context: context,
            builder: (context) => LoginBottomSheet(),
          );
        }
      });
    };
    context.read<AuthProvider>().addListener(_authListener);
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NavigationProvider>(
      builder: (context, authProvider, navigationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: SvgPicture.asset(
              'assets/logos/v2_simple_color_white.svg',
              width: 80,
            ),
          ),
          drawer: const AppDrawer(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) {
              navigationProvider.navigateToRoute(NavigationRoute.values[index]);
            },
            items: navigationProvider
                .getNavigationItems(context, iconSize: 24)
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
