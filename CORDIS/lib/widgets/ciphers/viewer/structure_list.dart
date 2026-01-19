import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/section_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StructureList extends StatelessWidget {
  final dynamic versionId;
  final List<String> filteredStructure;
  final ScrollController scrollController;
  final List<GlobalKey> sectionKeys;

  const StructureList({
    super.key,
    required this.versionId,
    required this.filteredStructure,
    required this.scrollController,
    required this.sectionKeys,
  });

  void _scrollToSection(BuildContext context, int index) {
    final sectionKey = sectionKeys[index];
    final renderBox =
        sectionKey.currentContext?.findRenderObject() as RenderBox;

    final offset = renderBox.localToGlobal(Offset.zero).dy;

    scrollController.animateTo(
      scrollController.offset + offset - 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer2<VersionProvider, SectionProvider>(
      builder: (context, versionProvider, sectionProvider, child) {
        return Container(
          padding: EdgeInsets.all(8),
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.surfaceContainerLowest),
            borderRadius: BorderRadius.circular(0),
          ),
          child: filteredStructure.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noSectionsInStructurePrompt,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: [
                      ...filteredStructure.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sectionCode = entry.value;
                        final section = sectionProvider.getSection(
                          versionId,
                          sectionCode,
                        );
                        // Loading state
                        if (section == null || sectionProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        final color = section.contentColor;
                        return GestureDetector(
                          onTap: () => _scrollToSection(context, index),
                          child: Container(
                            padding: const EdgeInsets.only(right: 8),
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: .8),
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(
                                color: colorScheme.shadow,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                sectionCode,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
