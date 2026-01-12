import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/library/version_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CipherWithVersionsList extends StatefulWidget {
  final int cipherId;

  const CipherWithVersionsList({super.key, required this.cipherId});

  @override
  State<CipherWithVersionsList> createState() => _CipherWithVersionsListState();
}

class _CipherWithVersionsListState extends State<CipherWithVersionsList> {
  @override
  void initState() {
    super.initState();
    // Load versions when this card becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VersionProvider>().loadVersionsOfCipher(widget.cipherId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VersionProvider>(
      builder: (context, versionProvider, child) {
        final versionIds = versionProvider.getVersionsByCipherId(
          widget.cipherId,
        );

        if (versionIds.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          spacing: 8,
          children: versionIds.map((versionId) {
            return VersionCard(cipherId: widget.cipherId, versionId: versionId);
          }).toList(),
        );
      },
    );
  }
}
