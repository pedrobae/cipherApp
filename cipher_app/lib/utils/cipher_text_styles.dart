import 'package:flutter/material.dart';

const double yOffset = -8;

TextStyle getLyricTextStyle() {
  return const TextStyle(
    fontSize: 16,
    fontFamily: 'OpenSans',
    color: Colors.black,
    height: 2.2,
    letterSpacing: 0,
  );
}

TextStyle getChordTextStyle() {
  return const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
    color: Colors.blue,
    height: 1,
    letterSpacing: 0,
  );
}
