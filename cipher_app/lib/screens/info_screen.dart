import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48),
          SizedBox(height: 16),
          Text(
            'App Information',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 8),
          Text('Version 1.0.0'),
        ],
      ),
    );
  }
}