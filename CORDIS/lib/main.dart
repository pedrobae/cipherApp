import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cordis/helpers/database_factory.dart';
import 'package:cordis/providers/admin_provider.dart';
import 'package:cordis/providers/auth_provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/collaborator_provider.dart';
import 'package:cordis/providers/import_provider.dart';
import 'package:cordis/providers/info_provider.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/parser_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/settings_provider.dart';
import 'package:cordis/providers/text_section_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/routes/app_routes.dart';
import 'package:cordis/services/firebase_service.dart';
import 'package:cordis/services/settings_service.dart';

void main() async {
  // Ensure Flutter is initialized before database operations
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseFactoryHelper.initialize();

  await FirebaseService.initialize();

  await SettingsService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CipherProvider()),
        ChangeNotifierProvider(create: (_) => CollaboratorProvider()),
        ChangeNotifierProvider(create: (_) => ImportProvider()),
        ChangeNotifierProvider(create: (_) => InfoProvider()),
        ChangeNotifierProvider(
          create: (_) => LayoutSettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ParserProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => SectionProvider()),
        ChangeNotifierProvider(create: (_) => SelectionProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => TextSectionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUsers()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CORDIS',
            theme: settingsProvider.lightTheme,
            darkTheme: settingsProvider.darkTheme,
            themeMode: settingsProvider.themeMode,
            initialRoute: AppRoutes.login,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
