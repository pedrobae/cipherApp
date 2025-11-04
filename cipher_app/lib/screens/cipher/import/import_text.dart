import 'package:flutter/material.dart';

class ImportTextScreen extends StatelessWidget {
  final bool isNewCipher;

  const ImportTextScreen({super.key, required this.isNewCipher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar de Texto')),
      body: Center(
        child: Text(
          isNewCipher
              ? 'Tela para importar uma nova cifra de texto.'
              : 'Tela para importar uma cifra existente de texto.',
        ),
      ),
    );
  }
}
