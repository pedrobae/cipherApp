import 'package:flutter/material.dart';
import 'package:cipher_app/utils/app_theme.dart';
import 'package:cipher_app/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeColor _themeColor = ThemeColor.green;
  String _locale = 'pt_BR';
  bool _notificationsEnabled = true;
  bool _reminderNotifications = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  ThemeColor get themeColor => _themeColor;
  String get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get reminderNotifications => _reminderNotifications;

  /// Initialize with stored settings
  Future<void> loadSettings() async {
    _themeMode = SettingsService.getThemeMode();
    _themeColor = SettingsService.getThemeColor();
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

  /// Set theme color and persist
  Future<void> setThemeColor(ThemeColor color) async {
    _themeColor = color;
    await SettingsService.setThemeColor(color);
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

  // Theme getters
  ThemeData get lightTheme =>
      AppTheme.getTheme(_getColorString(_themeColor), false);
  ThemeData get darkTheme =>
      AppTheme.getTheme(_getColorString(_themeColor), true);

  /// Convert ThemeColor enum to string for AppTheme
  String _getColorString(ThemeColor color) {
    switch (color) {
      case ThemeColor.green:
        return 'green';
      case ThemeColor.gold:
        return 'gold';
      case ThemeColor.orange:
        return 'orange';
      case ThemeColor.burgundy:
        return 'burgundy';
    }
  }

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
