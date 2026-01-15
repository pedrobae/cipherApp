import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/cipher_provider.dart';
import 'package:cordis/providers/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer3<AuthProvider, CipherProvider, PlaylistProvider>(
        builder: (context, authProvider, cipherProvider, playlistProvider, child) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final locale = Localizations.localeOf(context);

          if (authProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.loading),
                ],
              ),
            );
          }

          if (authProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.errorPrefix}${authProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => authProvider.signInAnonymously(),
                    child: Text(AppLocalizations.of(context)!.tryAgain),
                  ),
                ],
              ),
            );
          }

          // HOME SCREEN
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current date
              Text(
                DateFormat(
                  'EEEE, MMM d',
                  locale.languageCode,
                ).format(DateTime.now()),
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),

              // Welcome message
              Text(
                authProvider.userName != null
                    ? AppLocalizations.of(
                        context,
                      )!.welcome(authProvider.userName as Object)
                    : AppLocalizations.of(context)!.anonymousWelcome,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
