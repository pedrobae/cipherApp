import 'package:flutter/material.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:provider/provider.dart';


// Shows and allows for change of:
//  Font Size and Family for Content and Chords
//  Number of Columns
//  Filters (Chords, Lyrics, Annotations, INTROS OUTROS BRIDGES)
class LayoutSettings extends StatelessWidget {
  const LayoutSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<LayoutSettingsProvider>(context);
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Configurações de Visualização', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Fechar',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Filtros
              Text('Filtros', style: Theme.of(context).textTheme.titleMedium),
              SwitchListTile(
                title: const Text('Mostrar acordes'),
                value: settings.showChords,
                onChanged: (value) => settings.setShowChords(value),
              ),
              SwitchListTile(
                title: const Text('Mostrar letras'),
                value: settings.showLyrics,
                onChanged: (value) => settings.setShowLyrics(value),
              ),
              SwitchListTile(
                title: const Text('Mostrar notas'),
                value: settings.showNotes,
                onChanged: (value) => settings.setShowNotes(value),
              ),
              SwitchListTile(
                title: const Text('Mostrar transições'),
                value: settings.showTransitions,
                onChanged: (value) => settings.setShowTransitions(value),
              ),
              const Divider(),
              // Fonte
              Text('Fonte', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: const Text('Família da fonte'),
                trailing: DropdownButton<String>(
                  value: settings.fontFamily,
                  items: const [
                    DropdownMenuItem(value: 'OpenSans', child: Text('OpenSans')),
                    DropdownMenuItem(value: 'Asimovian', child: Text('Asimovian')),
                  ],
                  onChanged: (value) {
                    if (value != null) settings.setFontFamily(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Tamanho da fonte'),
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    min: 10,
                    max: 32,
                    divisions: 11,
                    value: settings.fontSize.toDouble(),
                    label: settings.fontSize.toString(),
                    onChanged: (value) => settings.setFontSize(value.round()),
                  ),
                ),
              ),
              const Divider(),
              // Cor dos acordes
              Text('Cor dos acordes', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: const Text('Escolher cor'),
                trailing: GestureDetector(
                  onTap: () {
                    // Implementar seletor de cor customizado
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: settings.chordColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const Divider(),
              // Layout
              Text('Layout', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: const Text('Número de colunas'),
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    min: 1,
                    max: 4,
                    divisions: 3,
                    value: settings.columnCount.toDouble(),
                    label: settings.columnCount.toString(),
                    onChanged: (value) => settings.setColumnCount(value.round()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}