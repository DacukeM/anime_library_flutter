import 'package:anime_library_flutter/ui/top_anime_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'di/di.dart';

void main() async {
  await setupDI();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The main router configuration
  static final GoRouter _router = GoRouter(
    initialLocation: '/home', // Set the initial route
    routes: [
      // This ShellRoute builds the responsive UI (with BottomNavBar or NavRail)
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              // This is the widget that contains the responsive Scaffold
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
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Jikan Anime App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        // A dark theme is nice for media apps
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213E),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF16213E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Color(0xFF16213E),
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.grey),
          selectedLabelTextStyle: TextStyle(color: Colors.white),
          unselectedLabelTextStyle: TextStyle(color: Colors.grey),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Main Responsive Navigation Widget ---

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  // A common breakpoint for tablets
  static const double _tabletBreakpoint = 600.0;

  const MainNavigationScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    // goBranch navigates to the branch at the given index
    // This preserves the navigation stack of each tab
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine if we're on a phone or tablet
    return LayoutBuilder(
      builder: (context, constraints) {
        // Phone Layout
        if (constraints.maxWidth < _tabletBreakpoint) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onTap,
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
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                labelType: NavigationRailLabelType.all,
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
              // The main content area
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}

// --- Placeholder Screens ---

// A simple placeholder screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Screen')),
    );
  }
}

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My List')),
      body: const Center(child: Text('My List Screen')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}
