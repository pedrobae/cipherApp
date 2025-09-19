import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/providers/cipher_provider.dart';
import 'package:cipher_app/providers/layout_settings_provider.dart';
import 'package:cipher_app/widgets/cipher/viewer/section_card.dart';
import 'package:cipher_app/utils/section.dart';

class PresentationCipherSection extends StatefulWidget {
  final int versionId;
  final Function(int versionId, Map<int, GlobalKey> sectionKeys)?
  onSectionKeysCreated;

  const PresentationCipherSection({
    super.key,
    required this.versionId,
    this.onSectionKeysCreated,
  });

  @override
  State<PresentationCipherSection> createState() =>
      _PresentationCipherSectionState();
}

class _PresentationCipherSectionState extends State<PresentationCipherSection> {
  Cipher? _cipher;
  bool _isLoading = true;
  final Map<int, GlobalKey> _sectionKeys = {};
  bool _keysNotified = false;

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
          child: Center(child: CircularProgressIndicator()),
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
              Icon(Icons.error, color: Colors.red.shade700, size: 32),
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
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<LayoutSettingsProvider>(
      builder: (context, layoutProvider, child) {
        final currentVersion = _cipher!.versions.first;

        final filteredStructure = currentVersion.songStructure
            .split(',')
            .map((s) => s.trim())
            .where(
              (sectionCode) =>
                  sectionCode.isNotEmpty &&
                  (layoutProvider.showAnnotations ||
                      !isAnnotation(sectionCode)) &&
                  (layoutProvider.showTransitions ||
                      !isTransition(sectionCode)),
            )
            .toList();

        if (!_keysNotified && filteredStructure.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onSectionKeysCreated?.call(widget.versionId, _sectionKeys);
            _keysNotified = true;
          });
        }

        return Card(
          surfaceTintColor: Theme.of(context).primaryColor,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildCipherHeader(layoutProvider),
                Divider(thickness: 1.5),
                MasonryGridView.builder(
                  padding: EdgeInsets.only(top: 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: layoutProvider.columnCount,
                  ),
                  itemCount: filteredStructure.length,
                  itemBuilder: (context, sectionIndex) {
                    _sectionKeys.putIfAbsent(sectionIndex, () => GlobalKey());

                    final sectionCode = filteredStructure[sectionIndex];
                    final section = currentVersion.sections?[sectionCode];
                    if (section == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CipherSectionCard(
                        key: _sectionKeys[sectionIndex],
                        sectionType: section.contentType,
                        sectionCode: sectionCode,
                        sectionText: section.contentText,
                        sectionColor: section.contentColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCipherHeader(LayoutSettingsProvider layoutProvider) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                _cipher!.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: layoutProvider.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: layoutProvider.fontSize * .8,
                ),
              ),
            ),
            if (_cipher!.author.isNotEmpty) ...[
              Text(
                'por ${_cipher!.author}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: layoutProvider.fontFamily,
                  fontStyle: FontStyle.italic,
                  fontSize: layoutProvider.fontSize * .7,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
        Row(
          spacing: 6,
          children: [
            if (_cipher!.versions.first.versionName?.isNotEmpty == true) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: .3),
                  ),
                ),
                child: Text(
                  _cipher!.versions.first.versionName!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],

            if (_cipher!.musicKey.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      _cipher!.musicKey,
                      style: const TextStyle(
                        fontSize: 11,
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
