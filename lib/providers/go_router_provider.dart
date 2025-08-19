import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
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
    initialLocation: '/',
    routes: [
      GoRoute(name: 'home', path: '/', builder: (_, _) => const HomePage()),
      GoRoute(name: 'login', path: '/login', builder: (_, _) => LoginPage()),
    ],
    redirect: (context, state) {
      final loggedIn = authNotifier.loggedIn;
      final loggingIn = state.uri.toString() == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login';
      } else if (loggedIn && loggingIn) {
        return '/';
      }

      return null; // no redirect
    },
  );
});
