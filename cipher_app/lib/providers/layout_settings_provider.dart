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
  // ...other setters...
}