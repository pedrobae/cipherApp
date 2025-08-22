import 'package:flutter/material.dart';
import '../../models/domain/info_item.dart';

class InfoCard extends StatelessWidget {
  final InfoItem item;

  const InfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeChip(),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                item.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(item.publishedAt),
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    Color chipColor;
    switch (item.type) {
      case InfoType.news:
        chipColor = Colors.blue;
        break;
      case InfoType.announcement:
        chipColor = Colors.orange;
        break;
      case InfoType.event:
        chipColor = Colors.green;
        break;
    }

    return Chip(
      label: Text(
        item.type.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
