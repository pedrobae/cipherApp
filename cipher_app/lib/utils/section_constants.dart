import 'package:flutter/material.dart';

final List<SectionLabels> commonSectionLabels = [
  SectionLabels(
    labelVariations: ['verse', 'verso', r'parte\s*\d+', r'estrofe\s*\d+'],
    officialLabel: 'Verse',
    code: 'V',
  ),
  SectionLabels(
    labelVariations: ['chorus', 'coro', 'refrao', 'refrão'],
    officialLabel: 'Chorus',
    code: 'C',
  ),
  SectionLabels(
    labelVariations: ['bridge', 'ponte'],
    officialLabel: 'Bridge',
    code: 'B',
  ),
  SectionLabels(labelVariations: ['intro'], officialLabel: 'Intro', code: 'I'),
  SectionLabels(labelVariations: ['outro'], officialLabel: 'Outro', code: 'O'),
];

class SectionLabels {
  List<String> labelVariations;
  String officialLabel;
  String code;

  SectionLabels({
    required this.labelVariations,
    required this.officialLabel,
    required this.code,
  });
}

/// Available colors for section selection in the cipher editor
const List<Color> availableColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.amber,
  Colors.teal,
  Colors.brown,
  Colors.indigo,
  Colors.pink,
  Colors.cyan,
  Colors.lime,
];

/// Predefined section types with Portuguese display names
const Map<String, String> predefinedSectionTypes = {
  'I': 'Intro',
  'V': 'Verso',
  'V1': 'Verso 1',
  'V2': 'Verso 2',
  'V3': 'Verso 3',
  'V4': 'Verso 4',
  'C': 'Refrão',
  'C1': 'Refrão 1',
  'C2': 'Refrão 2',
  'PC': 'Pré-Refrão',
  'B': 'Ponte',
  'B1': 'Ponte 1',
  'B2': 'Ponte 2',
  'S': 'Solo',
  'O': 'Outro',
  'F': 'Final',
  'N': 'Anotações',
  'T': 'Tag',
};

/// Default colors for predefined sections
const Map<String, Color> defaultSectionColors = {
  'I': Colors.purple,
  'V': Colors.blue,
  'V1': Colors.blue,
  'V2': Colors.blue,
  'V3': Colors.blue,
  'V4': Colors.blue,
  'C': Colors.red,
  'C1': Colors.red,
  'C2': Colors.red,
  'PC': Colors.orange,
  'B': Colors.green,
  'B1': Colors.green,
  'B2': Colors.green,
  'S': Colors.amber,
  'O': Colors.brown,
  'F': Colors.indigo,
  'N': Colors.grey,
  'T': Colors.teal,
};

String? getCodeFromLabel(String label) {
  String? code;

  for (var entry in commonSectionLabels) {
    if (entry.officialLabel.toLowerCase() == label.toLowerCase()) {
      code = entry.code;
      break;
    }
  }

  return code;
}
