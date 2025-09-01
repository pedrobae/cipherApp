import 'package:flutter/material.dart';
import '../../models/domain/cipher.dart';
import 'cipher_content_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CipherContentSection extends StatelessWidget {
  final Cipher cipher;
  final CipherMap currentVersion;
  final int columnCount;

  const CipherContentSection({
    super.key,
    required this.cipher,
    required this.currentVersion,
    required this.columnCount,
  });

  @override
  Widget build(BuildContext context) {
    final contentCardList = currentVersion.songStructure.split(',').map((
      sectionKey,
    ) {
      final contentText = currentVersion.content[sectionKey];
      return CipherContentCard(
        contentType: sectionKey,
        contentText: contentText,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.count(
          crossAxisCount: columnCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: contentCardList.length,
          itemBuilder: (context, index) => contentCardList[index],
        ),
      ),
    );
  }
}
