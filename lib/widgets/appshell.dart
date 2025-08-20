import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prototype_a/providers/index_provider.dart';
import 'package:prototype_a/utils/app_tab.dart';
import 'package:prototype_a/widgets/responsive_nav_bar.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  void onTap(int index, WidgetRef ref, BuildContext context) {
    final router = GoRouter.of(context);
    ref.read(currentIndexProvider.notifier).setIndex(index);
    router.go(AppTab.values[index].path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final currentIndex = ref.watch(currentIndexProvider);

    // Sync provider with actual location (safe, does not loop)
    ref.listenManual(currentIndexProvider, (_, _) {}); // keep alive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(currentIndexProvider.notifier)
          .syncWithLocation(router.state.uri.toString());
    });

    return Scaffold(
      appBar: kIsWeb
          ? PreferredSize(
              preferredSize: const Size.fromHeight(70),
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
