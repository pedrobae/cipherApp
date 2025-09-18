import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/providers/text_section_provider.dart';
import 'package:cipher_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  try {
    // Initialize database factory based on platform
    if (!kIsWeb) {
      await DatabaseFactoryHelper.initialize();
    }

    // Initialize settings service
    await SettingsService.initialize();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    // If initialization fails, show error screen
    if (kDebugMode) {
      print('Initialization error: $e');
      print('Stack trace: $stackTrace');
    }
    runApp(ErrorApp(error: e.toString()));
  }
}

// Error app to show when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Cifras - Erro',
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Erro de Inicialização',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'O aplicativo encontrou um erro durante a inicialização:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // For now, just show the error - in a real app you might retry
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
