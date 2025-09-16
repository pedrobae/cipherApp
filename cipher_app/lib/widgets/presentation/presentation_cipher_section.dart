import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cipher_provider.dart';
import '../../providers/layout_settings_provider.dart';
import '../../models/domain/cipher/cipher.dart';
import '../cipher/viewer/section_card.dart';
import '../../utils/section.dart';

class PresentationCipherSection extends StatefulWidget {
  final int versionId;

  const PresentationCipherSection({
    super.key,
    required this.versionId,
  });

  @override
  State<PresentationCipherSection> createState() => _PresentationCipherSectionState();
}

class _PresentationCipherSectionState extends State<PresentationCipherSection> {
  Cipher? _cipher;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCipher();
  }

  Future<void> _loadCipher() async {
    final cipherProvider = context.read<CipherProvider>();
    final cipher = await cipherProvider.getCipherVersionById(widget.versionId);

    if (mounted) {
      setState(() {
        _cipher = cipher;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_cipher == null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.error,
                color: Colors.red.shade700,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Erro ao carregar cifra',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ID: ${widget.versionId}',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<LayoutSettingsProvider>(
      builder: (context, layoutProvider, child) {
        final currentVersion = _cipher!.maps.first;
        
        // Get the filtered structure based on layout settings
        final filteredStructure = currentVersion.songStructure
            .split(',')
            .map((s) => s.trim())
            .where((sectionCode) =>
                sectionCode.isNotEmpty &&
                (layoutProvider.showAnnotations || !isAnnotation(sectionCode)) &&
                (layoutProvider.showTransitions || !isTransition(sectionCode)))
            .toList();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cipher title and author
                _buildCipherHeader(),
                
                const SizedBox(height: 20),
                
                // All sections in a single column (no grid for presentation)
                ...filteredStructure.map((sectionCode) {
                  final trimmedCode = sectionCode.trim();
                  final section = currentVersion.sections?[trimmedCode];
                  if (section == null) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CipherSectionCard(
                      sectionType: section.contentType,
                      sectionCode: trimmedCode,
                      sectionText: section.contentText,
                      sectionColor: section.contentColor,
                    ),
                  );
                })
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCipherHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          _cipher!.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Author
        if (_cipher!.author.isNotEmpty)
          Text(
            'por ${_cipher!.author}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        
        // Version and key info
        const SizedBox(height: 8),
        Row(
          children: [
            if (_cipher!.maps.first.versionName?.isNotEmpty == true) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: .3),
                  ),
                ),
                child: Text(
                  _cipher!.maps.first.versionName!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            
            if (_cipher!.musicKey.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _cipher!.musicKey,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}