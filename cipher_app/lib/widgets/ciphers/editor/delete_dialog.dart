import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteDialog extends StatelessWidget {
  final int? cipherId;
  final int? versionId;

  const DeleteDialog({super.key, this.cipherId, this.versionId});

  @override
  Widget build(BuildContext context) {
    final bool cipherDelete = versionId == null;
    final cipherProvider = context.read<CipherProvider>();
    final versionProvider = context.read<VersionProvider>();

    if (cipherDelete) {
      return AlertDialog(
        title: const Text('Excluir Cifra'),
        content: const Text(
          'Tem certeza que deseja excluir esta cifra? Excluir uma cifra excluirá todas as suas versões.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _deleteCipher(cipherProvider, context),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: const Text('Excluir Versão'),
        content: const Text(
          'Tem certeza que deseja excluir esta versão? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _deleteVersion(versionProvider, context),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      );
    }
  }

  void _deleteCipher(
    CipherProvider cipherProvider,
    BuildContext context,
  ) async {
    try {
      await cipherProvider.deleteCipher(cipherId!);
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context, true); // Close screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cifra excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _deleteVersion(
    VersionProvider versionProvider,
    BuildContext context,
  ) async {
    try {
      await versionProvider.deleteCipherVersion(versionId!);
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Versão excluída com sucesso!')));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
