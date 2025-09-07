import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Transposer extends StatelessWidget {
  const Transposer({super.key});

  @override
  Widget build(BuildContext context){
    final settings = Provider.of<LayoutSettingsProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          tooltip: 'Diminuir tom',
          onPressed: () => settings.transposeDown(),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Selecione um tom'),
                  content: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: settings.keys.map((key) {
                      return ElevatedButton(
                        onPressed: () {
                          settings.selectKey(key);
                          Navigator.of(context).pop();
                        },
                        child: Text(key),
                      );
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            settings.currentKey,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Aumentar tom',
          onPressed: () => settings.transposeUp(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Voltar ao tom original',
          onPressed: () => settings.resetToOriginalKey(),
        ),
      ],
    );
  }
}
