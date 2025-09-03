import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _locale = 'pt_BR';
  bool _notificationsEnabled = true;
  bool _reminderNotifications = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get reminderNotifications => _reminderNotifications;
  
  // Theme getters
  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;

  /// Initialize with stored settings
  Future<void> loadSettings() async {
    _themeMode = SettingsService.getThemeMode();
    _locale = SettingsService.getLocale();
    _notificationsEnabled = SettingsService.getNotificationsEnabled();
    _reminderNotifications = SettingsService.getReminderNotifications();
    notifyListeners();
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await SettingsService.setThemeMode(mode);
    notifyListeners();
  }

  /// Set locale and persist
  Future<void> setLocale(String locale) async {
    _locale = locale;
    await SettingsService.setLocale(locale);
    notifyListeners();
  }

  /// Toggle notifications and persist
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await SettingsService.setNotificationsEnabled(_notificationsEnabled);
    notifyListeners();
  }

  /// Set notifications enabled and persist
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await SettingsService.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  /// Toggle reminder notifications and persist
  Future<void> toggleReminderNotifications() async {
    _reminderNotifications = !_reminderNotifications;
    await SettingsService.setReminderNotifications(_reminderNotifications);
    notifyListeners();
  }

  /// Set reminder notifications and persist
  Future<void> setReminderNotifications(bool enabled) async {
    _reminderNotifications = enabled;
    await SettingsService.setReminderNotifications(enabled);
    notifyListeners();
  }

  /// Get theme data based on current theme mode
  ThemeData getThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark ||
        (_themeMode == ThemeMode.dark ||
            (_themeMode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark));

    if (isDark) {
      return _darkTheme;
    } else {
      return _lightTheme;
    }
  }

  /// Light theme configuration
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    fontFamily: 'OpenSans',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  /// Dark theme configuration
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    fontFamily: 'OpenSans',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await SettingsService.clearAllSettings();
    await loadSettings();
  }

  /// Get all settings for debugging/export
  Map<String, dynamic> exportSettings() {
    return SettingsService.exportSettings();
  }
}
