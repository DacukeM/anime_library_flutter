// The main router configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../common/repositories/network/responses/models.dart';
import '../main.dart';
import '../ui/anime/anime_details_screen.dart';
import '../ui/top/top_anime_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home', // Set the initial route
  routes: [
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return MainNavigationScreen(navigationShell: navigationShell);
          },
      branches: [
        // Branch 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomeScreen(),
            ),
          ],
        ),

        // Branch 2: Discover
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: TopAnimeScreen.navigationKey,
              name: TopAnimeScreen.navigationKey,
              builder: (BuildContext context, GoRouterState state) =>
                  const TopAnimeScreen(),
            ),
          ],
        ),

        // Branch 3: My List
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/myliste',
              builder: (BuildContext context, GoRouterState state) =>
                  const MyListScreen(),
            ),
          ],
        ),

        // Branch 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) =>
                  const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AnimeDetailsScreen.routeName,
      name: AnimeDetailsScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return AnimeDetailsScreen(initialAnime: state.extra as Anime?);
      },
    ),
  ],
);

// --- Main Responsive Navigation Widget ---

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({super.key, required this.navigationShell});

  static const double _tabletBreakpoint = 600.0;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Phone Layout
        if (constraints.maxWidth < _tabletBreakpoint) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onTap,
              selectedItemColor: colorScheme.secondary,
              unselectedItemColor:
                  theme.bottomNavigationBarTheme.unselectedItemColor,
              backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_rounded),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library_rounded),
                  label: 'My List',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }

        // Tablet Layout
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                backgroundColor: colorScheme.surface,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: IconThemeData(
                  color: colorScheme.secondary,
                  size: 28,
                ),
                unselectedIconTheme: IconThemeData(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
                selectedLabelTextStyle: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                indicatorColor: colorScheme.secondary.withValues(alpha: 0.15),
                // 🔹 adds a translucent highlight behind the selected item
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.explore_rounded),
                    label: Text('Discover'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.video_library_rounded),
                    label: Text('My List'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_rounded),
                    label: Text('Profile'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}
