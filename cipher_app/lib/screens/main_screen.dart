import 'package:cipher_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_drawer.dart';
import 'cipher_library.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String _previousRoute = '/library';

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        final currentRoute = navigationProvider.currentRoute;

        // Clear search when leaving library screen
        if (_previousRoute == '/library' && currentRoute != '/library') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CipherLibraryScreen.clearSearchFromOutside(context);
          });
        }

        // Update previous route for next comparison
        _previousRoute = currentRoute;

        return Scaffold(
          appBar: AppBar(title: Text(navigationProvider.routeTitle)),
          drawer: const AppDrawer(),
          body: AppRoutes.contentRoutes[currentRoute],
        );
      },
    );
  }
}
