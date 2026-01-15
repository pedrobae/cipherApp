import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:cordis/models/domain/cipher/cipher.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/providers/layout_settings_provider.dart';
import 'package:cordis/widgets/ciphers/viewer/section_card.dart';
import 'package:cordis/utils/section_helper.dart';

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
  final Map<int, GlobalKey> _sectionKeys = {};
  bool _keysNotified = false;

  @override
  void initState() {
    super.initState();
    // Pre-load cipher data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cipherProvider = context.read<CipherProvider>();

      // Ensure all ciphers are loaded (loads all ciphers if not already loaded)
      cipherProvider.loadLocalCiphers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VersionProvider>(
      builder: (context, versionProvider, child) {
        final version = versionProvider.getLocalVersionById(widget.versionId)!;

        return Consumer<CipherProvider>(
          builder: (context, cipherProvider, child) {
            final cipher = cipherProvider.getCipherById(version.cipherId)!;
            return Consumer<LayoutSettingsProvider>(
              builder: (context, layoutProvider, child) {
                return _buildCipherContent(cipher, version, layoutProvider);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCipherContent(
    Cipher cipher,
    Version version,
    LayoutSettingsProvider layoutProvider,
  ) {
    // Filter song structure based on display settings
    final List<String> filteredStructure = version.songStructure
        .map((s) => s.trim())
        .where(
          (sectionCode) =>
              sectionCode.isNotEmpty &&
              (layoutProvider.showAnnotations || !isAnnotation(sectionCode)) &&
              (layoutProvider.showTransitions || !isTransition(sectionCode)),
        )
        .toList();

    // Notify parent of section keys for navigation
    if (!_keysNotified && filteredStructure.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSectionKeysCreated?.call(widget.versionId, _sectionKeys);
        _keysNotified = true;
      });
    }

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCipherHeader(cipher, version, layoutProvider),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
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
                    final section = version.sections?[sectionCode];
                    if (section == null) return const SizedBox.shrink();

                    return CipherSectionCard(
                      key: _sectionKeys[sectionIndex],
                      sectionCode: section.contentCode,
                      sectionType: section.contentType,
                      sectionText: section.contentText,
                      sectionColor: section.contentColor,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCipherHeader(
    Cipher cipher,
    Version version,
    LayoutSettingsProvider layoutProvider,
  ) {
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
                cipher.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: layoutProvider.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: layoutProvider.fontSize * .8,
                ),
              ),
            ),
            if (cipher.author.isNotEmpty) ...[
              Text(
                'por ${cipher.author}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: layoutProvider.fontFamily,
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
            if (version.versionName.isNotEmpty == true) ...[
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
                  version.versionName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],

            if (cipher.musicKey.isNotEmpty)
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
                      cipher.musicKey,
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
