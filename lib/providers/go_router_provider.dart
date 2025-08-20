import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prototype_a/pages/academy_page.dart';
import 'package:prototype_a/pages/analysis_page.dart';
import 'package:prototype_a/pages/tracker_page.dart';
import 'package:prototype_a/pages/training_page.dart';
import 'package:prototype_a/pages/user_page.dart';
import 'package:prototype_a/widgets/appshell.dart';
import '../pages/login_page.dart';

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
          return AppShell(child: child); // your nav bar wrapper
        },
        routes: [
          GoRoute(
            name: 'tracker',
            path: '/tracker',
            builder: (_, _) => const TrackerPage(),
          ),
          GoRoute(
            name: 'training',
            path: '/training',
            builder: (_, _) => const TrainingPage(),
          ),
          GoRoute(
            name: 'analysis',
            path: '/analysis',
            builder: (_, _) => const AnalysisPage(),
          ),
          GoRoute(
            name: 'academy',
            path: '/academy',
            builder: (_, _) => const AcademyPage(),
          ),
          GoRoute(
            name: 'user',
            path: '/user',
            builder: (_, _) => const UserPage(),
          ),
          // GoRoute(name: 'login', path: '/login', builder: (_, _) => LoginPage()),
        ],
      ),
      GoRoute(name: 'login', path: '/login', builder: (_, _) => LoginPage()),
    ],
    redirect: (context, state) {
      final loggedIn = authNotifier.loggedIn;
      final loggingIn = state.uri.toString() == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login';
      } else if (loggedIn && loggingIn) {
        return '/tracker';
      }

      return null; // no redirect
    },
  );
});
