import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Configurações de Visualização',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
              Divider(color: Theme.of(context).dividerColor),
              // Filters
              Text('Filtros', style: Theme.of(context).textTheme.titleMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  FilterChip(
                    label: Text('Acordes'),
                    showCheckmark: false,
                    selected: settings.showChords,
                    onSelected: (_) => settings.toggleChords(),
                  ),
                  FilterChip(
                    label: Text('Letras'),
                    showCheckmark: false,
                    selected: settings.showLyrics,
                    onSelected: (_) => settings.toggleLyrics(),
                  ),
                  FilterChip(
                    label: Text('Notas'),
                    showCheckmark: false,
                    selected: settings.showNotes,
                    onSelected: (_) => settings.toggleNotes(),
                  ),
                  FilterChip(
                    label: Text('Transições'),
                    showCheckmark: false,
                    selected: settings.showTransitions,
                    onSelected: (_) => settings.toggleTransitions(),
                  ),
                ],
              ),
              Divider(color: Theme.of(context).dividerColor),
              // Font
              Text('Fonte', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: settings.fontFamily,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'OpenSans',
                            child: Text('OpenSans'),
                          ),
                          DropdownMenuItem(
                            value: 'Asimovian',
                            child: Text('Asimovian'),
                          ),
                          DropdownMenuItem(
                            value: 'Atkinson',
                            child: Text('Atkinson'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) settings.setFontFamily(v);
                        },
                        underline: Container(),
                      ),
                    ),
                    const SizedBox(width: 32),
                    DropdownButton<double>(
                      value: settings.fontSize,
                      items: List.generate(12, (i) {
                        final double size = 12 + i * 2;
                        return DropdownMenuItem(
                          value: size,
                          child: Text(size.toString()),
                        );
                      }),
                      onChanged: (v) {
                        if (v != null) settings.setFontSize(v);
                      },
                      underline: Container(),
                    ),
                  ],
                ),
              ),
              Divider(color: Theme.of(context).dividerColor),
              // Chord Color
              Text(
                'Cor dos acordes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Text('Escolher cor')),
                    GestureDetector(
                      onTap: () {
                        Color tempColor = settings.chordColor;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Selecione a cor dos acordes'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: settings.chordColor,
                                  onColorChanged: (color) {
                                    settings.setChordColor(color);
                                  },
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    settings.setChordColor(tempColor);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
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
                  ],
                ),
              ),
              Divider(color: Theme.of(context).dividerColor),
              // Layout
              Text('Layout', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Text('Número de colunas:')),
                    for (int i = 1; i <= 3; i++)
                      IconButton(
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            i,
                            (j) => const Icon(Icons.view_column, size: 18),
                          ),
                        ),
                        color: settings.columnCount == i
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).iconTheme.color,
                        tooltip: '$i coluna${i > 1 ? 's' : ''}',
                        onPressed: () => settings.setColumnCount(i),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
