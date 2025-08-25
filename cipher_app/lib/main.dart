import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/navigation_provider.dart';
import 'providers/search_provider.dart';
import 'providers/cipher_provider.dart';
import 'providers/info_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  // Ensure Flutter is initialized before database operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database factory based on platform
  await _initializeDatabaseFactory();
  
  runApp(const MyApp());
}

Future<void> _initializeDatabaseFactory() async {
  if (kIsWeb) {
    // Web platform - you might want to use a different storage solution
    // For now, we'll throw an error as sqflite doesn't work on web
    throw UnsupportedError('Database operations are not supported on web platform. Consider using shared_preferences or IndexedDB wrapper.');
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.linux ||
             defaultTargetPlatform == TargetPlatform.macOS) {
    // Desktop platforms - use FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    if (kDebugMode) {
      print('Database factory initialized for desktop platform');
    }
  } else {
    // Mobile platforms (iOS, Android) - sqflite works natively
    // No additional setup needed
    if (kDebugMode) {
      print('Using native sqflite for mobile platform');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => CipherProvider()),
        ChangeNotifierProvider(create: (_) => InfoProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cipher App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 129, 17),
            brightness: Brightness.light,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          ),
          useMaterial3: true,
          // Add custom theme extensions
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
      ),
    );
  }
}
