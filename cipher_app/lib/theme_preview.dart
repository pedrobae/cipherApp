// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'utils/app_theme.dart'; // Adjust import if needed

void main() {
  runApp(const ThemePreviewApp());
}

class ThemePreviewApp extends StatefulWidget {
  const ThemePreviewApp({super.key});

  @override
  State<ThemePreviewApp> createState() => _ThemePreviewAppState();
}

class _ThemePreviewAppState extends State<ThemePreviewApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);
  String _selectedTheme = 'green';

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Force rebuild on hot reload to pick up palette changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Theme Preview',
          theme: AppTheme.getTheme(_selectedTheme, false),
          darkTheme: AppTheme.getTheme(_selectedTheme, true),
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: ThemePreviewScreen(
            themeMode: mode,
            selectedTheme: _selectedTheme,
            onThemeChanged: (newMode) => _themeMode.value = newMode,
            onThemeSelected: (theme) =>
                setState(() => _selectedTheme = theme ?? _selectedTheme),
          ),
        );
      },
    );
  }
}

class ThemePreviewScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final String selectedTheme;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<String?> onThemeSelected;

  const ThemePreviewScreen({
    super.key,
    required this.themeMode,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Preview'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (val) =>
                    onThemeChanged(val ? ThemeMode.dark : ThemeMode.light),
              ),
              const Icon(Icons.dark_mode),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<String>(
            value: selectedTheme,
            items: const [
              DropdownMenuItem(value: 'green', child: Text('Green')),
              DropdownMenuItem(value: 'orange', child: Text('Orange')),
              DropdownMenuItem(value: 'gold', child: Text('Gold')),
              DropdownMenuItem(value: 'burgundy', child: Text('Burgundy')),
            ],
            onChanged: onThemeSelected,
          ),
          const SizedBox(height: 16),
          // Primary color demo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Primary (onPrimary text)',
              style: theme.textTheme.titleLarge?.copyWith(color: cs.onPrimary),
            ),
          ),
          const SizedBox(height: 16),
          // PrimaryContainer demo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'PrimaryContainer (onPrimaryContainer text)',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Secondary color demo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Secondary (onSecondary text)',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // SecondaryContainer demo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'SecondaryContainer (onSecondaryContainer text)',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tertiary color demo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tertiary (onTertiary text)',
              style: theme.textTheme.titleLarge?.copyWith(color: cs.onTertiary),
            ),
          ),
          const SizedBox(height: 16),
          // TertiaryContainer demo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TertiaryContainer (onTertiaryContainer text)',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onTertiaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Gradient demo
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary, cs.tertiary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Primary → Secondary → Tertiary Gradient',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Shadow and elevation demos
          _shadowDemo(cs, theme),
          const SizedBox(height: 16),
          // Surface containers
          _surfaceDemo(cs, theme),
          const SizedBox(height: 16),
          // Card demo
          Card(
            color: cs.surface,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Card (onSurface text)',
                style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Error demo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Error (onError text)',
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onError),
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            ],
          ),
          const SizedBox(height: 16),
          // FloatingActionButton and IconButton demo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.message),
                label: const Text('Extended FAB'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Icon buttons and toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
              IconButton.filled(onPressed: () {}, icon: const Icon(Icons.star)),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.bookmark),
              ),
              IconButton.outlined(
                onPressed: () {},
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Checkboxes and radio buttons
          _interactiveDemo(),
          const SizedBox(height: 16),
          // TextField demo
          TextField(
            decoration: InputDecoration(
              labelText: 'TextField',
              hintText: 'Digite algo...',
            ),
          ),
          const SizedBox(height: 16),
          // Accent chips
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: const Text('Secondary'),
                backgroundColor: cs.secondaryContainer,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSecondaryContainer,
                ),
              ),
              Chip(
                label: const Text('Tertiary'),
                backgroundColor: cs.tertiaryContainer,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Text samples for all "on" colors
          _onColorTextSamples(cs),
        ],
      ),
    );
  }

  Widget _surfaceDemo(ColorScheme cs, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _surfaceTile('Surface', cs.surface, cs.onSurface, theme),
        _surfaceTile('SurfaceDim', cs.surfaceDim, cs.onSurface, theme),
        _surfaceTile('SurfaceBright', cs.surfaceBright, cs.onSurface, theme),
        _surfaceTile(
          'SurfaceContainerLowest',
          cs.surfaceContainerLowest,
          cs.onSurface,
          theme,
        ),
        _surfaceTile(
          'SurfaceContainerLow',
          cs.surfaceContainerLow,
          cs.onSurface,
          theme,
        ),
        _surfaceTile(
          'SurfaceContainer',
          cs.surfaceContainer,
          cs.onSurface,
          theme,
        ),
        _surfaceTile(
          'SurfaceContainerHigh',
          cs.surfaceContainerHigh,
          cs.onSurface,
          theme,
        ),
        _surfaceTile(
          'SurfaceContainerHighest',
          cs.surfaceContainerHighest,
          cs.onSurface,
          theme,
        ),
      ],
    );
  }

  Widget _surfaceTile(String label, Color bg, Color fg, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: fg)),
    );
  }

  Widget _onColorTextSamples(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'onPrimary',
          style: TextStyle(color: cs.onPrimary, backgroundColor: cs.primary),
        ),
        Text(
          'onPrimaryContainer',
          style: TextStyle(
            color: cs.onPrimaryContainer,
            backgroundColor: cs.primaryContainer,
          ),
        ),
        Text(
          'onSecondary',
          style: TextStyle(
            color: cs.onSecondary,
            backgroundColor: cs.secondary,
          ),
        ),
        Text(
          'onSecondaryContainer',
          style: TextStyle(
            color: cs.onSecondaryContainer,
            backgroundColor: cs.secondaryContainer,
          ),
        ),
        Text(
          'onTertiary',
          style: TextStyle(color: cs.onTertiary, backgroundColor: cs.tertiary),
        ),
        Text(
          'onTertiaryContainer',
          style: TextStyle(
            color: cs.onTertiaryContainer,
            backgroundColor: cs.tertiaryContainer,
          ),
        ),
        Text(
          'onSurface',
          style: TextStyle(color: cs.onSurface, backgroundColor: cs.surface),
        ),
        Text(
          'onError',
          style: TextStyle(color: cs.onError, backgroundColor: cs.error),
        ),
        Text(
          'onErrorContainer',
          style: TextStyle(
            color: cs.onErrorContainer,
            backgroundColor: cs.errorContainer,
          ),
        ),
        Text(
          'onInverseSurface',
          style: TextStyle(
            color: cs.onInverseSurface,
            backgroundColor: cs.inverseSurface,
          ),
        ),
      ],
    );
  }

  Widget _shadowDemo(ColorScheme cs, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shadows & Elevation',
          style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Elevation 1
            Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 60,
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'Elev 1',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            // Elevation 3
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 60,
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'Elev 3',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            // Elevation 6
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 60,
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'Elev 6',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            // Elevation 12
            Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 60,
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'Elev 12',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _interactiveDemo() {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Elements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Checkboxes
            Row(
              children: [
                Checkbox(value: true, onChanged: (val) {}),
                const Text('Checked'),
                const SizedBox(width: 20),
                Checkbox(value: false, onChanged: (val) {}),
                const Text('Unchecked'),
              ],
            ),
            // Radio buttons
            Row(
              children: [
                Radio<int>(value: 1, groupValue: 1, onChanged: (val) {}),
                const Text('Selected'),
                const SizedBox(width: 20),
                Radio<int>(value: 2, groupValue: 1, onChanged: (val) {}),
                const Text('Unselected'),
              ],
            ),
            // Slider
            Slider(value: 0.6, onChanged: (val) {}),
            // Switch (additional to the one in AppBar)
            Row(
              children: [
                Switch(value: true, onChanged: (val) {}),
                const Text('Enabled'),
                const SizedBox(width: 20),
                Switch(value: false, onChanged: (val) {}),
                const Text('Disabled'),
              ],
            ),
          ],
        );
      },
    );
  }
}
