import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/providers/text_section_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/cipher_provider.dart';
import 'providers/collaborator_provider.dart';
import 'providers/info_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/settings_provider.dart';
import 'services/settings_service.dart';
import 'routes/app_routes.dart';
import 'helpers/database_factory.dart';

void main() async {
  // Ensure Flutter is initialized before database operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory based on platform
  await DatabaseFactoryHelper.initialize();

  // Initialize settings service
  await SettingsService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => LayoutSettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => CipherProvider()),
        ChangeNotifierProvider(create: (_) => InfoProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => CollaboratorProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TextSectionProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'App de Cifras',
            theme: settingsProvider.lightTheme,
            darkTheme: settingsProvider.darkTheme,
            themeMode: settingsProvider.themeMode,
            initialRoute: AppRoutes.home,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
