import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_a/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';

part 'user_provider.g.dart';

@riverpod
class UserController extends _$UserController {
  UserModel? get user => state.whenOrNull(data: (user) => user);

  @override
  Future<UserModel?> build() async {
    return _fetchCurrentUser();
  }

  Future<UserModel?> _fetchCurrentUser() async {
    final authUser = ref.watch(authControllerProvider);
    if (authUser == null) {
      state = const AsyncData(null);
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .get();

    if (!doc.exists) {
      // first login → create Firestore doc
      // possible change this to signup by admin
      final newUser = UserModel(
        id: authUser.uid,
        email: authUser.email ?? '',
        firstName: '',
        lastName: '',
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .set(newUser.toJson());

      return newUser;
    }

    final user = UserModel.fromJson({...doc.data()!, 'id': doc.id});
    state = AsyncData(user);
    return user;
  }

  Future<void> refresh() async {
    await _fetchCurrentUser();
  }

  Future<void> clear() async {
    state = const AsyncData(null);
  }

  Future<void> updateName(String first, String last) async {
    final current = state.whenOrNull(data: (user) => user);
    if (current == null) return;

    final updated = current.copyWith(firstName: first, lastName: last);
    state = AsyncData(updated);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(updated.id)
        .update(updated.toJson());
  }
}
