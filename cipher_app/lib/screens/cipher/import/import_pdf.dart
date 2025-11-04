import 'package:flutter/material.dart';

class ImportPdfScreen extends StatelessWidget {
  final bool isNewCipher;

  const ImportPdfScreen({super.key, required this.isNewCipher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar de PDF')),
      body: Center(
        child: Text(
          isNewCipher
              ? 'Tela para importar uma nova cifra de um PDF.'
              : 'Tela para importar uma cifra existente de um PDF.',
        ),
      ),
    );
  }
}
