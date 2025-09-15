import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/widgets/cipher/editor/custom_reorderable_delayed.dart';

class ReorderableStructureChips extends StatelessWidget {
  final List<String> songStructure;
  final Map<String, String> sectionTypes;
  final Map<String, Section> customSections;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onRemoveSection;

  const ReorderableStructureChips({
    super.key,
    required this.songStructure,
    required this.sectionTypes,
    required this.customSections,
    required this.onReorder,
    required this.onRemoveSection,
  });

  (String, Color) _getSectionInfo(String key) {
    if (customSections.containsKey(key)) {
      final section = customSections[key]!;
      return (section.contentType, section.contentColor);
    }
    final displayName = sectionTypes[key] ?? key;
    const defaultColors = {
      'I': Colors.purple,
      'V1': Colors.blue,
      'V2': Colors.blue,
      'V3': Colors.blue,
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
    return (displayName, defaultColors[key] ?? Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: songStructure.isEmpty
          ? Center(
              child: Text(
                'Adicione seções usando os botões acima',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          : ReorderableListView.builder(
              proxyDecorator: (child, index, animation) =>
                  Material(type: MaterialType.transparency, child: child),
              buildDefaultDragHandles: false,
              scrollDirection: Axis.horizontal,
              itemCount: songStructure.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final section = songStructure[index];
                final sectionInfo = _getSectionInfo(section);
                final color = sectionInfo.$2;

                return CustomReorderableDelayed(
                  delay: Duration(milliseconds: 100),
                  key: ValueKey('$section-$index'),
                  index: index,
                  child: Container(
                    key: ValueKey('$section-$index'),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .8),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Theme.of(context).highlightColor,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                section,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => onRemoveSection(index),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
