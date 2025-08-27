import 'package:flutter/material.dart';
import '../models/domain/cipher.dart';
import '../widgets/cipher/cipher_header_section.dart';
import '../widgets/cipher/cipher_content_section.dart';
import 'edit_cipher.dart';

class CipherViewer extends StatelessWidget {
  final Cipher cipher;

  const CipherViewer({super.key, required this.cipher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cipher.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Cifra',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCipher(cipher: cipher),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header information
            CipherHeaderSection(cipher: cipher),
            const SizedBox(height: 24),
            
            // Cipher content section
            CipherContentSection(cipher: cipher),
          ],
        ),
      ),
    );
  }
}
