import 'package:cipher_app/widgets/cipher/tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/domain/cipher.dart';
import 'package:cipher_app/providers/cipher_provider.dart';

class CipherVersionCard extends StatelessWidget {
  final int cipherVersionId;
  const CipherVersionCard({super.key, required this.cipherVersionId});

  @override
  Widget build(BuildContext context) {
    final cipherProvider = Provider.of<CipherProvider>(context);

    return FutureBuilder<Cipher?>(
      future: cipherProvider.getCipherVersionById(cipherVersionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        final cipher = snapshot.data;
        if (cipher == null) {
          return Text('Cifra não encontrada');
        }

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 10,
                        children: [
                          Text(
                            cipher.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(cipher.author),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Versão: ${cipher.maps[0].versionName}'),
                          const SizedBox(width: 8),
                          Text('Tom: ${cipher.musicKey}'),
                          const SizedBox(width: 8),
                          Text('Tempo: ${cipher.tempo}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: cipher.tags
                            .map((tag) => TagChip(tag: tag))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
