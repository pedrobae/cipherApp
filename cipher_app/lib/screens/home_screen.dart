import 'package:cipher_app/utils/design_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/providers/navigation_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-load authentication state with post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
      if (!isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (Route<dynamic> route) => false, // Clear all routes
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Modern background gradient
      body: Container(
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
        child: Consumer2<AuthProvider, NavigationProvider>(
          builder: (context, authProvider, navigationProvider, child) {
            if (authProvider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando...'),
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
                      'Erro: ${authProvider.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => authProvider.signInAnonymously(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }
            if (!authProvider.isAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/login');
              });
            }

            // User is authenticated - show navigation options
            final Color iconColor = colorScheme.onPrimaryContainer;
            final items = navigationProvider.getNavigationItems(
              iconColor: iconColor,
              iconSize: 80,
            );

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
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
                  actions: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.isAuthenticated) {
                          return IconButton(
                            icon: const Icon(Icons.logout),
                            tooltip: 'Sair',
                            color: colorScheme.onPrimaryContainer,
                            onPressed: () => authProvider.signOut(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  // Add a bottom border/divider
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(
                      height: 1,
                      color: colorScheme.outline.withValues(alpha: .25),
                    ),
                  ),
                ),
                // Placeholder for company logo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/logos/v1_simple_color_black.svg',
                        width: 200,
                      ),
                    ),
                  ),
                ),
                // Navigation Grid with ripple only
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
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
                            switch (item.route) {
                              case NavigationProvider.libraryRoute:
                                navigationProvider.navigateToLibrary();
                                break;
                              case NavigationProvider.playlistsRoute:
                                navigationProvider.navigateToPlaylists();
                                break;
                              case NavigationProvider.settingsRoute:
                                navigationProvider.navigateToSettings();
                                break;
                              case NavigationProvider.infoRoute:
                                navigationProvider.navigateToInfo();
                                break;
                            }
                            Navigator.pushNamed(context, '/main');
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
                                    color: iconColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: items.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: 0.95,
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
