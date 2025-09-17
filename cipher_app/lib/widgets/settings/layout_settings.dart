import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/widgets/settings/section_modules.dart';
import 'package:cipher_app/widgets/cipher/transposer.dart';

class LayoutSettings extends StatelessWidget {
  final ScrollController? scrollController;
  final bool includeTransposer;
  final bool includeFilters;

  const LayoutSettings({
    super.key,
    this.scrollController,
    this.includeTransposer = false,
    this.includeFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LayoutSettingsProvider>(
      builder: (context, settings, child) {
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações de Layout',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: Theme.of(context).dividerTheme.thickness,
                    ),
                    if (includeFilters) ...[
                      Text('Filtros', style: Theme.of(context).textTheme.titleMedium),
                      CipherFilters(settings: settings),
                      Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: Theme.of(context).dividerTheme.thickness,
                      ),
                    ],
                    Text('Fonte', style: Theme.of(context).textTheme.titleMedium),
                    FontSettings(settings: settings),
                    Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: Theme.of(context).dividerTheme.thickness,
                    ),
                    Text(
                      'Cor dos acordes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ChordColors(settings: settings),
                    Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: Theme.of(context).dividerTheme.thickness,
                    ),
                    Text('Layout', style: Theme.of(context).textTheme.titleMedium),
                    ColumnCount(settings: settings),
                    if (includeTransposer) ...[
                      Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: Theme.of(context).dividerTheme.thickness,
                      ),
                      Text('Transpose', style: Theme.of(context).textTheme.titleMedium),
                      Transposer(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}