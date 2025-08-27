import 'package:flutter/material.dart';

class SectionType {
  final String name;
  final Color color;

  const SectionType(this.name, this.color);
}

class SectionColorManager {
  // Predefined section types with display names and colors
  static const Map<String, SectionType> predefinedSectionTypes = {
    'I': SectionType('Intro', Colors.purple),
    'V1': SectionType('Verso 1', Colors.blue),
    'V2': SectionType('Verso 2', Colors.blue),
    'V3': SectionType('Verso 3', Colors.blue),
    'C': SectionType('Refrão', Colors.red),
    'C1': SectionType('Refrão 1', Colors.red),
    'C2': SectionType('Refrão 2', Colors.red),
    'PC': SectionType('Pré-Refrão', Colors.orange),
    'B': SectionType('Ponte', Colors.green),
    'B1': SectionType('Ponte 1', Colors.green),
    'B2': SectionType('Ponte 2', Colors.green),
    'S': SectionType('Solo', Colors.amber),
    'O': SectionType('Outro', Colors.brown),
    'F': SectionType('Final', Colors.indigo),
    'N': SectionType('Notas', Colors.grey),
    'T': SectionType('Tag', Colors.teal),
  };

  /// Gets the section type for a given key, checking custom sections first,
  /// then predefined sections, and finally falling back to a default grey section
  static SectionType getSectionType(
    String key, 
    Map<String, SectionType>? customSections,
  ) {
    return customSections?[key] ?? 
           predefinedSectionTypes[key] ?? 
           SectionType(key, Colors.grey);
  }

  /// Gets just the color for a section key
  static Color getSectionColor(
    String key, 
    Map<String, SectionType>? customSections,
  ) {
    return getSectionType(key, customSections).color;
  }

  /// Gets all available section types (predefined + custom)
  static Map<String, SectionType> getAllSectionTypes(
    Map<String, SectionType>? customSections,
  ) {
    final allTypes = Map<String, SectionType>.from(predefinedSectionTypes);
    if (customSections != null) {
      allTypes.addAll(customSections);
    }
    return allTypes;
  }

  /// Available colors for creating custom sections
  static const List<Color> availableColors = [
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
}
