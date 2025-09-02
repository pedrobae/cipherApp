import 'package:flutter/material.dart';

class LayoutSettingsProvider extends ChangeNotifier {
  int fontSize = 16;
  String fontFamily = 'OpenSans';
  Color chordColor = Colors.blue;
  int columnCount = 1;
  bool showChords = true;
  bool showLyrics = true;
  bool showNotes = true;
  bool showTransitions = true;

  // Add setters that call notifyListeners()
  void setFontSize(int value) {
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
}