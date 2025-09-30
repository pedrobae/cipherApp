import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/navigation_provider.dart';
import 'package:cipher_app/routes/app_routes.dart';
import 'package:cipher_app/widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    // If somehow the currentRoute is empty, default to info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationProvider = context.read<NavigationProvider>();
      if (navigationProvider.currentRoute.isEmpty) {
        navigationProvider.navigateToInfo();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        if (navigationProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando...'), // Portuguese UI
                ],
              ),
            ),
          );
        }

        if (navigationProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('App de Cifras')),
            drawer: const AppDrawer(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro: ${navigationProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => navigationProvider.clearError(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(navigationProvider.routeTitle)),
          drawer: const AppDrawer(),
          body: AppRoutes.contentRoutes[navigationProvider.currentRoute],
        );
      },
    );
  }
}
