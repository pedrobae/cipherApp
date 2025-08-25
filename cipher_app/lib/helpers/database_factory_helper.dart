import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseFactoryHelper {
  /// Initializes the appropriate database factory based on the current platform.
  /// 
  /// - **Mobile (iOS/Android)**: Uses native sqflite
  /// - **Desktop (Windows/Linux/macOS)**: Uses sqflite_common_ffi
  /// - **Web**: Throws UnsupportedError (sqflite doesn't work on web)
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web platform - sqflite doesn't work on web
      throw UnsupportedError(
        'Database operations are not supported on web platform. '
        'Consider using shared_preferences, IndexedDB wrapper, or Firebase Firestore.'
      );
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
               defaultTargetPlatform == TargetPlatform.linux ||
               defaultTargetPlatform == TargetPlatform.macOS) {
      // Desktop platforms - use FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      
      if (kDebugMode) {
        print('Database factory initialized for desktop platform (${defaultTargetPlatform.name})');
      }
    } else {
      // Mobile platforms (iOS, Android) - sqflite works natively
      // No additional setup needed
      if (kDebugMode) {
        print('Using native sqflite for mobile platform (${defaultTargetPlatform.name})');
      }
    }
  }

  /// Initializes database factory for testing environments.
  /// Always uses sqflite_common_ffi regardless of platform.
  static void initializeForTesting() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    if (kDebugMode) {
      print('Database factory initialized for testing');
    }
  }

  /// Checks if the database factory is properly initialized.
  /// Returns true if factory is available, false otherwise.
  static bool get isInitialized {
    try {
      // Try to access the factory - will throw if not initialized
      databaseFactory.toString();
      return true;
    } catch (e) {
      return false;
    }
  }
}
