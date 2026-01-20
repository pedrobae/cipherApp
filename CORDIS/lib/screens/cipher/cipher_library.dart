import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/version_provider.dart';
import 'package:cordis/widgets/ciphers/library/create_cipher_sheet.dart';
import 'package:cordis/widgets/filled_text_button.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/widgets/ciphers/library/cipher_scroll_view.dart';

class CipherLibraryScreen extends StatefulWidget {
  const CipherLibraryScreen({super.key});

  @override
  State<CipherLibraryScreen> createState() => _CipherLibraryScreenState();
}

class _CipherLibraryScreenState extends State<CipherLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-load data with post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cipherProvider = context.read<CipherProvider>();
      cipherProvider.loadLocalCiphers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer5<
      CipherProvider,
      UserProvider,
      MyAuthProvider,
      SelectionProvider,
      VersionProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            userProvider,
            authProvider,
            selectionProvider,
            versionProvider,
            child,
          ) {
            return Scaffold(
              appBar: selectionProvider.isSelectionMode
                  ? AppBar(
                      leading: const BackButton(),
                      title: Text(
                        AppLocalizations.of(context)!.addToPlaylist,
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
              body: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchCiphers,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(
                            color: colorScheme.surfaceContainer,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        suffixIcon: const Icon(Icons.search),
                        fillColor: colorScheme.surfaceContainerHighest,
                        visualDensity: VisualDensity.compact,
                      ),
                      onChanged: (value) {
                        cipherProvider.searchLocalCiphers(value);
                        versionProvider.searchCachedCloudVersions(value);
                      },
                    ),
                    Expanded(child: CipherScrollView()),

                    // CREATE CIPHER BUTTON
                    selectionProvider.isSelectionMode
                        ? const SizedBox.shrink()
                        : FilledTextButton(
                            onPressed: () {
                              _showCreateCipherSheet();
                            },
                            text: AppLocalizations.of(context)!.create,
                            isDarkButton: true,
                          ),
                  ],
                ),
              ),
            );
          },
    );
  }

  void _showCreateCipherSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CreateCipherSheet();
      },
    );
  }
}
