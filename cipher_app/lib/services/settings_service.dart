import 'package:cipher_app/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // App Settings Keys
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyThemeColor = 'theme_color';
  static const String _keyLocale = 'locale';

  // Layout Settings Keys
  static const String _keyFontSize = 'layout_font_size';
  static const String _keyFontFamily = 'layout_font_family';
  static const String _keyChordColor = 'layout_chord_color';
  static const String _keyLyricColor = 'layout_lyric_color';
  static const String _keyColumnCount = 'layout_column_count';
  static const String _keyShowChords = 'layout_show_chords';
  static const String _keyShowLyrics = 'layout_show_lyrics';
  static const String _keyShowNotes = 'layout_show_notes';
  static const String _keyShowTransitions = 'layout_show_transitions';
  static const String _keyShowTextSections = 'layout_show_text_sections';

  // Notification Settnigs Keys
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyReminderNotifications = 'reminder_notifications';

  static SharedPreferences? _prefs;

  /// Initialize the service
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get _preferences {
    assert(_prefs != null, 'SettingsService must be initialized first');
    return _prefs!;
  }

  // === APP SETTINGS ===

  /// Save theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    await _preferences.setString(_keyThemeMode, mode.name);
  }

  /// Get theme mode
  static ThemeMode getThemeMode() {
    final value = _preferences.getString(_keyThemeMode) ?? 'system';
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  /// Save theme color
  static Future<void> setThemeColor(ThemeColor color) async {
    await _preferences.setString(_keyThemeColor, color.name);
  }

  /// Get theme color
  static ThemeColor getThemeColor() {
    final value = _preferences.getString(_keyThemeColor) ?? 'green';
    return ThemeColor.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeColor.green,
    );
  }

  /// Save locale
  static Future<void> setLocale(String locale) async {
    await _preferences.setString(_keyLocale, locale);
  }

  /// Get locale
  static String getLocale() {
    return _preferences.getString(_keyLocale) ?? 'pt_BR';
  }

  // === LAYOUT SETTINGS ===

  /// Save font size
  static Future<void> setFontSize(double fontSize) async {
    await _preferences.setDouble(_keyFontSize, fontSize);
  }

  /// Get font size
  static double getFontSize() {
    return _preferences.getDouble(_keyFontSize) ?? 16.0;
  }

  /// Save font family
  static Future<void> setFontFamily(String fontFamily) async {
    await _preferences.setString(_keyFontFamily, fontFamily);
  }

  /// Get font family
  static String getFontFamily() {
    return _preferences.getString(_keyFontFamily) ?? 'OpenSans';
  }

  /// Save chord color
  static Future<void> setChordColor(Color color) async {
    await _preferences.setInt(_keyChordColor, color.toARGB32());
  }

  /// Get chord color
  static Color getChordColor() {
    final value = _preferences.getInt(_keyChordColor) ?? Colors.blue.toARGB32();
    return Color(value);
  }

  /// Save lyric color
  static Future<void> setLyricColor(Color color) async {
    await _preferences.setInt(_keyLyricColor, color.toARGB32());
  }

  /// Get lyric color
  static Color getLyricColor() {
    final value =
        _preferences.getInt(_keyLyricColor) ?? Colors.black.toARGB32();
    return Color(value);
  }

  /// Save column count
  static Future<void> setColumnCount(int count) async {
    await _preferences.setInt(_keyColumnCount, count);
  }

  /// Get column count
  static int getColumnCount() {
    return _preferences.getInt(_keyColumnCount) ?? 1;
  }

  /// Save show chords
  static Future<void> setShowChords(bool show) async {
    await _preferences.setBool(_keyShowChords, show);
  }

  /// Get show chords
  static bool getShowChords() {
    return _preferences.getBool(_keyShowChords) ?? true;
  }

  /// Save show lyrics
  static Future<void> setShowLyrics(bool show) async {
    await _preferences.setBool(_keyShowLyrics, show);
  }

  /// Get show lyrics
  static bool getShowLyrics() {
    return _preferences.getBool(_keyShowLyrics) ?? true;
  }

  /// Save show notes
  static Future<void> setShowNotes(bool show) async {
    await _preferences.setBool(_keyShowNotes, show);
  }

  /// Get show notes
  static bool getShowNotes() {
    return _preferences.getBool(_keyShowNotes) ?? true;
  }

  /// Save show transitions
  static Future<void> setShowTransitions(bool show) async {
    await _preferences.setBool(_keyShowTransitions, show);
  }

  /// Get show transitions
  static bool getShowTransitions() {
    return _preferences.getBool(_keyShowTransitions) ?? true;
  }

  /// Save show text sections
  static Future<void> setShowTextSections(bool show) async {
    await _preferences.setBool(_keyShowTextSections, show);
  }

  /// Get show text sections
  static bool getShowTextSections() {
    return _preferences.getBool(_keyShowTextSections) ?? true;
  }

  // === NOTIFICATION SETTINGS ===

  /// Save notifications enabled
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _preferences.setBool(_keyNotificationsEnabled, enabled);
  }

  /// Get notifications enabled
  static bool getNotificationsEnabled() {
    return _preferences.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Save reminder notifications
  static Future<void> setReminderNotifications(bool enabled) async {
    await _preferences.setBool(_keyReminderNotifications, enabled);
  }

  /// Get reminder notifications
  static bool getReminderNotifications() {
    return _preferences.getBool(_keyReminderNotifications) ?? true;
  }

  // === UTILITY METHODS ===

  /// Clear all settings (useful for debugging)
  static Future<void> clearAllSettings() async {
    await _preferences.clear();
  }

  /// Export all settings (useful for debugging or backup)
  static Map<String, dynamic> exportSettings() {
    return {
      'theme_mode': getThemeMode().name,
      'locale': getLocale(),
      'font_size': getFontSize(),
      'font_family': getFontFamily(),
      'chord_color': getChordColor().toARGB32(),
      'lyric_color': getLyricColor().toARGB32(),
      'column_count': getColumnCount(),
      'show_chords': getShowChords(),
      'show_lyrics': getShowLyrics(),
      'show_notes': getShowNotes(),
      'show_transitions': getShowTransitions(),
      'notifications_enabled': getNotificationsEnabled(),
      'reminder_notifications': getReminderNotifications(),
    };
  }
}
