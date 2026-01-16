import 'package:flutter/material.dart';

/// Common Section labels are iterated through on import / parsing to identify sections
/// MIGHT BE PRUDENT TO MAKE THIS LOCALIZABLE IN THE FUTURE
/// AREA OF OPTIMIZATION: use a more efficient data structure for lookups
const Map<String, SectionLabels> commonSectionLabels = {
  'verse': SectionLabels(
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
  'chorus': SectionLabels(
    labelVariations: ['chorus', 'coro', 'refrao', 'refrão'],
    officialLabel: 'Chorus',
    code: 'C',
    color: Colors.red,
  ),
  'bridge': SectionLabels(
    labelVariations: ['bridge', 'ponte'],
    officialLabel: 'Bridge',
    code: 'B',
    color: Colors.green,
  ),
  'intro': SectionLabels(
    labelVariations: ['intro'],
    officialLabel: 'Intro',
    code: 'I',
    color: Colors.purple,
  ),
  'outro': SectionLabels(
    labelVariations: ['outro'],
    officialLabel: 'Outro',
    code: 'O',
    color: Colors.brown,
  ),
  'solo': SectionLabels(
    labelVariations: ['solo'],
    officialLabel: 'Solo',
    code: 'S',
    color: Colors.amber,
  ),
  'pre-chorus': SectionLabels(
    labelVariations: ['pre[- ]?chorus', 'pre[- ]?refrao', 'pré[- ]?refrão'],
    officialLabel: 'Pre-Chorus',
    code: 'PC',
    color: Colors.orange,
  ),
  'tag': SectionLabels(
    labelVariations: ['tag'],
    officialLabel: 'Tag',
    code: 'T',
    color: Colors.teal,
  ),
  'finale': SectionLabels(
    labelVariations: ['finale', 'final'],
    officialLabel: 'Finale',
    code: 'F',
    color: Colors.indigo,
  ),
  'annotations': SectionLabels(
    labelVariations: ['notes', 'anotacoes', 'anotações'],
    officialLabel: 'Annotations',
    code: 'N',
    color: Colors.grey,
  ),
};

class SectionLabels {
  final List<String> labelVariations;
  final String officialLabel;
  final String code;
  final Color color;

  const SectionLabels({
    required this.labelVariations,
    required this.officialLabel,
    required this.code,
    required this.color,
  });
}
