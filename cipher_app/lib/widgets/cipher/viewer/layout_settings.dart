import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/widgets/settings/section_modules.dart';
import 'package:cipher_app/widgets/cipher/transposer.dart';

// Shows and allows for change of:
//  Font Size and Family for Content and Chords
//  Number of Columns
//  Filters (Chords, Lyrics, Annotations, INTROS OUTROS BRIDGES)
class LayoutSettings extends StatelessWidget {
  final String originalKey;
  const LayoutSettings({super.key, required this.originalKey});

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
              Divider(
                color: Theme.of(context).dividerColor,
                thickness: Theme.of(context).dividerTheme.thickness,
              ),
              // Filters
              Text('Filtros', style: Theme.of(context).textTheme.titleMedium),
              CipherFilters(settings: settings),
              Divider(
                color: Theme.of(context).dividerColor,
                thickness: Theme.of(context).dividerTheme.thickness,
              ),
              // Font
              Text('Fonte', style: Theme.of(context).textTheme.titleMedium),
              FontSettings(settings: settings),
              Divider(
                color: Theme.of(context).dividerColor,
                thickness: Theme.of(context).dividerTheme.thickness,
              ),
              // Chord Color
              Text(
                'Cor dos acordes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ChordColors(settings: settings),
              Divider(
                color: Theme.of(context).dividerColor,
                thickness: Theme.of(context).dividerTheme.thickness,
              ),
              // Layout
              Text('Layout', style: Theme.of(context).textTheme.titleMedium),
              ColumnCount(settings: settings),
              Divider(
                color: Theme.of(context).dividerColor,
                thickness: Theme.of(context).dividerTheme.thickness,
              ),
              // Transposer
              Text('Transpose', style: Theme.of(context).textTheme.titleMedium),
              Transposer()
            ],
          ),
        ),
      ),
    );
  }
}