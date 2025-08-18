import 'package:flutter/material.dart';

class BottomNavigationIcons extends StatelessWidget {
  const BottomNavigationIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => Navigator.pushNamed(context, '/info'),
          ),
          IconButton(
            icon: const Icon(Icons.featured_play_list),
            onPressed: () => Navigator.pushNamed(context, '/playlists'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }
}
