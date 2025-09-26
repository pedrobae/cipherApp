import 'package:flutter/material.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 72, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Bem-vindo ao App de Cifras',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text(
                'Entrar Anonimamente',
                style: theme.textTheme.labelSmall!.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              onPressed: () => authProvider.signInAnonymously(),
            ),
          ],
        ),
      ),
    );
  }
}
