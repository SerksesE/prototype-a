import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prototype_a/utils/app_tab.dart';
import 'package:prototype_a/widgets/responsive_nav_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    // List of your top-level routes
    final tabs = AppTab.values.map((tab) => tab.path).toList(growable: false);

    // Find active tab based on current route
    int currentIndex = tabs.indexWhere(
      (t) => router.state.uri.toString().startsWith(t),
    );
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      appBar: kIsWeb
          ? PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: ResponsiveNavBar(
                currentIndex: currentIndex,
                onTap: (index) => router.go(tabs[index]),
              ),
            )
          : null,
      body: child,
      bottomNavigationBar: kIsWeb
          ? null
          : ResponsiveNavBar(
              currentIndex: currentIndex,
              onTap: (index) => router.go(tabs[index]),
            ),
    );
  }
}
