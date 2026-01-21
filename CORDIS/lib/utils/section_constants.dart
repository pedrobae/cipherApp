import 'package:flutter/material.dart';

/// Common Section labels are iterated through on import / parsing to identify sections
/// MIGHT BE PRUDENT TO MAKE THIS LOCALIZABLE IN THE FUTURE
/// AREA OF OPTIMIZATION: use a more efficient data structure for lookups
const Map<String, SectionLabel> commonSectionLabels = {
  'verse': SectionLabel(
    labelVariations: [
      'verse',
      'verso',
      r'(?:\w+\s+)?parte(?:\s*\d+)?',
      r'(?:\w+\s+)?estrofe(?:\s*\d+)?',
    ],
    officialLabel: 'Verse',
    code: 'V',
    color: Colors.blue,
  ),
  'chorus': SectionLabel(
    labelVariations: ['chorus', 'coro', 'refrao', 'refrão'],
    officialLabel: 'Chorus',
    code: 'C',
    color: Colors.red,
  ),
  'bridge': SectionLabel(
    labelVariations: ['bridge', 'ponte'],
    officialLabel: 'Bridge',
    code: 'B',
    color: Colors.green,
  ),
  'intro': SectionLabel(
    labelVariations: ['intro'],
    officialLabel: 'Intro',
    code: 'I',
    color: Colors.purple,
  ),
  'outro': SectionLabel(
    labelVariations: ['outro'],
    officialLabel: 'Outro',
    code: 'O',
    color: Colors.brown,
  ),
  'solo': SectionLabel(
    labelVariations: ['solo'],
    officialLabel: 'Solo',
    code: 'S',
    color: Colors.amber,
  ),
  'pre-chorus': SectionLabel(
    labelVariations: ['pre[- ]?chorus', 'pre[- ]?refrao', 'pré[- ]?refrão'],
    officialLabel: 'Pre-Chorus',
    code: 'PC',
    color: Colors.orange,
  ),
  'tag': SectionLabel(
    labelVariations: ['tag'],
    officialLabel: 'Tag',
    code: 'T',
    color: Colors.teal,
  ),
  'finale': SectionLabel(
    labelVariations: ['finale', 'final'],
    officialLabel: 'Finale',
    code: 'F',
    color: Colors.indigo,
  ),
  'annotations': SectionLabel(
    labelVariations: ['notes', 'anotacoes', 'anotações'],
    officialLabel: 'Annotations',
    code: 'N',
    color: Colors.grey,
  ),
};

class SectionLabel {
  final List<String> labelVariations;
  final String officialLabel;
  final String code;
  final Color color;

  const SectionLabel({
    required this.labelVariations,
    required this.officialLabel,
    required this.code,
    required this.color,
  });

  factory SectionLabel.unknown() {
    return SectionLabel(
      labelVariations: [],
      officialLabel: 'Unlabeled Section',
      code: '',
      color: Colors.grey,
    );
  }
}
