import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prototype_a/app/providers/index_provider.dart';
import 'package:prototype_a/core/utils/app_tab.dart';
import 'package:prototype_a/features/admin/providers/admin_controller.dart';
import 'package:prototype_a/features/user/data/user_model.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<User?> build() {
    return AsyncData(FirebaseAuth.instance.currentUser);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Set the right page before updating the state, fixed some highlighting issues
      ref
          .read(currentIndexProvider.notifier)
          .syncWithLocation(AppTab.tracker.path);

      state = AsyncData(credentials.user);

      // Refresh userController
      ref.read(userControllerProvider.notifier).build();
    } on FirebaseAuthException catch (e) {
      state = AsyncError(_firebaseErrorMessage(e), StackTrace.current);
    } catch (_) {
      state = AsyncError('Unexpected error', StackTrace.current);
    }
  }

  Future<void> registerUserByEmail(String email) async {
    state = const AsyncLoading();

    // Prevent login after creating a new user
    FirebaseApp app = await Firebase.initializeApp(
      name: 'Register',
      options: Firebase.app().options,
    );
    final authCreate = FirebaseAuth.instanceFor(app: app);

    try {
      final credential = await authCreate.createUserWithEmailAndPassword(
        email: email,
        password: 'Welkom123!',
      );

      // check if usermodel should be full of nullable fields (email)
      final newUser = UserModel(
        id: credential.user!.uid,
        email: credential.user!.email,
        firstName: '',
        lastName: '',
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(credential.user!.uid)
          .set(newUser.toJson());

      state = AsyncData(credential.user);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e, st);
    }
    await app.delete();
  }

  Future<void> signOutAndClear() async {
    // Reset user and admin providers
    ref.invalidate(userControllerProvider);
    ref.invalidate(adminControllerProvider);

    state = const AsyncData(null);

    await FirebaseAuth.instance.signOut();
  }

  Future<void> clearError() async {
    state = const AsyncData(null);
  }
}

String _firebaseErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No account found for that email.';
    case 'wrong-password':
      return 'Incorrect password.';
    default:
      return 'Login failed. Please try again.';
  }
}
