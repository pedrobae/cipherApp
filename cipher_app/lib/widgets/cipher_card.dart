import 'package:flutter/material.dart';
import 'package:cipher_app/models/domain/cipher.dart';

class CipherCard extends StatelessWidget {
  final Cipher cipher;
  final VoidCallback? onAddToPlaylist;

  const CipherCard({super.key, required this.cipher, this.onAddToPlaylist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, '/cipher-viewer', arguments: cipher),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cipher.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: onAddToPlaylist,
                    tooltip: 'Add to playlist',
                  ),
                ],
              ),
              Text(cipher.author),
              Row(
                children: [
                  Text('Key: ${cipher.key}'),
                  const SizedBox(width: 8),
                  Text('Tempo: ${cipher.tempo}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
