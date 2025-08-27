import 'package:flutter/material.dart';
import '../models/domain/cipher.dart';
import '../widgets/cipher/cipher_content_section.dart';
import 'edit_cipher.dart';

class CipherViewer extends StatefulWidget {
  final Cipher cipher;

  const CipherViewer({super.key, required this.cipher});

  @override
  State<CipherViewer> createState() => _CipherViewerState();
}

class _CipherViewerState extends State<CipherViewer> {
  CipherMap? _currentVersion;
  
  @override
  void initState() {
    super.initState();
    // Use first version if available, otherwise null (empty state)
    _currentVersion = widget.cipher.maps.isNotEmpty ? widget.cipher.maps.first : null;
  }

  void _selectVersion(CipherMap version) {
    setState(() {
      _currentVersion = version;
    });
  }

  void _addNewVersion() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditCipher(
          cipher: widget.cipher,
          currentVersion: _currentVersion,
          isNewVersion: true,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the cipher data - you might want to reload from provider
        setState(() {
          // Update to use the first version after creation
          if (widget.cipher.maps.isNotEmpty) {
            _currentVersion = widget.cipher.maps.first;
          }
        });
      }
    });
  }

  void _editCurrentVersion() {
    // Only allow editing if there's a current version
    if (_currentVersion == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditCipher(
          cipher: widget.cipher,
          currentVersion: _currentVersion,
          isNewVersion: false,
        ),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          // Refresh data
        });
      }
    });
  }

  void _showVersionSelector() {
    // Only show version selector if there are versions and a current version is selected
    if (widget.cipher.maps.isEmpty || _currentVersion == null) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => _VersionSelectorBottomSheet(
        versions: widget.cipher.maps,
        currentVersion: _currentVersion!,
        onVersionSelected: _selectVersion,
        onNewVersion: _addNewVersion,
      ),
    );
  }

  Widget _buildVersionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.music_note,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            _currentVersion?.versionName ?? 'Versão sem nome',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasVersions = widget.cipher.maps.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.cipher.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'por ${widget.cipher.author}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ]
        ),
        centerTitle: true,
        actions: [
          if (hasVersions) ...[
            IconButton(
              icon: const Icon(Icons.library_music),
              tooltip: 'Versões',
              onPressed: _showVersionSelector,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: _editCurrentVersion,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Criar primeira versão',
              onPressed: _addNewVersion,
            ),
        ],
      ),
      body: hasVersions ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version selector (show for all versions, not just multiple)
            if (hasVersions) ...[
              _buildVersionSelector(),
            ],
            // Cipher content section
            CipherContentSection(
              cipher: widget.cipher,
              currentVersion: _currentVersion,
            ),
          ],
        ),
      ) : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma versão disponível',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta cifra ainda não possui conteúdo.\nCrie a primeira versão para começar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _addNewVersion,
              icon: const Icon(Icons.add),
              label: const Text('Criar primeira versão'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionSelectorBottomSheet extends StatelessWidget {
  final List<CipherMap> versions;
  final CipherMap currentVersion;
  final Function(CipherMap) onVersionSelected;
  final VoidCallback onNewVersion;

  const _VersionSelectorBottomSheet({
    required this.versions,
    required this.currentVersion,
    required this.onVersionSelected,
    required this.onNewVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Versões da Cifra',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onNewVersion();
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (versions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhuma versão encontrada',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              itemCount: versions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final version = versions[index];
                final isSelected = version.id == currentVersion.id;
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.music_note,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    version.versionName ?? 'Versão ${index + 1}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (version.createdAt != null)
                        Text(
                          'Criada em ${_formatDate(version.createdAt!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: isSelected 
                      ? Icon(
                          Icons.radio_button_checked,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.radio_button_unchecked),
                  onTap: () {
                    Navigator.pop(context);
                    onVersionSelected(version);
                  },
                );
              },
            ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
