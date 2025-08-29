import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prototype_a/app/providers/index_provider.dart';
import 'package:prototype_a/features/user/view/user_page.dart';
import 'package:prototype_a/pages/academy_page.dart';
import 'package:prototype_a/pages/analysis_page.dart';
import 'package:prototype_a/app/view/not_found_page.dart';
import 'package:prototype_a/pages/nutrition_page.dart';
import 'package:prototype_a/pages/tracker_page.dart';
import 'package:prototype_a/pages/training_page.dart';
import 'package:prototype_a/core/utils/app_tab.dart';
import 'package:prototype_a/core/utils/custom_transition.dart';
import 'package:prototype_a/app/view/appshell.dart';
import '../../features/user/view/login_page.dart';

class GoRouterAppNotifier extends ChangeNotifier {
  GoRouterAppNotifier(this.ref) {
    // listen to auth changes
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());

    // listen to index changes
    ref.listen<int>(currentIndexProvider, (_, _) {
      notifyListeners();
    });
  }

  void _setIndex(int index) {
    ref.read(currentIndexProvider.notifier).setIndex(index);
  }

  final Ref ref;

  bool get loggedIn => FirebaseAuth.instance.currentUser != null;
  int get index => ref.read(currentIndexProvider);
  Function get setIndex => _setIndex;
}

final goRouterAppNotifierProvider = Provider<GoRouterAppNotifier>((ref) {
  return GoRouterAppNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final appNotifier = ref.watch(goRouterAppNotifierProvider);

  return GoRouter(
    refreshListenable: appNotifier,
    initialLocation: '/tracker',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes:
            List.generate(AppTab.values.length, (i) {
              return GoRoute(
                path: AppTab.values[i].path,
                pageBuilder: (context, state) => buildPageWithTransition(
                  child: _pageFromTab(AppTab.values[i]),
                  state: state,
                  context: context,
                  targetIndex: i,
                ),
              );
            }).toList()..addAll([
              GoRoute(
                name: 'login',
                path: '/login',
                builder: (_, _) => LoginPage(),
              ),
              GoRoute(
                name: 'not-found',
                path: '/not-found',
                builder: (_, _) => const NotFoundPage(),
              ),
            ]),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = appNotifier.loggedIn;
      final loggingIn = state.uri.toString() == '/login';
      final validPaths = AppTab.values.map((t) => t.path).toList().followedBy([
        '/login',
      ]);

      if (!validPaths.contains(state.uri.toString())) {
        return '/not-found';
      }

      if (!loggedIn && !loggingIn) {
        return '/login';
      } else if (loggedIn && loggingIn) {
        return '/tracker';
      }

      final tabIndex = AppTab.values.indexWhere(
        (t) => t.path == state.uri.toString(),
      );

      if (tabIndex != -1 && tabIndex != appNotifier.index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          appNotifier.setIndex(tabIndex);
        });
      }

      return null;
    },
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});

Widget _pageFromTab(AppTab tab) {
  switch (tab) {
    case AppTab.tracker:
      return const TrackerPage();
    case AppTab.training:
      return const TrainingPage();
    case AppTab.nutrition:
      return const NutritionPage();
    case AppTab.analysis:
      return const AnalysisPage();
    case AppTab.academy:
      return const AcademyPage();
    case AppTab.user:
      return const UserPage();
  }
}
