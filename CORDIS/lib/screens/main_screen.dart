import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/providers/my_auth_provider.dart';

import 'package:cordis/widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<MyAuthProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) authProvider.addListener(_authListener);
    });
  }

  void _authListener() {
    final authProvider = context.read<MyAuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushNamed('/login');
    }
  }

  @override
  void dispose() {
    context.read<MyAuthProvider>().removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<MyAuthProvider, NavigationProvider>(
      builder: (context, authProvider, navigationProvider, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            navigationProvider.pop();
          },
          child: Scaffold(
            appBar: navigationProvider.showAppBar
                ? AppBar(
                    backgroundColor: colorScheme.surfaceContainer,
                    centerTitle: true,
                    title: SvgPicture.asset(
                      'assets/logos/v2_simple_color_white.svg',
                      width: 80,
                    ),
                  )
                : null,
            drawer: navigationProvider.showDrawerIcon ? AppDrawer() : null,
            bottomNavigationBar: navigationProvider.showBottomNavBar
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.surfaceContainerLowest,
                          width: 0.1,
                        ),
                      ),
                    ),
                    child: BottomNavigationBar(
                      currentIndex: navigationProvider.currentRoute.index,
                      selectedLabelStyle: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      showUnselectedLabels: true,
                      type: BottomNavigationBarType.fixed,
                      elevation: 2,
                      onTap: (index) {
                        if (mounted) {
                          navigationProvider.navigateToRoute(
                            NavigationRoute.values[index],
                          );
                        }
                      },
                      items: navigationProvider
                          .getNavigationItems(
                            context,
                            iconSize: 24,
                            color: colorScheme.onSurface,
                            activeColor: theme.colorScheme.primary,
                          )
                          .map(
                            (navItem) => BottomNavigationBarItem(
                              icon: navItem.icon,
                              label: navItem.title,
                              backgroundColor: colorScheme.surface,
                              activeIcon: navItem.activeIcon,
                            ),
                          )
                          .toList(),
                    ),
                  )
                : null,
            body: SafeArea(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  // iOS back gesture (swipe from left edge)
                  if (details.velocity.pixelsPerSecond.dx > 300) {
                    navigationProvider.pop();
                  }
                },
                child: Consumer<NavigationProvider>(
                  builder: (context, navProvider, _) {
                    final currentIndex = navProvider.currentRoute.index;
                    final direction = currentIndex > _previousIndex
                        ? -1.0
                        : 1.0;
                    _previousIndex = currentIndex;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        final isNewScreen =
                            child.key == ValueKey(navProvider.currentRoute);
                        final slideDirection = isNewScreen
                            ? -direction
                            : direction;

                        return SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: Offset(slideDirection, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOutCubic,
                                ),
                              ),
                          child: child,
                        );
                      },
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          children: <Widget>[
                            ...previousChildren,
                            currentChild ?? const SizedBox.shrink(),
                          ],
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(navProvider.currentRoute),
                        child: navProvider.currentScreen,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
