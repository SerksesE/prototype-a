import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class GoRouterAuthNotifier extends ChangeNotifier {
  GoRouterAuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }

  bool get loggedIn => FirebaseAuth.instance.currentUser != null;
}

final goRouterAuthNotifierProvider = Provider<GoRouterAuthNotifier>((ref) {
  return GoRouterAuthNotifier();
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(goRouterAuthNotifierProvider);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: '/tracker',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          for (var i = 0; i < AppTab.values.length; i++)
            GoRoute(
              path: AppTab.values[i].path,
              pageBuilder: (context, state) => buildPageWithTransition(
                child: _pageFromTab(AppTab.values[i]),
                state: state,
                context: context,
                targetIndex: i,
              ),
            ),
        ],
      ),
      GoRoute(name: 'login', path: '/login', builder: (_, _) => LoginPage()),
      GoRoute(
        name: 'not-found',
        path: '/not-found',
        builder: (_, _) => const NotFoundPage(),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = authNotifier.loggedIn;
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
