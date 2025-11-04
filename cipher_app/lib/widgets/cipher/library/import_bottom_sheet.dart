import 'package:cipher_app/screens/cipher/import/import_image.dart';
import 'package:cipher_app/screens/cipher/import/import_pdf.dart';
import 'package:cipher_app/screens/cipher/import/import_text.dart';
import 'package:flutter/material.dart';

class ImportBottomSheet extends StatelessWidget {
  final bool isNewCipher;

  const ImportBottomSheet({super.key, required this.isNewCipher});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        child: Align(
          alignment: AlignmentGeometry.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Importar Cifra',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Divider(),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text('Importar de Texto'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ImportTextScreen(isNewCipher: isNewCipher),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Importar de PDF'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ImportPdfScreen(isNewCipher: isNewCipher),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Importar de Imagem'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ImportImageScreen(isNewCipher: isNewCipher),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
