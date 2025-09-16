import 'package:flutter/material.dart';
import '../../models/domain/playlist/playlist_item.dart';

class PresentationHeader extends StatelessWidget {
  final PlaylistItem item;
  final int index;

  const PresentationHeader({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: .1),
            Theme.of(context).primaryColor.withValues(alpha: .05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: .3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Index number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Type icon
          Icon(
            _getIconForType(item.type),
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          
          const SizedBox(width: 8),
          
          // Type label
          Expanded(
            child: Text(
              _getLabelForType(item.type),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'cipher_version':
        return Icons.music_note;
      case 'text_section':
        return Icons.text_fields;
      default:
        return Icons.help;
    }
  }

  String _getLabelForType(String type) {
    switch (type) {
      case 'cipher_version':
        return 'Cifra';
      case 'text_section':
        return 'Seção de Texto';
      default:
        return 'Conteúdo Desconhecido';
    }
  }
}