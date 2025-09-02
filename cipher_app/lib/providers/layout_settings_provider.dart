import 'package:flutter/material.dart';

class LayoutSettingsProvider extends ChangeNotifier {
  double fontSize = 16;
  String fontFamily = 'OpenSans';
  Color chordColor = Colors.blue;
  Color lyricColor = Colors.black; // Assuming a default color for lyrics
  int columnCount = 1;
  bool showChords = true;
  bool showLyrics = true;
  bool showNotes = true;
  bool showTransitions = true;

  // Add setters that call notifyListeners()
  void setFontSize(double value) {
    fontSize = value;
    notifyListeners();
  }
  
  void setFontFamily(String family) {
    fontFamily = family;
    notifyListeners();
  }

  void setChordColor(Color color) {
    chordColor = color;
    notifyListeners();
  }

  void setColumnCount(int count) {
    columnCount = count;
    notifyListeners();
  }

  void toggleChords() {
    showChords = !showChords;
    notifyListeners();
  }

  void toggleLyrics() {
    showLyrics = !showLyrics;
    notifyListeners();
  }
  
  void toggleNotes() {
    showNotes = !showNotes;
    notifyListeners();
  }

  void toggleTransitions() {
    showTransitions = !showTransitions;
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