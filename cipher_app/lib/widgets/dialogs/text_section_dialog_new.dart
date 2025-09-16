import 'package:cipher_app/providers/text_section_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Dialog for text section editing and deletion
class TextSectionDialog extends StatefulWidget {
  final int textSectionId;
  final int playlistId;

  const TextSectionDialog({
    super.key,
    required this.textSectionId,
    required this.playlistId,
  });

  /// Shows the text section dialog
  static void show(
    BuildContext context, {
    required int textSectionId,
    required int playlistId,
  }) {
    showDialog(
      context: context,
      builder: (context) => TextSectionDialog(
        textSectionId: textSectionId,
        playlistId: playlistId,
      ),
    );
  }

  @override
  State<TextSectionDialog> createState() => _TextSectionDialogState();
}

class _TextSectionDialogState extends State<TextSectionDialog> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    
    final textSection = context.read<TextSectionProvider>()
        .textSections[widget.textSectionId];
    
    titleController = TextEditingController(text: textSection?.title ?? '');
    contentController = TextEditingController(text: textSection?.contentText ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and delete button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Editar Seção de Texto',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: _showDeleteConfirmation,
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Excluir seção',
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Content field with more space
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Saves changes to the text section
  void _saveChanges() async {
    final newTitle = titleController.text.trim();
    final newContent = contentController.text.trim();
    
    if (newTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O título não pode estar vazio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await context.read<TextSectionProvider>().updateTextSection(
        widget.textSectionId,
        newTitle,
        newContent,
        null, // Keep current position
      );
      
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seção atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar seção: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows delete confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Seção'),
        content: const Text(
          'Tem certeza que deseja excluir esta seção de texto? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _confirmDelete,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Confirms and executes the delete operation
  void _confirmDelete() async {
    Navigator.pop(context); // Close confirmation dialog
    
    try {
      await context.read<TextSectionProvider>().deleteTextSection(widget.textSectionId);
      
      if (mounted) {
        Navigator.pop(context); // Close main dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seção excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir seção: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
