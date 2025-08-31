import 'package:flutter/material.dart';

TextStyle getLyricTextStyle() {
  return const TextStyle(
    fontSize: 16,
    fontFamily: 'Roboto',
    color: Colors.black,
    height: 1.2,
    letterSpacing: 0
  );
}

TextStyle getChordTextStyle() {
  return const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    color: Colors.blue,
    height: 1.2,
    letterSpacing: 0
  );
}
