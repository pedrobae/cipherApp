import 'package:cipher_app/providers/collaborator_provider.dart';
import 'package:flutter/material.dart';
import 'package:cipher_app/models/domain/collaborator.dart';
import 'package:provider/provider.dart';

class CollaboratorTile extends StatelessWidget {
  final Collaborator collaborator;
  final int playlistId;

  const CollaboratorTile({
    super.key,
    required this.collaborator,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: collaborator.profilePhoto != null
            ? NetworkImage(collaborator.profilePhoto!)
            : null,
        child: collaborator.profilePhoto == null
            ? Text(collaborator.username?[0] ?? '?')
            : null,
      ),
      title: Text(collaborator.username ?? 'Usuário'),
      subtitle: Text(collaborator.email ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(label: Text(collaborator.role)),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _showInstrumentSelectionDialog(context, collaborator);
              } else if (value == 'remove') {
                _showRemoveConfirmationDialog(context, collaborator);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Alterar Função'),
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remover', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInstrumentSelectionDialog(
    BuildContext context,
    Collaborator collaborator,
  ) {
    String selectedInstrument = collaborator.role;
    final instrumentOptions = context
        .read<CollaboratorProvider>()
        .getCommonInstruments();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Função'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: collaborator.profilePhoto != null
                    ? NetworkImage(collaborator.profilePhoto!)
                    : null,
                child: collaborator.profilePhoto == null
                    ? Text(collaborator.username?[0] ?? '?')
                    : null,
              ),
              title: Text(collaborator.username ?? 'Usuário'),
              subtitle: Text(collaborator.email ?? ''),
            ),
            const SizedBox(height: 16),
            const Text('Selecione a função:'),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<String>(
                  initialValue: instrumentOptions.contains(selectedInstrument)
                      ? selectedInstrument
                      : 'Outro',
                  decoration: const InputDecoration(labelText: 'Função'),
                  items: instrumentOptions.map((String instrument) {
                    return DropdownMenuItem<String>(
                      value: instrument,
                      child: Text(instrument),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedInstrument = newValue!;
                    });
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CollaboratorProvider>().updateCollaboratorInstrument(
                playlistId,
                collaborator.userId,
                selectedInstrument,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmationDialog(
    BuildContext context,
    Collaborator collaborator,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Colaborador'),
        content: Text(
          'Tem certeza que deseja remover ${collaborator.username ?? "este colaborador"} da playlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CollaboratorProvider>().removeCollaborator(
                playlistId,
                collaborator.userId,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
