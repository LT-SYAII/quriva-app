import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/features/audio/presentation/mini_player.dart';
import 'package:quriva/shared/widgets/glass.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = switch (location) {
      '/bookmarks' => 1,
      '/settings' => 2,
      _ => 0,
    };

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayerBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: GlassPanel(
                radius: 26,
                padding: EdgeInsets.zero,
                blur: 10,
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    const locations = ['/', '/bookmarks', '/settings'];
                    context.go(locations[index]);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: 'Read',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bookmark_border_rounded),
                      selectedIcon: Icon(Icons.bookmark),
                      label: 'Library',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
