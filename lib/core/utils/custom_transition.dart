import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prototype_a/app/providers/index_provider.dart';

CustomTransitionPage<dynamic> buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
  required BuildContext context,
  required int targetIndex,
}) {
  final container = ProviderScope.containerOf(context);
  final notifier = container.read(currentIndexProvider.notifier);

  final isBackward = targetIndex < notifier.previousIndex;

  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = animation.drive(
        Tween<Offset>(
          begin: isBackward ? const Offset(-1, 0) : const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut)),
      );

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
