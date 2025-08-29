import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prototype_a/app/providers/index_provider.dart';
import 'package:prototype_a/core/utils/app_tab.dart';
import 'package:prototype_a/app/view/responsive_nav_bar.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  void onTap(int index, WidgetRef ref, BuildContext context) {
    final router = GoRouter.of(context);
    router.go(AppTab.values[index].path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    return Scaffold(
      appBar: kIsWeb
          ? PreferredSize(
              preferredSize: const Size.fromHeight(98), // 70 + 28
              child: ResponsiveNavBar(
                currentIndex: currentIndex,
                onTap: (index) => onTap(index, ref, context),
              ),
            )
          : null,
      body: child,
      bottomNavigationBar: kIsWeb
          ? null
          : ResponsiveNavBar(
              currentIndex: currentIndex,
              onTap: (index) => onTap(index, ref, context),
            ),
    );
  }
}
