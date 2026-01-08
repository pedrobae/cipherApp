import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CipherFilters extends StatelessWidget {
  const CipherFilters({
    super.key,
    required this.settings,
    required this.isPresenter,
  });

  final LayoutSettingsProvider settings;
  final bool isPresenter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 2,
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
          if (!isPresenter) ...[
            FilterChip(
              label: Text('Notas'),
              showCheckmark: false,
              selected: settings.showAnnotations,
              onSelected: (_) => settings.toggleNotes(),
            ),
            FilterChip(
              label: Text('Transições'),
              showCheckmark: false,
              selected: settings.showTransitions,
              onSelected: (_) => settings.toggleTransitions(),
            ),
          ] else ...[
            FilterChip(
              label: Text('Seções de Texto'),
              showCheckmark: false,
              selected: settings.showTextSections,
              onSelected: (_) => settings.toggleTextSections(),
            ),
          ],
        ],
      ),
    );
  }
}

class ColumnCount extends StatelessWidget {
  const ColumnCount({super.key, required this.settings});

  final LayoutSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class ChordColors extends StatelessWidget {
  const ChordColors({super.key, required this.settings});

  final LayoutSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        onPressed: () {
                          settings.setChordColor(tempColor);
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
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
    );
  }
}

class FontSettings extends StatelessWidget {
  const FontSettings({super.key, required this.settings});

  final LayoutSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: settings.fontFamily,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'OpenSans', child: Text('OpenSans')),
                DropdownMenuItem(value: 'Asimovian', child: Text('Asimovian')),
                DropdownMenuItem(value: 'Atkinson', child: Text('Atkinson')),
                DropdownMenuItem(value: 'Caveat', child: Text('Caveat')),
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
    );
  }
}
