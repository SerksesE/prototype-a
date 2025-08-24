import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_a/features/auth/providers/auth_controller.dart';
import 'package:prototype_a/features/user/data/user_model.dart';
import 'package:prototype_a/features/user/providers/user_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_controller.g.dart';

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  @override
  UserState build() {
    Future.microtask(() => _fetchCurrentUser());
    return UserState.initial();
  }

  // Load or refresh the current user from Firestore
  Future<void> _fetchCurrentUser() async {
    state = state.copyWith(currentUser: const AsyncValue.loading());
    final authState = ref.read(authControllerProvider);

    final userResult = await authState.when(
      data: (firebaseUser) async {
        if (firebaseUser == null) return null;

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!doc.exists) {
          final newUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            firstName: '',
            lastName: '',
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set(newUser.toJson());
          return newUser;
        }

        final admin = await FirebaseFirestore.instance
            .collection('admins')
            .doc(firebaseUser.uid)
            .get()
            .then((d) => d.exists);

        return UserModel.fromJson(doc.data()!).copyWith(isAdmin: admin);
      },
      loading: () async => null,
      error: (_, _) async => null,
    );

    state = state.copyWith(currentUser: AsyncValue.data(userResult));
  }

  // Update current user fields
  Future<void> updateCurrentUser(UserModel updatedUser) async {
    state = state.copyWith(
      currentUser: state.currentUser.whenData(
        (user) => user?.copyWith(
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
          email: updatedUser.email,
        ),
      ),
    );

    if (updatedUser.id != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
    }
  }

  // Select a user for admin view
  void selectUser(UserModel user) {
    state = state.copyWith(selectedUser: user);
  }

  // Clear selected user
  void clearSelectedUser() {
    state = state.copyWith(selectedUser: null);
  }

  // Update selected user (admin editing)
  Future<void> updateSelectedUser(UserModel updatedUser) async {
    if (state.selectedUser == null) return;

    state = state.copyWith(selectedUser: updatedUser);

    if (updatedUser.id != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
    }
  }
}
