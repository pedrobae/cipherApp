import 'package:cipher_app/providers/version_provider.dart';
import 'package:cipher_app/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../helpers/database.dart';
import '../providers/cipher_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/info_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isResettingDb = false;
  bool _isReloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSectionHeader('Configurações do App', Icons.settings),
            const SizedBox(height: 16),

            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notificações',
              subtitle: 'Configurar alertas e lembretes',
              onTap: () {
                // TODO: Implement notifications settings
                _showComingSoon(context);
              },
            ),

            _buildSettingsTile(
              icon: Icons.palette,
              title: 'Tema',
              subtitle: 'Personalizar aparência do app',
              onTap: () {
                _showThemeDialog(context);
              },
            ),

            const SizedBox(height: 32),

            // Development Tools Section (only in debug mode)
            if (kDebugMode) ...[
              _buildSectionHeader(
                'Ferramentas de Desenvolvimento',
                Icons.build,
              ),
              const SizedBox(height: 16),

              _buildDangerousTile(
                icon: Icons.refresh,
                title: 'Resetar Banco de Dados',
                subtitle: 'Apaga todos os dados e recria com dados iniciais',
                isLoading: _isResettingDb,
                onTap: _isResettingDb
                    ? null
                    : () => _showResetDatabaseDialog(context),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.cached),
                  title: const Text('Recarregar Interface'),
                  subtitle: const Text(
                    'Debug: Força recarga completa de dados e telas',
                  ),
                  trailing: _isReloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onTap: _isReloading ? null : _reloadAllData,
                ),
              ),

              _buildSettingsTile(
                icon: Icons.storage,
                title: 'Informações do Banco',
                subtitle: 'Ver estatísticas e tabelas',
                onTap: () => _showDatabaseInfo(),
              ),

              const SizedBox(height: 32),
            ],

            // About Section
            _buildSectionHeader('Sobre', Icons.info),
            const SizedBox(height: 16),

            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'Versão do App',
              subtitle: 'v1.0.0+1',
              onTap: () {
                _showAboutDialog(context);
              },
            ),

            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Ajuda e Suporte',
              subtitle: 'FAQ e contato',
              onTap: () {
                _showComingSoon(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Wrap(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerousTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.error,
      child: ListTile(
        leading: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: colorScheme.onError),
        title: Text(title, style: TextStyle(color: colorScheme.onError)),
        subtitle: Text(subtitle, style: TextStyle(color: colorScheme.onError)),
        trailing: isLoading
            ? null
            : Icon(Icons.chevron_right, color: colorScheme.onError),
        onTap: onTap,
      ),
    );
  }

  void _showResetDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Resetar Banco de Dados'),
        content: const Text(
          'Esta ação irá:\n\n'
          '• Apagar TODOS os dados do banco\n'
          '• Recriar as tabelas\n'
          '• Inserir dados iniciais (Amazing Grace, How Great Thou Art)\n\n'
          'Esta ação NÃO pode ser desfeita.\n\n'
          'Tem certeza que deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resetDatabase();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Resetar Banco'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetDatabase() async {
    setState(() => _isResettingDb = true);

    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.resetDatabase();

      // Check if widget is still mounted before using context
      if (mounted) await context.read<CipherProvider>().loadCiphers();

      if (mounted) await context.read<PlaylistProvider>().loadLocalPlaylists();

      // Check mounted again after async operations
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Banco de dados resetado com sucesso!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao resetar banco: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResettingDb = false);
      }
    }
  }

  Future<void> _reloadAllData() async {
    setState(() => _isReloading = true);

    try {
      // Clear all provider caches first
      context.read<CipherProvider>().clearCache();
      context.read<PlaylistProvider>().clearCache();
      context.read<InfoProvider>().clearCache();
      context.read<VersionProvider>().clearCache();

      // Force reload all providers from database
      await Future.wait([
        context.read<CipherProvider>().loadCiphers(forceReload: true),
        context.read<PlaylistProvider>().loadLocalPlaylists(),
        context.read<InfoProvider>().loadInfo(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Interface e dados recarregados completamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao recarregar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReloading = false);
      }
    }
  }

  Future<void> _showDatabaseInfo() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Get table counts
      final tables = [
        'cipher',
        'tag',
        'cipher_tags',
        'version',
        'section',
        'user',
        'playlist',
        'playlist_text',
        'app_info',
      ];
      final Map<String, int> tableCounts = {};

      for (final table in tables) {
        try {
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $table',
          );
          tableCounts[table] = result.first['count'] as int;
        } catch (e) {
          tableCounts[table] = -1; // Error indicator
        }
      }

      // Check mounted after async operations
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Informações do Banco de Dados'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registros por tabela:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...tableCounts.entries.map((entry) {
                  final count = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          count == -1 ? 'Erro' : count.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: count == -1
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao acessar banco: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento 🚧')),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) => AlertDialog.adaptive(
          title: const Text('Escolher Tema'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color palette selection
                const Text(
                  'Cor do Tema:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildColorPalette(settingsProvider),
                const SizedBox(height: 24),

                // Theme mode selection
                const Text(
                  'Modo:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildThemeModeSelection(settingsProvider),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Concluído'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette(SettingsProvider settingsProvider) {
    final colors = [
      {
        'name': 'Verde',
        'value': ThemeColor.green,
        'preview': const Color(0xFF145550),
      },
      {
        'name': 'Dourado',
        'value': ThemeColor.gold,
        'preview': const Color(0xFFE6B428),
      },
      {
        'name': 'Laranja',
        'value': ThemeColor.orange,
        'preview': const Color(0xFFE66423),
      },
      {
        'name': 'Vinho',
        'value': ThemeColor.burgundy,
        'preview': const Color(0xFF5A002D),
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((colorData) {
        final isSelected = settingsProvider.themeColor == colorData['value'];

        return GestureDetector(
          onTap: () =>
              settingsProvider.setThemeColor(colorData['value'] as ThemeColor),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorData['preview'] as Color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                if (isSelected)
                  Icon(Icons.check, color: Colors.white, size: 20)
                else
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                Text(
                  colorData['name'] as String,
                  style: isSelected
                      ? const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        )
                      : const TextStyle(color: Colors.white70, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThemeModeSelection(SettingsProvider settingsProvider) {
    final modes = [
      {'name': 'Claro', 'value': ThemeMode.light, 'icon': Icons.light_mode},
      {'name': 'Escuro', 'value': ThemeMode.dark, 'icon': Icons.dark_mode},
      {
        'name': 'Sistema',
        'value': ThemeMode.system,
        'icon': Icons.brightness_auto,
      },
    ];

    return RadioGroup<ThemeMode>(
      onChanged: (value) => settingsProvider.setThemeMode(value!),
      groupValue: settingsProvider.themeMode,
      child: Column(
        children: modes.map((modeData) {
          final isSelected = settingsProvider.themeMode == modeData['value'];

          return RadioListTile<ThemeMode>(
            value: modeData['value'] as ThemeMode,
            title: Row(
              children: [
                Icon(
                  modeData['icon'] as IconData,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Text(modeData['name'] as String),
              ],
            ),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'App de Cifras',
      applicationVersion: '1.0.0+1',
      applicationIcon: const Icon(Icons.music_note, size: 48),
      children: [
        const Text('App para gerenciamento de cifras musicais.'),
        const SizedBox(height: 16),
        const Text('Desenvolvido com Flutter 💙'),
      ],
    );
  }
}
