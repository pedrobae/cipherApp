import 'dart:math' as math;
import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/screens/settings_screen.dart';
import 'package:cordis/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/my_auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<NavigationProvider, MyAuthProvider>(
      builder: (context, navigationProvider, authProvider, child) {
        return Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.horizontal(
              right: Radius.circular(0),
            ),
          ),
          width: math.min(
            math.max(MediaQuery.of(context).size.width * (3 / 4), 224),
            320,
          ),
          backgroundColor: colorScheme.surface,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UserCard(),
                      Divider(
                        color: colorScheme.surfaceContainerLowest,
                        height: 1,
                      ),
                      ...navigationProvider
                          .getNavigationItems(context, iconSize: 24)
                          .map(
                            (navItem) => Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: colorScheme.surfaceContainerLowest,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                leading: navItem.icon,
                                title: Text(navItem.title),
                                selected:
                                    navigationProvider.currentRoute ==
                                    navItem.route,
                                onTap: () {
                                  navigationProvider.navigateToRoute(
                                    navItem.route,
                                  );
                                  Navigator.of(context).pop();
                                },
                                trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.surfaceContainerLowest,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(AppLocalizations.of(context)!.about),
                          onTap: () {
                            // TODO: Show about
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
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.surfaceContainerLowest,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text(AppLocalizations.of(context)!.settings),
                          onTap: () {
                            Navigator.of(context).pop();
                            navigationProvider.push(const SettingsScreen());
                          },
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // LOGOUT BUTTON
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).pop();
                      authProvider.logOut();
                    },
                    child: Row(
                      spacing: 16,
                      children: [
                        Icon(Icons.logout),
                        Text(
                          AppLocalizations.of(context)!.logOut,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
