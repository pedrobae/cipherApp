import 'package:flutter/material.dart';

class CipherViewer extends StatelessWidget {
  const CipherViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cipher Viewer')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 48),
            SizedBox(height: 16),
            Text('Cipher Viewer', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('This is a placeholder screen for viewing ciphers.'),
          ],
        ),
      ),
    );
  }
}
