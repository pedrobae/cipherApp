import 'package:cipher_app/providers/navigation_provider.dart';
import 'package:cipher_app/utils/design_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          final items = navigationProvider.getAdminItems(
            iconColor: colorScheme.onPrimaryContainer,
            iconSize: 72,
          );
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: .9),
                  colorScheme.surface.withValues(alpha: .95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: colorScheme.primaryContainer,
                  elevation: 2,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Text(
                    appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add a bottom border/divider
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(
                      height: 1,
                      color: colorScheme.outline.withValues(alpha: .25),
                    ),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Material(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          splashColor: colorScheme.primary.withValues(
                            alpha: .13,
                          ),
                          highlightColor: colorScheme.primary.withValues(
                            alpha: .08,
                          ),
                          onTap: () {
                            switch (items[index].title) {
                              case 'Importação em Massa':
                                navigationProvider.navigateToBulkImport();
                                break;
                              case 'User Management':
                                navigationProvider.navigateToUserManagement();
                                break;
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                item.icon,
                                const SizedBox(height: 18),
                                Text(
                                  item.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
