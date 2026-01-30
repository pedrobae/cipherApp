import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/screens/cipher/edit_cipher.dart';
import 'package:cordis/screens/cipher/import/import_pdf.dart';
import 'package:cordis/screens/cipher/import/import_text.dart';
import 'package:cordis/widgets/filled_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCipherSheet extends StatelessWidget {
  final bool secret;
  const CreateCipherSheet({super.key, this.secret = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Icon Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          // CREATE MANUALLY
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LABEL
              Text(
                AppLocalizations.of(context)!.create,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              FilledTextButton(
                text: AppLocalizations.of(context)!.createManually,
                isDark: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<NavigationProvider>().push(
                    EditCipherScreen(
                      versionID: -1,
                      cipherID: -1,
                      versionType: VersionType.brandNew,
                    ),
                    showAppBar: false,
                    showDrawerIcon: false,
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16),

          // IMPORT
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LABEL
              Text(
                AppLocalizations.of(context)!.import,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              if (secret)
                FilledTextButton(
                  text: AppLocalizations.of(context)!.importFromText,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<NavigationProvider>().push(
                      const ImportTextScreen(),
                      showAppBar: false,
                      showDrawerIcon: false,
                      showBottomNavBar: false,
                    );
                  },
                ),
              FilledTextButton(
                text: AppLocalizations.of(context)!.importFromPDF,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<NavigationProvider>().push(
                    const ImportPdfScreen(),
                    showAppBar: false,
                    showDrawerIcon: false,
                    showBottomNavBar: false,
                  );
                },
              ),
              if (secret)
                FilledTextButton(
                  text: AppLocalizations.of(context)!.importFromImage,
                  onPressed: () {
                    // for now show coming soon snackbar from the settings screen
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.amberAccent,
                        content: Text(
                          'Funcionalidade em desenvolvimento,',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
