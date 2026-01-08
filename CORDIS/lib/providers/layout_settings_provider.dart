import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class LayoutSettingsProvider extends ChangeNotifier {
  double fontSize = 16;
  String fontFamily = 'OpenSans';
  Color chordColor = const Color.fromARGB(255, 0, 0, 0);
  Color lyricColor = Colors.black;
  int columnCount = 1;
  int transposeAmount = 0;
  bool showChords = true;
  bool showLyrics = true;
  bool showAnnotations = true;
  bool showTransitions = true;
  bool showTextSections = true;

  /// Initialize with stored settings
  Future<void> loadSettings() async {
    fontSize = SettingsService.getFontSize();
    fontFamily = SettingsService.getFontFamily();
    chordColor = SettingsService.getChordColor();
    lyricColor = SettingsService.getLyricColor();
    columnCount = SettingsService.getColumnCount();
    showChords = SettingsService.getShowChords();
    showLyrics = SettingsService.getShowLyrics();
    showAnnotations = SettingsService.getShowNotes();
    showTransitions = SettingsService.getShowTransitions();
    showTextSections = SettingsService.getShowTextSections();
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
    showAnnotations = !showAnnotations;
    SettingsService.setShowNotes(showAnnotations);
    notifyListeners();
  }

  void toggleTransitions() {
    showTransitions = !showTransitions;
    SettingsService.setShowTransitions(showTransitions);
    notifyListeners();
  }

  void toggleTextSections() {
    showTextSections = !showTextSections;
    SettingsService.setShowTextSections(showTextSections);
    notifyListeners();
  }

  // Transposition Logic
  String originalKey = 'C';
  String currentKey = 'C';

  void setOriginalKey(String key) {
    originalKey = key;
    currentKey = key;
  }

  void resetToOriginalKey() {
    currentKey = originalKey;
    transposeAmount = 0;
    notifyListeners();
  }

  void transposeUp() {
    final currentIndex = keys.indexOf(currentKey);
    final newIndex = (currentIndex + 1) % keys.length;
    currentKey = keys[newIndex];
    transposeAmount = newIndex - keys.indexOf(originalKey);
    notifyListeners();
  }

  void transposeDown() {
    final currentIndex = keys.indexOf(currentKey);
    final newIndex = (currentIndex - 1 + keys.length) % keys.length;
    currentKey = keys[newIndex];
    transposeAmount = newIndex - keys.indexOf(originalKey);
    notifyListeners();
  }

  void selectKey(String key) {
    currentKey = key;
    transposeAmount = keys.indexOf(currentKey) - keys.indexOf(originalKey);
    notifyListeners();
  }

  // Getter for keys
  List<String> get keys => [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'F#',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];

  TextStyle get chordTextStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize.toDouble(),
    color: chordColor,
    fontWeight: FontWeight.bold,
    height: 2,
    letterSpacing: 0,
  );

  TextStyle get lyricTextStyle => TextStyle(
    color: lyricColor,
    fontFamily: fontFamily,
    fontSize: fontSize.toDouble(),
    height: 2,
    letterSpacing: 0,
  );
}
