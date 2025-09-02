import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain/cipher.dart';
import '../providers/cipher_provider.dart';
import '../widgets/cipher/viewer/content_section.dart';
import '../widgets/cipher/viewer/version_header.dart';
import '../widgets/cipher/viewer/layout_settings.dart';
import '../widgets/cipher/version_selector.dart';
import 'cipher_editor.dart';

class CipherViewer extends StatefulWidget {
  final Cipher cipher;
  
  const CipherViewer({super.key, required this.cipher});

  @override
  State<CipherViewer> createState() => _CipherViewerState();
}

class _CipherViewerState extends State<CipherViewer> {
  CipherMap? _currentVersion;
  int? _columnCount;
  bool _hasShownVersionSelector = false;

  @override
  void initState() {
    super.initState();
    _currentVersion = widget.cipher.maps.isNotEmpty
        ? widget.cipher.maps.first
        : null;
    _columnCount = 1;

    if (widget.cipher.maps.isNotEmpty && !_hasShownVersionSelector) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVersionSelector();
      _hasShownVersionSelector = true;
    });
  }
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
    );
  }

  void _editCurrentVersion() {
    // Only allow editing if there's a current version
    if (_currentVersion == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCipher(
          cipher: widget.cipher,
          currentVersion: _currentVersion,
          isNewVersion: false,
        ),
      ),
    );
  }

  void _showVersionSelector() {
    // Only show version selector if there are versions and a current version is selected
    if (widget.cipher.maps.isEmpty || _currentVersion == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => VersionSelectorBottomSheet(
        versions: widget.cipher.maps,
        currentVersion: _currentVersion!,
        onVersionSelected: _selectVersion,
        onNewVersion: _addNewVersion,
      ),
    );
  }

  void _showLayoutSettings() {
  }

  @override
  Widget build(BuildContext context) {
    final cipherProvider = context.watch<CipherProvider>();
    final hasVersions = widget.cipher.maps.isNotEmpty;

    final currentCipher = cipherProvider.ciphers.firstWhere(
      (c) => c.id == widget.cipher.id,
      orElse: () => widget.cipher, // Fallback to original if not found
    );
    // Always refresh _currentVersion from provider by id
    if (_currentVersion != null && hasVersions) {
      final updatedVersion = currentCipher.maps.firstWhere(
        (m) => m.id == _currentVersion!.id,
        orElse: () => currentCipher.maps.first,
      );
      _currentVersion = updatedVersion;
    } else if (hasVersions) {
      _currentVersion = currentCipher.maps.first;
    } else {
      _currentVersion = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              currentCipher.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'por ${currentCipher.author}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
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
      body: hasVersions
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(0),
                  child: CipherVersionHeader(currentVersion: _currentVersion!),
                ),
                // Cipher content section
                Expanded(
                  child: CipherContentSection(
                    cipher: currentCipher,
                    currentVersion: _currentVersion!,
                    columnCount: _columnCount!,
                  ),
                ),
              ],
            )
          : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note_outlined, size: 80, color: Colors.grey[400]),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}