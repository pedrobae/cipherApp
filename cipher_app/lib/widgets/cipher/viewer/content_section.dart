import 'package:cipher_app/models/domain/version.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/layout_settings_provider.dart';
import '../../../models/domain/cipher.dart';
import '../../../utils/section.dart';
import 'section_card.dart';

class CipherContentSection extends StatelessWidget {
  final Cipher cipher;
  final Version currentVersion;
  final int columnCount;

  const CipherContentSection({
    super.key,
    required this.cipher,
    required this.currentVersion,
    required this.columnCount,
  });

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LayoutSettingsProvider>();
    final filteredStructure = currentVersion.songStructure
        .split(',')
        .where(
          (sectionCode) =>
              ((ls.showAnnotations || !isAnnotation(sectionCode)) &&
              (ls.showTransitions || !isTransition(sectionCode))),
        );
    final sectionCardList = filteredStructure.map((sectionCode) {
      String trimmedCode = sectionCode.trim();
      return CipherSectionCard(
        sectionType: currentVersion.sections![trimmedCode]!.contentType,
        sectionCode: trimmedCode,
        sectionText: currentVersion.sections![trimmedCode]!.contentText,
        sectionColor: currentVersion.sections![trimmedCode]!.contentColor,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.count(
          crossAxisCount: columnCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: sectionCardList.length,
          itemBuilder: (context, index) => sectionCardList[index],
        ),
      ),
    );
  }
}
