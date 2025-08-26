import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../helpers/database_helper.dart';
import '../providers/cipher_provider.dart';
import '../providers/playlist_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isResettingDb = false;

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
                // TODO: Implement theme settings
                _showComingSoon(context);
              },
            ),
            
            const SizedBox(height: 32),
            
            // Development Tools Section (only in debug mode)
            if (kDebugMode) ...[
              _buildSectionHeader('Ferramentas de Desenvolvimento', Icons.build),
              const SizedBox(height: 16),
              
              _buildDangerousTile(
                icon: Icons.refresh,
                title: 'Resetar Banco de Dados',
                subtitle: 'Apaga todos os dados e recria com dados iniciais',
                isLoading: _isResettingDb,
                onTap: _isResettingDb ? null : () => _showResetDatabaseDialog(context),
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
    return Row(
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
      color: colorScheme.errorContainer.withValues(alpha: 0.9),
      child: ListTile(
        leading: isLoading 
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: colorScheme.error),
        title: Text(title, style: TextStyle(color: colorScheme.error)),
        subtitle: Text(subtitle),
        trailing: isLoading ? null : Icon(Icons.chevron_right, color: colorScheme.error),
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
          'Tem certeza que deseja continuar?'
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
      if (!mounted) return;
      
      // Refresh the cipher provider data
      await context.read<CipherProvider>().loadCiphers();
      
      // Refresh the playlist provider data
      await context.read<PlaylistProvider>().loadPlaylists();
      
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

  Future<void> _showDatabaseInfo() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      
      // Get table counts
      final tables = ['cipher', 'tag', 'cipher_tags', 'cipher_map', 'map_content', 'user', 'playlist', 'playlist_cipher_map', 'user_playlist', 'app_info'];
      final Map<String, int> tableCounts = {};
      
      for (final table in tables) {
        try {
          final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
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
                const Text('Registros por tabela:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            color: count == -1 ? Theme.of(context).colorScheme.error : null,
                          ),
                        ),
                      ],
                    ),
                  );
                })
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
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento 🚧'),
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
