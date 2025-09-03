import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class LayoutSettingsProvider extends ChangeNotifier {
  double fontSize = 16;
  String fontFamily = 'OpenSans';
  Color chordColor = Colors.blue;
  Color lyricColor = Colors.black;
  int columnCount = 1;
  bool showChords = true;
  bool showLyrics = true;
  bool showNotes = true;
  bool showTransitions = true;

  /// Initialize with stored settings
  Future<void> loadSettings() async {
    fontSize = SettingsService.getFontSize();
    fontFamily = SettingsService.getFontFamily();
    chordColor = SettingsService.getChordColor();
    lyricColor = SettingsService.getLyricColor();
    columnCount = SettingsService.getColumnCount();
    showChords = SettingsService.getShowChords();
    showLyrics = SettingsService.getShowLyrics();
    showNotes = SettingsService.getShowNotes();
    showTransitions = SettingsService.getShowTransitions();
    notifyListeners();
  }

  // Add setters that call notifyListeners() and persist to storage
  void setFontSize(double value) {
    fontSize = value;
    SettingsService.setFontSize(value);
    notifyListeners();
  }
  
  void setFontFamily(String family) {
    fontFamily = family;
    SettingsService.setFontFamily(family);
    notifyListeners();
  }

  void setChordColor(Color color) {
    chordColor = color;
    SettingsService.setChordColor(color);
    notifyListeners();
  }

  void setLyricColor(Color color) {
    lyricColor = color;
    SettingsService.setLyricColor(color);
    notifyListeners();
  }

  void setColumnCount(int count) {
    columnCount = count;
    SettingsService.setColumnCount(count);
    notifyListeners();
  }

  void toggleChords() {
    showChords = !showChords;
    SettingsService.setShowChords(showChords);
    notifyListeners();
  }

  void toggleLyrics() {
    showLyrics = !showLyrics;
    SettingsService.setShowLyrics(showLyrics);
    notifyListeners();
  }
  
  void toggleNotes() {
    showNotes = !showNotes;
    SettingsService.setShowNotes(showNotes);
    notifyListeners();
  }

  void toggleTransitions() {
    showTransitions = !showTransitions;
    SettingsService.setShowTransitions(showTransitions);
    notifyListeners();
  }

  TextStyle get chordTextStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize.toDouble(),
    color: chordColor,
    fontWeight: FontWeight.bold,
    height: 2.2,
    letterSpacing: 0,
  );

  TextStyle get lyricTextStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize.toDouble(),
    color: lyricColor,
    height: 2.2,
    letterSpacing: 0, 
  );
}