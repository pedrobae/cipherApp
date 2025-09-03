import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../models/domain/cipher.dart';
import 'section_card.dart';


class CipherContentSection extends StatelessWidget {
  final Cipher cipher;
  final CipherVersion currentVersion;
  final int columnCount;

  const CipherContentSection({
    super.key,
    required this.cipher,
    required this.currentVersion,
    required this.columnCount,
  });

  @override
  Widget build(BuildContext context) {
    final sectionCardList = currentVersion.songStructure.split(',').map((
      sectionCode,
    ) {
      return CipherSectionCard(
        sectionType: currentVersion.sections![sectionCode]!.contentType,
        sectionCode: sectionCode,
        sectionText: currentVersion.sections![sectionCode]!.contentText,
        sectionColor: currentVersion.sections![sectionCode]!.contentColor,
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
