import 'package:cordis/l10n/app_localizations.dart';

import 'package:cordis/widgets/icon_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:cordis/providers/selection_provider.dart';
import 'package:cordis/providers/user_provider.dart';
import 'package:cordis/widgets/ciphers/library/cipher_scroll_view.dart';

class CipherLibraryScreen extends StatefulWidget {
  final bool selectionMode;
  final int? playlistId;

  const CipherLibraryScreen({
    super.key,
    this.selectionMode = false,
    this.playlistId,
  });

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

    return Consumer4<
      CipherProvider,
      UserProvider,
      MyAuthProvider,
      SelectionProvider
    >(
      builder:
          (
            context,
            cipherProvider,
            userProvider,
            authProvider,
            selectionProvider,
            child,
          ) {
            return Scaffold(
              appBar: widget.selectionMode
                  ? AppBar(
                      title: Text(AppLocalizations.of(context)!.addToPlaylist),
                      backgroundColor: colorScheme.surface,
                    )
                  : null,
              body: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Column(
                  spacing: 8,
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
                        // TODO: Implement search functionality
                      },
                    ),
                    // Buttons Row (e.g., Filters, Sort, Create New Cipher)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // CREATE NEW CIPHER
                        IconTextButton(
                          onTap: () {
                            //TODO: Implement create new cipher functionality
                          },
                          text: AppLocalizations.of(context)!.create,
                          icon: Icon(Icons.add, color: colorScheme.onSurface),
                        ),
                        // SORT BUTTON
                        IconTextButton(
                          onTap: () {
                            // TODO: Implement sort functionality
                          },
                          text: AppLocalizations.of(context)!.sort,
                          icon: Icon(Icons.sort, color: colorScheme.onSurface),
                        ),
                        // FILTER BUTTON
                        IconTextButton(
                          onTap: () {
                            // TODO: Implement filter functionality
                          },
                          text: AppLocalizations.of(context)!.filter,
                          icon: Icon(
                            Icons.filter_list,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: CipherScrollView(playlistId: widget.playlistId),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}
