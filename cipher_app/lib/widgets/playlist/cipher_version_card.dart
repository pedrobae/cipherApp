import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/domain/cipher.dart';
import 'package:cipher_app/providers/cipher_provider.dart';

class CipherVersionCard extends StatelessWidget {
  final int cipherVersionId;
  const CipherVersionCard({super.key, required this.cipherVersionId});

  @override
  Widget build(BuildContext context) {
    final cipherProvider = Provider.of<CipherProvider>(context);
    final Cipher? cipher =
        cipherProvider.getCipherVersionById(cipherVersionId) as Cipher?;

    return cipher != null
        ? Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Text(cipher.title),
          )
        : Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Text('Error, No cipher found'),
          );
  }
}
