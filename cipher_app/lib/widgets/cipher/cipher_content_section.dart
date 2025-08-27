import 'package:flutter/material.dart';
import '../../models/domain/cipher.dart';
import 'cipher_content_card.dart';

class CipherContentSection extends StatelessWidget {
  final Cipher cipher;

  const CipherContentSection({
    super.key,
    required this.cipher,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check if cipher has maps and content
            if (cipher.maps.isNotEmpty) 
              ...cipher.maps.map((map) => _buildMapContent(context, map))
            else
              _buildEmptyContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Conteúdo não disponível',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Edite esta cifra para adicionar o conteúdo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent(BuildContext context, dynamic map) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (map.versionName != null && map.versionName!.isNotEmpty) ...[
          Text(
            map.versionName!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        if (map.content.isNotEmpty)
          // Use song structure to display content in correct order
          ...map.songStructure.split(',').map((sectionKey) {
            final sectionKeyTrimmed = sectionKey.trim();
            final contentText = map.content[sectionKeyTrimmed];
            if (contentText != null) {
              return CipherContentCard(
                  contentType: sectionKeyTrimmed,
                  contentText: contentText,
                );
            } else {
              return const SizedBox.shrink();
            }
          })
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta versão não possui conteúdo ainda',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
      ],
    );
  }
}
