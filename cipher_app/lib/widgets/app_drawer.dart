import 'dart:math' as math;
import 'package:cipher_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/navigation_provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<NavigationProvider, AuthProvider>(
      builder: (context, navigationProvider, authProvider, child) {
        return Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.horizontal(
              right: Radius.circular(50),
            ),
          ),
          width: math.min(
            math.max(MediaQuery.of(context).size.width * (2 / 3), 224),
            320,
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.appName,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
